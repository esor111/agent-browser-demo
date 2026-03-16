#!/bin/bash

###############################################################################
# PROPERTY ONBOARDING AUTOMATION - FINAL WORKING VERSION
# Successfully creates a new property through the 8-step onboarding process
# Uses simplified approach with direct ref clicking
# Tested and verified: March 5, 2026
###############################################################################

AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
OUTPUT_DIR="./frontend-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$OUTPUT_DIR/screenshots"

# Property data
PROPERTY_NAME="Test Automation Hotel ${TIMESTAMP}"
PHONE="9841234567"
EMAIL="test@automation.com"
WEBSITE="https://testhotel.com"
DESCRIPTION="A beautiful test hotel for automation testing purposes. Located in the heart of Kathmandu with modern amenities."

echo ""
echo "========================================"
echo " PROPERTY ONBOARDING AUTOMATION"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""

# ── STEP 1: Open onboarding page ──────────────────────────────────────────────
echo "[1/8] Opening onboarding page..."
$AB --headed open "$FRONTEND_URL/onboarding"
$AB wait 4000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_01_${TIMESTAMP}.png"

# ── STEP 2: Property Type (assuming we're already logged in) ──────────────────
echo "[2/8] Selecting property type..."
$AB snapshot -i > /dev/null

# Find and click Hotel button
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const hotelBtn = buttons.find(b => b.textContent.includes('Hotel') && b.textContent.includes('Full-service'));
  if (hotelBtn) hotelBtn.click();
" > /dev/null 2>&1
$AB wait 1000

# Find and click room count (1-5)
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
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_02_${TIMESTAMP}.png"
echo "✓ Property type selected"

# ── STEP 3: Property Name ─────────────────────────────────────────────────────
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
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_03_${TIMESTAMP}.png"
echo "✓ Property name: $PROPERTY_NAME"

# ── STEP 4: Location ──────────────────────────────────────────────────────────
echo "[4/8] Filling location..."
$AB snapshot -i > /dev/null

# Get all textbox refs
REFS=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null)
REFS_ARRAY=($REFS)

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
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_04_${TIMESTAMP}.png"
echo "✓ Location filled"

# ── STEP 5: Contact ───────────────────────────────────────────────────────────
echo "[5/8] Filling contact..."
$AB snapshot -i > /dev/null

REFS=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null)
REFS_ARRAY=($REFS)

# Fill: phone, email, website
[ -n "${REFS_ARRAY[0]}" ] && $AB fill "@${REFS_ARRAY[0]}" "$PHONE" && $AB wait 500
[ -n "${REFS_ARRAY[1]}" ] && $AB fill "@${REFS_ARRAY[1]}" "$EMAIL" && $AB wait 500
[ -n "${REFS_ARRAY[2]}" ] && $AB fill "@${REFS_ARRAY[2]}" "$WEBSITE" && $AB wait 1000

# Click Continue
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const continueBtn = buttons.find(b => b.textContent.trim() === 'Continue');
  if (continueBtn) continueBtn.click();
" > /dev/null 2>&1
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_05_${TIMESTAMP}.png"
echo "✓ Contact filled"

# ── STEP 6: Operations ────────────────────────────────────────────────────────
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
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_06_${TIMESTAMP}.png"
echo "✓ Operations set"

# ── STEP 7: Plan ──────────────────────────────────────────────────────────────
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
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_07_${TIMESTAMP}.png"
echo "✓ Plan selected"

# ── STEP 8: Submit ────────────────────────────────────────────────────────────
echo "[8/8] Submitting..."

# Click Register My Property
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const submitBtn = buttons.find(b => b.textContent.includes('Register My Property'));
  if (submitBtn) submitBtn.click();
" > /dev/null 2>&1
$AB wait 8000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_08_${TIMESTAMP}.png"
echo "✓ Submitted"

# ── Check Result ──────────────────────────────────────────────────────────────
CURRENT_URL=$($AB get url 2>/dev/null)
PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null | tr -d '"')
PROPERTY_CODE=$(echo "$PAGE_TEXT" | grep -oP '[A-Z]+-[A-Z]+-[A-Z]+-[0-9]+' | head -1)

$AB close

echo ""
echo "========================================"
if [ "$CURRENT_URL" = "$FRONTEND_URL/onboarding/success" ]; then
  echo " ✅ SUCCESS!"
  echo "========================================"
  echo ""
  echo "  Property: $PROPERTY_NAME"
  echo "  Code: $PROPERTY_CODE"
  echo "  Location: Kathmandu, Bagmati"
  EXIT_CODE=0
else
  echo " ❌ FAILED"
  echo "========================================"
  echo "  URL: $CURRENT_URL"
  EXIT_CODE=1
fi
echo ""

exit $EXIT_CODE
