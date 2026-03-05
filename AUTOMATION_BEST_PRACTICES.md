# 🎯 Automation Best Practices - Quick Reference Guide

**Purpose**: Quick checklist to avoid common mistakes when building browser automation  
**Created**: March 5, 2026  
**Project**: Hotel Management System Frontend Automation

---

## ⚡ Golden Rules (Never Break These!)

### 1. 🔍 ALWAYS Test Manually First
```bash
# ❌ DON'T: Write automation script immediately
# ✅ DO: Test manually using agent-browser commands first

# Manual testing example:
$AB --headed open "http://localhost:3001/page"
$AB wait 3000
$AB snapshot -i  # See what's available
$AB click "@e5"  # Try clicking things
$AB screenshot "test.png"  # Verify visually
```

**Why**: You need to understand the actual flow before automating it.

---

### 2. 🎭 ALWAYS Detect State Before Acting
```bash
# ❌ BAD: Assume you're on a specific page
$AB fill "@e3" "$VALUE"

# ✅ GOOD: Check where you are first
PAGE_TEXT=$($AB eval "document.body.innerText")
if [[ "$PAGE_TEXT" == *"Login"* ]]; then
  # Handle login page
elif [[ "$PAGE_TEXT" == *"Dashboard"* ]]; then
  # Handle dashboard page
fi
```

**Why**: Users might be logged in, logged out, or on a different page than you expect.

---

### 3. 🧹 ALWAYS Clear State When Testing Registration
```bash
# ❌ BAD: Assume clean state
$AB open "http://localhost:3001/register"

# ✅ GOOD: Clear session first
$AB --headed open "http://localhost:3001/logout"
$AB wait 2000
$AB open "http://localhost:3001/register"
```

**Why**: Previous sessions can interfere with registration/login flows.

---

### 4. 🎲 ALWAYS Use Unique Data for Registration
```bash
# ❌ BAD: Hardcoded data (fails on second run)
PHONE="9841234567"
EMAIL="test@test.com"

# ✅ GOOD: Generate unique data
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
PHONE="98$(date +%s | tail -c 9)"  # Unique phone
EMAIL="testuser${TIMESTAMP}@automation.com"
```

**Why**: Registration with duplicate data will fail.

---

### 5. ⏱️ ALWAYS Wait After Actions
```bash
# ❌ BAD: No waits
$AB click "@e5"
$AB fill "@e6" "value"

# ✅ GOOD: Wait for React to update
$AB click "@e5"
$AB wait 1000  # Let React process
$AB fill "@e6" "value"
$AB wait 500   # Let input update
```

**Wait Time Guidelines:**
- `500ms` - After filling a single field
- `1000ms` - After clicking a button (React state update)
- `3000ms` - After navigation to new page
- `5000ms` - After login/authentication
- `8000ms` - After form submission (API call)

---

### 6. 🛡️ ALWAYS Check If Refs Exist Before Using
```bash
# ❌ BAD: Assume ref exists
$AB click "@$BUTTON_REF"

# ✅ GOOD: Check first
if [ -n "$BUTTON_REF" ]; then
  $AB click "@$BUTTON_REF"
else
  echo "⚠️  Button not found!"
fi
```

**Why**: Empty refs cause cryptic errors like `Unexpected token "@"`.

---

### 7. 📸 ALWAYS Take Screenshots at Key Steps
```bash
# ✅ GOOD: Screenshot before and after critical actions
$AB screenshot "before_submit_${TIMESTAMP}.png"
$AB click "@$SUBMIT_BTN"
$AB wait 5000
$AB screenshot "after_submit_${TIMESTAMP}.png"
```

**Why**: Screenshots help debug failures and verify success.

---

