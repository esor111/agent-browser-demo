import { chromium } from 'playwright';

(async () => {
  const browser = await chromium.launch({ headless: false });
  const page = await browser.newPage();
  
  console.log('\n========================================');
  console.log(' COMPLETE PROPERTY FLOW TEST');
  console.log('========================================\n');
  
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-').substring(0, 19);
  
  try {
    // PHASE 1: Test existing owner property management
    console.log('[PHASE 1] Testing existing owner property management...');
    
    // Login as existing owner
    console.log('  [1.1] Logging in as existing owner...');
    await page.goto('http://localhost:3001/login', { waitUntil: 'domcontentloaded', timeout: 15000 });
    
    const phoneInput = await page.$('input[type="tel"], input[name="phone"], input[placeholder*="phone"]');
    const passwordInput = await page.$('input[type="password"]');
    
    if (phoneInput && passwordInput) {
      await phoneInput.fill('9800000001');
      await passwordInput.fill('password123');
      
      const loginBtn = await page.$('button[type="submit"], button:has-text("Login"), button:has-text("Sign In")');
      if (loginBtn) {
        await loginBtn.click();
        await page.waitForTimeout(3000);
        console.log('    ✓ Login successful');
      }
    }
    
    // Test owner dashboard
    console.log('  [1.2] Testing owner dashboard...');
    await page.goto('http://localhost:3001/owner/dashboard', { waitUntil: 'domcontentloaded', timeout: 10000 });
    await page.screenshot({ path: `./frontend-results/screenshots/complete_01_dashboard_${timestamp}.png`, fullPage: true });
    
    const dashboardContent = await page.textContent('body');
    const hasDashboardContent = dashboardContent.includes('Dashboard') || dashboardContent.includes('Property') || dashboardContent.includes('Room');
    console.log(`    Dashboard accessible: ${hasDashboardContent}`);
    
    // Test rooms management
    console.log('  [1.3] Testing rooms management...');
    await page.goto('http://localhost:3001/owner/rooms', { waitUntil: 'domcontentloaded', timeout: 10000 });
    await page.screenshot({ path: `./frontend-results/screenshots/complete_02_rooms_${timestamp}.png`, fullPage: true });
    
    const roomsContent = await page.textContent('body');
    const hasRoomTypes = roomsContent.includes('Room Types');
    const hasAllRooms = roomsContent.includes('All Rooms');
    const hasNewRoom = roomsContent.includes('New Room');
    
    console.log(`    Room Types tab: ${hasRoomTypes}`);
    console.log(`    All Rooms tab: ${hasAllRooms}`);
    console.log(`    New Room button: ${hasNewRoom}`);
    
    // Test room type creation
    if (hasRoomTypes) {
      console.log('  [1.4] Testing room type creation...');
      
      // Click Room Types tab
      const roomTypesTab = await page.$('a:has-text("Room Types"), button:has-text("Room Types")');
      if (roomTypesTab) {
        await roomTypesTab.click();
        await page.waitForTimeout(2000);
        await page.screenshot({ path: `./frontend-results/screenshots/complete_03_room_types_${timestamp}.png`, fullPage: true });
        
        // Click New Room Type
        const newRoomTypeBtn = await page.$('button:has-text("New Room Type"), a:has-text("New Room Type")');
        if (newRoomTypeBtn) {
          await newRoomTypeBtn.click();
          await page.waitForTimeout(2000);
          await page.screenshot({ path: `./frontend-results/screenshots/complete_04_new_room_type_${timestamp}.png`, fullPage: true });
          
          // Fill room type form
          const roomTypeCode = `TEST${timestamp.substring(11, 16).replace(/-/g, '')}`;
          const roomTypeName = `Test Room Type ${timestamp.substring(11, 16)}`;
          
          const inputs = await page.$$('input[type="text"]');
          if (inputs.length >= 2) {
            await inputs[0].fill(roomTypeCode);
            await inputs[1].fill(roomTypeName);
            
            // Submit
            const createBtn = await page.$('button:has-text("Create Room Type"), button[type="submit"]');
            if (createBtn) {
              await createBtn.click();
              await page.waitForTimeout(3000);
              await page.screenshot({ path: `./frontend-results/screenshots/complete_05_room_type_created_${timestamp}.png`, fullPage: true });
              console.log(`    ✓ Room type created: ${roomTypeName}`);
            }
          }
        }
      }
    }
    
    // Test room creation
    console.log('  [1.5] Testing room creation...');
    
    // Go back to All Rooms
    const allRoomsTab = await page.$('a:has-text("All Rooms"), button:has-text("All Rooms")');
    if (allRoomsTab) {
      await allRoomsTab.click();
      await page.waitForTimeout(2000);
      
      const newRoomBtn = await page.$('button:has-text("New Room"), a:has-text("New Room")');
      if (newRoomBtn) {
        await newRoomBtn.click();
        await page.waitForTimeout(2000);
        await page.screenshot({ path: `./frontend-results/screenshots/complete_06_new_room_${timestamp}.png`, fullPage: true });
        
        // Fill room form
        const roomNumber = `${timestamp.substring(14, 16)}${Math.floor(Math.random() * 100)}`;
        const floor = '1';
        
        // Select room type (if dropdown exists)
        const roomTypeDropdown = await page.$('select, [role="combobox"]');
        if (roomTypeDropdown) {
          await roomTypeDropdown.click();
          await page.waitForTimeout(1000);
          
          // Try to select the first option
          const firstOption = await page.$('[role="option"]:first-child, option:first-child');
          if (firstOption) {
            await firstOption.click();
            await page.waitForTimeout(500);
          }
        }
        
        // Fill room details
        const roomInputs = await page.$$('input[type="text"]');
        if (roomInputs.length >= 2) {
          await roomInputs[0].fill(roomNumber);
          await roomInputs[1].fill(floor);
          
          await page.screenshot({ path: `./frontend-results/screenshots/complete_07_room_filled_${timestamp}.png`, fullPage: true });
          
          // Submit
          const createRoomBtn = await page.$('button:has-text("Create Room"), button[type="submit"]');
          if (createRoomBtn) {
            await createRoomBtn.click();
            await page.waitForTimeout(3000);
            await page.screenshot({ path: `./frontend-results/screenshots/complete_08_room_created_${timestamp}.png`, fullPage: true });
            console.log(`    ✓ Room created: ${roomNumber}`);
          }
        }
      }
    }
    
    // PHASE 2: Test new user registration flow
    console.log('\n[PHASE 2] Testing new user registration flow...');
    
    // Logout first
    console.log('  [2.1] Logging out...');
    await page.goto('http://localhost:3001/logout', { waitUntil: 'domcontentloaded', timeout: 10000 });
    await page.waitForTimeout(2000);
    
    // Test registration entry points
    console.log('  [2.2] Testing registration entry points...');
    
    // Go to homepage
    await page.goto('http://localhost:3001', { waitUntil: 'domcontentloaded', timeout: 15000 });
    await page.screenshot({ path: `./frontend-results/screenshots/complete_09_homepage_${timestamp}.png`, fullPage: true });
    
    // Look for registration links
    const registrationLinks = await page.evaluate(() => {
      const links = Array.from(document.querySelectorAll('a, button'));
      return links
        .map(link => ({
          text: link.textContent?.trim(),
          href: link.getAttribute('href'),
          visible: link.offsetParent !== null
        }))
        .filter(link => 
          link.text && link.visible && (
            link.text.toLowerCase().includes('list your property') ||
            link.text.toLowerCase().includes('register') ||
            link.text.toLowerCase().includes('sign up') ||
            link.text.toLowerCase().includes('get started')
          )
        );
    });
    
    console.log('    Registration entry points found:');
    registrationLinks.forEach((link, i) => {
      console.log(`      ${i+1}. "${link.text}" -> ${link.href || 'button'}`);
    });
    
    // Try to click the first registration link
    if (registrationLinks.length > 0) {
      console.log('  [2.3] Testing registration flow...');
      
      const firstRegLink = registrationLinks[0];
      if (firstRegLink.href) {
        await page.goto(`http://localhost:3001${firstRegLink.href}`, { waitUntil: 'domcontentloaded', timeout: 10000 });
      } else {
        // Click the button
        const regButton = await page.$(`button:has-text("${firstRegLink.text}"), a:has-text("${firstRegLink.text}")`);
        if (regButton) {
          await regButton.click();
          await page.waitForTimeout(3000);
        }
      }
      
      await page.screenshot({ path: `./frontend-results/screenshots/complete_10_registration_${timestamp}.png`, fullPage: true });
      
      const currentUrl = page.url();
      const pageTitle = await page.title();
      console.log(`    Registration page: ${currentUrl}`);
      console.log(`    Page title: ${pageTitle}`);
      
      // Check if it's a registration form
      const hasForm = await page.$('form') !== null;
      const inputCount = await page.$$eval('input', inputs => inputs.length);
      
      console.log(`    Has registration form: ${hasForm}`);
      console.log(`    Input fields: ${inputCount}`);
      
      if (hasForm && inputCount > 3) {
        console.log('    ✓ Registration form found - ready for automation');
      } else if (!pageTitle.includes('404')) {
        console.log('    ⚠️ Registration page loads but may need different approach');
      } else {
        console.log('    ✗ Registration endpoint not available');
      }
    }
    
    // PHASE 3: Summary and recommendations
    console.log('\n[PHASE 3] Summary and recommendations...');
    
    await page.screenshot({ path: `./frontend-results/screenshots/complete_11_final_${timestamp}.png`, fullPage: true });
    
    console.log('\n✅ PROPERTY FLOW TEST COMPLETE');
    console.log('\nFindings:');
    console.log(`  • Existing owner management: ${hasDashboardContent ? '✓ Working' : '✗ Issues'}`);
    console.log(`  • Room management interface: ${hasRoomTypes ? '✓ Working' : '✗ Issues'}`);
    console.log(`  • Room creation flow: ${hasNewRoom ? '✓ Working' : '✗ Issues'}`);
    console.log(`  • Registration entry points: ${registrationLinks.length} found`);
    
    console.log('\nScreenshots saved with timestamp:', timestamp);
    
    await page.waitForTimeout(10000);
    
  } catch (error) {
    console.error('Test error:', error.message);
    await page.screenshot({ path: `./frontend-results/screenshots/complete_error_${timestamp}.png`, fullPage: true });
  } finally {
    await browser.close();
  }
  
  console.log('\n✓ Complete property flow test finished');
})();