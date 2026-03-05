#!/bin/bash

###############################################################################
# PROPERTY ONBOARDING FLOW AUTOMATION
# Tests the complete 8-step property registration process:
# 1. Account (Login)
# 2. Property Type
# 3. Property Name
# 4. Location
# 5. Contact
# 6. Operations
# 7. Plan Selector
# 8. Review & Submit
###############################################################################

AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
OUTPUT_DIR="./frontend-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$OUTPUT_DIR/screenshots"

# Test credentials
PHONE="9800000001"
PASSWORD="password123"

# Property data
PROPERTY_NAME="Test Automation Hotel"
PROPERTY_TYPE="Hotel"
STREET_ADDRESS="Thamel Street"
CITY="Kathmandu"
STATE="Bagmati"
DISTRICT="Kathmandu"
MUNICIPALITY="Kathmandu Metropolitan City"
WARD="26"
POSTAL_CODE="44600"
CONTACT_PHONE="9841234567"
CONTACT_EMAIL="test@automation.com"
WEBSITE="https://testhotel.com"
CHECKIN_TIME="14:00"
CHECKOUT_TIME="11:00"
DESCRIPTION="A beautiful test hotel for automation testing purposes"

echo ""
echo "========================================"
echo " PROPERTY ONBOARDING AUTOMATION"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""
echo "Property Details:"
echo "  Name: $PROPERTY_NAME"
echo "  Type: $PROPERTY_TYPE"
echo "  Location: $CITY, $STATE"
echo "  Contact: $CONTACT_PHONE"
echo ""

# ── STEP 1: Login ─────────────────────────────────────────────────────────────
echo "[STEP 1/8] Account - Logging in..."
$AB --headed open "$FRONTEND_URL/onboarding"
$AB wait 4000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_step1_account_${TIMESTAMP}.png"

# Click Sign in tab
$AB snapshot -i > /dev/null
SIGNIN_TAB=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button" and .value.name == "Sign in")
  | .key
' 2>/dev/null | head -1)

if [ -n "$SIGNIN_TAB" ]; then
  $AB click "@$SIGNIN_TAB"
  $AB wait 1000
fi

# Fill login form
$AB snapshot -i > /dev/null
PHONE_INPUT=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null | head -1)
PASSWORD_INPUT=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null | tail -1)

$AB fill "@$PHONE_INPUT" "$PHONE"
$AB wait 500
$AB fill "@$PASSWORD_INPUT" "$PASSWORD"
$AB wait 1000

# Click login button
$AB snapshot -i > /dev/null
LOGIN_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Sign in.*continue"; "i"))
  | .key
' 2>/dev/null | head -1)

$AB click "@$LOGIN_BTN"
$AB wait 5000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_step2_property_type_${TIMESTAMP}.png"
echo "✓ Step 1 complete - Logged in"

# ── STEP 2: Property Type ─────────────────────────────────────────────────────
echo ""
echo "[STEP 2/8] Property Type - Selecting $PROPERTY_TYPE..."
$AB snapshot -i > /dev/null

HOTEL_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name == "Hotel")
  | .key
' 2>/dev/null | head -1)

if [ -n "$HOTEL_BTN" ]; then
  $AB click "@$HOTEL_BTN"
  $AB wait 1000
  echo "✓ Hotel selected"
fi

# Click Continue
$AB snapshot -i > /dev/null
CONTINUE_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Continue|Next"; "i"))
  | .key
' 2>/dev/null | head -1)

$AB click "@$CONTINUE_BTN"
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_step3_property_name_${TIMESTAMP}.png"
echo "✓ Step 2 complete - Property type selected"

# ── STEP 3: Property Name ─────────────────────────────────────────────────────
echo ""
echo "[STEP 3/8] Property Name - Entering name..."
$AB snapshot -i > /dev/null

NAME_INPUT=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "textbox")
  | .key
' 2>/dev/null | head -1)

$AB fill "@$NAME_INPUT" "$PROPERTY_NAME"
$AB wait 1000
echo "✓ Property name entered: $PROPERTY_NAME"

# Click Continue
$AB snapshot -i > /dev/null
CONTINUE_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Continue|Next"; "i"))
  | .key
' 2>/dev/null | head -1)

$AB click "@$CONTINUE_BTN"
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_step4_location_${TIMESTAMP}.png"
echo "✓ Step 3 complete - Property name set"

# ── STEP 4: Location ──────────────────────────────────────────────────────────
echo ""
echo "[STEP 4/8] Location - Filling address..."
$AB snapshot -i > /dev/null

