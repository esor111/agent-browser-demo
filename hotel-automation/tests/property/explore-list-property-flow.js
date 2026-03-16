import { chromium } from 'playwright';

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  console.log('\n========================================');
  console.log(' PROPERTY LISTING FLOW EXPLORATION');
  console.log('========================================\n');
  
  try {
    // Test the actual property listing flow
    console.log('[1/6] Testing /list-your-property path...');
    await page.goto('http://localhost:3001/list-your-property', { waitUntil: 'domcontentloaded', timeout: 15000 });
    
    const title = await page.title();
    console.log(`  Page title: ${title}`);
    
    if (title.includes('404')) {
      console.log('  ✗ /list-your-property returns 404');
    } else {
      console.log('  ✓ Page loaded successfully');
      await page.screenshot({ path: './frontend-results/screenshots/list_01_initial.png', fullPage: true });
      
      // Analyze the page content
      const hasForm = await page.$('form') !== null;
      const inputCount = await page.$$eval('input', inputs => inputs.length);
      const buttonCount = await page.$$eval('button', buttons => buttons.length);
      
      console.log(`  Has form: ${hasForm}`);
      console.log(`  Input fields: ${inputCount}`);
      console.log(`  Buttons: ${buttonCount}`);
      
      if (hasForm) {
        console.log('\n[2/6] Analyzing form structure...');
        
        // Get form fields
        const formFields = await page.evaluate(() => {
          const inputs = Array.from(document.querySelectorAll('input, select, textarea'));
          return inputs.map(input => ({
            type: input.type || input.tagName.toLowerCase(),
            name: input.name,
            placeholder: input.placeholder,
            required: input.required,
            id: input.id
          }));
        });
        
        console.log('  Form fields:');
        formFields.forEach((field, i) => {
          console.log(`    ${i+1}. ${field.type} - name:"${field.name}" placeholder:"${field.placeholder}" required:${field.required}`);
        });
        
        // Get buttons
        const buttons = await page.evaluate(() => {
          return Array.from(document.querySelectorAll('button')).map(btn => ({
            text: btn.textContent?.trim(),
            type: btn.type,
            disabled: btn.disabled
          }));
        });
        
        console.log('  Buttons:');
        buttons.forEach((btn, i) => {
          console.log(`    ${i+1}. "${btn.text}" (type: ${btn.type}, disabled: ${btn.disabled})`);
        });
      }
    }
    
    console.log('\n[3/6] Testing existing owner flow with property creation...');
    
    // Login first
    await page.goto('http://localhost:3001/login', { waitUntil: 'domcontentloaded', timeout: 10000 });
    
    const phoneInput = await page.$('input[type="tel"], input[name="phone"], input[placeholder*="phone"]');
    const passwordInput = await page.$('input[type="password"]');
    
    if (phoneInput && passwordInput) {
      await phoneInput.fill('9800000001');
      await passwordInput.fill('password123');
      
      const loginBtn = await page.$('button[type="submit"], button:has-text("Login"), button:has-text("Sign In")');
      if (loginBtn) {
        await loginBtn.click();
        await page.waitForTimeout(3000);
        console.log('  ✓ Logged in successfully');
      }
    }
    
    console.log('\n[4/6] Exploring rooms page for property setup...');
    await page.goto('http://localhost:3001/owner/rooms', { waitUntil: 'domcontentloaded', timeout: 10000 });
    await page.screenshot({ path: './frontend-results/screenshots/list_02_rooms_page.png', fullPage: true });
    
    // Check for room types and room creation
    const roomsContent = await page.textContent('body');
    console.log('  Rooms page analysis:');
    console.log(`    Has "Room Types": ${roomsContent.includes('Room Types')}`);
    console.log(`    Has "All Rooms": ${roomsContent.includes('All Rooms')}`);
    console.log(`    Has "New Room": ${roomsContent.includes('New Room')}`);
    console.log(`    Has "New Room Type": ${roomsContent.includes('New Room Type')}`);
    
    console.log('\n[5/6] Testing room type creation...');
    
    // Try to click Room Types tab
    const roomTypesTab = await page.$('a:has-text("Room Types"), button:has-text("Room Types")');
    if (roomTypesTab) {
      await roomTypesTab.click();
      await page.waitForTimeout(2000);
      await page.screenshot({ path: './frontend-results/screenshots/list_03_room_types.png', fullPage: true });
      console.log('  ✓ Clicked Room Types tab');
      
      // Look for New Room Type button
      const newRoomTypeBtn = await page.$('button:has-text("New Room Type"), a:has-text("New Room Type")');
      if (newRoomTypeBtn) {
        await newRoomTypeBtn.click();
        await page.waitForTimeout(2000);
        await page.screenshot({ path: './frontend-results/screenshots/list_04_new_room_type.png', fullPage: true });
        console.log('  ✓ Opened New Room Type form');
        
        // Analyze the room type form
        const roomTypeInputs = await page.$$eval('input', inputs => 
          inputs.map(input => ({
            type: input.type,
            placeholder: input.placeholder,
            name: input.name
          }))
        );
        
        console.log('  Room Type form fields:');
        roomTypeInputs.forEach((input, i) => {
          console.log(`    ${i+1}. ${input.type} - "${input.placeholder}" (name: ${input.name})`);
        });
      } else {
        console.log('  ✗ No New Room Type button found');
      }
    } else {
      console.log('  ✗ No Room Types tab found');
    }
    
    console.log('\n[6/6] Summary of findings...');
    
    await page.waitForTimeout(10000);
    
  } catch (error) {
    console.error('Exploration error:', error.message);
  } finally {
    await browser.close();
  }
  
  console.log('\n✓ Property listing flow exploration complete');
})();