import { chromium } from 'playwright';

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  console.log('\n========================================');
  console.log(' DEBUG HOTELS PAGE STRUCTURE');
  console.log('========================================\n');
  
  try {
    console.log('Loading hotels page...');
    await page.goto('http://localhost:3001/hotels', { waitUntil: 'domcontentloaded', timeout: 15000 });
    
    // Take screenshot
    await page.screenshot({ path: './frontend-results/screenshots/debug_hotels_page.png', fullPage: true });
    
    // Get page title
    const title = await page.title();
    console.log(`Page title: ${title}`);
    
    // Get all links
    const allLinks = await page.evaluate(() => {
      return Array.from(document.querySelectorAll('a')).map(link => ({
        href: link.getAttribute('href'),
        text: link.textContent?.trim().substring(0, 50),
        classes: link.className
      }));
    });
    
    console.log(`\nAll links found (${allLinks.length}):`);
    allLinks.forEach((link, i) => {
      if (link.href && link.text) {
        console.log(`  ${i+1}. "${link.text}" -> ${link.href}`);
      }
    });
    
    // Get page content structure
    const pageStructure = await page.evaluate(() => {
      return {
        hasMain: document.querySelector('main') !== null,
        hasContainer: document.querySelector('.container, .content') !== null,
        hasHotelCards: document.querySelectorAll('.hotel, .property, .card').length,
        hasImages: document.querySelectorAll('img').length,
        bodyText: document.body.textContent.substring(0, 500)
      };
    });
    
    console.log('\nPage structure:');
    Object.entries(pageStructure).forEach(([key, value]) => {
      console.log(`  ${key}: ${value}`);
    });
    
    // Look for specific hotel content
    const hotelContent = await page.evaluate(() => {
      const text = document.body.textContent;
      return {
        hasYakYeti: text.includes('Yak & Yeti'),
        hasTempleTree: text.includes('Temple Tree'),
        hasBarahi: text.includes('Barahi'),
        hasClubHimalaya: text.includes('Club Himalaya'),
        hasKathmandu: text.includes('Kathmandu'),
        hasPokhara: text.includes('Pokhara'),
        hasNPR: text.includes('NPR'),
        hasStars: text.includes('⭐') || text.includes('star')
      };
    });
    
    console.log('\nHotel content check:');
    Object.entries(hotelContent).forEach(([key, value]) => {
      console.log(`  ${key}: ${value ? '✓' : '✗'}`);
    });
    
    // Check if we need to wait for content to load
    console.log('\nWaiting for dynamic content...');
    await page.waitForTimeout(5000);
    
    // Check again after waiting
    const afterWait = await page.evaluate(() => {
      return {
        linkCount: document.querySelectorAll('a').length,
        hotelLinks: document.querySelectorAll('a[href*="/hotels/"]').length,
        cardElements: document.querySelectorAll('.card, .hotel, .property').length,
        hasLoadingIndicator: document.querySelector('.loading, .spinner') !== null
      };
    });
    
    console.log('\nAfter waiting:');
    Object.entries(afterWait).forEach(([key, value]) => {
      console.log(`  ${key}: ${value}`);
    });
    
    await page.screenshot({ path: './frontend-results/screenshots/debug_hotels_after_wait.png', fullPage: true });
    
    // Try to find any clickable elements that might lead to hotel details
    const clickableElements = await page.evaluate(() => {
      const elements = Array.from(document.querySelectorAll('div, span, button, a'));
      return elements
        .filter(el => {
          const text = el.textContent?.toLowerCase() || '';
          return text.includes('hotel') || text.includes('yak') || text.includes('temple') || text.includes('view');
        })
        .slice(0, 10)
        .map(el => ({
          tagName: el.tagName,
          text: el.textContent?.substring(0, 50),
          href: el.getAttribute('href'),
          onclick: el.getAttribute('onclick'),
          classes: el.className
        }));
    });
    
    console.log('\nClickable hotel elements:');
    clickableElements.forEach((el, i) => {
      console.log(`  ${i+1}. [${el.tagName}] "${el.text}" -> ${el.href || el.onclick || 'no action'}`);
    });
    
    console.log('\nBrowser will stay open for manual inspection...');
    await page.waitForTimeout(15000);
    
  } catch (error) {
    console.error('Debug error:', error.message);
  } finally {
    await browser.close();
  }
  
  console.log('\n✓ Hotels page debug complete');
})();