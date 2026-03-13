import { chromium } from 'playwright';

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  console.log('\n========================================');
  console.log(' GUEST BOOKING FLOW EXPLORATION');
  console.log(' From property listing to booking confirmation');
  console.log('========================================\n');
  
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-').substring(0, 19);
  
  try {
    // PHASE 1: Guest discovers properties
    console.log('[PHASE 1] Guest Property Discovery...');
    
    console.log('  [1.1] Landing on hotel listings page...');
    await page.goto('http://localhost:3001/hotels', { waitUntil: 'domcontentloaded', timeout: 15000 });
    await page.screenshot({ path: `./frontend-results/screenshots/guest_01_hotel_listings_${timestamp}.png`, fullPage: true });
    
    // Analyze available properties
    const properties = await page.evaluate(() => {
      const propertyCards = Array.from(document.querySelectorAll('[data-testid*="hotel"], .hotel-card, .property-card, a[href*="/hotels/"]'));
      return propertyCards.slice(0, 5).map((card, index) => ({
        index,
        text: card.textContent?.substring(0, 100),
        href: card.getAttribute('href'),
        hasImage: card.querySelector('img') !== null,
        hasPrice: card.textContent?.includes('NPR') || card.textContent?.includes('₹')
      }));
    });
    
    console.log('    Available properties:');
    properties.forEach(prop => {
      console.log(`      ${prop.index + 1}. ${prop.text?.substring(0, 50)}... (${prop.href})`);
    });
    
    // PHASE 2: Select a property
    console.log('\n  [1.2] Selecting first property...');
    const firstPropertyLink = await page.$('a[href*="/hotels/"]');
    if (firstPropertyLink) {
      await firstPropertyLink.click();
      await page.waitForTimeout(3000);
      await page.screenshot({ path: `./frontend-results/screenshots/guest_02_property_detail_${timestamp}.png`, fullPage: true });
      
      const propertyName = await page.evaluate(() => {
        return document.querySelector('h1, .property-name, .hotel-name')?.textContent || 'Property';
      });
      console.log(`    ✓ Viewing: ${propertyName}`);
    }
    
    // PHASE 3: Analyze property detail page
    console.log('\n[PHASE 2] Property Detail Analysis...');
    
    console.log('  [2.1] Analyzing room options...');
    const roomInfo = await page.evaluate(() => {
      const roomElements = Array.from(document.querySelectorAll('.room, .room-type, [data-testid*="room"]'));
      return roomElements.slice(0, 3).map((room, index) => ({
        index,
        name: room.querySelector('.room-name, .name, h3, h4')?.textContent,
        price: room.querySelector('.price, .rate, [class*="price"]')?.textContent,
        capacity: room.querySelector('.capacity, .guests, [class*="guest"]')?.textContent,
        hasBookButton: room.querySelector('button, .book, .reserve') !== null
      }));
    });
    
    console.log('    Available rooms:');
    roomInfo.forEach(room => {
      console.log(`      ${room.index + 1}. ${room.name} - ${room.price} (${room.capacity}) [Book: ${room.hasBookButton}]`);
    });
    
    // Look for booking interface
    console.log('  [2.2] Looking for booking interface...');
    const bookingElements = await page.evaluate(() => {
      return {
        hasDatePicker: document.querySelector('input[type="date"], .date-picker, [placeholder*="check"]') !== null,
        hasGuestSelector: document.querySelector('.guest, .adults, .children, [placeholder*="guest"]') !== null,
        hasBookButton: document.querySelector('button:has-text("Book"), button:has-text("Reserve"), .book-now') !== null,
        hasRoomSelector: document.querySelector('.room-quantity, .rooms, [name*="room"]') !== null
      };
    });
    
    console.log('    Booking interface elements:');
    Object.entries(bookingElements).forEach(([key, value]) => {
      console.log(`      ${key}: ${value ? '✓' : '✗'}`);
    });
    
    // PHASE 4: Test booking initiation
    console.log('\n[PHASE 3] Booking Initiation...');
    
    // Try to find and click a book/reserve button
    console.log('  [3.1] Attempting to start booking...');
    const bookButton = await page.$('button:has-text("Book"), button:has-text("Reserve"), .book-now, .reserve-now');
    if (bookButton) {
      await bookButton.click();
      await page.waitForTimeout(3000);
      await page.screenshot({ path: `./frontend-results/screenshots/guest_03_booking_initiated_${timestamp}.png`, fullPage: true });
      console.log('    ✓ Booking button clicked');
    } else {
      // Try direct booking URL approach
      console.log('    No booking button found, trying direct booking URL...');
      await page.goto('http://localhost:3001/booking?hotelId=00000000-0000-4000-a000-000000000100&checkIn=2026-03-15&checkOut=2026-03-17&guests=2&rooms=1', 
                      { waitUntil: 'domcontentloaded', timeout: 10000 });
      await page.screenshot({ path: `./frontend-results/screenshots/guest_03_direct_booking_${timestamp}.png`, fullPage: true });
      console.log('    ✓ Using direct booking URL');
    }
    
    // PHASE 5: Analyze booking form
    console.log('\n[PHASE 4] Booking Form Analysis...');
    
    console.log('  [4.1] Analyzing booking form structure...');
    const bookingForm = await page.evaluate(() => {
      const form = document.querySelector('form');
      if (!form) return { hasForm: false };
      
      const inputs = Array.from(form.querySelectorAll('input, select, textarea'));
      return {
        hasForm: true,
        inputCount: inputs.length,
        inputs: inputs.map(input => ({
          type: input.type || input.tagName.toLowerCase(),
          name: input.name,
          placeholder: input.placeholder,
          required: input.required
        })),
        hasSubmitButton: form.querySelector('button[type="submit"], .submit, .complete') !== null
      };
    });
    
    if (bookingForm.hasForm) {
      console.log('    ✓ Booking form found');
      console.log(`    Form inputs (${bookingForm.inputCount}):`);
      bookingForm.inputs.forEach((input, i) => {
        console.log(`      ${i+1}. ${input.type} - "${input.placeholder}" (${input.name}) ${input.required ? '[Required]' : ''}`);
      });
    } else {
      console.log('    ✗ No booking form found');
    }
    
    // PHASE 6: Test form filling
    console.log('\n[PHASE 5] Guest Information Entry...');
    
    if (bookingForm.hasForm) {
      console.log('  [5.1] Filling guest information...');
      
      // Fill guest details
      const guestData = {
        firstName: 'John',
        lastName: 'Doe', 
        email: 'john.doe@example.com',
        phone: '9876543210'
      };
      
      // Try to fill form fields
      const firstNameInput = await page.$('input[placeholder*="John"], input[name*="first"], input[placeholder*="First"]');
      const lastNameInput = await page.$('input[placeholder*="Doe"], input[name*="last"], input[placeholder*="Last"]');
      const emailInput = await page.$('input[type="email"], input[name*="email"]');
      const phoneInput = await page.$('input[type="tel"], input[name*="phone"]');
      
      if (firstNameInput) await firstNameInput.fill(guestData.firstName);
      if (lastNameInput) await lastNameInput.fill(guestData.lastName);
      if (emailInput) await emailInput.fill(guestData.email);
      if (phoneInput) await phoneInput.fill(guestData.phone);
      
      await page.screenshot({ path: `./frontend-results/screenshots/guest_04_form_filled_${timestamp}.png`, fullPage: true });
      console.log('    ✓ Guest information filled');
      
      // PHASE 7: Booking summary verification
      console.log('\n[PHASE 6] Booking Summary Verification...');
      
      console.log('  [6.1] Checking booking details...');
      const bookingSummary = await page.evaluate(() => {
        const bodyText = document.body.textContent;
        return {
          hasHotelName: bodyText.includes('Hotel') || bodyText.includes('Resort'),
          hasRoomType: bodyText.includes('Room') || bodyText.includes('Suite'),
          hasPrice: bodyText.includes('NPR') || bodyText.includes('₹') || bodyText.includes('Total'),
          hasDates: bodyText.includes('Check-in') || bodyText.includes('Check-out'),
          hasGuests: bodyText.includes('Guest') || bodyText.includes('Adult'),
          hasRoomCount: bodyText.includes('room') || bodyText.includes('Room'),
          paymentMethod: bodyText.includes('Pay at property') ? 'Pay at property' : 
                        bodyText.includes('Online') ? 'Online payment' : 'Unknown'
        };
      });
      
      console.log('    Booking summary elements:');
      Object.entries(bookingSummary).forEach(([key, value]) => {
        if (typeof value === 'boolean') {
          console.log(`      ${key}: ${value ? '✓' : '✗'}`);
        } else {
          console.log(`      ${key}: ${value}`);
        }
      });
      
      // PHASE 8: Complete booking
      console.log('\n[PHASE 7] Booking Completion...');
      
      console.log('  [7.1] Accepting terms and completing booking...');
      
      // Look for terms checkbox
      const termsCheckbox = await page.$('input[type="checkbox"]');
      if (termsCheckbox) {
        await termsCheckbox.check();
        console.log('    ✓ Terms accepted');
      }
      
      // Submit booking
      const submitButton = await page.$('button[type="submit"], button:has-text("Complete"), button:has-text("Book")');
      if (submitButton) {
        await submitButton.click();
        await page.waitForTimeout(5000);
        await page.screenshot({ path: `./frontend-results/screenshots/guest_05_booking_submitted_${timestamp}.png`, fullPage: true });
        console.log('    ✓ Booking submitted');
        
        // Check for confirmation
        const confirmationText = await page.textContent('body');
        const hasConfirmation = confirmationText.includes('confirmed') || 
                               confirmationText.includes('success') || 
                               confirmationText.includes('booking') ||
                               confirmationText.includes('reservation');
        
        console.log(`    Booking confirmation: ${hasConfirmation ? '✓' : '?'}`);
      }
    }
    
    // PHASE 9: Summary
    console.log('\n[PHASE 8] Guest Booking Flow Summary...');
    
    await page.screenshot({ path: `./frontend-results/screenshots/guest_06_final_state_${timestamp}.png`, fullPage: true });
    
    console.log('\n✅ GUEST BOOKING FLOW EXPLORATION COMPLETE');
    console.log('\nFlow Analysis:');
    console.log(`  • Property listings: ${properties.length} properties found`);
    console.log(`  • Property detail: ${roomInfo.length} room types available`);
    console.log(`  • Booking interface: ${bookingForm.hasForm ? 'Form found' : 'No form'}`);
    console.log(`  • Guest information: ${bookingForm.inputCount || 0} form fields`);
    console.log(`  • Booking summary: Price and details verification`);
    console.log(`  • Payment method: ${bookingSummary?.paymentMethod || 'Unknown'}`);
    
    console.log('\nScreenshots saved with timestamp:', timestamp);
    
    await page.waitForTimeout(10000);
    
  } catch (error) {
    console.error('Exploration error:', error.message);
    await page.screenshot({ path: `./frontend-results/screenshots/guest_error_${timestamp}.png`, fullPage: true });
  } finally {
    await browser.close();
  }
  
  console.log('\n🎯 Guest booking flow exploration finished');
})();