# Get all textboxes for location fields
ALL_INPUTS=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "textbox" or .value.role == "combobox")
  | "\(.key):\(.value.name)"
' 2>/dev/null)

echo "Location fields found:"
echo "$ALL_INPUTS"

# Fill location fields (we'll need to identify them by their labels/names)
# This is a simplified version - may need adjustment based on actual field names
$AB eval "
  const inputs = document.querySelectorAll('input, select');
  inputs.forEach(input => {
    const label = input.placeholder || input.name || input.id || '';
    if (label.toLowerCase().includes('street') || label.toLowerCase().includes('address')) {
      input.value = '$STREET_ADDRESS';
      input.dispatchEvent(new Event('input', { bubbles: true }));
      input.dispatchEvent(new Event('change', { bubbles: true }));
    }
    if (label.toLowerCase().includes('city')) {
      input.value = '$CITY';
      input.dispatchEvent(new Event('input', { bubbles: true }));
      input.dispatchEvent(new Event('change', { bubbles: true }));
    }
    if (label.toLowerCase().includes('state') || label.toLowerCase().includes('province')) {
      input.value = '$STATE';
      input.dispatchEvent(new Event('input', { bubbles: true }));
      input.dispatchEvent(new Event('change', { bubbles: true }));
    }
    if (label.toLowerCase().includes('district')) {
      input.value = '$DISTRICT';
      input.dispatchEvent(new Event('input', { bubbles: true }));
      input.dispatchEvent(new Event('change', { bubbles: true }));
    }
    if (label.toLowerCase().includes('municipality')) {
      input.value = '$MUNICIPALITY';
      input.dispatchEvent(new Event('input', { bubbles: true }));
      input.dispatchEvent(new Event('change', { bubbles: true }));
    }
    if (label.toLowerCase().includes('ward')) {
      input.value = '$WARD';
      input.dispatchEvent(new Event('input', { bubbles: true }));
      input.dispatchEvent(new Event('change', { bubbles: true }));
    }
    if (label.toLowerCase().includes('postal') || label.toLowerCase().includes('zip')) {
      input.value = '$POSTAL_CODE';
      input.dispatchEvent(new Event('input', { bubbles: true }));
      input.dispatchEvent(new Event('change', { bubbles: true }));
    }
  });
" > /dev/null 2>&1

$AB wait 2000
echo "✓ Location fields filled"

# Click Continue
$AB snapshot -i > /dev/null
CONTINUE_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Continue|Next"; "i"))
  | .key
' 2>/dev/null | head -1)

$AB click "@$CONTINUE_BTN"
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_step5_contact_${TIMESTAMP}.png"
echo "✓ Step 4 complete - Location set"

# ── STEP 5: Contact ───────────────────────────────────────────────────────────
echo ""
echo "[STEP 5/8] Contact - Filling contact details..."
$AB snapshot -i > /dev/null

# Fill contact fields using eval for React controlled components
$AB eval "
  const inputs = document.querySelectorAll('input');
  inputs.forEach(input => {
    const label = input.placeholder || input.name || input.id || '';
    if (label.toLowerCase().includes('phone')) {
      input.value = '$CONTACT_PHONE';
      input.dispatchEvent(new Event('input', { bubbles: true }));
      input.dispatchEvent(new Event('change', { bubbles: true }));
    }
    if (label.toLowerCase().includes('email')) {
      input.value = '$CONTACT_EMAIL';
      input.dispatchEvent(new Event('input', { bubbles: true }));
      input.dispatchEvent(new Event('change', { bubbles: true }));
    }
    if (label.toLowerCase().includes('website')) {
      input.value = '$WEBSITE';
      input.dispatchEvent(new Event('input', { bubbles: true }));
      input.dispatchEvent(new Event('change', { bubbles: true }));
    }
  });
" > /dev/null 2>&1

$AB wait 2000
echo "✓ Contact details filled"

# Click Continue
$AB snapshot -i > /dev/null
CONTINUE_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Continue|Next"; "i"))
  | .key
' 2>/dev/null | head -1)

$AB click "@$CONTINUE_BTN"
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_step6_operations_${TIMESTAMP}.png"
echo "✓ Step 5 complete - Contact info set"

# ── STEP 6: Operations ────────────────────────────────────────────────────────
echo ""
echo "[STEP 6/8] Operations - Setting operational details..."
$AB snapshot -i > /dev/null

