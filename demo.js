/**
 * Agent Browser Demo
 * 
 * This demonstrates why agent-browser is better than Playwright for AI agents:
 * 
 * 1. SEMANTIC LOCATORS - Find elements by what they DO, not CSS selectors
 * 2. SNAPSHOT SYSTEM - Get structured page info AI can understand
 * 3. REFS - Deterministic element selection from snapshots
 * 4. JSON OUTPUT - Machine-readable responses for AI
 * 5. CLI-FIRST - AI agents can use it via shell commands
 */

const { exec } = require('child_process');
const { promisify } = require('util');
const execAsync = promisify(exec);

async function runCommand(cmd) {
  console.log(`\n🤖 Running: ${cmd}\n`);
  try {
    const { stdout, stderr } = await execAsync(cmd);
    if (stderr && !stderr.includes('Debugger')) console.error('stderr:', stderr);
    return stdout;
  } catch (error) {
    console.error('Error:', error.message);
    throw error;
  }
}

async function demo() {
  console.log('🚀 AGENT BROWSER DEMO\n');
  console.log('=' .repeat(60));

  // Demo 1: Navigate and get snapshot
  console.log('\n📍 DEMO 1: Navigate to a page and get semantic snapshot');
  console.log('-'.repeat(60));
  await runCommand('npx agent-browser goto https://example.com');
  const snapshot = await runCommand('npx agent-browser snapshot --json');
  console.log('Snapshot (first 500 chars):', snapshot.substring(0, 500));

  // Demo 2: Semantic locators - find by role and text
  console.log('\n📍 DEMO 2: Find elements semantically (no CSS selectors!)');
  console.log('-'.repeat(60));
  const elements = await runCommand('npx agent-browser find "link More information"');
  console.log(elements);

  // Demo 3: Take a screenshot
  console.log('\n📍 DEMO 3: Take a screenshot');
  console.log('-'.repeat(60));
  await runCommand('npx agent-browser screenshot screenshot.png');
  console.log('✅ Screenshot saved to screenshot.png');

  // Demo 4: Navigate to a more complex page
  console.log('\n📍 DEMO 4: Navigate to GitHub and get interactive elements');
  console.log('-'.repeat(60));
  await runCommand('npx agent-browser goto https://github.com');
  const interactive = await runCommand('npx agent-browser snapshot --interactive --json');
  console.log('Interactive elements (first 800 chars):', interactive.substring(0, 800));

  // Demo 5: Get page info
  console.log('\n📍 DEMO 5: Get page information');
  console.log('-'.repeat(60));
  const info = await runCommand('npx agent-browser info --json');
  console.log(info);

  console.log('\n' + '='.repeat(60));
  console.log('✅ DEMO COMPLETE!\n');
  
  console.log('🎯 WHY AGENT BROWSER > PLAYWRIGHT FOR AI:\n');
  console.log('1. Semantic locators - AI describes what to find, not CSS');
  console.log('2. Snapshot system - Structured page data AI can parse');
  console.log('3. Refs system - Deterministic element selection');
  console.log('4. JSON output - Machine-readable for AI agents');
  console.log('5. CLI-first - AI can use shell commands directly');
  console.log('6. Fast Rust CLI - Persistent daemon for speed');
  console.log('7. Built FOR AI agents, not adapted from testing tools\n');
}

demo().catch(console.error);
