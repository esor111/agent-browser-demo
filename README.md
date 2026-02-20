# Agent Browser Demo

Demo of Vercel's Agent Browser - a headless browser automation CLI built specifically for AI agents.

## What is Agent Browser?

Agent Browser is a CLI tool that lets AI agents control web browsers through simple commands. It's built with Rust for speed and uses Playwright under the hood.

## Why Agent Browser > Playwright for AI?

| Feature | Agent Browser | Playwright |
|---------|--------------|------------|
| **Semantic Locators** | ✅ Find by role/text ("button Sign In") | ❌ Requires CSS/XPath |
| **Snapshot System** | ✅ Structured page data for AI | ❌ Manual DOM parsing |
| **Refs System** | ✅ Deterministic element IDs | ❌ Selectors can break |
| **JSON Output** | ✅ Built-in `--json` flag | ❌ Manual serialization |
| **CLI-First** | ✅ AI uses shell commands | ❌ Requires code integration |
| **Persistent Daemon** | ✅ Fast subsequent commands | ❌ Slower startup |
| **Built For AI** | ✅ Designed for agents | ❌ Designed for testing |

## Installation

Already installed! The package is in `node_modules`.

## Quick Test

Run the simple test:

```bash
node simple-test.js
```

This will:
1. Navigate to example.com
2. Get page info
3. Take a screenshot
4. Get page snapshot

## Full Demo

Run the comprehensive demo:

```bash
node demo.js
```

This shows all the AI-friendly features.

## Manual CLI Testing

Try these commands directly:

```bash
# Navigate to a page
npx agent-browser goto https://example.com

# Get page info
npx agent-browser info

# Take a screenshot
npx agent-browser screenshot output.png

# Get page snapshot (AI-friendly structure)
npx agent-browser snapshot --compact

# Get only interactive elements
npx agent-browser snapshot --interactive

# Find elements semantically
npx agent-browser find "link More information"

# Get JSON output (for AI parsing)
npx agent-browser info --json

# Click an element
npx agent-browser click "link More information"

# Fill a form field
npx agent-browser fill "textbox Search" "hello world"

# Type text
npx agent-browser type "Hello World"
```

## Key Concepts

### 1. Semantic Locators
Instead of CSS selectors, use natural language:
- `"button Sign In"` - finds a button with text "Sign In"
- `"link Home"` - finds a link with text "Home"
- `"textbox Email"` - finds an input with label "Email"

### 2. Snapshot System
Get structured page data that AI can understand:
```bash
npx agent-browser snapshot --json
```

Returns a tree of elements with roles, text, and refs.

### 3. Refs
Deterministic element IDs from snapshots:
```bash
npx agent-browser click ref:abc123
```

### 4. Sessions
Run multiple isolated browser instances:
```bash
npx agent-browser --session user1 goto https://example.com
npx agent-browser --session user2 goto https://google.com
```

## Use Cases for AI Agents

1. **Web Scraping** - AI describes what to extract, agent-browser finds it
2. **Form Filling** - AI fills forms using semantic locators
3. **Testing** - AI writes tests in natural language
4. **Automation** - AI automates workflows without brittle selectors
5. **Research** - AI navigates and extracts information from websites

## Architecture

- **Rust CLI** - Fast native binary for parsing commands
- **Node.js Daemon** - Manages Playwright browser instance
- **Persistent** - Daemon stays running between commands for speed

## Next Steps

1. Run `node simple-test.js` to verify it works
2. Run `node demo.js` to see all features
3. Try manual CLI commands
4. Build your own AI agent that uses these commands!
