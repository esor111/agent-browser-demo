#!/bin/bash

###############################################################################
# PROPERTY ONBOARDING - NEW USER REGISTRATION
# Registers a BRAND NEW user and creates a property
# Full flow: Register Account → Create Property
###############################################################################

AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
OUTPUT_DIR="./frontend-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$OUTPUT_DIR/screenshots"

# NEW USER credentials (unique each time)
FIRST_NAME="Test"
LAST_NAME="User${TIMESTAMP}"
NEW_PHONE="98$(date +%s | tail -c 9)"  # Generate unique phone: 98XXXXXXXXX
NEW_EMAIL="testuser${TIMESTAMP}@automation.com"
NEW_PASSWORD="TestPass123!"

# Property data
PROPERTY_NAME="New User Hotel ${TIMESTAMP}"
CONTACT_PHONE="9841234567"
WEBSITE="https://newuserhotel.com"
DESCRIPTION="A beautiful hotel created by a newly registered user for automation testing."

echo ""
echo "========================================"
echo " NEW USER REGISTRATION + PROPERTY"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""
echo "New User:"
echo "  Name: $FIRST_NAME $LAST_NAME"
echo "  Phone: $NEW_PHONE"
echo "  Email: $NEW_EMAIL"
echo ""
echo "Property:"
echo "  Name: $PROPERTY_NAME"
echo ""

# ── STEP 0: Logout first (clear session) ─────────────────────────────────────
echo "[0/9] Clearing session (logout)..."
$AB --headed open "$FRONTEND_URL/logout"
$AB wait 2000

# ── STEP 1: Open onboarding page ──────────────────────────────────────────────
echo "[1/9] Opening onboarding page..."
$AB open "$FRONTEND_URL/onboarding"
$AB wait 4000
$AB screenshot "$OUTPUT_DIR/screenshots/newuser_01_initial_${TIMESTAMP}.png"

# ── STEP 2: Register New Account ──────────────────────────────────────────────
echo ""
echo "[2/9] Registering new user..."

# Make sure we're on "Create account" tab (should be default)
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const createBtn = buttons.find(b => b.textContent.trim() === 'Create account');
  if (createBtn) createBtn.click();
" > /dev/null 2>&1
$AB wait 1000

# Get all textbox refs for registration form
$AB snapshot -i > /dev/null
REFS=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null)
REFS_ARRAY=($REFS)

echo "  Found ${#REFS_ARRAY[@]} registration fields"
echo "  Filling: First Name, Last Name, Phone, Email, Password"

# Fill registration form
# Order: First Name, Last Name, Phone, Email, Password
[ -n "${REFS_ARRAY[0]}" ] && $AB fill "@${REFS_ARRAY[0]}" "$FIRST_NAME" && $AB wait 500
[ -n "${REFS_ARRAY[1]}" ] && $AB fill "@${REFS_ARRAY[1]}" "$LAST_NAME" && $AB wait 500
[ -n "${REFS_ARRAY[2]}" ] && $AB fill "@${REFS_ARRAY[2]}" "$NEW_PHONE" && $AB wait 500
[ -n "${REFS_ARRAY[3]}" ] && $AB fill "@${REFS_ARRAY[3]}" "$NEW_EMAIL" && $AB wait 500
[ -n "${REFS_ARRAY[4]}" ] && $AB fill "@${REFS_ARRAY[4]}" "$NEW_PASSWORD" && $AB wait 1000

$AB screenshot "$OUTPUT_DIR/screenshots/newuser_02_registration_filled_${TIMESTAMP}.png"

# Click "Create account & continue" button
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const registerBtn = buttons.find(b => b.textContent.includes('Create account') && b.textContent.includes('continue'));
  if (registerBtn) registerBtn.click();
" > /dev/null 2>&1
$AB wait 5000
$AB screenshot "$OUTPUT_DIR/screenshots/newuser_03_after_registration_${TIMESTAMP}.png"
echo "✓ New user registered: $FIRST_NAME $LAST_NAME ($NEW_PHONE)"

# ── STEP 3: Property Type ─────────────────────────────────────────────────────
echo ""
echo "[3/9] Selecting property type..."

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
$AB screenshot "$OUTPUT_DIR/screenshots/newuser_04_property_type_${TIMESTAMP}.png"
echo "✓ Property type: Hotel (1-5 rooms)"

# ── STEP 4: Property Name ─────────────────────────────────────────────────────
echo ""
echo "[4/9] Entering property name..."
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
$AB screenshot "$OUTPUT_DIR/screenshots/newuser_05_name_${TIMESTAMP}.png"
echo "✓ Property name: $PROPERTY_NAME"

# ── STEP 5: Location ──────────────────────────────────────────────────────────
echo ""
echo "[5/9] Filling location..."
$AB snapshot -i > /dev/null

REFS=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null)
REFS_ARRAY=($REFS)

echo "  Found ${#REFS_ARRAY[@]} location fields"

