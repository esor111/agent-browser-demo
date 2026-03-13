import { chromium } from 'playwright';

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  console.log('\n========================================');
  console.log(' COMPREHENSIVE PROPERTY FLOW DISCOVERY');
  console.log('========================================\n');
  
  try {
    // PHASE 1: Discover registration/onboarding flow
    console.log('[PHASE 1] Discovering registration flow...');
    
    // Check homepage for registration links
    console.log('  [1.1] Analyzing homepage...');
    await page.goto('http://localhost:3001', { waitUntil: 'domcontentloaded', timeout: 15000 });
    await page.screenshot({ path: './frontend-results/screenshots/discovery_01_homepage.png', fullPage: true });
    
    // Look for registration/signup links
    const registrationLinks = await page.evaluate(() => {
      const links = Array.from(document.querySelectorAll('a, button'));
      return links
        .map(link => ({
          text: link.textContent?.trim(),
          href: link.getAttribute('href'),
          onclick: link.getAttribute('onclick')
        }))
        .filter(link => 
          link.text && (
            link.text.toLowerCase().includes('register') ||
            link.text.toLowerCase().includes('sign up') ||
            link.text.toLowerCase().includes('join') ||
            link.text.toLowerCase().includes('list your property') ||
            link.text.toLowerCase().includes('become') ||
            link.text.toLowerCase().includes('owner')
          )
        );
    });
    
    console.log('    Registration-related links found:');
    registrationLinks.forEach((link, i) => {
      console.log(`      ${i+1}. "${link.text}" -> ${link.href || link.onclick || 'button'}`);
    });
    
    // Try different registration paths
    const registrationPaths = [
      '/register',
      '/signup', 
      '/owner/register',
      '/hotel-owner-register',
      '/property-owner-register',
      '/join',
      '/onboard',
      '/owner/onboard'
    ];
    
    console.log('\n  [1.2] Testing registration paths...');
    for (const path of registrationPaths) {
      try {
        console.log(`    Testing: ${path}`);
        await page.goto(`http://localhost:3001${path}`, { waitUntil: 'domcontentloaded', timeout: 8000 });
        const title = await page.title();
        const hasForm = await page.$('form') !== null;
        const inputCount = await page.$$eval('input', inputs => inputs.length);
        
        if (!title.includes('404') && (hasForm || inputCount > 0)) {
          console.log(`      ✓ FOUND: ${title} (form: ${hasForm}, inputs: ${inputCount})`);
          await page.screenshot({ path: `./frontend-results/screenshots/discovery_reg_${path.replace(/\//g, '_')}.png`, fullPage: true });
        } else {
          console.log(`      ✗ ${path}: ${title.includes('404') ? '404' : 'No form'}`);
        }
      } catch (e) {
        console.log(`      ✗ ${path}: ${e.message.substring(0, 30)}`);
      }
    }
    
    // PHASE 2: Login and explore existing owner flow
    console.log('\n[PHASE 2] Exploring existing owner dashboard...');
    
    console.log('  [2.1] Logging in...');
    await page.goto('http://localhost:3001/login', { waitUntil: 'domcontentloaded', timeout: 10000 });
    
    // Fill login form
    const phoneInput = await page.$('input[type="tel"], input[name="phone"], input[placeholder*="phone"]');
    const passwordInput = await page.$('input[type="password"]');
    
    if (phoneInput && passwordInput) {
      await phoneInput.fill('9800000001');
      await passwordInput.fill('password123');
      
      const loginBtn = await page.$('button[type="submit"], button:has-text("Login"), button:has-text("Sign In")');
      if (loginBtn) {
        await loginBtn.click();
        await page.waitForTimeout(3000);
        console.log(`    ✓ Logged in, URL: ${page.url()}`);
      }
    }
    
    // PHASE 3: Comprehensive dashboard exploration
    console.log('\n  [2.2] Exploring dashboard navigation...');
    await page.screenshot({ path: './frontend-results/screenshots/discovery_02_dashboard.png', fullPage: true });
    
    // Get all navigation elements
    const navElements = await page.evaluate(() => {
      const elements = Array.from(document.querySelectorAll('a, button, [role="button"]'));
      return elements
        .map(el => ({
          text: el.textContent?.trim(),
          href: el.getAttribute('href'),
          classes: el.className,
          role: el.getAttribute('role'),
          type: el.tagName
        }))
        .filter(el => el.text && el.text.length > 0 && el.text.length < 50)
        .slice(0, 30); // Limit to avoid too much output
    });
    
    console.log('    Available navigation options:');
    navElements.forEach((el, i) => {
      console.log(`      ${i+1}. [${el.type}] "${el.text}" -> ${el.href || 'button'}`);
    });
    
    // PHASE 4: Test property management paths
    console.log('\n  [2.3] Testing property management paths...');
    const propertyPaths = [
      '/owner/dashboard',
      '/owner/properties', 
      '/owner/property',
      '/owner/hotels',
      '/owner/rooms',
      '/owner/bookings',
      '/owner/settings',
      '/owner/profile',
      '/dashboard',
      '/properties',
      '/property',
      '/hotels',
      '/rooms'
    ];
    
    for (const path of propertyPaths) {
      try {
        console.log(`    Testing: ${path}`);
        await page.goto(`http://localhost:3001${path}`, { waitUntil: 'domcontentloaded', timeout: 8000 });
        const title = await page.title();
        const hasContent = await page.$('main, .container, .content, [role="main"]') !== null;
        const bodyText = await page.textContent('body');
        const hasPropertyContent = bodyText.includes('Property') || bodyText.includes('Hotel') || bodyText.includes('Room');
        
        if (!title.includes('404') && (hasContent || hasPropertyContent)) {
          console.log(`      ✓ ${path}: "${title}" (content: ${hasContent}, property-related: ${hasPropertyContent})`);
          await page.screenshot({ path: `./frontend-results/screenshots/discovery_${path.replace(/\//g, '_')}.png`, fullPage: true });
          
          // If this looks like a property management page, analyze it further
          if (hasPropertyContent) {
            const buttons = await page.evaluate(() => {
              return Array.from(document.querySelectorAll('button, a'))
                .map(btn => btn.textContent?.trim())
                .filter(text => text && (
                  text.includes('Add') || text.includes('New') || text.includes('Create') ||
                  text.includes('Property') || text.includes('Room') || text.includes('Hotel')
                ))
                .slice(0, 10);
            });
            
            if (buttons.length > 0) {
              console.log(`        Action buttons: ${buttons.join(', ')}`);
            }
          }
        } else {
          console.log(`      ✗ ${path}: ${title.includes('404') ? '404' : 'No content'}`);
        }
      } catch (e) {
        console.log(`      ✗ ${path}: Error`);
      }
    }
    
    // PHASE 5: Check if user already has properties
    console.log('\n[PHASE 3] Analyzing current user property status...');
    
    // Go to rooms page to see if user has properties
    await page.goto('http://localhost:3001/owner/rooms', { waitUntil: 'domcontentloaded', timeout: 10000 });
    await page.screenshot({ path: './frontend-results/screenshots/discovery_03_rooms_analysis.png', fullPage: true });
    
    const roomsPageContent = await page.textContent('body');
    const hasRooms = roomsPageContent.includes('Room Number') || roomsPageContent.includes('Room Type');
    const hasNoRoomsMessage = roomsPageContent.includes('No rooms') || roomsPageContent.includes('empty');
    const hasAddRoomButton = roomsPageContent.includes('New Room') || roomsPageContent.includes('Add Room');
    
    console.log('  Current property status:');
    console.log(`    Has existing rooms: ${hasRooms}`);
    console.log(`    Has "no rooms" message: ${hasNoRoomsMessage}`);
    console.log(`    Has add room button: ${hasAddRoomButton}`);
    
    // PHASE 6: Look for onboarding or setup flows
    console.log('\n[PHASE 4] Looking for onboarding/setup flows...');
    
    // Check if there are any setup or onboarding prompts
    const onboardingIndicators = await page.evaluate(() => {
      const text = document.body.textContent.toLowerCase();
      return {
        hasSetup: text.includes('setup') || text.includes('get started'),
        hasOnboarding: text.includes('onboard') || text.includes('welcome'),
        hasPropertySetup: text.includes('property setup') || text.includes('add your property'),
        hasCompleteProfile: text.includes('complete') && text.includes('profile')
      };
    });
    
    console.log('  Onboarding indicators:');
    Object.entries(onboardingIndicators).forEach(([key, value]) => {
      console.log(`    ${key}: ${value}`);
    });
    
    // PHASE 7: Test room creation flow (if available)
    console.log('\n[PHASE 5] Testing room creation flow...');
    
    // Look for room creation buttons
    const roomButtons = await page.$$('button, a');
    let foundRoomCreation = false;
    
    for (const button of roomButtons) {
      const text = await button.textContent();
      if (text && (text.includes('New Room') || text.includes('Add Room') || text.includes('Create Room'))) {
        console.log(`  Found room creation button: "${text}"`);
        try {
          await button.click();
          await page.waitForTimeout(2000);
          await page.screenshot({ path: './frontend-results/screenshots/discovery_04_room_creation.png', fullPage: true });
          foundRoomCreation = true;
          break;
        } catch (e) {
          console.log(`    Error clicking: ${e.message}`);
        }
      }
    }
    
    if (!foundRoomCreation) {
      console.log('  No room creation flow found');
    }
    
    console.log('\n[PHASE 6] Discovery complete!');
    console.log('  Screenshots saved to: ./frontend-results/screenshots/discovery_*.png');
    console.log('  Browser will stay open for 15 seconds for manual inspection...');
    
    await page.waitForTimeout(15000);
    
  } catch (error) {
    console.error('Discovery error:', error.message);
  } finally {
    await browser.close();
  }
  
  console.log('\n✓ Comprehensive property flow discovery finished');
})();