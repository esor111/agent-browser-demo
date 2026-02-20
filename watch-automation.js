const { exec } = require('child_process');
const { promisify } = require('util');
const execAsync = promisify(exec);

const AB = '.\\node_modules\\agent-browser\\bin\\agent-browser-win32-x64.exe --headed';

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function run(cmd, description) {
  console.log(`\n${description}`);
  try {
    const { stdout } = await execAsync(`${AB} ${cmd}`);
    console.log(stdout.trim());
    return stdout.trim();
  } catch (error) {
    console.error(`❌ Error: ${error.message}`);
    throw error;
  }
}

async function main() {
  console.log('========================================');
  console.log('GITHUB AUTOMATION - WATCH IT HAPPEN!');
  console.log('========================================\n');
  console.log('A browser window will open and you will see:');
  console.log('1. Go to GitHub login');
  console.log('2. Type username');
  console.log('3. Type password');
  console.log('4. Click Sign in');
  console.log('5. Go to repositories');
  console.log('6. Extract first repo URL\n');
  console.log('Starting in 3 seconds...\n');
  
  await sleep(3000);

  try {
    // Step 1
    await run('open https://github.com/login', '[Step 1/9] Opening GitHub login page...');
    await sleep(3000);

    // Step 2
    await run('fill "@e2" "esor111"', '[Step 2/9] Typing username: esor111');
    await sleep(2000);

    // Step 3
    await run('fill "@e3" "ishwor19944"', '[Step 3/9] Typing password...');
    await sleep(2000);

    // Step 4
    await run('click "@e5"', '[Step 4/9] Clicking Sign in button...');
    console.log('Waiting for login to complete...');
    await sleep(6000);

    // Step 5
    await run('get url', '[Step 5/9] Checking if logged in...');
    await sleep(1000);

    // Step 6
    await run('open https://github.com/esor111?tab=repositories', '[Step 6/9] Going to your repositories page...');
    await sleep(3000);

    // Step 7
    const repoUrl = await run('eval "document.querySelector(\'#user-repositories-list li a\').href"', '[Step 7/9] Extracting first repository URL...');
    
    // Step 8
    console.log('\n[Step 8/9] First repo URL is:');
    console.log(repoUrl);
    
    const fs = require('fs');
    fs.writeFileSync('first-repo-url.txt', repoUrl);

    // Step 9
    await run('screenshot github-automation-complete.png', '[Step 9/9] Taking final screenshot...');

    console.log('\n========================================');
    console.log('✅ AUTOMATION COMPLETE!');
    console.log('========================================\n');
    console.log('Results:');
    console.log(`- First repo URL: ${repoUrl}`);
    console.log('- Screenshot: github-automation-complete.png');
    console.log('- URL saved to: first-repo-url.txt\n');
    console.log('Browser window is STILL OPEN.');
    console.log('You can interact with it manually if you want!\n');
    console.log('To close browser: .\\ab close\n');

  } catch (error) {
    console.error('\n❌ Automation failed:', error.message);
    process.exit(1);
  }
}

main();