# Fill operations fields
$AB eval "
  const inputs = document.querySelectorAll('input, textarea, select');
  inputs.forEach(input => {
    const label = input.placeholder || input.name || input.id || '';
    if (label.toLowerCase().includes('check-in') || label.toLowerCase().includes('checkin')) {
      input.value = '$CHECKIN_TIME';
      input.dispatchEvent(new Event('input', { bubbles: true }));
      input.dispatchEvent(new Event('change', { bubbles: true }));
    }
    if (label.toLowerCase().includes('check-out') || label.toLowerCase().includes('checkout')) {
      input.value = '$CHECKOUT_TIME';
      input.dispatchEvent(new Event('input', { bubbles: true }));
      input.dispatchEvent(new Event('change', { bubbles: true }));
    }
    if (label.toLowerCase().includes('description')) {
      input.value = '$DESCRIPTION';
      input.dispatchEvent(new Event('input', { bubbles: true }));
      input.dispatchEvent(new Event('change', { bubbles: true }));
    }
  });
" > /dev/null 2>&1

$AB wait 2000
echo "✓ Operations details filled"

# Click Continue
$AB snapshot -i > /dev/null
CONTINUE_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Continue|Next"; "i"))
  | .key
' 2>/dev/null | head -1)

$AB click "@$CONTINUE_BTN"
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_step7_plan_${TIMESTAMP}.png"
echo "✓ Step 6 complete - Operations set"

# ── STEP 7: Plan Selector ─────────────────────────────────────────────────────
echo ""
echo "[STEP 7/8] Plan Selector - Selecting subscription plan..."
$AB snapshot -i > /dev/null

# Select first available plan
PLAN_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Select|Choose"; "i"))
  | .key
' 2>/dev/null | head -1)

if [ -n "$PLAN_BTN" ]; then
  $AB click "@$PLAN_BTN"
  $AB wait 2000
  echo "✓ Plan selected"
fi

# Click Continue
$AB snapshot -i > /dev/null
CONTINUE_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Continue|Next"; "i"))
  | .key
' 2>/dev/null | head -1)

$AB click "@$CONTINUE_BTN"
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_step8_review_${TIMESTAMP}.png"
echo "✓ Step 7 complete - Plan selected"

# ── STEP 8: Review & Submit ───────────────────────────────────────────────────
echo ""
echo "[STEP 8/8] Review - Reviewing and submitting..."
$AB snapshot -i > /dev/null

# Take screenshot of review page
$AB wait 2000

# Find and click Submit button
SUBMIT_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Submit|Create|Finish"; "i"))
  | .key
' 2>/dev/null | head -1)

echo "Submit button ref: $SUBMIT_BTN"

if [ -n "$SUBMIT_BTN" ]; then
  echo "  Submitting property..."
  $AB click "@$SUBMIT_BTN"
  $AB wait 8000
  $AB screenshot "$OUTPUT_DIR/screenshots/onboard_step9_success_${TIMESTAMP}.png"
  echo "✓ Property submitted"
fi

# ── Check for success ─────────────────────────────────────────────────────────
echo ""
echo "Checking for success..."
CURRENT_URL=$($AB get url 2>/dev/null)
echo "Current URL: $CURRENT_URL"

PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null | tr -d '"')
HAS_SUCCESS=$(echo "$PAGE_TEXT" | grep -i "success\|congratulations\|complete" | head -1)
PROPERTY_CODE=$(echo "$PAGE_TEXT" | grep -oP 'PROP-[A-Z0-9]+' | head -1)

$AB close
echo "✓ Browser closed"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "========================================"

if [ -n "$HAS_SUCCESS" ] || [ "$CURRENT_URL" = "$FRONTEND_URL/onboarding/success" ]; then
  echo " ✅ PROPERTY ONBOARDING - SUCCESS!"
  echo "========================================"
  echo ""
  echo "Property Details:"
  echo "  • Name: $PROPERTY_NAME"
  echo "  • Type: $PROPERTY_TYPE"
  echo "  • Location: $CITY, $STATE"
  echo "  • Contact: $CONTACT_PHONE"
  [ -n "$PROPERTY_CODE" ] && echo "  • Property Code: $PROPERTY_CODE"
  EXIT_CODE=0
else
  echo " ❌ PROPERTY ONBOARDING - INCOMPLETE"
  echo "========================================"
  echo ""
  echo "Final URL: $CURRENT_URL"
  echo "Expected: $FRONTEND_URL/onboarding/success"
  EXIT_CODE=1
fi

echo ""
echo "Screenshots saved:"
ls -1 "$OUTPUT_DIR/screenshots/onboard_step"*"_${TIMESTAMP}.png" 2>/dev/null | while read file; do
  echo "  📸 $(basename $file)"
done
echo ""

exit $EXIT_CODE
