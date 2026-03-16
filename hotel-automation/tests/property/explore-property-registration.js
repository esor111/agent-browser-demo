import { chromium } from 'playwright';

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  console.log('\n========================================');
  console.log(' PROPERTY REGISTRATION FLOW EXPLORATION');
  console.log('========================================\n');
  
  console.log('[1/10] Starting exploration of property registration...');
  
  // First, let's check what registration options are available
  console.log('\n[2/10] Checking homepage for registration links...');
  await page.goto('http://localhost:3001', { waitUntil: 'networkidle', timeout: 30000 });
  await page.waitForTimeout(2000);
  
  const bodyText = await page.textContent('body');
  const hasListProperty = bodyText.includes('List Property') || bodyText.includes('List Your Property');
  const hasRegister = bodyText.includes('Register') || bodyText.includes('Sign Up');
  const hasOwner = bodyText.includes('Owner') || bodyText.includes('Hotel Owner');
  
  console.log(`  Has "List Property": ${hasListProperty}`);
  console.log(`  Has "Register": ${hasRegister}`);
  console.log(`  Has "Owner": ${hasOwner}`);
  
  await page.screenshot({ path: './frontend-results/screenshots/prop_01_homepage.png', fullPage: true });
  
  // Look for registration/list property buttons
  console.log('\n[3/10] Looking for property registration buttons...');
  const buttons = await page.$$('button, a');
  let registrationLinks = [];
  
  for (const btn of buttons) {
    const text = await btn.textContent();
    const href = await btn.getAttribute('href');
    if (text && (text.includes('List') || text.includes('Register') || text.includes('Owner'))) {
      registrationLinks.push({ text: text.trim(), href });
      console.log(`  Found: "${text.trim()}" -> ${href || 'button'}`);
    }
  }
  
  // Try different registration paths
  const registrationPaths = [
    '/hotel-owner-register',
    '/register',
    '/list-your-property',
    '/owner/register',
    '/signup'
  ];
  
  console.log('\n[4/10] Testing registration paths...');
  for (const path of registrationPaths) {
    try {
      console.log(`  Testing: ${path}`);
      await page.goto(`http://localhost:3001${path}`, { waitUntil: 'domcontentloaded', timeout: 10000 });
      const title = await page.title();
      const hasForm = await page.$('form') !== null;
      const inputCount = await page.$$eval('input', inputs => inputs.length);
      
      console.log(`    Title: ${title}`);
      console.log(`    Has form: ${hasForm}`);
      console.log(`    Input fields: ${inputCount}`);
      
      if (hasForm && inputCount > 3) {
        console.log(`    ✓ FOUND REGISTRATION FORM AT: ${path}`);
        await page.screenshot({ path: `./frontend-results/screenshots/prop_02_registration_${path.replace(/\//g, '_')}.png`, fullPage: true });
        
        // Analyze the form
        console.log('\n[5/10] Analyzing registration form...');
        const inputs = await page.$$('input');
        console.log(`    Form has ${inputs.length} input fields:`);
        
        for (let i = 0; i < inputs.length; i++) {
          const type = await inputs[i].getAttribute('type');
          const placeholder = await inputs[i].getAttribute('placeholder');
          const name = await inputs[i].getAttribute('name');
          const required = await inputs[i].getAttribute('required');
          console.log(`      ${i+1}. type="${type}", placeholder="${placeholder}", name="${name}", required="${required !== null}"`);
        }
        
        // Look for submit button
        const submitBtns = await page.$$('button[type="submit"], button:has-text("Register"), button:has-text("Sign Up"), button:has-text("Create")');
        console.log(`    Submit buttons: ${submitBtns.length}`);
        
        break;
      }
    } catch (e) {
      console.log(`    ✗ Not found or error: ${e.message.substring(0, 50)}`);
    }
  }
  
  // Check if we need to login first
  console.log('\n[6/10] Checking if login is required...');
  await page.goto('http://localhost:3001/login', { waitUntil: 'domcontentloaded', timeout: 15000 });
  const loginTitle = await page.title();
  console.log(`  Login page title: ${loginTitle}`);
  
  const hasLoginForm = await page.$('form') !== null;
  if (hasLoginForm) {
    console.log('  ✓ Login form found');
    await page.screenshot({ path: './frontend-results/screenshots/prop_03_login.png', fullPage: true });
    
    // Try logging in with test credentials
    console.log('\n[7/10] Attempting login with test credentials...');
    try {
      await page.fill('input[type="email"], input[name="email"]', 'owner@test.com');
      await page.fill('input[type="password"], input[name="password"]', 'password123');
      
      const loginBtn = await page.$('button[type="submit"], button:has-text("Login"), button:has-text("Sign In")');
      if (loginBtn) {
        await loginBtn.click();
        await page.waitForTimeout(3000);
        
        const newUrl = page.url();
        console.log(`    After login URL: ${newUrl}`);
        
        if (newUrl.includes('/owner') || newUrl.includes('/dashboard')) {
          console.log('    ✓ Login successful - redirected to owner area');
          await page.screenshot({ path: './frontend-results/screenshots/prop_04_after_login.png', fullPage: true });
          
          // Now explore the owner dashboard
          console.log('\n[8/10] Exploring owner dashboard...');
          const dashboardText = await page.textContent('body');
          const hasProperties = dashboardText.includes('Properties') || dashboardText.includes('Property');
          const hasRooms = dashboardText.includes('Rooms') || dashboardText.includes('Room');
          const hasAddProperty = dashboardText.includes('Add Property') || dashboardText.includes('New Property');
          
          console.log(`    Has Properties section: ${hasProperties}`);
          console.log(`    Has Rooms section: ${hasRooms}`);
          console.log(`    Has Add Property: ${hasAddProperty}`);
          
          // Look for navigation or property management options
          const navLinks = await page.$$('a, button');
          console.log('    Available navigation options:');
          for (const link of navLinks) {
            const text = await link.textContent();
            const href = await link.getAttribute('href');
            if (text && text.trim() && (text.includes('Property') || text.includes('Room') || text.includes('Add') || text.includes('Create'))) {
              console.log(`      "${text.trim()}" -> ${href || 'button'}`);
            }
          }
        }
      }
    } catch (e) {
      console.log(`    ✗ Login failed: ${e.message}`);
    }
  }
  
  // Check for property creation/management pages
  console.log('\n[9/10] Checking property management pages...');
  const propertyPaths = [
    '/owner/properties',
    '/owner/properties/new',
    '/owner/properties/add',
    '/owner/dashboard',
    '/properties/create',
    '/properties/new'
  ];
  
  for (const path of propertyPaths) {
    try {
      console.log(`  Testing: ${path}`);
      await page.goto(`http://localhost:3001${path}`, { waitUntil: 'domcontentloaded', timeout: 10000 });
      const title = await page.title();
      const hasForm = await page.$('form') !== null;
      const hasPropertyFields = await page.$('input[name*="property"], input[placeholder*="property" i], input[placeholder*="hotel" i]') !== null;
      
      console.log(`    Title: ${title}`);
      console.log(`    Has form: ${hasForm}`);
      console.log(`    Has property fields: ${hasPropertyFields}`);
      
      if (hasForm || hasPropertyFields) {
        console.log(`    ✓ FOUND PROPERTY MANAGEMENT AT: ${path}`);
        await page.screenshot({ path: `./frontend-results/screenshots/prop_05_property_${path.replace(/\//g, '_')}.png`, fullPage: true });
      }
    } catch (e) {
      console.log(`    ✗ Not accessible: ${e.message.substring(0, 30)}`);
    }
  }
  
  console.log('\n[10/10] Exploration complete!');
  console.log('\n  Browser will stay open for 30 seconds for manual inspection...');
  await page.waitForTimeout(30000);
  
  await browser.close();
  console.log('\n✓ Property registration exploration finished');
  console.log('\nScreenshots saved to: ./frontend-results/screenshots/prop_*.png');
})();