### 8. 🎯 ALWAYS Use Semantic Selectors, Not Positional
```bash
# ❌ BAD: Positional (fragile)
FIRST_INPUT="${REFS_ARRAY[0]}"  # Could be ANY field!
$AB fill "@$FIRST_INPUT" "$PHONE"

# ✅ GOOD: Semantic (robust)
$AB eval "
  const phoneInput = document.querySelector('input[type=\"tel\"]');
  if (phoneInput) phoneInput.value = '$PHONE';
"

# OR: Find by text content
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const loginBtn = buttons.find(b => b.textContent.includes('Login'));
  if (loginBtn) loginBtn.click();
"
```

**Why**: Positional selectors break when page structure changes.

---

### 9. ✅ ALWAYS Verify Success Before Proceeding
```bash
# ❌ BAD: Assume it worked
$AB click "@$SUBMIT_BTN"
$AB wait 5000

# ✅ GOOD: Verify the result
$AB click "@$SUBMIT_BTN"
$AB wait 5000
CURRENT_URL=$($AB get url)
if [ "$CURRENT_URL" != "$EXPECTED_URL" ]; then
  echo "❌ Submission failed!"
  exit 1
fi
```

**Why**: Silent failures are hard to debug.

---

### 10. 🔢 ALWAYS Return Proper Exit Codes
```bash
# ✅ GOOD: Clear success/failure indication
if [ "$SUCCESS" = "true" ]; then
  echo "✅ SUCCESS!"
  exit 0  # Success
else
  echo "❌ FAILED!"
  exit 1  # Failure
fi
```

**Why**: Exit codes allow scripts to be chained and monitored.

---

## 📋 Pre-Automation Checklist

Before writing ANY automation script:

- [ ] Tested the flow manually using agent-browser
- [ ] Documented all steps and refs needed
- [ ] Identified all possible starting states
- [ ] Planned how to handle each state
- [ ] Decided on unique test data generation
- [ ] Planned screenshot locations
- [ ] Planned wait times for each action
- [ ] Planned success/failure verification

---

## 🔧 Debugging Checklist

When automation fails:

- [ ] Check screenshots to see what actually happened
- [ ] Print debug info (refs, URLs, page text)
- [ ] Verify wait times are adequate
- [ ] Check if refs are empty
- [ ] Verify you're on the expected page
- [ ] Check browser console for errors
- [ ] Test manually to confirm flow still works
- [ ] Check if page structure changed

---

## 🎨 Code Patterns to Use

### Pattern 1: State Detection
```bash
PAGE_TEXT=$($AB eval "document.body.innerText")
if [[ "$PAGE_TEXT" == *"keyword"* ]]; then
  # Handle this state
fi
```

### Pattern 2: Safe Ref Usage
```bash
REF=$($AB snapshot -i --json | jq -r '...')
if [ -n "$REF" ]; then
  $AB click "@$REF"
fi
```

### Pattern 3: Semantic Button Click
```bash
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const target = buttons.find(b => b.textContent.includes('Text'));
  if (target) target.click();
"
```

### Pattern 4: Form Field Filling
```bash
# Get all textbox refs
REFS=$($AB snapshot -i --json | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key')
REFS_ARRAY=($REFS)

# Fill with checks
[ -n "${REFS_ARRAY[0]}" ] && $AB fill "@${REFS_ARRAY[0]}" "$VALUE1" && $AB wait 500
[ -n "${REFS_ARRAY[1]}" ] && $AB fill "@${REFS_ARRAY[1]}" "$VALUE2" && $AB wait 500
```

### Pattern 5: Success Verification
```bash
CURRENT_URL=$($AB get url)
PAGE_TEXT=$($AB eval "document.body.innerText")
SUCCESS_CODE=$(echo "$PAGE_TEXT" | grep -oP 'CODE-[A-Z0-9]+')

if [ "$CURRENT_URL" = "$EXPECTED_URL" ] && [ -n "$SUCCESS_CODE" ]; then
  echo "✅ SUCCESS: $SUCCESS_CODE"
  exit 0
else
  echo "❌ FAILED"
  exit 1
fi
```

---

## 🚫 Common Mistakes to Avoid

