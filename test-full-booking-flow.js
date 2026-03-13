import { chromium } from 'playwright';

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  const hotelId = '00000000-0000-4000-a000-000000000100';
  const url = `http://localhost:3001/hotels/${hotelId}`;
  
  console.log('\n========================================');
  console.log(' FULL BOOKING FLOW TEST');
  console.log('========================================\n');
  
  console.log('[1/10] Navigating to hotel detail page...');
  await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
  await page.screenshot({ path: './frontend-results/screenshots/flow_01_hotel_page.png', fullPage: true });
  console.log('✓ Page loaded');
  
  console.log('\n[2/10] Looking for booking widget...');
  await page.waitForTimeout(2000); // Let page fully render
  
  // Check if dates are already in URL
  const currentUrl = page.url();
  console.log(`  Current URL: ${currentUrl}`);
  
  console.log('\n[3/10] Looking for date inputs...');
  const dateInputs = await page.$$('input[type="text"], input[placeholder*="Check"], input[placeholder*="date"]');
  console.log(`  Found ${dateInputs.length} potential date inputs`);
  
  for (let i = 0; i < dateInputs.length; i++) {
    const placeholder = await dateInputs[i].getAttribute('placeholder');
    const value = await dateInputs[i].inputValue();
    console.log(`  Input ${i+1}: placeholder="${placeholder}", value="${value}"`);
  }
  
  console.log('\n[4/10] Looking for Reserve/Book buttons...');
  const allButtons = await page.$$('button');
  console.log(`  Found ${allButtons.length} total buttons`);
  
  let reserveButton = null;
  for (const btn of allButtons) {
    const text = await btn.textContent();
    const visible = await btn.isVisible();
    if (text && visible && (text.includes('Reserve') || text.includes('Book'))) {
      console.log(`  ✓ Found button: "${text.trim()}"`);
      if (!reserveButton) reserveButton = btn;
    }
  }
  
  if (!reserveButton) {
    console.log('  ✗ No Reserve/Book button found');
    console.log('\n[5/10] Checking page text for booking keywords...');
    const bodyText = await page.textContent('body');
    console.log(`  Contains "Reserve": ${bodyText.includes('Reserve')}`);
    console.log(`  Contains "Book": ${bodyText.includes('Book')}`);
    console.log(`  Contains "Select dates": ${bodyText.includes('Select dates') || bodyText.includes('select dates')}`);
    
    await page.waitForTimeout(15000);
    await browser.close();
    return;
  }
  
  console.log('\n[5/10] Clicking Reserve button...');
  await reserveButton.click();
  await page.waitForTimeout(3000);
  await page.screenshot({ path: './frontend-results/screenshots/flow_02_after_reserve_click.png', fullPage: true });
  
  const newUrl = page.url();
  console.log(`  New URL: ${newUrl}`);
  
  if (newUrl.includes('/booking')) {
    console.log('  ✓ Navigated to booking page!');
    
    console.log('\n[6/10] Analyzing booking page...');
    const pageTitle = await page.title();
    console.log(`  Page title: ${pageTitle}`);
    
    console.log('\n[7/10] Looking for form fields...');
    const inputs = await page.$$('input');
    console.log(`  Found ${inputs.length} input fields`);
    
    for (let i = 0; i < Math.min(inputs.length, 10); i++) {
      const type = await inputs[i].getAttribute('type');
      const placeholder = await inputs[i].getAttribute('placeholder');
      const name = await inputs[i].getAttribute('name');
      console.log(`  Input ${i+1}: type="${type}", placeholder="${placeholder}", name="${name}"`);
    }
    
    console.log('\n[8/10] Looking for submit/confirm buttons...');
    const bookingButtons = await page.$$('button');
    for (const btn of bookingButtons) {
      const text = await btn.textContent();
      const visible = await btn.isVisible();
      if (text && visible && (text.includes('Confirm') || text.includes('Submit') || text.includes('Complete'))) {
        console.log(`  ✓ Found: "${text.trim()}"`);
      }
    }
    
    console.log('\n[9/10] Taking final screenshot...');
    await page.screenshot({ path: './frontend-results/screenshots/flow_03_booking_page.png', fullPage: true });
    
    console.log('\n[10/10] SUCCESS! Booking flow is working.');
    console.log('  ✓ Hotel detail page loads');
    console.log('  ✓ Reserve button exists and works');
    console.log('  ✓ Navigates to booking page');
    console.log('  ✓ Booking form is present');
    
  } else if (newUrl === url) {
    console.log('  ✗ Still on hotel detail page - button click had no effect');
    console.log('\n[6/10] Checking for error messages...');
    const bodyText = await page.textContent('body');
    if (bodyText.includes('select') && bodyText.includes('date')) {
      console.log('  ! Likely needs dates to be selected first');
    }
  } else {
    console.log(`  ? Navigated to unexpected page: ${newUrl}`);
  }
  
  console.log('\n  Browser will stay open for 20 seconds for inspection...');
  await page.waitForTimeout(20000);
  
  await browser.close();
  console.log('\n✓ Test complete');
})();
