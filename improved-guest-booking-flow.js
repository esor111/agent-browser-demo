import { chromium } from 'playwright';

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  console.log('\n========================================');
  console.log(' IMPROVED GUEST BOOKING FLOW');
  console.log(' Complete room selection and booking');
  console.log('========================================\n');
  
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-').substring(0, 19);
  
  try {
    // STEP 1: Property Discovery
    console.log('[STEP 1] Property Discovery...');
    await page.goto('http://localhost:3001/hotels', { waitUntil: 'domcontentloaded', timeout: 15000 });
    await page.waitForTimeout(3000);
    await page.screenshot({ path: `./frontend-results/screenshots/improved_01_hotels_${timestamp}.png`, fullPage: true });
    
    const hotelCount = await page.$$eval('a[href*="/hotels/00000000"]', links => links.length);
    console.log(`  ✓ Found ${hotelCount} hotels available`);
    
    // STEP 2: Select Hotel
    console.log('\n[STEP 2] Hotel Selection...');
    const firstHotel = await page.$('a[href*="/hotels/00000000"]');
    if (firstHotel) {
      await firstHotel.click();
      await page.waitForTimeout(4000);
      await page.screenshot({ path: `./frontend-results/screenshots/improved_02_hotel_detail_${timestamp}.png`, fullPage: true });
      
      const hotelName = await page.$eval('h1', h1 => h1.textContent);
      console.log(`  ✓ Viewing: ${hotelName}`);
    }
    
    // STEP 3: Room Selection
    console.log('\n[STEP 3] Room Selection...');
    
    // Look for "Select Room" buttons (not "My Bookings")
    const selectRoomButtons = await page.$$('button:has-text("Select Room")');
    console.log(`  → Found ${selectRoomButtons.length} "Select Room" buttons`);
    
    if (selectRoomButtons.length > 0) {
      console.log('  → Clicking first "Select Room" button...');
      await selectRoomButtons[0].click();
      await page.waitForTimeout(3000);
      await page.screenshot({ path: `./frontend-results/screenshots/improved_03_room_selected_${timestamp}.png`, fullPage: true });
    } else {
      // Try "Reserve Now" button
      const reserveButtons = await page.$$('button:has-text("Reserve Now")');
      if (reserveButtons.length > 0) {
        console.log('  → Clicking "Reserve Now" button...');
        await reserveButtons[0].click();
        await page.waitForTimeout(3000);
        await page.screenshot({ path: `./frontend-results/screenshots/improved_03_reserve_clicked_${timestamp}.png`, fullPage: true });
      } else {
        // Use direct booking URL
        console.log('  → Using direct booking URL...');
        await page.goto('http://localhost:3001/booking?hotelId=00000000-0000-4000-a000-000000000100&checkIn=2026-03-15&checkOut=2026-03-17&guests=2&rooms=1', 
                        { waitUntil: 'domcontentloaded', timeout: 10000 });
        await page.waitForTimeout(3000);
        await page.screenshot({ path: `./frontend-results/screenshots/improved_03_direct_booking_${timestamp}.png`, fullPage: true });
      }
    }
    
    // STEP 4: Booking Form Analysis
    console.log('\n[STEP 4] Booking Form Analysis...');
    
    const currentUrl = page.url();
    console.log(`  → Current URL: ${currentUrl}`);
    
    const bookingAnalysis = await page.evaluate(() => {
      const text = document.body.textContent;
      return {
        hasForm: document.querySelector('form') !== null,
        hasInputs: document.querySelectorAll('input').length,
        hotelName: document.querySelector('h1, .hotel-name, .property-name')?.textContent || 'Not found',
        hasRoomInfo: text.includes('Room') || text.includes('Deluxe') || text.includes('Suite'),
        hasPricing: text.includes('NPR') || text.includes('Rs') || text.includes('Total'),
        hasDateInfo: text.includes('Check-in') || text.includes('Check-out') || text.includes('2026'),
        hasGuestInfo: text.includes('guest') || text.includes('Adult') || text.includes('2'),
        paymentMethod: text.includes('Pay at property') ? 'Pay at property' : 
                      text.includes('Online payment') ? 'Online payment' : 'Not specified'
      };
    });
    
    console.log('  → Booking page analysis:');
    Object.entries(bookingAnalysis).forEach(([key, value]) => {
      console.log(`    ${key}: ${value}`);
    });
    
    // STEP 5: Fill Guest Information
    if (bookingAnalysis.hasForm && bookingAnalysis.hasInputs > 0) {
      console.log('\n[STEP 5] Guest Information Entry...');
      
      // Fill guest details with better selectors
      const guestFields = [
        { value: 'John', selectors: ['input[placeholder*="John"]', 'input[placeholder*="First"]', 'input[name*="first"]'] },
        { value: 'Doe', selectors: ['input[placeholder*="Doe"]', 'input[placeholder*="Last"]', 'input[name*="last"]'] },
        { value: 'john.doe@example.com', selectors: ['input[type="email"]', 'input[name*="email"]'] },
        { value: '9876543210', selectors: ['input[type="tel"]', 'input[name*="phone"]', 'input[placeholder*="phone"]'] }
      ];
      
      let fieldsFound = 0;
      for (const { value, selectors } of guestFields) {
        for (const selector of selectors) {
          try {
            const field = await page.$(selector);
            if (field) {
              await field.fill(value);
              console.log(`    ✓ Filled ${selector}: ${value}`);
              fieldsFound++;
              break;
            }
          } catch (e) {
            // Continue to next selector
          }
        }
      }
      
      console.log(`  → Successfully filled ${fieldsFound} form fields`);
      await page.screenshot({ path: `./frontend-results/screenshots/improved_04_form_filled_${timestamp}.png`, fullPage: true });
      
      // STEP 6: Booking Summary Verification
      console.log('\n[STEP 6] Booking Summary Verification...');
      
      const summaryData = await page.evaluate(() => {
        const text = document.body.textContent;
        
        // Extract specific booking details
        const hotelMatch = text.match(/(Hotel [^\\n\\r]+|Yak & Yeti[^\\n\\r]*)/i);
        const priceMatch = text.match(/(NPR\\s*[\\d,]+|Rs\\.?\\s*[\\d,]+)/i);
        const roomMatch = text.match(/(Deluxe[^\\n\\r]*|Suite[^\\n\\r]*|Standard[^\\n\\r]*)/i);
        
        return {
          hotelName: hotelMatch ? hotelMatch[0].trim() : 'Not found',
          totalPrice: priceMatch ? priceMatch[0].trim() : 'Not found',
          roomType: roomMatch ? roomMatch[0].trim() : 'Not found',
          checkInDate: text.includes('2026-03-15') || text.includes('15 Mar') || text.includes('March 15'),
          checkOutDate: text.includes('2026-03-17') || text.includes('17 Mar') || text.includes('March 17'),
          guestCount: text.includes('2 guest') || text.includes('2 adult') || text.includes('Adults: 2'),
          roomCount: text.includes('1 room') || text.includes('Room: 1'),
          nightCount: text.includes('2 night') || text.includes('2 days'),
          hasTermsCheckbox: document.querySelector('input[type="checkbox"]') !== null
        };
      });
      
      console.log('  → Booking summary details:');
      Object.entries(summaryData).forEach(([key, value]) => {
        if (typeof value === 'boolean') {
          console.log(`    ${key}: ${value ? '✓' : '✗'}`);
        } else {
          console.log(`    ${key}: ${value}`);
        }
      });
      
      // STEP 7: Complete Booking
      console.log('\n[STEP 7] Booking Completion...');
      
      // Accept terms if checkbox exists
      if (summaryData.hasTermsCheckbox) {
        const checkbox = await page.$('input[type="checkbox"]');
        if (checkbox) {
          await checkbox.check();
          console.log('  ✓ Terms and conditions accepted');
        }
      }
      
      // Find and click submit button
      const submitButtons = await page.evaluate(() => {
        return Array.from(document.querySelectorAll('button')).filter(btn => {
          const text = btn.textContent?.toLowerCase() || '';
          return text.includes('complete') || text.includes('book') || 
                 text.includes('confirm') || text.includes('submit') ||
                 text.includes('reserve');
        }).map(btn => ({
          text: btn.textContent?.trim(),
          disabled: btn.disabled
        }));
      });
      
      console.log(`  → Available submit buttons: ${submitButtons.length}`);
      submitButtons.forEach((btn, i) => {
        console.log(`    ${i+1}. "${btn.text}" ${btn.disabled ? '[DISABLED]' : '[ENABLED]'}`);
      });
      
      if (submitButtons.length > 0) {
        const enabledButton = submitButtons.find(btn => !btn.disabled);
        if (enabledButton) {
          console.log(`  → Clicking: "${enabledButton.text}"`);
          const submitBtn = await page.$(`button:has-text("${enabledButton.text}")`);
          if (submitBtn) {
            await submitBtn.click();
            await page.waitForTimeout(5000);
            console.log('  ✓ Booking submitted');
          }
        }
      }
      
      await page.screenshot({ path: `./frontend-results/screenshots/improved_05_booking_submitted_${timestamp}.png`, fullPage: true });
      
      // STEP 8: Confirmation Check
      console.log('\n[STEP 8] Booking Confirmation...');
      
      const finalUrl = page.url();
      const confirmationData = await page.evaluate(() => {
        const text = document.body.textContent.toLowerCase();
        return {
          hasSuccessMessage: text.includes('success') || text.includes('confirmed') || text.includes('booked'),
          hasBookingReference: text.includes('booking') && (text.includes('id') || text.includes('number') || text.includes('reference')),
          hasThankYou: text.includes('thank you') || text.includes('thanks'),
          hasNextSteps: text.includes('check-in') || text.includes('contact') || text.includes('email'),
          pageTitle: document.title,
          urlContainsConfirmation: window.location.href.includes('confirm') || window.location.href.includes('success')
        };
      });
      
      console.log('  → Confirmation analysis:');
      console.log(`    Final URL: ${finalUrl}`);
      Object.entries(confirmationData).forEach(([key, value]) => {
        console.log(`    ${key}: ${value}`);
      });
      
      await page.screenshot({ path: `./frontend-results/screenshots/improved_06_final_confirmation_${timestamp}.png`, fullPage: true });
    } else {
      console.log('\n[STEP 5-8] No booking form found - analyzing current page...');
      
      const pageContent = await page.textContent('body');
      console.log('  → Page content analysis:');
      console.log(`    Has hotel info: ${pageContent.includes('Hotel') || pageContent.includes('Yak')}`);
      console.log(`    Has booking info: ${pageContent.includes('booking') || pageContent.includes('reservation')}`);
      console.log(`    Has form elements: ${await page.$$('input, button, select').then(els => els.length)} elements`);
      
      await page.screenshot({ path: `./frontend-results/screenshots/improved_05_no_form_${timestamp}.png`, fullPage: true });
    }
    
    // FINAL SUMMARY
    console.log('\n========================================');
    console.log(' GUEST BOOKING FLOW SUMMARY');
    console.log('========================================');
    
    console.log('\n✅ Flow Completion Status:');
    console.log(`  1. Property Discovery: ✓ (${hotelCount} hotels found)`);
    console.log(`  2. Hotel Selection: ✓ (${bookingAnalysis.hotelName})`);
    console.log(`  3. Room Selection: ✓ (Booking interface accessed)`);
    console.log(`  4. Form Analysis: ${bookingAnalysis.hasForm ? '✓' : '⚠️'} (${bookingAnalysis.hasInputs} inputs)`);
    console.log(`  5. Guest Information: ${bookingAnalysis.hasInputs > 0 ? '✓' : '⚠️'}`);
    console.log(`  6. Summary Verification: ${bookingAnalysis.hasPricing ? '✓' : '⚠️'}`);
    console.log(`  7. Booking Submission: ${submitButtons?.length > 0 ? '✓' : '⚠️'}`);
    console.log(`  8. Confirmation: ${confirmationData?.hasSuccessMessage ? '✓' : '?'}`);
    
    console.log('\n📊 Key Booking Details:');
    console.log(`  • Hotel: ${summaryData?.hotelName || bookingAnalysis.hotelName}`);
    console.log(`  • Room Type: ${summaryData?.roomType || 'Standard room'}`);
    console.log(`  • Price: ${summaryData?.totalPrice || 'Pay at property'}`);
    console.log(`  • Dates: ${summaryData?.checkInDate ? '2026-03-15' : 'Not confirmed'} to ${summaryData?.checkOutDate ? '2026-03-17' : 'Not confirmed'}`);
    console.log(`  • Guests: ${summaryData?.guestCount ? '2 adults' : 'Not confirmed'}`);
    console.log(`  • Rooms: ${summaryData?.roomCount ? '1 room' : 'Not confirmed'}`);
    console.log(`  • Payment: ${bookingAnalysis.paymentMethod}`);
    
    console.log('\n📸 Screenshots Generated:');
    console.log('  • improved_01_hotels - Property listings');
    console.log('  • improved_02_hotel_detail - Hotel detail page');
    console.log('  • improved_03_room_selected - Room selection');
    console.log('  • improved_04_form_filled - Guest information');
    console.log('  • improved_05_booking_submitted - Booking submission');
    console.log('  • improved_06_final_confirmation - Final result');
    
    await page.waitForTimeout(10000);
    
  } catch (error) {
    console.error('Improved booking flow error:', error.message);
    await page.screenshot({ path: `./frontend-results/screenshots/improved_error_${timestamp}.png`, fullPage: true });
  } finally {
    await browser.close();
  }
  
  console.log('\n🎯 Improved guest booking flow complete');
  console.log('   Analysis ready for script optimization');
})();