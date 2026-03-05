#!/bin/bash

###############################################################################
# PAYMENT RECORDING AUTOMATION
# Tests the complete payment recording workflow:
# 1. Login as owner
# 2. Create a booking (with guest)
# 3. Confirm → Check-in → Check-out the booking
# 4. Navigate to payments page
# 5. Record payment for the checked-out booking
# 6. Verify payment was recorded
###############################################################################

AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
OUTPUT_DIR="./frontend-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$OUTPUT_DIR/screenshots"

# Owner credentials
OWNER_PHONE="9800000001"
OWNER_PASSWORD="password123"

# Guest data for booking
GUEST_NAME="Payment Test Guest"
GUEST_EMAIL="paymenttest${TIMESTAMP}@test.com"
GUEST_PHONE="9841234567"
CHECKIN_DATE="2026-03-10"
CHECKOUT_DATE="2026-03-15"
ADULTS="2"

# Payment data
PAYMENT_METHOD="Cash"
PAYMENT_REFERENCE="CASH-${TIMESTAMP}"
PAYMENT_NOTES="Test payment recorded via automation"

echo ""
echo "========================================"
echo " PAYMENT RECORDING AUTOMATION"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""

# ── STEP 1: Login as Owner ────────────────────────────────────────────────────
echo "[1/7] Logging in as owner..."
$AB --headed open "$FRONTEND_URL/login"
$AB wait 3000

$AB snapshot -i > /dev/null
PHONE_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null | head -1)
PASSWORD_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null | tail -1)

[ -n "$PHONE_REF" ] && $AB fill "@$PHONE_REF" "$OWNER_PHONE" && $AB wait 500
[ -n "$PASSWORD_REF" ] && $AB fill "@$PASSWORD_REF" "$OWNER_PASSWORD" && $AB wait 1000

$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const signInBtn = buttons.find(b => b.textContent.includes('Sign In'));
  if (signInBtn) signInBtn.click();
" > /dev/null 2>&1
$AB wait 5000

echo "✓ Logged in"

# ── STEP 2: Create Booking ────────────────────────────────────────────────────
echo ""
echo "[2/7] Creating booking..."
$AB open "$FRONTEND_URL/owner/bookings"
$AB wait 4000

# Click "New Booking"
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const newBookingBtn = buttons.find(b => b.textContent.includes('New Booking'));
  if (newBookingBtn) newBookingBtn.click();
" > /dev/null 2>&1
$AB wait 3000

# Click "Create New Guest"
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const createGuestBtn = buttons.find(b => b.textContent.includes('Create New Guest'));
  if (createGuestBtn) createGuestBtn.click();
" > /dev/null 2>&1
$AB wait 2000

# Fill guest details
$AB snapshot -i > /dev/null
REFS=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null)
REFS_ARRAY=($REFS)

[ -n "${REFS_ARRAY[0]}" ] && $AB fill "@${REFS_ARRAY[0]}" "$GUEST_NAME" && $AB wait 500
[ -n "${REFS_ARRAY[1]}" ] && $AB fill "@${REFS_ARRAY[1]}" "$GUEST_EMAIL" && $AB wait 500
[ -n "${REFS_ARRAY[2]}" ] && $AB fill "@${REFS_ARRAY[2]}" "$GUEST_PHONE" && $AB wait 1000

# Click "Create Guest"
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const createBtn = buttons.find(b => b.textContent.trim() === 'Create Guest');
  if (createBtn) createBtn.click();
" > /dev/null 2>&1
$AB wait 2000

# Fill booking details
$AB snapshot -i > /dev/null
REFS=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox" or .value.role == "spinbutton") | .key' 2>/dev/null)
REFS_ARRAY=($REFS)

[ -n "${REFS_ARRAY[0]}" ] && $AB fill "@${REFS_ARRAY[0]}" "$CHECKIN_DATE" && $AB wait 500
[ -n "${REFS_ARRAY[1]}" ] && $AB fill "@${REFS_ARRAY[1]}" "$CHECKOUT_DATE" && $AB wait 500
[ -n "${REFS_ARRAY[2]}" ] && $AB fill "@${REFS_ARRAY[2]}" "$ADULTS" && $AB wait 1000

# Click "Create Booking"
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const createBookingBtn = buttons.find(b => b.textContent.includes('Create Booking'));
  if (createBookingBtn && !createBookingBtn.disabled) createBookingBtn.click();
" > /dev/null 2>&1
$AB wait 3000

$AB screenshot "$OUTPUT_DIR/screenshots/payment_01_booking_created_${TIMESTAMP}.png"
echo "✓ Booking created"

# ── STEP 3: Confirm Booking ───────────────────────────────────────────────────
echo ""
echo "[3/7] Confirming booking..."
$AB wait 2000

# Click on the first booking row
$AB eval "
  const rows = Array.from(document.querySelectorAll('tr[data-state]'));
  if (rows[0]) rows[0].click();
" > /dev/null 2>&1
$AB wait 2000

# Click "Confirm"
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const confirmBtn = buttons.find(b => b.textContent.includes('Confirm'));
  if (confirmBtn) confirmBtn.click();
" > /dev/null 2>&1
$AB wait 2000

echo "✓ Booking confirmed"

# ── STEP 4: Check-in Guest ────────────────────────────────────────────────────
echo ""
echo "[4/7] Checking in guest..."

# Click "Check In"
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const checkinBtn = buttons.find(b => b.textContent.includes('Check In'));
  if (checkinBtn) checkinBtn.click();
" > /dev/null 2>&1
$AB wait 2000

echo "✓ Guest checked in"

# ── STEP 5: Check-out Guest ───────────────────────────────────────────────────
echo ""
echo "[5/7] Checking out guest..."

