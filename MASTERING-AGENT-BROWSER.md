# Mastering Agent Browser: A Developer's Guide to Maximum Impact

## Philosophy: Think in Workflows, Not Scripts

Agent Browser isn't just a tool - it's a paradigm shift. Stop thinking "how do I write code to automate this?" and start thinking "what workflow do I want to automate?"

---

## 1. The Three Pillars of Mastery

### Pillar 1: Semantic Understanding
**Stop thinking in CSS selectors. Start thinking in user intent.**

```bash
# Beginner: Fighting with selectors
agent-browser click 'button.btn-primary.submit-form[data-testid="submit"]'

# Expert: Describing what you want
agent-browser click "button Submit"
agent-browser fill "textbox Email" "user@example.com"
```

**Why this matters**: Pages change. CSS classes get refactored. But "Submit" button stays "Submit".

### Pillar 2: Snapshot-Driven Development
**Get the page structure first, then act.**

```bash
# The expert workflow:
# 1. Understand the page
agent-browser snapshot --interactive --json > page.json

# 2. Parse and plan (AI or manual)
# Find: { "ref": "e5", "role": "button", "name": "Submit" }

# 3. Execute with confidence
agent-browser click @e5
```

**Why this matters**: Refs are deterministic. Same element = same ref. No guessing.

### Pillar 3: Session Isolation
**One browser per context. Always.**

```bash
# Test multi-user scenarios
agent-browser --session admin open app.com/admin
agent-browser --session user open app.com/dashboard

# Each session = isolated cookies, storage, state
```

**Why this matters**: Test race conditions, permissions, multi-tenant scenarios in parallel.

---

## 2. Advanced Patterns for Automation Engineers

### Pattern 1: The Snapshot-Parse-Act Loop
**The most powerful pattern for complex automation.**

```bash
#!/bin/bash
# Step 1: Get current state
agent-browser snapshot --interactive --json > state.json

# Step 2: AI/script parses JSON to decide next action
# (Your logic here - could be AI, could be jq, could be Python)

# Step 3: Act based on parsed data
agent-browser click @e5

# Step 4: Verify
agent-browser wait 2000
agent-browser snapshot --json > new-state.json

# Step 5: Compare states to confirm action succeeded
```

**Use cases**:
- Dynamic forms that change based on input
- Multi-step wizards with conditional paths
- E-commerce flows with variable checkout steps

### Pattern 2: Idempotent Automation
**Make your scripts runnable multiple times safely.**

```bash
# Check current state before acting
if agent-browser is visible "button Logout" --json | grep -q "true"; then
  echo "Already logged in"
else
  # Login flow
  agent-browser open app.com/login
  agent-browser fill "textbox Email" "$EMAIL"
  agent-browser fill "textbox Password" "$PASSWORD"
  agent-browser click "button Sign in"
fi
```

**Why this matters**: Scripts that can recover from partial failures are production-ready.

### Pattern 3: Progressive Enhancement
**Start simple, add complexity only when needed.**

```bash
# Level 1: Basic automation
agent-browser open example.com
agent-browser click "button Submit"

# Level 2: Add verification
agent-browser click "button Submit"
agent-browser wait "text Success"

# Level 3: Add error handling
if ! agent-browser wait "text Success" --timeout 5000; then
  agent-browser screenshot error.png
  exit 1
fi

# Level 4: Add retry logic
for i in {1..3}; do
  agent-browser click "button Submit"
  if agent-browser wait "text Success" --timeout 5000; then
    break
  fi
  sleep 2
done
```

### Pattern 4: Data-Driven Automation
**Separate data from logic.**

```bash
# users.json
# [
#   {"email": "user1@example.com", "password": "pass1"},
#   {"email": "user2@example.com", "password": "pass2"}
# ]

# Script
while IFS= read -r user; do
  email=$(echo "$user" | jq -r '.email')
  password=$(echo "$user" | jq -r '.password')
  
  agent-browser --session "$email" open app.com/login
  agent-browser --session "$email" fill "textbox Email" "$email"
  agent-browser --session "$email" fill "textbox Password" "$password"
  agent-browser --session "$email" click "button Sign in"
done < <(jq -c '.[]' users.json)
```

**Use cases**:
- Bulk account testing
- Multi-user load testing
- Data migration validation

### Pattern 5: State Machines
**Model complex workflows as state transitions.**

