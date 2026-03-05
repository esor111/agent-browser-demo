#!/bin/bash

###############################################################################
# PROPERTY ONBOARDING AUTOMATION - COMPLETE VERSION
# Handles both logged-in and logged-out states
# Creates a new property through the full 8-step onboarding process
###############################################################################

AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
OUTPUT_DIR="./frontend-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$OUTPUT_DIR/screenshots"

# Account credentials
PHONE="9800000001"
PASSWORD="password123"

# Property data
PROPERTY_NAME="Test Automation Hotel ${TIMESTAMP}"
CONTACT_PHONE="9841234567"
EMAIL="test@automation.com"
WEBSITE="https://testhotel.com"
DESCRIPTION="A beautiful test hotel for automation testing purposes. Located in the heart of Kathmandu with modern amenities."

echo ""
echo "========================================"
echo " PROPERTY ONBOARDING AUTOMATION"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""

# ── STEP 0: Open onboarding page ──────────────────────────────────────────────
echo "[0] Opening onboarding page..."
$AB --headed open "$FRONTEND_URL/onboarding"
$AB wait 4000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_00_initial_${TIMESTAMP}.png"

# Check if we need to login
PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null | tr -d '"')
NEEDS_LOGIN=$(echo "$PAGE_TEXT" | grep -i "Create your host account\|Sign in" | head -1)

if [ -n "$NEEDS_LOGIN" ]; then
  echo "✓ Need to login first"
  
  # ── STEP 1: Login ───────────────────────────────────────────────────────────
  echo ""
  echo "[1/8] Logging in..."
  
  # Click "Sign in" tab
  $AB eval "
    const buttons = Array.from(document.querySelectorAll('button'));
    const signinBtn = buttons.find(b => b.textContent.trim() === 'Sign in');
    if (signinBtn) signinBtn.click();
  " > /dev/null 2>&1
  $AB wait 1000
  
  # Get phone and password inputs
  $AB snapshot -i > /dev/null
  PHONE_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null | head -1)
  PASSWORD_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null | tail -1)
  
  echo "  Phone ref: $PHONE_REF"
  echo "  Password ref: $PASSWORD_REF"
  
  # Fill login form
  [ -n "$PHONE_REF" ] && $AB fill "@$PHONE_REF" "$PHONE" && $AB wait 500
  [ -n "$PASSWORD_REF" ] && $AB fill "@$PASSWORD_REF" "$PASSWORD" && $AB wait 1000
  
  # Click login button
  $AB eval "
    const buttons = Array.from(document.querySelectorAll('button'));
    const loginBtn = buttons.find(b => b.textContent.includes('Sign in') && b.textContent.includes('continue'));
    if (loginBtn) loginBtn.click();
  " > /dev/null 2>&1
  $AB wait 5000
  $AB screenshot "$OUTPUT_DIR/screenshots/onboard_01_after_login_${TIMESTAMP}.png"
  echo "✓ Logged in"
else
  echo "✓ Already logged in"
fi

# ── STEP 2: Property Type ─────────────────────────────────────────────────────
echo ""
echo "[2/8] Selecting property type..."
$AB snapshot -i > /dev/null

# Click Hotel button
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const hotelBtn = buttons.find(b => b.textContent.includes('Hotel') && b.textContent.includes('Full-service'));
  if (hotelBtn) hotelBtn.click();
" > /dev/null 2>&1
$AB wait 1000

# Click room count (1-5)
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const roomBtn = buttons.find(b => b.textContent.includes('1') && b.textContent.includes('5') && b.textContent.includes('Small'));
  if (roomBtn) roomBtn.click();
" > /dev/null 2>&1
$AB wait 1000

# Click Continue
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const continueBtn = buttons.find(b => b.textContent.trim() === 'Continue');
  if (continueBtn) continueBtn.click();
" > /dev/null 2>&1
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_02_property_type_${TIMESTAMP}.png"
echo "✓ Property type: Hotel (1-5 rooms)"

# ── STEP 3: Property Name ─────────────────────────────────────────────────────
echo ""
echo "[3/8] Entering property name..."
$AB snapshot -i > /dev/null

NAME_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null | head -1)
if [ -n "$NAME_REF" ]; then
  $AB fill "@$NAME_REF" "$PROPERTY_NAME"
  $AB wait 1000
fi

# Click Continue
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const continueBtn = buttons.find(b => b.textContent.trim() === 'Continue');
  if (continueBtn) continueBtn.click();
" > /dev/null 2>&1
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_03_name_${TIMESTAMP}.png"
echo "✓ Property name: $PROPERTY_NAME"

# ── STEP 4: Location ──────────────────────────────────────────────────────────
echo ""
echo "[4/8] Filling location..."
$AB snapshot -i > /dev/null

# Get all textbox refs
REFS=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null)
REFS_ARRAY=($REFS)

echo "  Found ${#REFS_ARRAY[@]} location fields"

# Fill: city, street, state, district, postal
[ -n "${REFS_ARRAY[0]}" ] && $AB fill "@${REFS_ARRAY[0]}" "Kathmandu" && $AB wait 500
[ -n "${REFS_ARRAY[1]}" ] && $AB fill "@${REFS_ARRAY[1]}" "Thamel Street" && $AB wait 500
[ -n "${REFS_ARRAY[2]}" ] && $AB fill "@${REFS_ARRAY[2]}" "Bagmati" && $AB wait 500
[ -n "${REFS_ARRAY[3]}" ] && $AB fill "@${REFS_ARRAY[3]}" "Kathmandu" && $AB wait 500
[ -n "${REFS_ARRAY[4]}" ] && $AB fill "@${REFS_ARRAY[4]}" "44600" && $AB wait 1000

