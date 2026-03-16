import { chromium } from 'playwright';

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  console.log('\n========================================');
  console.log(' QUICK PROPERTY REGISTRATION EXPLORATION');
  console.log('========================================\n');
  
  // From the HTML, I can see there's a "List Your Property" link to /hotel-owner-register
  console.log('[1/8] Testing hotel owner registration page...');
  
  try {
    await page.goto('http://localhost:3001/hotel-owner-register', { waitUntil: 'domcontentloaded', timeout: 15000 });
    const title = await page.title();
    console.log(`  ✓ Page loaded: ${title}`);
    
    await page.screenshot({ path: './frontend-results/screenshots/prop_01_registration.png', fullPage: true });
    
    // Check if it's a registration form
    const hasForm = await page.$('form') !== null;
    const inputCount = await page.$$eval('input', inputs => inputs.length);
    console.log(`  Has form: ${hasForm}`);
    console.log(`  Input fields: ${inputCount}`);
    
    if (hasForm && inputCount > 3) {
      console.log('  ✓ FOUND REGISTRATION FORM!');
      
      console.log('\n[2/8] Analyzing registration form fields...');
      const inputs = await page.$$('input');
      for (let i = 0; i < inputs.length; i++) {
        const type = await inputs[i].getAttribute('type');
        const placeholder = await inputs[i].getAttribute('placeholder');
        const name = await inputs[i].getAttribute('name');
        console.log(`    ${i+1}. type="${type}", placeholder="${placeholder}", name="${name}"`);
      }
    }
  } catch (e) {
    console.log(`  ✗ Registration page error: ${e.message}`);
  }
  
  console.log('\n[3/8] Testing login page...');
  try {
    await page.goto('http://localhost:3001/login', { waitUntil: 'domcontentloaded', timeout: 10000 });
    const title = await page.title();
    console.log(`  ✓ Login page: ${title}`);
    
    await page.screenshot({ path: './frontend-results/screenshots/prop_02_login.png', fullPage: true });
    
    // Try logging in with seeded credentials
    console.log('\n[4/8] Attempting login with seeded credentials...');
    
    // From the seed data, we know there's a user with phone: 9800000001, password: password123
    const emailInput = await page.$('input[type="email"], input[name="email"]');
    const phoneInput = await page.$('input[type="tel"], input[name="phone"]');
    const passwordInput = await page.$('input[type="password"]');
    
    if (phoneInput && passwordInput) {
      console.log('  Using phone login...');
      await phoneInput.fill('9800000001');
      await passwordInput.fill('password123');
    } else if (emailInput && passwordInput) {
      console.log('  Using email login...');
      await emailInput.fill('owner@test.com');
      await passwordInput.fill('password123');
    }
    
    const loginBtn = await page.$('button[type="submit"], button:has-text("Login"), button:has-text("Sign In")');
    if (loginBtn) {
      await loginBtn.click();
      await page.waitForTimeout(3000);
      
      const newUrl = page.url();
      console.log(`  After login URL: ${newUrl}`);
      
      if (newUrl.includes('/owner') || newUrl.includes('/dashboard')) {
        console.log('  ✓ LOGIN SUCCESSFUL!');
        await page.screenshot({ path: './frontend-results/screenshots/prop_03_dashboard.png', fullPage: true });
        
        console.log('\n[5/8] Exploring owner dashboard...');
        const bodyText = await page.textContent('body');
        
        // Look for property management options
        const hasProperties = bodyText.includes('Properties') || bodyText.includes('Property');
        const hasRooms = bodyText.includes('Rooms') || bodyText.includes('Room');
        const hasAddProperty = bodyText.includes('Add Property') || bodyText.includes('New Property') || bodyText.includes('Create Property');
        
        console.log(`    Has Properties: ${hasProperties}`);
        console.log(`    Has Rooms: ${hasRooms}`);
        console.log(`    Has Add Property: ${hasAddProperty}`);
        
        // Look for navigation links
        console.log('\n[6/8] Finding navigation options...');
        const links = await page.$$('a, button');
        const navOptions = [];
        
        for (const link of links) {
          const text = await link.textContent();
          const href = await link.getAttribute('href');
          if (text && text.trim() && (
            text.includes('Property') || text.includes('Room') || 
            text.includes('Add') || text.includes('Create') ||
            text.includes('Dashboard') || text.includes('Booking')
          )) {
            navOptions.push({ text: text.trim(), href });
          }
        }
        
        console.log('    Available options:');
        navOptions.forEach((option, i) => {
          console.log(`      ${i+1}. "${option.text}" -> ${option.href || 'button'}`);
        });
        
        // Try to navigate to property management
        console.log('\n[7/8] Testing property management pages...');
        const propertyPaths = [
          '/owner/properties',
          '/owner/rooms',
          '/owner/dashboard',
          '/properties',
          '/rooms'
        ];
        
        for (const path of propertyPaths) {
          try {
            console.log(`    Testing: ${path}`);
            await page.goto(`http://localhost:3001${path}`, { waitUntil: 'domcontentloaded', timeout: 8000 });
            const pageTitle = await page.title();
            const hasContent = await page.$('main, .container, .content') !== null;
            console.log(`      ✓ ${pageTitle} (has content: ${hasContent})`);
            
            if (hasContent) {
              await page.screenshot({ path: `./frontend-results/screenshots/prop_04_${path.replace(/\//g, '_')}.png`, fullPage: true });
            }
          } catch (e) {
            console.log(`      ✗ ${path}: ${e.message.substring(0, 30)}`);
          }
        }
      } else {
        console.log('  ✗ Login failed or redirected elsewhere');
      }
    }
  } catch (e) {
    console.log(`  ✗ Login error: ${e.message}`);
  }
  
  console.log('\n[8/8] Exploration complete!');
  console.log('\n  Browser will stay open for 20 seconds...');
  await page.waitForTimeout(20000);
  
  await browser.close();
  console.log('\n✓ Property exploration finished');
  console.log('Screenshots saved to: ./frontend-results/screenshots/prop_*.png');
})();