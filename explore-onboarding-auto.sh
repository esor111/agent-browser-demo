#!/bin/bash

###############################################################################
# AUTO EXPLORE: Property Onboarding Flow
# Automatically explores the onboarding flow to understand the structure
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
echo " AUTO EXPLORE: Property Onboarding"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""

# ── STEP 1: Open onboarding page ──────────────────────────────────────────────
echo "[1/10] Opening onboarding page..."
$AB --headed open "$FRONTEND_URL/onboarding"
$AB wait 4000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_01_initial_${TIMESTAMP}.png"
echo "✓ Page loaded"

# ── STEP 2: Check current step ────────────────────────────────────────────────
echo ""
echo "[2/10] Checking current step..."
CURRENT_STEP=$($AB eval "document.body.innerText" 2>/dev/null | tr -d '"')
echo "Page text preview:"
echo "$CURRENT_STEP" | head -10

# Check if we need to login first
HAS_LOGIN=$($AB eval "document.body.innerText?.includes('Login') || document.body.innerText?.includes('Sign in')" 2>/dev/null | tr -d '"')
echo ""
echo "Has login form: $HAS_LOGIN"

if [ "$HAS_LOGIN" = "true" ]; then
  echo ""
  echo "[3/10] Found login form, attempting to login..."
  
  # Get snapshot
  $AB snapshot -i > /dev/null
  $AB wait 1000
  
  # Find login button/tab
  LOGIN_TAB=$($AB snapshot -i --json 2>/dev/null | jq -r '
    .data.refs
    | to_entries[]
    | select(.value.role == "button" or .value.role == "tab")
    | select(.value.name | test("Login|Sign in"; "i"))
    | .key
  ' 2>/dev/null | head -1)
  
  if [ -n "$LOGIN_TAB" ]; then
    echo "  Clicking login tab..."
    $AB click "@$LOGIN_TAB"
    $AB wait 1000
  fi
  
  # Get form fields
  $AB snapshot -i > /dev/null
  
  PHONE_INPUT=$($AB snapshot -i --json 2>/dev/null | jq -r '
    .data.refs
    | to_entries[]
    | select(.value.role == "textbox")
    | select(.value.name | test("phone|mobile|9800"; "i"))
    | .key
  ' 2>/dev/null | head -1)
  
  PASSWORD_INPUT=$($AB snapshot -i --json 2>/dev/null | jq -r '
    .data.refs
    | to_entries[]
    | select(.value.role == "textbox")
    | select(.value.name | test("password"; "i"))
    | .key
  ' 2>/dev/null | head -1)
  
  echo "  Phone input ref: $PHONE_INPUT"
  echo "  Password input ref: $PASSWORD_INPUT"
  
  if [ -n "$PHONE_INPUT" ] && [ -n "$PASSWORD_INPUT" ]; then
    echo "  Filling phone..."
    $AB fill "@$PHONE_INPUT" "$PHONE"
    $AB wait 500
    
    echo "  Filling password..."
    $AB fill "@$PASSWORD_INPUT" "$PASSWORD"
    $AB wait 1000
    
    $AB screenshot "$OUTPUT_DIR/screenshots/onboard_02_login_filled_${TIMESTAMP}.png"
    
    # Find and click login button
    $AB snapshot -i > /dev/null
    LOGIN_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
      .data.refs
      | to_entries[]
      | select(.value.role == "button")
      | select(.value.name | test("Continue|Login|Sign in|Next"; "i"))
      | .key
    ' 2>/dev/null | head -1)
    
    echo "  Login button ref: $LOGIN_BTN"
    
    if [ -n "$LOGIN_BTN" ]; then
      echo "  Clicking login button..."
      $AB click "@$LOGIN_BTN"
      $AB wait 5000
      $AB screenshot "$OUTPUT_DIR/screenshots/onboard_03_after_login_${TIMESTAMP}.png"
      echo "✓ Login attempted"
    fi
  fi
else
  echo ""
  echo "[3/10] No login required, already authenticated or on property type step"
fi

# ── STEP 4: Check what step we're on now ──────────────────────────────────────
echo ""
echo "[4/10] Checking current step after login..."
CURRENT_URL=$($AB get url 2>/dev/null)
echo "Current URL: $CURRENT_URL"

PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null | tr -d '"')
echo ""
echo "Page contains:"
echo "  - 'Property Type': $(echo "$PAGE_TEXT" | grep -i 'property type' | head -1)"
echo "  - 'Hotel': $(echo "$PAGE_TEXT" | grep -i 'hotel' | head -1)"
echo "  - 'Hostel': $(echo "$PAGE_TEXT" | grep -i 'hostel' | head -1)"
echo "  - 'Guest House': $(echo "$PAGE_TEXT" | grep -i 'guest house' | head -1)"

# ── STEP 5: Get snapshot of current step ──────────────────────────────────────
echo ""
echo "[5/10] Getting snapshot of current step..."
$AB snapshot -i > /dev/null

ALL_ELEMENTS=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "button" or .value.role == "radio" or .value.role == "textbox")
  | "\(.key): \(.value.role) - \(.value.name)"
' 2>/dev/null)

echo "Interactive elements found:"
echo "$ALL_ELEMENTS" | head -20

# ── STEP 6: Try to select a property type ─────────────────────────────────────
echo ""
echo "[6/10] Attempting to select property type..."

# Look for Hotel button/radio
HOTEL_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "button" or .value.role == "radio")
  | select(.value.name | test("^Hotel$"; "i"))
  | .key