```bash
STATE="START"

while [ "$STATE" != "DONE" ]; do
  case $STATE in
    START)
      agent-browser open app.com
      STATE="LOGIN"
      ;;
    LOGIN)
      agent-browser fill "textbox Email" "$EMAIL"
      agent-browser fill "textbox Password" "$PASSWORD"
      agent-browser click "button Sign in"
      if agent-browser wait "text Dashboard"; then
        STATE="DASHBOARD"
      else
        STATE="ERROR"
      fi
      ;;
    DASHBOARD)
      agent-browser click "link Settings"
      STATE="SETTINGS"
      ;;
    SETTINGS)
      # Do settings work
      STATE="DONE"
      ;;
    ERROR)
      echo "Failed"
      exit 1
      ;;
  esac
done
```

---

## 3. Engineering Best Practices

### Practice 1: Always Clean State
```bash
# Kill processes before starting
taskkill /F /IM node.exe 2>nul
taskkill /F /IM chrome.exe 2>nul
sleep 2

# Now start fresh
agent-browser open app.com
```

### Practice 2: Adequate Wait Times
```bash
# After navigation
agent-browser open app.com
sleep 3  # Let page load

# After form submission
agent-browser click "button Submit"
sleep 5  # Let server process

# After login
agent-browser click "button Sign in"
sleep 7  # Authentication takes time
```

### Practice 3: Capture Evidence
```bash
# Before critical actions
agent-browser screenshot before-submit.png

# After critical actions
agent-browser screenshot after-submit.png

# On errors
trap 'agent-browser screenshot error-$(date +%s).png' ERR
```

### Practice 4: Structured Logging
```bash
log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a automation.log
}

log "Starting automation"
agent-browser open app.com
log "Opened app"
agent-browser click "button Submit"
log "Clicked submit"
```

### Practice 5: Configuration Management
```bash
# config.env
APP_URL=https://app.com
EMAIL=user@example.com
PASSWORD=secret123
TIMEOUT=5000

# script.sh
source config.env
agent-browser open "$APP_URL"
agent-browser fill "textbox Email" "$EMAIL"
```

---

## 4. Advanced Use Cases

### Use Case 1: Continuous Monitoring
```bash
# monitor.sh - Run every 5 minutes via cron
agent-browser open https://myapp.com
if ! agent-browser is visible "text Healthy"; then
  agent-browser screenshot down-$(date +%s).png
  # Send alert
  curl -X POST slack-webhook -d "App is down!"
fi
agent-browser close
```

### Use Case 2: Competitive Intelligence
```bash
# Track competitor pricing
agent-browser open competitor.com/pricing
agent-browser snapshot --json > pricing-$(date +%Y%m%d).json

# Extract prices (with jq or AI)
# Compare with historical data
# Alert on changes
```

### Use Case 3: Automated Testing Pipeline
```bash
# test-suite.sh
TESTS=(
  "test-login.sh"
  "test-checkout.sh"
  "test-profile.sh"
)

for test in "${TESTS[@]}"; do
  echo "Running $test"
  if ./"$test"; then
    echo "✓ $test passed"
  else
    echo "✗ $test failed"
    agent-browser screenshot "failed-$test-$(date +%s).png"
  fi
done
```

### Use Case 4: Data Migration Validation
```bash
# Validate migrated data
while IFS=, read -r id name email; do
  agent-browser open "app.com/users/$id"
  
  actual_name=$(agent-browser get text "heading Name" --json | jq -r '.text')
  actual_email=$(agent-browser get text "text Email" --json | jq -r '.text')
  
  if [ "$actual_name" != "$name" ] || [ "$actual_email" != "$email" ]; then
    echo "Mismatch for user $id"
  fi
done < users.csv
```

### Use Case 5: Form Fuzzing
```bash
# Test form validation
INVALID_EMAILS=("notanemail" "@example.com" "user@" "")

for email in "${INVALID_EMAILS[@]}"; do
  agent-browser open app.com/signup
  agent-browser fill "textbox Email" "$email"
  agent-browser click "button Submit"
  
  if agent-browser is visible "text Invalid email"; then
    echo "✓ Validation works for: $email"
  else
    echo "✗ Validation missing for: $email"
    agent-browser screenshot "validation-bug-$email.png"
  fi
done
```

---

## 5. Integration Patterns

### With AI Agents
```bash
# AI decides what to do based on page state
snapshot=$(agent-browser snapshot --interactive --json)

# Send to AI
response=$(curl -X POST ai-api.com/decide \
  -d "{\"page\": $snapshot, \"goal\": \"find cheapest product\"}")

# AI returns action
action=$(echo "$response" | jq -r '.action')
target=$(echo "$response" | jq -r '.target')

# Execute AI's decision
agent-browser "$action" "$target"
```

