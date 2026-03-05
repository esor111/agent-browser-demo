#!/bin/bash

###############################################################################
# LOGIN FLOW AUTOMATION TEST
# Tests the owner/staff login functionality
###############################################################################

AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
OUTPUT_DIR="./frontend-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$OUTPUT_DIR/screenshots"
mkdir -p "$OUTPUT_DIR/snapshots"

# Test credentials (from seed.ts)
PHONE="9800000001"  # Owner user from seed data
PASSWORD="password123"

echo ""
echo "========================================"
echo " LOGIN FLOW TEST"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""

# ── STEP 1: Navigate to login page ────────────────────────────────────────────
echo "[1/6] Opening login page..."
$AB --headed open "$FRONTEND_URL/login"
$AB wait 3000
echo "✓ Login page opened"

# ── STEP 2: Take snapshot to find form elements ───────────────────────────────
echo "[2/6] Snapshotting page to find form elements..."
LOGIN_SNAPSHOT=$($AB snapshot -i --json 2>/dev/null)
echo "$LOGIN_SNAPSHOT" > "$OUTPUT_DIR/snapshots/login_page_${TIMESTAMP}.json"

# Find phone input ref
PHONE_REF=$(echo "$LOGIN_SNAPSHOT" | jq -r '
  .data.refs
  | to_entries[]
  | select(
      .value.role == "textbox" and
      ((.value.name // "") | test("phone|tel|mobile"; "i"))
    )
  | .key
' 2>/dev/null | head -1)

# Find password input ref
PASSWORD_REF=$(echo "$LOGIN_SNAPSHOT" | jq -r '
  .data.refs
  | to_entries[]
  | select(
      .value.role == "textbox" and
      ((.value.name // "") | test("password|pass"; "i"))
    )
  | .key
' 2>/dev/null | head -1)

# Find login button ref
LOGIN_BTN_REF=$(echo "$LOGIN_SNAPSHOT" | jq -r '
  .data.refs
  | to_entries[]
  | select(
      .value.role == "button" and
      ((.value.name // "") | test("login|sign in|submit"; "i"))
    )
  | .key
' 2>/dev/null | head -1)

echo "✓ Found form elements:"
echo "  Phone input: @$PHONE_REF"
echo "  Password input: @$PASSWORD_REF"
echo "  Login button: @$LOGIN_BTN_REF"

# ── STEP 3: Fill phone number ─────────────────────────────────────────────────
echo "[3/6] Filling phone number..."
if [ -n "$PHONE_REF" ]; then
  $AB fill "@$PHONE_REF" "$PHONE"
  $AB wait 1000
  echo "✓ Phone number entered: $PHONE"
else
  echo "⚠ Could not find phone input, trying fallback..."
  $AB fill "textbox" "$PHONE"
  $AB wait 1000
fi

# ── STEP 4: Fill password ─────────────────────────────────────────────────────
echo "[4/6] Filling password..."
if [ -n "$PASSWORD_REF" ]; then
  $AB fill "@$PASSWORD_REF" "$PASSWORD"
  $AB wait 1000
  echo "✓ Password entered"
else
  echo "⚠ Could not find password input, trying fallback..."
  # Try to find second textbox (usually password)
  $AB eval "document.querySelectorAll('input[type=\"password\"]')[0]?.focus()"
  $AB type "$PASSWORD"
  $AB wait 1000
fi

# Take screenshot before clicking login
$AB screenshot "$OUTPUT_DIR/screenshots/login_before_submit_${TIMESTAMP}.png"
echo "✓ Screenshot taken (before submit)"

# ── STEP 5: Click login button ────────────────────────────────────────────────
echo "[5/6] Clicking login button..."
if [ -n "$LOGIN_BTN_REF" ]; then
  $AB click "@$LOGIN_BTN_REF"
else
  echo "⚠ Could not find login button, trying fallback..."
  $AB press Enter
fi

# Wait for navigation/response
$AB wait --load networkidle 2>/dev/null || $AB wait 5000
echo "✓ Login submitted"

# ── STEP 6: Verify login success ──────────────────────────────────────────────
echo "[6/6] Verifying login success..."

# Get current URL
CURRENT_URL=$($AB get url 2>/dev/null)
echo "  Current URL: $CURRENT_URL"

# Take screenshot after login
$AB screenshot "$OUTPUT_DIR/screenshots/login_after_submit_${TIMESTAMP}.png"
echo "✓ Screenshot taken (after submit)"

# Check if redirected to dashboard
if [[ "$CURRENT_URL" == *"/owner/dashboard"* ]] || [[ "$CURRENT_URL" == *"/dashboard"* ]]; then
  echo ""
  echo "========================================"
  echo " ✅ LOGIN TEST PASSED"
  echo "========================================"
  echo ""
  echo "Successfully logged in and redirected to dashboard"
  echo "URL: $CURRENT_URL"
  
  # Take snapshot of dashboard
  DASHBOARD_SNAPSHOT=$($AB snapshot -i --json 2>/dev/null)
  echo "$DASHBOARD_SNAPSHOT" > "$OUTPUT_DIR/snapshots/dashboard_${TIMESTAMP}.json"
  
  # Extract dashboard metrics if visible
  METRICS=$($AB eval "
    const metrics = Array.from(document.querySelectorAll('[class*=\"metric\"],[class*=\"stat\"],[class*=\"card\"]'))
      .slice(0, 4)
      .map(el => el.innerText?.trim())
      .filter(text => text && text.length > 0);
    JSON.stringify(metrics, null, 2);
  " 2>/dev/null)
  
  if [ -n "$METRICS" ] && [ "$METRICS" != "[]" ]; then
    echo ""
    echo "Dashboard metrics visible:"
    echo "$METRICS" | jq -r '.[]' 2>/dev/null || echo "$METRICS"
  fi
  
  EXIT_CODE=0
else
  echo ""
  echo "========================================"
  echo " ❌ LOGIN TEST FAILED"
  echo "========================================"
  echo ""
  echo "Did not redirect to dashboard"
  echo "Current URL: $CURRENT_URL"
  
  # Check for error messages
  ERROR_MSG=$($AB eval "
    const errors = Array.from(document.querySelectorAll('[class*=\"error\"],[role=\"alert\"]'))
      .map(el => el.innerText?.trim())
      .filter(text => text && text.length > 0);
    errors.join(' | ');
  " 2>/dev/null)
  
  if [ -n "$ERROR_MSG" ]; then
    echo ""
    echo "Error messages found:"
    echo "$ERROR_MSG"
  fi
  
  EXIT_CODE=1
fi

# ── Close browser ─────────────────────────────────────────────────────────────
$AB close
echo "✓ Browser closed"

echo ""
echo "Files saved:"
echo "  📸  $OUTPUT_DIR/screenshots/login_before_submit_${TIMESTAMP}.png"
echo "  📸  $OUTPUT_DIR/screenshots/login_after_submit_${TIMESTAMP}.png"
echo "  📋  $OUTPUT_DIR/snapshots/login_page_${TIMESTAMP}.json"
if [ $EXIT_CODE -eq 0 ]; then
  echo "  📋  $OUTPUT_DIR/snapshots/dashboard_${TIMESTAMP}.json"
fi
echo ""

exit $EXIT_CODE