# Click Continue
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const continueBtn = buttons.find(b => b.textContent.trim() === 'Continue');
  if (continueBtn) continueBtn.click();
" > /dev/null 2>&1
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_04_location_${TIMESTAMP}.png"
echo "✓ Location: Kathmandu, Bagmati"

# ── STEP 5: Contact ───────────────────────────────────────────────────────────
echo ""
echo "[5/8] Filling contact..."
$AB snapshot -i > /dev/null

REFS=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null)
REFS_ARRAY=($REFS)

echo "  Found ${#REFS_ARRAY[@]} contact fields"

# Fill: phone, email, website
[ -n "${REFS_ARRAY[0]}" ] && $AB fill "@${REFS_ARRAY[0]}" "$CONTACT_PHONE" && $AB wait 500
[ -n "${REFS_ARRAY[1]}" ] && $AB fill "@${REFS_ARRAY[1]}" "$EMAIL" && $AB wait 500
[ -n "${REFS_ARRAY[2]}" ] && $AB fill "@${REFS_ARRAY[2]}" "$WEBSITE" && $AB wait 1000

# Click Continue
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const continueBtn = buttons.find(b => b.textContent.trim() === 'Continue');
  if (continueBtn) continueBtn.click();
" > /dev/null 2>&1
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_05_contact_${TIMESTAMP}.png"
echo "✓ Contact: $CONTACT_PHONE, $EMAIL"

# ── STEP 6: Operations ────────────────────────────────────────────────────────
echo ""
echo "[6/8] Setting operations..."

# Click check-in 2:00 PM
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const checkinBtn = buttons.find(b => b.textContent.trim() === '2:00 PM');
  if (checkinBtn) checkinBtn.click();
" > /dev/null 2>&1
$AB wait 500

# Click check-out 11:00 AM (second occurrence)
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const checkoutBtns = buttons.filter(b => b.textContent.trim() === '11:00 AM');
  if (checkoutBtns[1]) checkoutBtns[1].click();
" > /dev/null 2>&1
$AB wait 500

# Click 4 stars
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const emptyBtns = buttons.filter(b => b.textContent.trim() === '');
  if (emptyBtns[3]) emptyBtns[3].click();
" > /dev/null 2>&1
$AB wait 500

# Fill description
$AB snapshot -i > /dev/null
DESC_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null | head -1)
if [ -n "$DESC_REF" ]; then
  $AB fill "@$DESC_REF" "$DESCRIPTION"
  $AB wait 1000
fi

# Click Continue
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const continueBtn = buttons.find(b => b.textContent.trim() === 'Continue');
  if (continueBtn) continueBtn.click();
" > /dev/null 2>&1
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_06_operations_${TIMESTAMP}.png"
echo "✓ Operations: Check-in 2PM, Check-out 11AM, 4 stars"

# ── STEP 7: Plan ──────────────────────────────────────────────────────────────
echo ""
echo "[7/8] Selecting plan..."

# Click Free Trial plan
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const planBtn = buttons.find(b => b.textContent.includes('Free Trial'));
  if (planBtn) planBtn.click();
" > /dev/null 2>&1
$AB wait 1000

# Click Continue
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const continueBtn = buttons.find(b => b.textContent.trim() === 'Continue');
  if (continueBtn) continueBtn.click();
" > /dev/null 2>&1
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_07_plan_${TIMESTAMP}.png"
echo "✓ Plan: Free Trial"

# ── STEP 8: Submit ────────────────────────────────────────────────────────────
echo ""
echo "[8/8] Submitting..."

# Click Register My Property
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const submitBtn = buttons.find(b => b.textContent.includes('Register My Property'));
  if (submitBtn) submitBtn.click();
" > /dev/null 2>&1
$AB wait 8000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_08_success_${TIMESTAMP}.png"

# ── Check Result ──────────────────────────────────────────────────────────────
CURRENT_URL=$($AB get url 2>/dev/null)
PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null | tr -d '"')
PROPERTY_CODE=$(echo "$PAGE_TEXT" | grep -oP '[A-Z]+-[A-Z]+-[A-Z]+-[0-9]+' | head -1)

$AB close

echo ""
echo "========================================"
if [ "$CURRENT_URL" = "$FRONTEND_URL/onboarding/success" ]; then
  echo " ✅ PROPERTY ONBOARDING - SUCCESS!"
  echo "========================================"
  echo ""
  echo "Property Created:"
  echo "  • Name: $PROPERTY_NAME"
  echo "  • Code: $PROPERTY_CODE"
  echo "  • Type: Hotel (1-5 rooms)"
  echo "  • Location: Kathmandu, Bagmati"
  echo "  • Contact: $CONTACT_PHONE"
  echo "  • Email: $EMAIL"
  echo "  • Check-in: 2:00 PM"
  echo "  • Check-out: 11:00 AM"
  echo "  • Rating: 4 stars"
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
echo "Screenshots saved in: $OUTPUT_DIR/screenshots/"
echo ""

exit $EXIT_CODE
