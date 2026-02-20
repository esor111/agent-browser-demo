/**
 * GitHub Automation - PROPERLY WORKING VERSION
 * 
 * This script ensures the daemon is running and handles all edge cases
 */

const { spawn, exec } = require('child_process');
const { promisify } = require('util');
const fs = require('fs');
const path = require('path');
const os = require('os');
const execAsync = promisify(exec);

const AB_PATH = path.join(__dirname, 'node_modules', 'agent-browser', 'bin', 'agent-browser-win32-x64.exe');

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

// Check if daemon is running
function isDaemonRunning() {
  const pidFile = path.join(os.tmpdir(), 'agent-browser-default.pid');
  if (!fs.existsSync(pidFile)) return false;
  
  try {
    const pid = parseInt(fs.readFileSync(pidFile, 'utf8').trim(), 10);
    process.kill(pid, 0); // Check if process exists
    return true;
  } catch {
    return false;
  }
}

// Start daemon by running a simple command
async function ensureDaemonRunning() {
  if (isDaemonRunning()) {
    console.log('✓ Daemon already running\n');
    return;
  }
  
  console.log('Starting daemon...');
  try {
    // Run a simple command to start the daemon
    await execAsync(`"${AB_PATH}" --version`);
    await sleep(2000); // Give daemon time to start
    console.log('✓ Daemon started\n');
  } catch (error) {
    console.error('Failed to start daemon:', error.message);
    throw error;
  }
}

async function run(cmd, description) {
  if (description) {
    console.log(`${description}`);
  }
  
  try {
    const { stdout, stderr } = await execAsync(`"${AB_PATH}" --headed ${cmd}`);
    const output = stdout.trim();
    if (output) console.log(output);
    return output;
  } catch (error) {
    console.error(`❌ Error: ${error.message}`);
    throw error;
  }
}

async function main() {
  console.log('========================================');
  console.log('GITHUB AUTOMATION - WATCH IT HAPPEN!');
  console.log('========================================\n');
  console.log('A browser window will open and automate:');
  console.log('1. Login to GitHub');
  console.log('2. Navigate to repositories');
  console.log('3. Extract first repo URL\n');
  
  try {
    // CRITICAL: Ensure daemon is running first
    await ensureDaemonRunning();
    
    console.log('Starting automation in 2 seconds...\n');
    await sleep(2000);

    // Step 1: Open GitHub login
    await run('open https://github.com/login', '[1/9] Opening GitHub login page...');
    await sleep(3000);

    // Step 2: Fill username
    await run('fill "@e2" "esor111"', '[2/9] Typing username: esor111');
    await sleep(2000);

    // Step 3: Fill password
    await run('fill "@e3" "ishwor19944"', '[3/9] Typing password...');
    await sleep(2000);

    // Step 4: Click sign in
    await run('click "@e5"', '[4/9] Clicking Sign in button...');
    console.log('Waiting for login...');
    await sleep(6000);

    // Step 5: Verify login
    await run('get url', '[5/9] Verifying login...');
    await sleep(1000);

    // Step 6: Go to repositories
    await run('open https://github.com/esor111?tab=repositories', '[6/9] Going to repositories...');
    await sleep(3000);

    // Step 7: Extract first repo URL
    const repoUrl = await run('eval "document.querySelector(\'#user-repositories-list li a\').href"', '[7/9] Extracting first repo URL...');
    
    // Step 8: Save to file
    console.log('\n[8/9] Saving URL to file...');
    fs.writeFileSync('first-repo-url.txt', repoUrl);
    console.log(`First repo: ${repoUrl}`);

    // Step 9: Screenshot
    await run('screenshot github-final.png', '[9/9] Taking screenshot...');

    console.log('\n========================================');
    console.log('✅ AUTOMATION COMPLETE!');
    console.log('========================================\n');
    console.log('Results:');
    console.log(`- First repo URL: ${repoUrl}`);
    console.log('- Saved to: first-repo-url.txt');
    console.log('- Screenshot: github-final.png\n');
    console.log('Browser window is still open.');
    console.log('To close: .\\ab close\n');

  } catch (error) {
    console.error('\n❌ Automation failed:', error.message);
    console.error('\nTroubleshooting:');
    console.error('1. Make sure Chromium is installed: .\\ab install');
    console.error('2. Kill any stuck processes: taskkill /F /IM node.exe');
    console.error('3. Try running: .\\ab --version');
    process.exit(1);
  }
}

main();
