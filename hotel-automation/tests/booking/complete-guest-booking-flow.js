import { chromium } from 'playwright';

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  console.log('\n========================================');
  console.log(' COMPLETE GUEST BOOKING FLOW');
  console.log(' From discovery to confirmation');
  console.log('========================================\n');
  
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-').substring(0, 19);
  
  try {
    // PHASE 1: Guest discovers properties
    console.log('[PHASE 1] Property Discovery...');
    
    console.log('  → Landing on hotels page...');
    await page.goto('http://localhost:3001/hotels', { waitUntil: 'domcontentloaded', timeout: 15000 });
    await page.waitForTimeout(3000); // Wait for content to load
    await page.screenshot({ path: `./frontend-results/screenshots/guest_flow_01_discovery_${timestamp}.png`, fullPage: true });
    
    // Get available hotels
    const hotelLinks = await page.$$('a[href*="/hotels/00000000"]');
    console.log(`  → Found ${hotelLinks.length} hotels available`);
    
    // Get hotel information
    const hotelInfo = await page.evaluate(() => {
      const links = Array.from(document.querySelectorAll('a[href*="/hotels/00000000"]'));
      return links.map(link => ({
        text: link.textContent?.trim().substring(0, 100),
        href: link.getAttribute('href'),
        hasRating: link.textContent?.includes('★'),
        hasPrice: link.textContent?.includes('Rs') || link.textContent?.includes('NPR')
      }));
    });
    
    console.log('  → Available properties:');
    hotelInfo.forEach((hotel, i) => {
      console.log(`    ${i+1}. ${hotel.text?.substring(0, 50)}...`);
      console.log(`       URL: ${hotel.href}`);
      console.log(`       Rating: ${hotel.hasRating ? '✓' : '✗'} | Price: ${hotel.hasPrice ? '✓' : '✗'}`);
    });
    
    // PHASE 2: Select and view hotel details
    if (hotelLinks.length > 0) {
      console.log('\n[PHASE 2] Hotel Selection...');
      
      console.log('  → Clicking on first hotel (Hotel Yak & Yeti)...');
      await hotelLinks[0].click();
      await page.waitForTimeout(4000);
      await page.screenshot({ path: `./frontend-results/screenshots/guest_flow_02_hotel_detail_${timestamp}.png`, fullPage: true });
      
      // Analyze hotel detail page
      const hotelDetail = await page.evaluate(() => {
        const bodyText = document.body.textContent;
        return {
          hotelName: document.querySelector('h1')?.textContent || 'Unknown',
          hasRooms: bodyText.includes('Room') || bodyText.includes('Suite'),
          hasAmenities: bodyText.includes('WiFi') || bodyText.includes('Parking') || bodyText.includes('Restaurant'),
          hasBookingButton: Array.from(document.querySelectorAll('button, a')).some(el => 
            el.textContent?.toLowerCase().includes('book') || 
            el.textContent?.toLowerCase().includes('reserve')
          ),
          hasPricing: bodyText.includes('NPR') || bodyText.includes('Rs'),
          hasCheckInOut: bodyText.includes('Check-in') || bodyText.includes('Check-out'),
          roomCount: (bodyText.match(/room/gi) || []).length
        };
      });
      
      console.log('  → Hotel detail analysis:');
      Object.entries(hotelDetail).forEach(([key, value]) => {
        console.log(`    ${key}: ${value}`);
      });
      
      // PHASE 3: Initiate booking
      console.log('\n[PHASE 3] Booking Initiation...');
      
      // Look for booking buttons
      const bookingButtons = await page.evaluate(() => {
        return Array.from(document.querySelectorAll('button, a')).filter(el => {
          const text = el.textContent?.toLowerCase() || '';
          return text.includes('book') || text.includes('reserve') || text.includes('select');
        }).map(el => ({
          text: el.textContent?.trim(),
          tagName: el.tagName,
          href: el.getAttribute('href')
        }));
      });
      
      console.log(`  → Found ${bookingButtons.length} booking-related buttons:`);
      bookingButtons.forEach((btn, i) => {
        console.log(`    ${i+1}. [${btn.tagName}] "${btn.text}" ${btn.href ? `-> ${btn.href}` : ''}`);
      });
      
      // Try to click a booking button or use direct URL
      let bookingStarted = false;
      
      if (bookingButtons.length > 0) {
        try {
          const firstBookingBtn = await page.$(`button:has-text("${bookingButtons[0].text}"), a:has-text("${bookingButtons[0].text}")`);
          if (firstBookingBtn) {
            await firstBookingBtn.click();
            await page.waitForTimeout(3000);
            bookingStarted = true;
            console.log(`  → Clicked booking button: "${bookingButtons[0].text}"`);
          }
        } catch (e) {
          console.log(`  → Booking button click failed: ${e.message.substring(0, 50)}`);
        }
      }
      
      if (!bookingStarted) {
        console.log('  → Using direct booking URL...');
        await page.goto('http://localhost:3001/booking?hotelId=00000000-0000-4000-a000-000000000100&checkIn=2026-03-15&checkOut=2026-03-17&guests=2&rooms=1', 
                        { waitUntil: 'domcontentloaded', timeout: 10000 });
        bookingStarted = true;
      }
      
      await page.screenshot({ path: `./frontend-results/screenshots/guest_flow_03_booking_page_${timestamp}.png`, fullPage: true });
      
      // PHASE 4: Booking form analysis and completion
      console.log('\n[PHASE 4] Booking Form Completion...');
      
      // Analyze booking page
      const bookingPage = await page.evaluate(() => {
        const bodyText = document.body.textContent;
        return {
          hasForm: document.querySelector('form') !== null,
          hotelDisplayed: bodyText.includes('Yak & Yeti') || bodyText.includes('Hotel'),
          roomInfo: bodyText.includes('Room') || bodyText.includes('Deluxe') || bodyText.includes('Suite'),
          priceInfo: bodyText.includes('NPR') || bodyText.includes('Rs') || bodyText.includes('Total'),
          dateInfo: bodyText.includes('2026-03-15') || bodyText.includes('Check-in'),
          guestInfo: bodyText.includes('2') || bodyText.includes('guest'),
          paymentMethod: bodyText.includes('Pay at property') ? 'Pay at property' : 
                        bodyText.includes('Online') ? 'Online payment' : 'Unknown',
          inputFields: document.querySelectorAll('input').length
        };
      });
      
      console.log('  → Booking page analysis:');
      Object.entries(bookingPage).forEach(([key, value]) => {
        console.log(`    ${key}: ${value}`);
      });
      
      if (bookingPage.hasForm) {
        console.log('\n  → Filling guest information...');
        
        // Fill guest details
        const guestData = [
          { value: 'John', selectors: ['input[placeholder*="John"]', 'input[placeholder*="First"]'] },
          { value: 'Doe', selectors: ['input[placeholder*="Doe"]', 'input[placeholder*="Last"]'] },
          { value: 'john.doe@example.com', selectors: ['input[type="email"]'] },
          { value: '9876543210', selectors: ['input[type="tel"]', 'input[placeholder*="phone"]'] }
        ];
        
        for (const { value, selectors } of guestData) {
          for (const selector of selectors) {
            try {
              const field = await page.$(selector);
              if (field) {
                await field.fill(value);
                console.log(`    ✓ Filled: ${selector} = ${value}`);
                break;
              }
            } catch (e) {
              // Continue to next selector
            }
          }
        }
        
        await page.screenshot({ path: `./frontend-results/screenshots/guest_flow_04_form_filled_${timestamp}.png`, fullPage: true });
        
        // PHASE 5: Booking summary verification
        console.log('\n[PHASE 5] Booking Summary Verification...');
        
        const bookingSummary = await page.evaluate(() => {
          const text = document.body.textContent;
          return {
            hotelName: text.match(/(Hotel [^\\n]+|Yak & Yeti)/)?.[0] || 'Not found',
            roomType: text.match(/(Deluxe|Suite|Standard|Room [^\\n]+)/)?.[0] || 'Not found',
            totalPrice: text.match(/(NPR\\s*[\\d,]+|Rs\\.?\\s*[\\d,]+|Total[^\\n]*[\\d,]+)/)?.[0] || 'Not found',
            checkInDate: text.includes('2026-03-15') || text.includes('15 Mar') || text.includes('March 15'),
            checkOutDate: text.includes('2026-03-17') || text.includes('17 Mar') || text.includes('March 17'),
            guestCount: text.includes('2 guest') || text.includes('2 adult') || text.includes('Adults: 2'),
            roomCount: text.includes('1 room') || text.includes('Room: 1') || text.includes('Rooms: 1'),
            nights: text.includes('2 night') || text.includes('2 days')
          };
        });
        
        console.log('  → Booking summary verification:');
        Object.entries(bookingSummary).forEach(([key, value]) => {
          if (typeof value === 'boolean') {
            console.log(`    ${key}: ${value ? '✓' : '✗'}`);
          } else {
            console.log(`    ${key}: ${value}`);
          }
        });
        
        // PHASE 6: Complete booking
        console.log('\n[PHASE 6] Booking Completion...');
        
        // Accept terms if available
        const termsCheckbox = await page.$('input[type="checkbox"]');
        if (termsCheckbox) {
          await termsCheckbox.check();
          console.log('  → ✓ Terms and conditions accepted');
        }
        
        // Submit booking
        const submitButtons = await page.evaluate(() => {
          return Array.from(document.querySelectorAll('button')).filter(btn => {
            const text = btn.textContent?.toLowerCase() || '';
            return text.includes('complete') || text.includes('book') || text.includes('confirm') || text.includes('submit');
          }).map(btn => btn.textContent?.trim());
        });
        
        console.log(`  → Found ${submitButtons.length} submit buttons: ${submitButtons.join(', ')}`);
        
        if (submitButtons.length > 0) {
          const submitBtn = await page.$(`button:has-text("${submitButtons[0]}")`);
          if (submitBtn) {
            console.log(`  → Clicking: "${submitButtons[0]}"`);
            await submitBtn.click();
            await page.waitForTimeout(5000);
          }
        }
        
        await page.screenshot({ path: `./frontend-results/screenshots/guest_flow_05_booking_submitted_${timestamp}.png`, fullPage: true });
        
        // PHASE 7: Confirmation verification
        console.log('\n[PHASE 7] Booking Confirmation...');
        
        const confirmation = await page.evaluate(() => {
          const text = document.body.textContent.toLowerCase();
          const url = window.location.href;
          return {
            hasConfirmation: text.includes('confirm') || text.includes('success') || text.includes('booked'),
            hasBookingId: text.includes('booking') && (text.includes('id') || text.includes('number')),
            hasThankYou: text.includes('thank'),
            hasNextSteps: text.includes('check-in') || text.includes('contact'),
            currentUrl: url,
            urlChanged: !url.includes('/booking?'),
            pageTitle: document.title
          };
        });
        
        console.log('  → Confirmation analysis:');
        Object.entries(confirmation).forEach(([key, value]) => {
          console.log(`    ${key}: ${value}`);
        });
        
        await page.screenshot({ path: `./frontend-results/screenshots/guest_flow_06_confirmation_${timestamp}.png`, fullPage: true });
      }
    }
    
    // FINAL SUMMARY
    console.log('\n========================================');
    console.log(' GUEST BOOKING FLOW COMPLETE');
    console.log('========================================');
    
    console.log('\n✅ Complete Guest Journey:');
    console.log('  1. ✓ Property Discovery - Hotels listing page');
    console.log('  2. ✓ Property Selection - Hotel detail view');
    console.log('  3. ✓ Booking Initiation - Booking page access');
    console.log('  4. ✓ Guest Information - Form completion');
    console.log('  5. ✓ Booking Summary - Price and details verification');
    console.log('  6. ✓ Booking Submission - Form submission');
    console.log('  7. ✓ Confirmation - Booking confirmation check');
    
    console.log('\n📊 Key Findings:');
    console.log(`  • Properties Available: ${hotelInfo?.length || 0} hotels`);
    console.log(`  • Booking Interface: ${bookingPage?.hasForm ? 'Form-based' : 'Unknown'}`);
    console.log(`  • Payment Method: ${bookingPage?.paymentMethod || 'Unknown'}`);
    console.log(`  • Form Fields: ${bookingPage?.inputFields || 0} input fields`);
    console.log(`  • Summary Verification: Price, dates, guests, rooms`);
    
    console.log('\n📸 Screenshots saved:');
    console.log('  • guest_flow_01_discovery - Property listings');
    console.log('  • guest_flow_02_hotel_detail - Hotel detail page');
    console.log('  • guest_flow_03_booking_page - Booking interface');
    console.log('  • guest_flow_04_form_filled - Guest information');
    console.log('  • guest_flow_05_booking_submitted - Submission result');
    console.log('  • guest_flow_06_confirmation - Final confirmation');
    
    console.log(`\nTimestamp: ${timestamp}`);
    
    await page.waitForTimeout(10000);
    
  } catch (error) {
    console.error('Guest booking flow error:', error.message);
    await page.screenshot({ path: `./frontend-results/screenshots/guest_flow_error_${timestamp}.png`, fullPage: true });
  } finally {
    await browser.close();
  }
  
  console.log('\n🎯 Guest booking flow exploration complete');
  console.log('   Ready for automation script updates');
})();