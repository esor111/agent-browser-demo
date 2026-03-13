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
  const timestamp = Date.now();
  const hotelId = '00000000-0000-4000-a000-000000000100';
  
  const guestData = {
    firstName: 'Test',
    lastName: `Guest${timestamp}`,
    email: `test${timestamp}@example.com`,
    phone: '9800000001'
  };
  
  console.log('========================================');
  console.log('QUICK BOOKING TEST');
  console.log('========================================\n');
  
  const bookingUrl = `http://localhost:3001/booking?hotelId=${hotelId}&checkIn=${checkIn}&checkOut=${checkOut}&guests=2&rooms=1`;
  
  console.log('[1/5] Loading booking page...');
  await page.goto(bookingUrl, { waitUntil: 'domcontentloaded', timeout: 20000 });
  await page.waitForTimeout(2000);
  console.log('✓ Page loaded');
  
  console.log('\n[2/5] Filling form...');
  await page.fill('input[placeholder*="John"]', guestData.firstName);
  await page.fill('input[placeholder*="Doe"]', guestData.lastName);
  await page.fill('input[type="email"]', guestData.email);
  await page.fill('input[type="tel"]', guestData.phone);
  console.log('✓ Form filled');
  
  await page.screenshot({ path: './frontend-results/screenshots/quick_01_filled.png', fullPage: true });
  
  console.log('\n[3/5] Checking terms checkbox...');
  try {
    const checkbox = await page.waitForSelector('input[type="checkbox"]', { timeout: 2000 });
    await checkbox.click();
    console.log('✓ Terms accepted');
  } catch {
    console.log('! No checkbox or already checked');
  }
  
  console.log('\n[4/5] Submitting...');
  try {
    const submitBtn = await page.waitForSelector('button:has-text("Complete")', { timeout: 2000 });
    await submitBtn.click();
    console.log('✓ Clicked submit');
    
    await page.waitForTimeout(5000);
    await page.screenshot({ path: './frontend-results/screenshots/quick_02_result.png', fullPage: true });
    
    const bodyText = await page.textContent('body');
    const confirmed = bodyText.includes('Confirmed') || bodyText.includes('confirmed');
    const code = bodyText.match(/[A-Z0-9]{6,}/)?.[0];
    
    console.log(`\n[5/5] Result:`);
    console.log(`  Confirmed: ${confirmed}`);
    console.log(`  Code: ${code || 'Not found'}`);
    
    if (confirmed && code) {
      console.log(`\n✅ BOOKING SUCCESSFUL!`);
      console.log(`  Confirmation: ${code}`);
    } else {
      console.log(`\n❌ Booking failed or incomplete`);
    }
  } catch (e) {
    console.log(`✗ Error: ${e.message}`);
  }
  
  await page.waitForTimeout(10000);
  await browser.close();
  console.log('\n✓ Done');
})();