' 2>/dev/null | head -1)

echo "Hotel button ref: $HOTEL_BTN"

if [ -n "$HOTEL_BTN" ]; then
  echo "  Clicking Hotel..."
  $AB click "@$HOTEL_BTN"
  $AB wait 1000
  $AB screenshot "$OUTPUT_DIR/screenshots/onboard_04_hotel_selected_${TIMESTAMP}.png"
  echo "✓ Hotel selected"
  
  # Look for Next/Continue button
  $AB snapshot -i > /dev/null
  NEXT_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
    .data.refs
    | to_entries[]
    | select(.value.role == "button")
    | select(.value.name | test("Next|Continue"; "i"))
    | .key
  ' 2>/dev/null | head -1)
  
  echo "  Next button ref: $NEXT_BTN"
  
  if [ -n "$NEXT_BTN" ]; then
    echo "  Clicking Next..."
    $AB click "@$NEXT_BTN"
    $AB wait 3000
    $AB screenshot "$OUTPUT_DIR/screenshots/onboard_05_next_step_${TIMESTAMP}.png"
    echo "✓ Moved to next step"
  fi
fi

# ── STEP 7: Check what step we're on now ──────────────────────────────────────
echo ""
echo "[7/10] Checking current step..."
CURRENT_URL=$($AB get url 2>/dev/null)
echo "Current URL: $CURRENT_URL"

PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null | tr -d '"')
echo ""
echo "Page contains:"
echo "  - 'Property Name': $(echo "$PAGE_TEXT" | grep -i 'property name' | head -1)"
echo "  - 'Location': $(echo "$PAGE_TEXT" | grep -i 'location' | head -1)"
echo "  - 'Contact': $(echo "$PAGE_TEXT" | grep -i 'contact' | head -1)"

# ── STEP 8: Get form fields ───────────────────────────────────────────────────
echo ""
echo "[8/10] Getting form fields..."
$AB snapshot -i > /dev/null

FORM_FIELDS=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "textbox")
  | "\(.key): \(.value.name)"
' 2>/dev/null)

echo "Form fields found:"
echo "$FORM_FIELDS"

# ── STEP 9: Take final screenshot ─────────────────────────────────────────────
echo ""
echo "[9/10] Taking final screenshot..."
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_06_final_${TIMESTAMP}.png"

# ── STEP 10: Close browser ────────────────────────────────────────────────────
echo ""
echo "[10/10] Closing browser..."
$AB close
echo "✓ Browser closed"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "========================================"
echo " EXPLORATION COMPLETE"
echo "========================================"
echo ""
echo "Screenshots saved:"
ls -1 "$OUTPUT_DIR/screenshots/onboard_"*"_${TIMESTAMP}.png" 2>/dev/null | while read file; do
  echo "  📸 $file"
done
echo ""
echo "Next: Review screenshots and create full automation script"
echo ""

exit 0
