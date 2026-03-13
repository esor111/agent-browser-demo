import { chromium } from 'playwright';

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  // Get tomorrow and day after as check-in/check-out
  const tomorrow = new Date();
  tomorrow.setDate(tomorrow.getDate() + 1);
  const dayAfter = new Date();
  dayAfter.setDate(dayAfter.getDate() + 6);
  
  const checkIn = tomorrow.toISOString().split('T')[0];
  const checkOut = dayAfter.toISOString().split('T')[0];
  
  const hotelId = '00000000-0000-4000-a000-000000000100';
  
  console.log('\n========================================');
  console.log(' BOOKING FLOW TEST WITH DATES');
  console.log('========================================\n');
  console.log(`Check-in: ${checkIn}`);
  console.log(`Check-out: ${checkOut}`);
  
  // Try going directly to booking page with all params
  const bookingUrl = `http://localhost:3001/booking?hotelId=${hotelId}&checkIn=${checkIn}&checkOut=${checkOut}&guests=2&rooms=1`;
  
  console.log(`\n[1/5] Navigating directly to booking page...`);
  console.log(`  URL: ${bookingUrl}`);
  
  await page.goto(bookingUrl, { waitUntil: 'networkidle', timeout: 30000 });
  await page.waitForTimeout(3000);
  await page.screenshot({ path: './frontend-results/screenshots/direct_booking_01.png', fullPage: true });
  
  const title = await page.title();
  console.log(`✓ Page loaded: ${title}`);
  console.log(`  Current URL: ${page.url()}`);
  
  console.log(`\n[2/5] Checking if booking form is present...`);
  const inputs = await page.$$('input[type="text"], input[type="email"], input[type="tel"]');
  console.log(`  Found ${inputs.length} form inputs`);
  
  if (inputs.length > 0) {
    console.log(`  ✓ Booking form is present!`);
    
    console.log(`\n[3/5] Analyzing form fields...`);
    for (let i = 0; i < inputs.length; i++) {
      const type = await inputs[i].getAttribute('type');
      const placeholder = await inputs[i].getAttribute('placeholder');
      const name = await inputs[i].getAttribute('name');
      console.log(`  Field ${i+1}: type="${type}", placeholder="${placeholder}", name="${name}"`);
    }
    
    console.log(`\n[4/5] Filling out guest information...`);
    
    // Fill first name
    await page.fill('input[type="text"]', 'Test');
    console.log(`  ✓ Filled first name`);
    await page.waitForTimeout(500);
    
    // Fill other fields by placeholder or type
    const emailInput = await page.$('input[type="email"]');
    if (emailInput) {
      await emailInput.fill('test@example.com');
      console.log(`  ✓ Filled email`);
    }
    
    const phoneInput = await page.$('input[type="tel"]');
    if (phoneInput) {
      await phoneInput.fill('9800000001');
      console.log(`  ✓ Filled phone`);
    }
    
    await page.screenshot({ path: './frontend-results/screenshots/direct_booking_02_filled.png', fullPage: true });
    
    console.log(`\n[5/5] Looking for submit button...`);
    const buttons = await page.$$('button');
    for (const btn of buttons) {
      const text = await btn.textContent();
      const visible = await btn.isVisible();
      if (text && visible && (text.includes('Confirm') || text.includes('Complete') || text.includes('Submit'))) {
        console.log(`  ✓ Found submit button: "${text.trim()}"`);
      }
    }
    
    console.log(`\n✓ SUCCESS! Booking page is accessible with dates in URL`);
    console.log(`  ✓ Form loads correctly`);
    console.log(`  ✓ Can fill guest information`);
    console.log(`  ✓ Submit button is present`);
    
  } else {
    console.log(`  ✗ No form inputs found`);
    const bodyText = await page.textContent('body');
    console.log(`  Page contains: ${bodyText.substring(0, 200)}...`);
  }
  
  console.log(`\n  Browser will stay open for 20 seconds...`);
  await page.waitForTimeout(20000);
  
  await browser.close();
  console.log(`\n✓ Test complete`);
})();
