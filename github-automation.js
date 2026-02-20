const { exec } = require('child_process');
const { promisify } = require('util');
const fs = require('fs').promises;
const execAsync = promisify(exec);

const AB = '.\\node_modules\\agent-browser\\bin\\agent-browser-win32-x64.exe';

async function run(cmd) {
  console.log(`🤖 ${cmd}`);
  const { stdout, stderr } = await execAsync(`${AB} ${cmd}`);
  return stdout.trim();
}

async function githubWorkflow() {
  console.log('🚀 Starting GitHub automation...\n');

  try {
    // Step 1: Open GitHub login
    console.log('📍 Step 1: Opening GitHub login page...');
    await run('--headed open https://github.com/login');
    await sleep(3000);

    // Step 2: Fill username
    console.log('📍 Step 2: Entering username...');
    await run('--headed fill "textbox Username or email address" "esor111"');
    await sleep(1000);

    // Step 3: Fill password
    console.log('📍 Step 3: Entering password...');
    await run('--headed fill "textbox Password" "ishwor19944"');
    await sleep(1000);

    // Step 4: Click sign in
    console.log('📍 Step 4: Clicking Sign in...');
    await run('--headed click "button Sign in"');
    console.log('⏳ Waiting for login to complete...');
    await sleep(5000);

    // Step 5: Check if logged in
    console.log('📍 Step 5: Verifying login...');
    const currentUrl = await run('--headed get url');
    console.log(`Current URL: ${currentUrl}`);

    // Step 6: Go to repositories
    console.log('📍 Step 6: Navigating to repositories...');
    await run('--headed open https://github.com/esor111?tab=repositories');
    await sleep(3000);

    // Step 7: Get page snapshot
    console.log('📍 Step 7: Getting page structure...');
    const snapshot = await run('--headed snapshot --interactive --json');
    await fs.writeFile('repos-snapshot.json', snapshot);
    console.log('✅ Snapshot saved to repos-snapshot.json');

    // Step 8: Extract first repo URL using JavaScript
    console.log('📍 Step 8: Extracting first repository URL...');
    const repoUrl = await run('--headed eval "document.querySelector(\'article h3 a\')?.href || document.querySelector(\'[itemprop=\\\"name codeRepository\\\"] a\')?.href || \'No repo found\'"');
    console.log(`\n🎯 First Repository URL: ${repoUrl}\n`);
    
    // Save to file
    await fs.writeFile('first-repo-url.txt', repoUrl);
    console.log('✅ URL saved to first-repo-url.txt');

    // Step 9: Take screenshot
    console.log('📍 Step 9: Taking screenshot...');
    await run('--headed screenshot github-repos-final.png');
    console.log('✅ Screenshot saved to github-repos-final.png');

    console.log('\n========================================');
    console.log('✅ SUCCESS!');
    console.log('========================================');
    console.log(`First Repo URL: ${repoUrl}`);
    console.log('Files created:');
    console.log('  - first-repo-url.txt');
    console.log('  - repos-snapshot.json');
    console.log('  - github-repos-final.png');
    console.log('\nBrowser window is still open.');
    console.log('Run: .\\ab close to close it.');

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// Run the workflow
githubWorkflow();