### With CI/CD
```yaml
# .github/workflows/e2e-tests.yml
name: E2E Tests
on: [push]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - run: npm install agent-browser
      - run: ./test-suite.sh
      - uses: actions/upload-artifact@v2
        if: failure()
        with:
          name: screenshots
          path: "*.png"
```

### With Monitoring Systems
```bash
# Send metrics to monitoring
duration=$(time agent-browser open app.com 2>&1 | grep real | awk '{print $2}')
curl -X POST metrics-api.com/record \
  -d "{\"metric\": \"page_load_time\", \"value\": \"$duration\"}"
```

---

## 6. Performance Optimization

### Optimization 1: Reuse Sessions
```bash
# Bad: New browser each time (slow)
for i in {1..10}; do
  agent-browser open app.com/page$i
  agent-browser close
done

# Good: Reuse browser (fast)
for i in {1..10}; do
  agent-browser open app.com/page$i
done
agent-browser close
```

### Optimization 2: Parallel Execution
```bash
# Run multiple sessions in parallel
for user in user1 user2 user3; do
  (
    agent-browser --session "$user" open app.com
    agent-browser --session "$user" fill "textbox Email" "$user@example.com"
    agent-browser --session "$user" click "button Submit"
  ) &
done
wait
```

### Optimization 3: Headless by Default
```bash
# Development: Use --headed to see what's happening
agent-browser --headed open app.com

# Production: Headless is faster
agent-browser open app.com
```

---

## 7. Debugging Strategies

### Strategy 1: Visual Debugging
```bash
# See what the browser sees
agent-browser --headed open app.com
agent-browser snapshot --compact  # See page structure
agent-browser screenshot debug.png  # Capture state
```

### Strategy 2: Incremental Testing
```bash
# Test each step individually
agent-browser open app.com  # Does this work?
agent-browser fill "textbox Email" "test@example.com"  # Does this work?
agent-browser click "button Submit"  # Does this work?
```

### Strategy 3: State Inspection
```bash
# Check what's actually on the page
agent-browser get title
agent-browser get url
agent-browser snapshot --interactive
agent-browser is visible "button Submit"
```

---

## 8. Security Considerations

### Never Hardcode Credentials
```bash
# Bad
agent-browser fill "textbox Password" "mypassword123"

# Good
agent-browser fill "textbox Password" "$PASSWORD"
```

### Use Environment Variables
```bash
export EMAIL="user@example.com"
export PASSWORD="$(cat ~/.secrets/password)"

agent-browser fill "textbox Email" "$EMAIL"
agent-browser fill "textbox Password" "$PASSWORD"
```

### Sanitize Screenshots
```bash
# Blur sensitive data before saving
agent-browser eval "document.querySelectorAll('[data-sensitive]').forEach(el => el.style.filter = 'blur(10px)')"
agent-browser screenshot sanitized.png
```

---

## 9. The Expert Mindset

### Think Declaratively
"I want to be logged in" not "I want to click this button"

### Think Idempotently
"Ensure I'm logged in" not "Log in"

### Think Observably
"Capture evidence of what happened" not "Just do it"

### Think Resiliently
"Retry on failure" not "Hope it works"

### Think Compositionally
"Chain small reliable pieces" not "One big fragile script"

---

## 10. Your Action Plan

### Week 1: Foundation
- [ ] Master semantic locators
- [ ] Practice snapshot-driven development
- [ ] Build 3 simple automations

### Week 2: Patterns
- [ ] Implement idempotent scripts
- [ ] Add error handling and retries
- [ ] Use sessions for multi-user testing

### Week 3: Integration
- [ ] Integrate with your CI/CD
- [ ] Set up monitoring automation
- [ ] Build data-driven test suite

### Week 4: Mastery
- [ ] Optimize for performance
- [ ] Implement state machines for complex flows
- [ ] Contribute patterns back to community

---

## Final Wisdom

**Agent Browser is not just a tool - it's a new way of thinking about automation.**

The best automators don't write the most code. They write the most resilient, maintainable, and understandable automation.

Focus on:
1. **Clarity**: Can someone else understand this in 6 months?
2. **Reliability**: Does it work every time?
3. **Observability**: Can I see what went wrong?
4. **Maintainability**: Can I change it easily?

Master these principles, and you'll be unstoppable.
