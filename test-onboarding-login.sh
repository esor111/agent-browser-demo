#!/bin/bash

###############################################################################
# TEST: Property Onboarding - Login Step
# Tests logging in on the onboarding page
###############################################################################

AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
OUTPUT_DIR="./frontend-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$OUTPUT_DIR/screenshots"

# Test credentials
PHONE="9800000001"
PASSWORD="password123"

echo ""
echo "========================================"
echo " ONBOARDING LOGIN TEST"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""

# ── STEP 1: Open onboarding page ──────────────────────────────────────────────
echo "[1/7] Opening onboarding page..."
$AB --headed open "$FRONTEND_URL/onboarding"
$AB wait 4000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_login_01_initial_${TIMESTAMP}.png"
echo "✓ Page loaded"

# ── STEP 2: Click "Sign in" tab ───────────────────────────────────────────────
echo ""
echo "[2/7] Clicking 'Sign in' tab..."
$AB snapshot -i > /dev/null

SIGNIN_TAB=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "button")
  | select(.value.name == "Sign in")
  | .key
' 2>/dev/null | head -1)

echo "Sign in tab ref: $SIGNIN_TAB"

if [ -n "$SIGNIN_TAB" ]; then
  $AB click "@$SIGNIN_TAB"
  $AB wait 1000
  $AB screenshot "$OUTPUT_DIR/screenshots/onboard_login_02_signin_tab_${TIMESTAMP}.png"
  echo "✓ Sign in tab clicked"
fi

# ── STEP 3: Get form fields ───────────────────────────────────────────────────
echo ""
echo "[3/7] Getting form fields..."
$AB snapshot -i > /dev/null

# List all textboxes
echo "All textboxes:"
$AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "textbox")
  | "\(.key): \(.value.name)"
' 2>/dev/null

PHONE_INPUT=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "textbox")
  | .key
' 2>/dev/null | head -1)

PASSWORD_INPUT=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "textbox")
  | .key
' 2>/dev/null | tail -1)

echo ""
echo "Phone input ref: $PHONE_INPUT"
echo "Password input ref: $PASSWORD_INPUT"

# ── STEP 4: Fill phone number ─────────────────────────────────────────────────
echo ""
echo "[4/7] Filling phone number..."
$AB fill "@$PHONE_INPUT" "$PHONE"
$AB wait 1000
echo "✓ Phone filled"

# ── STEP 5: Fill password ─────────────────────────────────────────────────────
echo ""
echo "[5/7] Filling password..."
$AB fill "@$PASSWORD_INPUT" "$PASSWORD"
$AB wait 1000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_login_03_form_filled_${TIMESTAMP}.png"
echo "✓ Password filled"

# ── STEP 6: Click login button ────────────────────────────────────────────────
echo ""
echo "[6/7] Clicking login button..."
$AB snapshot -i > /dev/null

LOGIN_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Sign in.*continue"; "i"))
  | .key
' 2>/dev/null | head -1)

echo "Login button ref: $LOGIN_BTN"

if [ -n "$LOGIN_BTN" ]; then
  $AB click "@$LOGIN_BTN"
  echo "  Waiting for login..."
  $AB wait 5000
  $AB screenshot "$OUTPUT_DIR/screenshots/onboard_login_04_after_login_${TIMESTAMP}.png"
  echo "✓ Login button clicked"
fi

# ── STEP 7: Check if we moved to next step ────────────────────────────────────
echo ""
echo "[7/7] Checking if login was successful..."
CURRENT_URL=$($AB get url 2>/dev/null)
echo "Current URL: $CURRENT_URL"

PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null | tr -d '"')
HAS_PROPERTY_TYPE=$(echo "$PAGE_TEXT" | grep -i "property type" | head -1)
HAS_HOTEL=$(echo "$PAGE_TEXT" | grep -i "hotel" | head -1)
HAS_ERROR=$(echo "$PAGE_TEXT" | grep -i "error\|invalid\|incorrect" | head -1)

echo ""
if [ -n "$HAS_PROPERTY_TYPE" ] || [ -n "$HAS_HOTEL" ]; then
  echo "✅ LOGIN SUCCESSFUL - Moved to Property Type step"
  echo ""
  echo "Page now shows:"
  echo "  $HAS_PROPERTY_TYPE"
  echo "  $HAS_HOTEL"
  EXIT_CODE=0
elif [ -n "$HAS_ERROR" ]; then
  echo "❌ LOGIN FAILED - Error message found"
  echo ""
  echo "Error: $HAS_ERROR"
  EXIT_CODE=1
else
  echo "⚠️  LOGIN STATUS UNCLEAR"
  echo ""
  echo "Page text preview:"
  echo "$PAGE_TEXT" | head -10
  EXIT_CODE=1
fi

$AB close
echo ""
echo "✓ Browser closed"

echo ""
echo "========================================"
echo " TEST COMPLETE"
echo "========================================"
echo ""
echo "Screenshots:"
ls -1 "$OUTPUT_DIR/screenshots/onboard_login_"*"_${TIMESTAMP}.png" 2>/dev/null | while read file; do
  echo "  📸 $file"
done
echo ""

exit $EXIT_CODE