### Mistake 1: Assuming Starting State
```bash
# ❌ WRONG
$AB open "http://localhost:3001/onboarding"
# Assume we're at Step 2...

# ✅ RIGHT
$AB open "http://localhost:3001/onboarding"
PAGE_TEXT=$($AB eval "document.body.innerText")
# Check what step we're actually on...
```

### Mistake 2: Using Same Data Twice
```bash
# ❌ WRONG (fails on second run)
PHONE="9841234567"

# ✅ RIGHT (unique every time)
PHONE="98$(date +%s | tail -c 9)"
```

### Mistake 3: No Wait Times
```bash
# ❌ WRONG
$AB click "@e5"
$AB fill "@e6" "value"

# ✅ RIGHT
$AB click "@e5"
$AB wait 1000
$AB fill "@e6" "value"
```

### Mistake 4: Ignoring Empty Refs
```bash
# ❌ WRONG
$AB click "@$REF"  # Fails if $REF is empty

# ✅ RIGHT
if [ -n "$REF" ]; then
  $AB click "@$REF"
fi
```

### Mistake 5: No Screenshots
```bash
# ❌ WRONG (can't debug failures)
$AB click "@e5"
$AB wait 5000

# ✅ RIGHT (can see what happened)
$AB screenshot "before.png"
$AB click "@e5"
$AB wait 5000
$AB screenshot "after.png"
```

---

## 📊 Testing Matrix

Test your automation in ALL these scenarios:

| Scenario | Description | Test It? |
|----------|-------------|----------|
| Fresh start | No cookies, not logged in | ✅ |
| Logged in | Existing session | ✅ |
| With draft data | Partially completed form | ✅ |
| After error | Previous submission failed | ✅ |
| Different browser | Chrome vs Firefox | ⚠️ Optional |
| Slow network | Simulate slow connection | ⚠️ Optional |

---

## 🎓 Agent Browser Specific Tips

### Use `eval` for Complex Logic
```bash
# ✅ GOOD: Complex DOM manipulation
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const target = buttons.find(b => b.textContent.includes('Login'));
  if (target) target.click();
"
```

### Use `fill` for React Inputs
```bash
# ✅ GOOD: Triggers React onChange
$AB fill "@$REF" "value"
```

### Use `snapshot -i` to Explore
```bash
# ✅ GOOD: See all available refs
$AB snapshot -i
```

### Parse JSON for Automation
```bash
# ✅ GOOD: Get refs programmatically
REFS=$($AB snapshot -i --json | jq -r '.data.refs | ...')
```

---

## 🎯 Success Criteria

Your automation is ready when:

- ✅ Works when logged in
- ✅ Works when logged out
- ✅ Uses unique data (no duplicates)
- ✅ Has adequate wait times
- ✅ Takes screenshots at key points
- ✅ Verifies success/failure
- ✅ Returns proper exit codes
- ✅ Has clear console output
- ✅ Handles errors gracefully
- ✅ Cleans up (closes browser)

---

## 📝 Quick Command Reference

```bash
# Open browser
$AB --headed open "URL"

# Wait
$AB wait 1000  # milliseconds

# Take screenshot
$AB screenshot "file.png"

# Get page info
$AB get url
$AB eval "document.body.innerText"

# Interact
$AB click "@ref"
$AB fill "@ref" "value"

# Explore
$AB snapshot -i
$AB snapshot -i --json | jq '.'

# Close
$AB close
```

---

## 🔄 Workflow Summary

1. **Manual Test** → Understand the flow
2. **Document Steps** → Write down what to do
3. **Detect States** → Check where you are
4. **Use Unique Data** → Generate fresh data
5. **Add Waits** → Let React update
6. **Take Screenshots** → Capture evidence
7. **Verify Success** → Check the result
8. **Return Exit Code** → Signal success/failure

---

## 💡 Remember

> **"Test manually first, detect state always, use unique data, wait adequately, verify everything."**

These 5 principles will save you hours of debugging.

---

**Last Updated**: March 5, 2026  
**Status**: Battle-tested on 5+ automation scripts ✅