# Fill: city, street, state, district, postal
[ -n "${REFS_ARRAY[0]}" ] && $AB fill "@${REFS_ARRAY[0]}" "Pokhara" && $AB wait 500
[ -n "${REFS_ARRAY[1]}" ] && $AB fill "@${REFS_ARRAY[1]}" "Lakeside Street" && $AB wait 500
[ -n "${REFS_ARRAY[2]}" ] && $AB fill "@${REFS_ARRAY[2]}" "Gandaki" && $AB wait 500
[ -n "${REFS_ARRAY[3]}" ] && $AB fill "@${REFS_ARRAY[3]}" "Kaski" && $AB wait 500
[ -n "${REFS_ARRAY[4]}" ] && $AB fill "@${REFS_ARRAY[4]}" "33700" && $AB wait 1000

# Click Continue
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const continueBtn = buttons.find(b => b.textContent.trim() === 'Continue');
  if (continueBtn) continueBtn.click();
" > /dev/null 2>&1
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/newuser_06_location_${TIMESTAMP}.png"
echo "✓ Location: Pokhara, Gandaki"

# ── STEP 6: Contact ───────────────────────────────────────────────────────────
echo ""
echo "[6/9] Filling contact..."
$AB snapshot -i > /dev/null

REFS=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null)
REFS_ARRAY=($REFS)

echo "  Found ${#REFS_ARRAY[@]} contact fields"

# Fill: phone, email, website
[ -n "${REFS_ARRAY[0]}" ] && $AB fill "@${REFS_ARRAY[0]}" "$CONTACT_PHONE" && $AB wait 500
[ -n "${REFS_ARRAY[1]}" ] && $AB fill "@${REFS_ARRAY[1]}" "$NEW_EMAIL" && $AB wait 500
[ -n "${REFS_ARRAY[2]}" ] && $AB fill "@${REFS_ARRAY[2]}" "$WEBSITE" && $AB wait 1000

# Click Continue
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const continueBtn = buttons.find(b => b.textContent.trim() === 'Continue');
  if (continueBtn) continueBtn.click();
" > /dev/null 2>&1
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/newuser_07_contact_${TIMESTAMP}.png"
echo "✓ Contact: $CONTACT_PHONE, $NEW_EMAIL"

# ── STEP 7: Operations ────────────────────────────────────────────────────────
echo ""
echo "[7/9] Setting operations..."

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

# Click 5 stars
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const emptyBtns = buttons.filter(b => b.textContent.trim() === '');
  if (emptyBtns[4]) emptyBtns[4].click();
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
$AB screenshot "$OUTPUT_DIR/screenshots/newuser_08_operations_${TIMESTAMP}.png"
echo "✓ Operations: Check-in 2PM, Check-out 11AM, 5 stars"

# ── STEP 8: Plan ──────────────────────────────────────────────────────────────
echo ""
echo "[8/9] Selecting plan..."

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
$AB screenshot "$OUTPUT_DIR/screenshots/newuser_09_plan_${TIMESTAMP}.png"
echo "✓ Plan: Free Trial"

# ── STEP 9: Submit ────────────────────────────────────────────────────────────
echo ""
echo "[9/9] Submitting..."

# Click Register My Property
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const submitBtn = buttons.find(b => b.textContent.includes('Register My Property'));
  if (submitBtn) submitBtn.click();
" > /dev/null 2>&1
$AB wait 8000
$AB screenshot "$OUTPUT_DIR/screenshots/newuser_10_success_${TIMESTAMP}.png"

# ── Check Result ──────────────────────────────────────────────────────────────
CURRENT_URL=$($AB get url 2>/dev/null)
PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null | tr -d '"')
PROPERTY_CODE=$(echo "$PAGE_TEXT" | grep -oP '[A-Z]+-[A-Z]+-[A-Z]+-[0-9]+' | head -1)

$AB close

echo ""
echo "========================================"
if [ "$CURRENT_URL" = "$FRONTEND_URL/onboarding/success" ]; then
  echo " ✅ NEW USER + PROPERTY - SUCCESS!"
  echo "========================================"
  echo ""
  echo "New User Created:"
  echo "  • Name: $FIRST_NAME $LAST_NAME"
  echo "  • Phone: $NEW_PHONE"
  echo "  • Email: $NEW_EMAIL"
  echo "  • Password: $NEW_PASSWORD"
  echo ""
  echo "Property Created:"
  echo "  • Name: $PROPERTY_NAME"
  echo "  • Code: $PROPERTY_CODE"
  echo "  • Type: Hotel (1-5 rooms)"
  echo "  • Location: Pokhara, Gandaki"
  echo "  • Contact: $CONTACT_PHONE"
  echo "  • Email: $NEW_EMAIL"
  echo "  • Check-in: 2:00 PM"
  echo "  • Check-out: 11:00 AM"
  echo "  • Rating: 5 stars"
  EXIT_CODE=0
else
  echo " ❌ NEW USER + PROPERTY - INCOMPLETE"
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
