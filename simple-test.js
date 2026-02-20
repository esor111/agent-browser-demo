/**
 * Simple Agent Browser Test
 * Tests basic functionality step by step
 */

const { exec } = require('child_process');
const { promisify } = require('util');
const execAsync = promisify(exec);

async function test() {
  console.log('🧪 Testing Agent Browser...\n');

  try {
    // Test 1: Navigate
    console.log('1️⃣ Navigating to example.com...');
    await execAsync('npx agent-browser goto https://example.com');
    console.log('✅ Navigation successful\n');

    // Test 2: Get page title
    console.log('2️⃣ Getting page info...');
    const { stdout } = await execAsync('npx agent-browser info');
    console.log(stdout);
    console.log('✅ Got page info\n');

    // Test 3: Take screenshot
    console.log('3️⃣ Taking screenshot...');
    await execAsync('npx agent-browser screenshot test-screenshot.png');
    console.log('✅ Screenshot saved to test-screenshot.png\n');

    // Test 4: Get snapshot
    console.log('4️⃣ Getting page snapshot...');
    const snapshot = await execAsync('npx agent-browser snapshot --compact');
    console.log(snapshot.stdout.substring(0, 500) + '...\n');
    console.log('✅ Got page snapshot\n');

    console.log('🎉 All tests passed! Agent Browser is working correctly.\n');
    
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    process.exit(1);
  }
}

test();
