import { chromium } from 'playwright';

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  const hotelId = '00000000-0000-4000-a000-000000000100';
  const url = `http://localhost:3001/hotels/${hotelId}?guests=2`;
  
  console.log('\n[1/6] Navigating to hotel detail page...');
  await page.goto(url, { waitUntil: 'networkidle', timeout: 30000 });
  await page.screenshot({ path: './frontend-results/screenshots/explore_01_hotel_page.png', fullPage: true });
  console.log('✓ Page loaded');
  
  console.log('\n[2/6] Analyzing page structure...');
  const title = await page.title();
  console.log(`  Page title: ${title}`);
  
  console.log('\n[3/6] Looking for all buttons...');
  const buttons = await page.$$('button');
  console.log(`  Found ${buttons.length} buttons`);
  
  for (let i = 0; i < Math.min(buttons.length, 30); i++) {
    const text = await buttons[i].textContent();
    const visible = await buttons[i].isVisible();
    const classes = await buttons[i].getAttribute('class');
    if (text && text.trim() && visible) {
      console.log(`  ${i+1}. "${text.trim().substring(0, 50)}"`);
    }
  }
  
  console.log('\n[4/6] Looking for booking-related text...');
  const bodyText = await page.textContent('body');
  const keywords = ['Reserve', 'Book', 'Select Room', 'Check Availability', 'Continue', 'Proceed'];
  for (const keyword of keywords) {
    const count = (bodyText.match(new RegExp(keyword, 'gi')) || []).length;
    if (count > 0) {
      console.log(`  ✓ Found "${keyword}" ${count} times`);
    }
  }
  
  console.log('\n[5/6] Trying to find booking buttons by text...');
  const bookingSelectors = [
    'button:has-text("Reserve")',
    'button:has-text("Book")',
    'button:has-text("Select")',
    'button:has-text("Continue")',
    'button:has-text("Check Availability")',
    '[role="button"]:has-text("Reserve")',
    '[role="button"]:has-text("Book")'
  ];
  
  for (const selector of bookingSelectors) {
    try {
      const count = await page.locator(selector).count();
      if (count > 0) {
        console.log(`  ✓ Found ${count} elements: ${selector}`);
        const first = page.locator(selector).first();
        const text = await first.textContent();
        const visible = await first.isVisible();
        console.log(`    Text: "${text?.trim()}", Visible: ${visible}`);
      }
    } catch (e) {
      // Skip
    }
  }
  
  console.log('\n[6/6] Checking for room type sections...');
  const roomSections = await page.$$('[class*="room-type"], [class*="RoomType"], section');
  console.log(`  Found ${roomSections.length} potential room sections`);
  
  console.log('\n✓ Exploration complete. Browser will stay open for 30 seconds...');
  await page.waitForTimeout(30000);
  
  await browser.close();
  console.log('✓ Browser closed');
})();