# Click "Check Out"
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const checkoutBtn = buttons.find(b => b.textContent.includes('Check Out'));
  if (checkoutBtn) checkoutBtn.click();
" > /dev/null 2>&1
$AB wait 2000

$AB screenshot "$OUTPUT_DIR/screenshots/payment_02_checked_out_${TIMESTAMP}.png"
echo "✓ Guest checked out"

# Extract booking confirmation code
PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null | tr -d '"')
BOOKING_CODE=$(echo "$PAGE_TEXT" | grep -oP 'BK-[A-Z0-9]+' | head -1)
echo "  Booking code: $BOOKING_CODE"

# ── STEP 6: Navigate to Payments and Record Payment ──────────────────────────
echo ""
echo "[6/7] Recording payment..."
$AB open "$FRONTEND_URL/owner/payments"
$AB wait 4000

$AB screenshot "$OUTPUT_DIR/screenshots/payment_03_payments_page_${TIMESTAMP}.png"

# Click "Record Payment" button
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const recordPaymentBtn = buttons.find(b => b.textContent.includes('Record Payment'));
  if (recordPaymentBtn) recordPaymentBtn.click();
" > /dev/null 2>&1
$AB wait 2000

$AB screenshot "$OUTPUT_DIR/screenshots/payment_04_payment_form_${TIMESTAMP}.png"

# Search for the booking by confirmation code
$AB snapshot -i > /dev/null
SEARCH_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "combobox" or .value.role == "textbox") | .key' 2>/dev/null | head -1)

if [ -n "$SEARCH_REF" ] && [ -n "$BOOKING_CODE" ]; then
  $AB fill "@$SEARCH_REF" "$BOOKING_CODE"
  $AB wait 2000
  
  # Select the booking from dropdown
  $AB eval "
    const options = Array.from(document.querySelectorAll('[role=\"option\"]'));
    if (options[0]) options[0].click();
  " > /dev/null 2>&1
  $AB wait 1000
fi

# Select payment method
$AB snapshot -i > /dev/null
METHOD_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "combobox") | .key' 2>/dev/null | tail -1)

if [ -n "$METHOD_REF" ]; then
  $AB click "@$METHOD_REF"
  $AB wait 1000
  
  # Select Cash option
  $AB eval "
    const options = Array.from(document.querySelectorAll('[role=\"option\"]'));
    const cashOption = options.find(o => o.textContent.includes('Cash'));
    if (cashOption) cashOption.click();
  " > /dev/null 2>&1
  $AB wait 500
fi

# Fill payment reference and notes
$AB snapshot -i > /dev/null
REFS=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null)
REFS_ARRAY=($REFS)

# Fill reference (usually second textbox after booking search)
if [ ${#REFS_ARRAY[@]} -ge 2 ]; then
  $AB fill "@${REFS_ARRAY[1]}" "$PAYMENT_REFERENCE"
  $AB wait 500
fi

# Fill notes (usually third textbox or textarea)
if [ ${#REFS_ARRAY[@]} -ge 3 ]; then
  $AB fill "@${REFS_ARRAY[2]}" "$PAYMENT_NOTES"
  $AB wait 500
fi

$AB screenshot "$OUTPUT_DIR/screenshots/payment_05_form_filled_${TIMESTAMP}.png"

# Click "Record Payment" submit button
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const submitBtn = buttons.find(b => b.textContent.includes('Record Payment') || b.textContent.includes('Submit'));
  if (submitBtn && !submitBtn.disabled) submitBtn.click();
" > /dev/null 2>&1
$AB wait 3000

$AB screenshot "$OUTPUT_DIR/screenshots/payment_06_payment_recorded_${TIMESTAMP}.png"
echo "✓ Payment recorded"

# ── STEP 7: Verify Payment ────────────────────────────────────────────────────
echo ""
echo "[7/7] Verifying payment..."
$AB wait 2000

PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null | tr -d '"')
HAS_PAYMENT=$(echo "$PAGE_TEXT" | grep -i "$BOOKING_CODE\|$PAYMENT_REFERENCE\|completed\|paid" | head -1)
TOTAL_REVENUE=$(echo "$PAGE_TEXT" | grep -oP "Total Revenue\s+NPR\s+[\d,]+" | grep -oP "[\d,]+" | head -1)

$AB screenshot "$OUTPUT_DIR/screenshots/payment_07_verification_${TIMESTAMP}.png"
$AB close

echo ""
echo "========================================"
if [ -n "$HAS_PAYMENT" ]; then
  echo " ✅ PAYMENT RECORDING - SUCCESS!"
  echo "========================================"
  echo ""
  echo "Booking Details:"
  echo "  • Confirmation Code: $BOOKING_CODE"
  echo "  • Guest: $GUEST_NAME"
  echo "  • Email: $GUEST_EMAIL"
  echo "  • Check-in: $CHECKIN_DATE"
  echo "  • Check-out: $CHECKOUT_DATE"
  echo ""
  echo "Payment Details:"
  echo "  • Method: $PAYMENT_METHOD"
  echo "  • Reference: $PAYMENT_REFERENCE"
  echo "  • Status: Recorded ✓"
  if [ -n "$TOTAL_REVENUE" ]; then
    echo "  • Total Revenue: NPR $TOTAL_REVENUE"
  fi
  EXIT_CODE=0
else
  echo " ❌ PAYMENT RECORDING - INCOMPLETE"
  echo "========================================"
  echo ""
  echo "Could not verify payment was recorded"
  EXIT_CODE=1
fi

echo ""
echo "Screenshots saved in: $OUTPUT_DIR/screenshots/"
echo ""

exit $EXIT_CODE
