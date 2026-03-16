import { chromium } from 'playwright';

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  // Calculate dates
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  const dayAfter = new Date();
  dayAfter.setDate(dayAfter.getDate() + 6);
  
  const checkIn = tomorrow.toISOString().split('T')[0];
  const checkOut = dayAfter.toISOString().split('T')[0];
  
  const timestamp = Date.now();
  const hotelId = '00000000-0000-4000-a000-000000000100';
  
  // Test data
  const guestData = {
    firstName: 'Test',
    lastName: `Guest${timestamp}`,
    email: `test${timestamp}@example.com`,
    phone: '9800000001'
  };
  
  console.log('\n========================================');
  console.log(' COMPLETE BOOKING FLOW TEST');
  console.log('========================================\n');
  console.log(`Guest: ${guestData.firstName} ${guestData.lastName}`);
  console.log(`Email: ${guestData.email}`);
  console.log(`Phone: ${guestData.phone}`);
  console.log(`Check-in: ${checkIn}`);
  console.log(`Check-out: ${checkOut}\n`);
  
  // Navigate directly to booking page with all parameters
  const bookingUrl = `http://localhost:3001/booking?hotelId=${hotelId}&checkIn=${checkIn}&checkOut=${checkOut}&guests=2&rooms=1`;
  
  console.log('[1/7] Navigating to booking page...');
  await page.goto(bookingUrl, { waitUntil: 'networkidle', timeout: 30000 });
  await page.waitForTimeout(2000);
  await page.screenshot({ path: './frontend-results/screenshots/booking_test_01_page.png', fullPage: true });
  console.log('✓ Booking page loaded');
  
  console.log('\n[2/7] Filling guest information...');
  
  // Fill first name
  const firstNameInput = await page.$('input[placeholder*="John"], input[placeholder*="First"]');
  if (firstNameInput) {
    await firstNameInput.fill(guestData.firstName);
    console.log('  ✓ First name');
  }
  
  // Fill last name
  const lastNameInput = await page.$('input[placeholder*="Doe"], input[placeholder*="Last"]');
  if (lastNameInput) {
    await lastNameInput.fill(guestData.lastName);
    console.log('  ✓ Last name');
  }
  
  // Fill email
  const emailInput = await page.$('input[type="email"]');
  if (emailInput) {
    await emailInput.fill(guestData.email);
    console.log('  ✓ Email');
  }
  
  // Fill phone
  const phoneInput = await page.$('input[type="tel"]');
  if (phoneInput) {
    await phoneInput.fill(guestData.phone);
    console.log('  ✓ Phone');
  }
  
  await page.waitForTimeout(1000);
  await page.screenshot({ path: './frontend-results/screenshots/booking_test_02_filled.png', fullPage: true });
  
  console.log('\n[3/7] Checking for terms checkbox...');
  const termsCheckbox = await page.$('input[type="checkbox"]');
  if (termsCheckbox) {
    const isChecked = await termsCheckbox.isChecked();
    if (!isChecked) {
      await termsCheckbox.click();
      console.log('  ✓ Terms accepted');
    } else {
      console.log('  ✓ Terms already accepted');
    }
  } else {
    console.log('  ! No terms checkbox found');
  }
  
  await page.waitForTimeout(500);
  await page.screenshot({ path: './frontend-results/screenshots/booking_test_03_ready.png', fullPage: true });
  
  console.log('\n[4/7] Looking for submit button...');
  const submitButton = await page.$('button:has-text("Complete Booking")');
  if (submitButton) {
    const isDisabled = await submitButton.isDisabled();
    console.log(`  ✓ Found "Complete Booking" button (disabled: ${isDisabled})`);
    
    if (!isDisabled) {
      console.log('\n[5/7] Submitting booking...');
      await submitButton.click();
      console.log('  ✓ Clicked submit');
      
      console.log('\n[6/7] Waiting for confirmation...');
      await page.waitForTimeout(5000);
      await page.screenshot({ path: './frontend-results/screenshots/booking_test_04_after_submit.png', fullPage: true });
      
      const finalUrl = page.url();
      const bodyText = await page.textContent('body');
      
      console.log(`  Final URL: ${finalUrl}`);
      
      // Check for confirmation
      const hasConfirmed = bodyText.includes('Confirmed') || bodyText.includes('confirmed') || bodyText.includes('Success');
      const confirmationCode = bodyText.match(/[A-Z0-9]{6,12}/)?.[0];
      
      console.log(`  Has confirmation: ${hasConfirmed}`);
      console.log(`  Confirmation code: ${confirmationCode || 'Not found'}`);
      
      if (hasConfirmed) {
        console.log('\n[7/7] ✓ BOOKING SUCCESSFUL!');
        console.log(`  Confirmation code: ${confirmationCode}`);
        console.log(`  Guest: ${guestData.firstName} ${guestData.lastName}`);
        console.log(`  Email: ${guestData.email}`);
      } else {
        console.log('\n[7/7] ✗ Booking may have failed');
        console.log(`  Check screenshot for details`);
      }
    } else {
      console.log('  ✗ Submit button is disabled');
      console.log('  Checking for validation errors...');
      const errorText = await page.textContent('body');
      if (errorText.includes('required') || errorText.includes('invalid')) {
        console.log('  ! Form has validation errors');
      }
    }
  } else {
    console.log('  ✗ Submit button not found');
  }
  
  console.log('\n  Browser will stay open for 15 seconds...');
  await page.waitForTimeout(15000);
  
  await browser.close();
  console.log('\n✓ Test complete');
  console.log('\nScreenshots saved to: ./frontend-results/screenshots/booking_test_*.png');
})();
