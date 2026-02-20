import { BrowserManager } from 'agent-browser/dist/browser.js';

async function run() {
  const browser = new BrowserManager();
  
  try {
    console.log('Starting browser...');
    await browser.launch({ headless: false });
    
    console.log('Opening GitHub login...');
    await browser.navigate('https://github.com/login');
    await browser.wait(3000);
    
    console.log('Filling username...');
    await browser.fill('@e2', 'esor111');
    await browser.wait(2000);
    
    console.log('Filling password...');
    await browser.fill('@e3', 'ishwor19944');
    await browser.wait(2000);
    
    console.log('Clicking sign in...');
    await browser.click('@e5');
    await browser.wait(6000);
    
    console.log('Navigating to repositories...');
    await browser.navigate('https://github.com/esor111?tab=repositories');
    await browser.wait(3000);
    
    console.log('Getting first repo URL...');
    const repoUrl = await browser.evaluate("document.querySelector('#user-repositories-list li a').href");
    console.log('First repo:', repoUrl);
    
    console.log('Taking screenshot...');
    await browser.screenshot('github-final-result.png');
    
    console.log('\n===== SUCCESS =====');
    console.log('Screenshot saved: github-final-result.png');
    console.log('First repo URL:', repoUrl);
    
    await browser.wait(3000);
    await browser.close();
    
    console.log('Browser closed. Done!');
    process.exit(0);
    
  } catch (error) {
    console.error('Error:', error.message);
    console.error(error.stack);
    process.exit(1);
  }
}

run();
