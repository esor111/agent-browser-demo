# Agent Browser Quick Reference

## Installation
```bash
npm install agent-browser
npm run install-browser  # Download Chromium
```

## Basic Commands

| Command | Description | Example |
|---------|-------------|---------|
| `open <url>` | Navigate to URL | `agent-browser open example.com` |
| `click <sel>` | Click element | `agent-browser click "button Submit"` |
| `fill <sel> <text>` | Fill input | `agent-browser fill "textbox Email" "user@example.com"` |
| `type <text>` | Type text | `agent-browser type "Hello World"` |
| `press <key>` | Press key | `agent-browser press Enter` |
| `screenshot [path]` | Take screenshot | `agent-browser screenshot out.png` |
| `snapshot` | Get page structure | `agent-browser snapshot --json` |
| `get <what>` | Get info | `agent-browser get title` |
| `is <what> <sel>` | Check state | `agent-browser is visible "button"` |
| `wait <sel\|ms>` | Wait | `agent-browser wait 2000` |

## Semantic Locators (AI-Friendly!)

Instead of CSS selectors, use natural language:

```bash
# By role and text
agent-browser click "button Sign In"
agent-browser click "link Home"
agent-browser fill "textbox Email" "user@example.com"
agent-browser check "checkbox Remember me"

# By label
agent-browser fill "textbox Search" "query"

# By placeholder
agent-browser fill "textbox Enter email..." "user@example.com"
```

## Refs (Deterministic Element IDs)

```bash
# Step 1: Get snapshot with refs
agent-browser snapshot --json > page.json

# Step 2: AI parses JSON, finds: { "ref": "e5", "role": "button", "name": "Submit" }

# Step 3: Click using ref
agent-browser click @e5
```

## Snapshot Options

```bash
# Full snapshot
agent-browser snapshot

# JSON output (for AI)
agent-browser snapshot --json

# Only interactive elements (buttons, links, inputs)
agent-browser snapshot --interactive

# Compact (remove empty elements)
agent-browser snapshot --compact

# Limit depth
agent-browser snapshot --depth 3

# Combine filters
agent-browser snapshot --interactive --compact --json
```

## Get Information

```bash
agent-browser get title          # Page title
agent-browser get url            # Current URL
agent-browser get text "button"  # Element text
agent-browser get html "div"     # Element HTML
agent-browser get value "input"  # Input value
agent-browser get count "button" # Count elements

# JSON output
agent-browser get title --json
```

## Check State

```bash
agent-browser is visible "button Submit"
agent-browser is enabled "button Submit"
agent-browser is checked "checkbox Terms"

# JSON output
agent-browser is visible "button" --json
# Returns: {"visible": true}
```

## Find Elements

```bash
# Find by role
agent-browser find role button --name "Submit"
agent-browser find role link --name "Home"
agent-browser find role textbox --name "Email"

# Find by text
agent-browser find text "Click here"

# Find by label
agent-browser find label "Email address"

# Find and click
agent-browser find role button click --name "Submit"
```

## Sessions (Multiple Browsers)

```bash
# Use different sessions
agent-browser --session user1 open example.com
agent-browser --session user2 open google.com

# Each session is isolated
agent-browser --session user1 fill "textbox" "user1@example.com"
agent-browser --session user2 fill "textbox" "user2@example.com"

# List sessions
agent-browser session list
```

## Authentication

```bash
# Set headers for authentication
agent-browser --headers '{"Authorization":"Bearer token123"}' open api.example.com

# Set credentials
agent-browser set credentials username password
```

## Advanced

```bash
# Run JavaScript
agent-browser eval "document.title"

# Scroll
agent-browser scroll down 500
agent-browser scrollintoview "button"

# Mouse control
agent-browser mouse move 100 200
agent-browser mouse down left
agent-browser mouse up left

# Set viewport
agent-browser set viewport 1920 1080

# Set device
agent-browser set device "iPhone 12"

# Go offline
agent-browser set offline on

# Set geolocation
agent-browser set geo 37.7749 -122.4194
```

## Options

| Option | Description | Example |
|--------|-------------|---------|
| `--json` | JSON output | `agent-browser get title --json` |
| `--session <name>` | Use session | `agent-browser --session user1 open example.com` |
| `--headed` | Show browser | `agent-browser --headed open example.com` |
| `--full` | Full screenshot | `agent-browser screenshot --full out.png` |
| `--debug` | Debug output | `agent-browser --debug open example.com` |
| `--headers <json>` | Set headers | `agent-browser --headers '{"Auth":"token"}' open api.com` |

## AI Agent Workflow

```bash
# 1. Navigate
agent-browser open https://example.com/login

# 2. Get page structure
agent-browser snapshot --interactive --json > page.json

# 3. AI parses JSON to find elements and their refs

# 4. Fill form using refs
agent-browser fill @e1 "username"
agent-browser fill @e2 "password"
agent-browser click @e3

# 5. Verify
agent-browser wait 2000
agent-browser get url --json
agent-browser screenshot success.png
```

## Common Patterns

### Login Flow
```bash
agent-browser open example.com/login
agent-browser fill "textbox Username" "myuser"
agent-browser fill "textbox Password" "mypass"
agent-browser click "button Sign in"
agent-browser wait 2000
agent-browser screenshot logged-in.png
```

### Form Submission
```bash
agent-browser open example.com/contact
agent-browser fill "textbox Name" "John Doe"
agent-browser fill "textbox Email" "john@example.com"
agent-browser fill "textbox Message" "Hello!"
agent-browser click "button Submit"
agent-browser wait "text Thank you"
```

### Web Scraping
```bash
agent-browser open example.com
agent-browser snapshot --json > data.json
agent-browser get text "heading" --json
agent-browser screenshot page.png
```

### Testing
```bash
agent-browser open localhost:3000
agent-browser click "button Add Item"
agent-browser is visible "text Item added" --json
agent-browser screenshot test-result.png
```

## Keyboard Shortcuts

```bash
agent-browser press Enter
agent-browser press Tab
agent-browser press Escape
agent-browser press Control+a
agent-browser press Control+c
agent-browser press Control+v
agent-browser press Shift+Tab
```

## Tips

1. **Use semantic locators** - More reliable than CSS
2. **Use refs from snapshots** - Most deterministic
3. **Use --json for AI** - Machine-readable output
4. **Use --interactive** - Reduce snapshot noise
5. **Use sessions** - Test multiple users
6. **Use --headed** - Debug visually
7. **Use wait** - Let pages load

## Windows Path

Full path on Windows:
```bash
.\node_modules\agent-browser\bin\agent-browser-win32-x64.exe
```

Or add to PATH, or use via npm scripts.
