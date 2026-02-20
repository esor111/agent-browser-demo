# Getting Started with Agent Browser

## ✅ Installation Complete!

Agent Browser v0.6.0 is installed and ready to use.

## 🚀 Quick Start

### Step 1: Install Browser Binaries

Before using agent-browser, you need to download Chromium:

```bash
npm run install-browser
```

Or directly:
```bash
.\node_modules\agent-browser\bin\agent-browser-win32-x64.exe install
```

This downloads Chromium (~150MB). It only needs to be done once.

### Step 2: Try Your First Commands

```bash
# Navigate to a page
.\node_modules\agent-browser\bin\agent-browser-win32-x64.exe open example.com

# Get page title
.\node_modules\agent-browser\bin\agent-browser-win32-x64.exe get title

# Take a screenshot
.\node_modules\agent-browser\bin\agent-browser-win32-x64.exe screenshot test.png

# Get page structure (AI-friendly)
.\node_modules\agent-browser\bin\agent-browser-win32-x64.exe snapshot --compact
```

### Step 3: Run the Test Script

```bash
test.bat
```

This runs a complete test workflow.

## 📚 Key Commands

### Navigation
```bash
# Open URL
agent-browser open https://example.com

# Go back/forward
agent-browser back
agent-browser forward

# Reload
agent-browser reload
```

### Getting Information
```bash
# Get page title
agent-browser get title

# Get current URL
agent-browser get url

# Get element text
agent-browser get text "button Submit"

# Get page snapshot (AI-friendly structure)
agent-browser snapshot --json

# Get only interactive elements
agent-browser snapshot --interactive

# Get compact snapshot (less noise)
agent-browser snapshot --compact
```

### Interacting with Elements
```bash
# Click by semantic locator
agent-browser click "button Sign In"
agent-browser click "link Home"

# Click by ref (from snapshot)
agent-browser click @e5

# Fill form fields
agent-browser fill "textbox Email" "user@example.com"
agent-browser fill "textbox Password" "secret123"

# Type text
agent-browser type "Hello World"

# Press keys
agent-browser press Enter
agent-browser press Tab
agent-browser press Control+a

# Check/uncheck
agent-browser check "checkbox Remember me"
agent-browser uncheck "checkbox Remember me"

# Select dropdown
agent-browser select "combobox Country" "United States"

# Hover
agent-browser hover "button More Options"
```

### Screenshots & PDFs
```bash
# Screenshot visible area
agent-browser screenshot output.png

# Full page screenshot
agent-browser screenshot --full output.png

# Save as PDF
agent-browser pdf output.pdf
```

### Finding Elements
```bash
# Find by role and name
agent-browser find role button --name "Submit"

# Find by text
agent-browser find text "Click here"

# Find by label
agent-browser find label "Email address"

# Find and click
agent-browser find role button click --name "Submit"
```

### Checking State
```bash
# Check if visible
agent-browser is visible "button Submit"

# Check if enabled
agent-browser is enabled "button Submit"

# Check if checked
agent-browser is checked "checkbox Terms"

# JSON output
agent-browser is visible "button Submit" --json
```

### Sessions (Multiple Browsers)
```bash
# Use different sessions
agent-browser --session user1 open example.com
agent-browser --session user2 open google.com

# List sessions
agent-browser session list

# Each session is isolated (separate cookies, storage, etc.)
```

### Advanced
```bash
# Run JavaScript
agent-browser eval "document.title"

# Wait for element
agent-browser wait "button Submit"

# Wait for time
agent-browser wait 2000

# Scroll
agent-browser scroll down 500
agent-browser scrollintoview "button Submit"

# Mouse control
agent-browser mouse move 100 200
agent-browser mouse down left
agent-browser mouse up left

# Set viewport
agent-browser set viewport 1920 1080

# Set geolocation
agent-browser set geo 37.7749 -122.4194

# Go offline
agent-browser set offline on
```

## 🤖 AI Agent Workflow

Here's how an AI agent would use agent-browser:

### 1. Navigate to page
```bash
agent-browser open https://github.com/login
```

### 2. Get page structure
```bash
agent-browser snapshot --interactive --json > page.json
```

### 3. AI parses JSON to find elements
```json
{
  "role": "textbox",
  "name": "Username or email address",
  "ref": "e1"
},
{
  "role": "textbox",
  "name": "Password",
  "ref": "e2"
},
{
  "role": "button",
  "name": "Sign in",
  "ref": "e3"
}
```

### 4. AI fills form using refs
```bash
agent-browser fill @e1 "myusername"
agent-browser fill @e2 "mypassword"
agent-browser click @e3
```

### 5. Verify success
```bash
agent-browser wait 2000
agent-browser get url --json
agent-browser screenshot logged-in.png
```

## 🎯 Why This is Better for AI

### Traditional Playwright Approach:
AI must generate code like this:
```javascript
const { chromium } = require('playwright');
const browser = await chromium.launch();
const page = await browser.newPage();
await page.goto('https://example.com');
await page.click('button.submit-btn'); // Fragile CSS selector!
```

### Agent Browser Approach:
AI just uses CLI commands:
```bash
agent-browser open example.com
agent-browser click "button Submit"  # Semantic locator!
```

**Benefits:**
1. ✅ No code generation needed
2. ✅ Semantic locators (find by what it does, not CSS)
3. ✅ Structured JSON output AI can parse
4. ✅ Deterministic refs (stable element IDs)
5. ✅ Fast persistent daemon
6. ✅ Simple shell commands

## 📖 Next Steps

1. **Read WHY-BETTER-THAN-PLAYWRIGHT.md** - Detailed comparison
2. **Read README.md** - Full feature overview
3. **Run test.bat** - See it in action
4. **Try manual commands** - Experiment with the CLI
5. **Build an AI agent** - Use these commands in your agent!

## 🔗 Resources

- GitHub: https://github.com/vercel-labs/agent-browser
- Documentation: See README.md in node_modules/agent-browser/
- Help: `agent-browser --help`

## 💡 Pro Tips

1. **Use --json for AI parsing**: Every command supports `--json` flag
2. **Use refs for reliability**: Get snapshot, use refs instead of selectors
3. **Use sessions for isolation**: Test multiple users simultaneously
4. **Use --interactive filter**: Reduce noise in snapshots
5. **Use --headed for debugging**: See what the browser is doing

## 🐛 Troubleshooting

**Browser not installed?**
```bash
npm run install-browser
```

**Command not found?**
Use the full path:
```bash
.\node_modules\agent-browser\bin\agent-browser-win32-x64.exe
```

**Daemon issues?**
The daemon starts automatically and persists. If you have issues, just run commands again.

**Need to see the browser?**
Add `--headed` flag:
```bash
agent-browser --headed open example.com
```
