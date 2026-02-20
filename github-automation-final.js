import { BrowserManager } from 'agent-browser';

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
    
  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    console.log('\nPress Ctrl+C to close browser...');
    // Keep browser open so you can see the result
    await new Promise(() => {});
  }
}

run();
