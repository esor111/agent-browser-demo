import { chromium } from 'playwright';

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  const dayAfter = new Date();
  dayAfter.setDate(dayAfter.getDate() + 6);
  
  const checkIn = tomorrow.toISOString().split('T')[0];
  const checkOut = dayAfter.toISOString().split('T')[0];
  const hotelId = '00000000-0000-4000-a000-000000000100';
  
  const bookingUrl = `http://localhost:3001/booking?hotelId=${hotelId}&checkIn=${checkIn}&checkOut=${checkOut}&guests=2&rooms=1`;
  
  console.log('DEBUG: Booking Submit Process');
  console.log('=====================================\n');
  
  console.log('[1/6] Loading booking page...');
  await page.goto(bookingUrl, { waitUntil: 'domcontentloaded', timeout: 20000 });
  await page.waitForTimeout(3000);
  console.log('✓ Page loaded');
  
  console.log('\n[2/6] Filling form quickly...');
  await page.fill('input[placeholder*="John"]', 'Test');
  await page.fill('input[placeholder*="Doe"]', 'User');
  await page.fill('input[type="email"]', 'test@example.com');
  await page.fill('input[type="tel"]', '9800000001');
  console.log('✓ Form filled');
  
  console.log('\n[3/6] Checking terms checkbox...');
  try {
    const checkbox = await page.$('input[type="checkbox"]');
    if (checkbox) {
      const isChecked = await checkbox.isChecked();
      if (!isChecked) {
        await checkbox.click();
        console.log('✓ Terms accepted');
      } else {
        console.log('✓ Terms already accepted');
      }
    }
  } catch (e) {
    console.log('! No checkbox found');
  }
  
  await page.screenshot({ path: './frontend-results/screenshots/debug_01_ready.png', fullPage: true });
  
  console.log('\n[4/6] Looking for submit button...');
  const buttons = await page.$$('button');
  console.log(`  Found ${buttons.length} buttons total`);
  
  let submitButton = null;
  for (const btn of buttons) {
    const text = await btn.textContent();
    const visible = await btn.isVisible();
    const disabled = await btn.isDisabled();
    if (text && visible) {
      console.log(`  Button: "${text.trim()}" (disabled: ${disabled})`);
      if (text.includes('Complete') && !disabled) {
        submitButton = btn;
      }
    }
  }
  
  if (submitButton) {
    console.log('\n[5/6] Clicking submit button...');
    await submitButton.click();
    console.log('✓ Clicked submit');
    
    console.log('\n[6/6] Waiting and checking result...');
    await page.waitForTimeout(8000);
    
    const finalUrl = page.url();
    const bodyText = await page.textContent('body');
    
    console.log(`  Final URL: ${finalUrl}`);
    console.log(`  URL changed: ${finalUrl !== bookingUrl}`);
    
    // Look for specific confirmation indicators
    const hasConfirmed = bodyText.includes('Booking Confirmed') || bodyText.includes('confirmed');
    const hasSuccess = bodyText.includes('Success') || bodyText.includes('success');
    const hasThankYou = bodyText.includes('Thank you') || bodyText.includes('thank you');
    const hasError = bodyText.includes('error') || bodyText.includes('Error') || bodyText.includes('failed');
    
    console.log(`  Has "confirmed": ${hasConfirmed}`);
    console.log(`  Has "success": ${hasSuccess}`);
    console.log(`  Has "thank you": ${hasThankYou}`);
    console.log(`  Has error: ${hasError}`);
    
    // Look for confirmation codes
    const codes = bodyText.match(/[A-Z0-9]{6,}/g);
    console.log(`  Potential codes: ${codes ? codes.slice(0, 3).join(', ') : 'None'}`);
    
    await page.screenshot({ path: './frontend-results/screenshots/debug_02_result.png', fullPage: true });
    
    if (hasConfirmed || hasSuccess) {
      console.log('\n✅ BOOKING APPEARS SUCCESSFUL');
    } else if (hasError) {
      console.log('\n❌ BOOKING FAILED WITH ERROR');
    } else {
      console.log('\n⚠️  BOOKING STATUS UNCLEAR');
    }
  } else {
    console.log('\n❌ No enabled submit button found');
  }
  
  await page.waitForTimeout(10000);
  await browser.close();
  console.log('\n✓ Debug complete');
})();