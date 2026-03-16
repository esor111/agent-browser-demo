#!/bin/bash

# Simple hotel detail page explorer
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
SCREENSHOT_DIR="./frontend-results/screenshots"
mkdir -p "$SCREENSHOT_DIR"

echo "========================================="
echo " HOTEL DETAIL PAGE EXPLORER"
echo "========================================="

# Get first hotel ID
HOTEL_ID=$(curl -s http://localhost:3000/public/hotels | jq -r '.[0].id')
echo "Hotel ID: $HOTEL_ID"

# Create Playwright script
cat > /tmp/explore_hotel_${TIMESTAMP}.js << 'SCRIPT'
const { chromium } = require('playwright');

(async () => {
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext();
  const page = await context.newPage();
  
  const hotelId = process.env.HOTEL_ID;
  const url = `http://localhost:3001/hotels/${hotelId}?guests=2`;
  
  console.log(`\n[1/5] Navigating to hotel detail page...`);
  await page.goto(url, { waitUntil: 'networkidle' });
  await page.screenshot({ path: './frontend-results/screenshots/hotel_detail_page.png', fullPage: true });
  console.log(`✓ Screenshot saved`);
  
  console.log(`\n[2/5] Looking for booking buttons...`);
  const buttons = await page.$$('button');
  console.log(`Found ${buttons.length} buttons on page`);
  
  for (let i = 0; i < buttons.length; i++) {
    const text = await buttons[i].textContent();
    const visible = await buttons[i].isVisible();
    if (text && text.trim()) {
      console.log(`  Button ${i+1}: "${text.trim()}" (visible: ${visible})`);
    }
  }
  
  console.log(`\n[3/5] Looking for room type cards...`);
  const roomCards = await page.$$('[class*="room"], [class*="Room"]');
  console.log(`Found ${roomCards.length} potential room elements`);
  
  console.log(`\n[4/5] Checking for "Reserve" or "Book" text...`);
  const pageText = await page.textContent('body');
  const hasReserve = pageText.includes('Reserve') || pageText.includes('reserve');
  const hasBook = pageText.includes('Book') || pageText.includes('book');
  const hasSelect = pageText.includes('Select') || pageText.includes('select');
  
  console.log(`  Contains "Reserve": ${hasReserve}`);
  console.log(`  Contains "Book": ${hasBook}`);
  console.log(`  Contains "Select": ${hasSelect}`);
  
  console.log(`\n[5/5] Looking for specific booking-related elements...`);
  
  // Check for various possible booking triggers
  const selectors = [
    'button:has-text("Reserve")',
    'button:has-text("Book")',
    'button:has-text("Select")',
    '[data-testid*="book"]',
    '[data-testid*="reserve"]',
    '[class*="booking"]',
    '[class*="reserve"]'
  ];
  
  for (const selector of selectors) {
    try {
      const count = await page.locator(selector).count();
      if (count > 0) {
        console.log(`  ✓ Found ${count} elements matching: ${selector}`);
        const first = page.locator(selector).first();
        const text = await first.textContent();
        console.log(`    First element text: "${text}"`);
      }
    } catch (e) {
      // Selector not found, skip
    }
  }
  
  console.log(`\n[DONE] Exploration complete. Check screenshot for visual reference.`);
  
  await page.waitForTimeout(2000);
  await browser.close();
})();
SCRIPT

# Run the script
HOTEL_ID="$HOTEL_ID" node /tmp/explore_hotel_${TIMESTAMP}.js

echo ""
echo "========================================="
echo " EXPLORATION COMPLETE"
echo "========================================="
echo "Screenshot: $SCREENSHOT_DIR/hotel_detail_page.png"
