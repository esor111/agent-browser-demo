import { chromium } from 'playwright';

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  const hotelId = '00000000-0000-4000-a000-000000000100';
  const url = `http://localhost:3001/hotels/${hotelId}?guests=2`;
  
  console.log('\n[1/8] Navigating to hotel detail page...');
  await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
  await page.screenshot({ path: './frontend-results/screenshots/test_01_hotel_page.png', fullPage: true });
  console.log('✓ Page loaded');
  
  console.log('\n[2/8] Looking for "Select Room" buttons...');
  const selectButtons = await page.locator('button:has-text("Select Room")').count();
  console.log(`  Found ${selectButtons} "Select Room" buttons`);
  
  if (selectButtons > 0) {
    console.log('\n[3/8] Clicking first "Select Room" button...');
    await page.locator('button:has-text("Select Room")').first().click();
    await page.waitForTimeout(2000);
    await page.screenshot({ path: './frontend-results/screenshots/test_02_after_select_click.png', fullPage: true });
    console.log('✓ Clicked "Select Room"');
    console.log(`  Current URL: ${page.url()}`);
    
    // Check if modal or new page appeared
    console.log('\n[4/8] Checking for modal or booking form...');
    const modals = await page.$$('[role="dialog"], [class*="modal"], [class*="Modal"]');
    console.log(`  Found ${modals.length} potential modals`);
    
    // Check for form fields
    const inputs = await page.$$('input[type="text"], input[type="email"], input[type="tel"]');
    console.log(`  Found ${inputs.length} input fields`);
    
    // Check for booking-related text
    const bodyText = await page.textContent('body');
    const hasGuestInfo = bodyText.includes('Guest') || bodyText.includes('guest');
    const hasPayment = bodyText.includes('Payment') || bodyText.includes('payment');
    const hasConfirm = bodyText.includes('Confirm') || bodyText.includes('confirm');
    
    console.log(`  Contains "Guest": ${hasGuestInfo}`);
    console.log(`  Contains "Payment": ${hasPayment}`);
    console.log(`  Contains "Confirm": ${hasConfirm}`);
    
    console.log('\n[5/8] Looking for next step buttons...');
    const nextButtons = await page.$$('button');
    console.log(`  Total buttons now: ${nextButtons.length}`);
    
    for (let i = 0; i < Math.min(nextButtons.length, 20); i++) {
      const text = await nextButtons[i].textContent();
      const visible = await nextButtons[i].isVisible();
      if (text && text.trim() && visible) {
        console.log(`  ${i+1}. "${text.trim()}"`);
      }
    }
    
    console.log('\n[6/8] Checking if we navigated to booking page...');
    const currentUrl = page.url();
    console.log(`  Current URL: ${currentUrl}`);
    
    if (currentUrl.includes('/booking')) {
      console.log('  ✓ Navigated to booking page!');
    } else if (currentUrl === url) {
      console.log('  ✗ Still on hotel detail page');
    } else {
      console.log(`  ? Navigated to: ${currentUrl}`);
    }
    
    console.log('\n[7/8] Taking final screenshot...');
    await page.screenshot({ path: './frontend-results/screenshots/test_03_final_state.png', fullPage: true });
    
    console.log('\n[8/8] Waiting 20 seconds for manual inspection...');
    await page.waitForTimeout(20000);
  } else {
    console.log('  ✗ No "Select Room" buttons found');
    
    console.log('\n[3/8] Trying "Reserve Now" button instead...');
    const reserveButtons = await page.locator('button:has-text("Reserve")').count();
    console.log(`  Found ${reserveButtons} "Reserve" buttons`);
    
    if (reserveButtons > 0) {
      await page.locator('button:has-text("Reserve")').first().click();
      await page.waitForTimeout(2000);
      await page.screenshot({ path: './frontend-results/screenshots/test_02_after_reserve_click.png', fullPage: true });
      console.log('✓ Clicked "Reserve Now"');
      console.log(`  Current URL: ${page.url()}`);
    }
  }
  
  await browser.close();
  console.log('\n✓ Exploration complete');
})();
