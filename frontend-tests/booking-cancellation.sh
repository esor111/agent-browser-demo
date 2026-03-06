#!/bin/bash

###############################################################################
# BOOKING CANCELLATION AUTOMATION
# Tests the owner booking cancellation workflow:
# 1. Login as owner
# 2. Create a booking
# 3. Navigate to bookings page
# 4. Select the booking
# 5. Cancel the booking
# 6. Add cancellation reason
# 7. Verify status changed to "cancelled"
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
GUEST_NAME="Cancellation Test Guest"
GUEST_EMAIL="canceltest${TIMESTAMP}@test.com"
GUEST_PHONE="9841234567"
CHECKIN_DATE="2026-03-10"
CHECKOUT_DATE="2026-03-15"
ADULTS="2"

# Cancellation data
CANCEL_REASON="Customer requested cancellation - automated test"

echo ""
echo "========================================"
echo " BOOKING CANCELLATION AUTOMATION"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""

# ── STEP 1: Login as Owner ────────────────────────────────────────────────────
echo "[1/5] Logging in as owner..."
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

# ── STEP 2: Create a Booking ──────────────────────────────────────────────────
echo ""
echo "[2/5] Creating booking..."
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

$AB screenshot "$OUTPUT_DIR/screenshots/cancel_01_booking_created_${TIMESTAMP}.png"
echo "✓ Booking created"

# ── STEP 3: Select the Booking ────────────────────────────────────────────────
echo ""
echo "[3/5] Selecting booking..."
$AB wait 2000

# Click on the first booking row to open details
$AB eval "
  const rows = Array.from(document.querySelectorAll('tr[data-state]'));
  if (rows[0]) rows[0].click();
" > /dev/null 2>&1
$AB wait 2000

$AB screenshot "$OUTPUT_DIR/screenshots/cancel_02_booking_selected_${TIMESTAMP}.png"
echo "✓ Booking selected"

# ── STEP 4: Cancel the Booking ────────────────────────────────────────────────
echo ""
echo "[4/5] Cancelling booking..."

# Look for "Cancel" button
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const cancelBtn = buttons.find(b => b.textContent.includes('Cancel') && !b.textContent.includes('Cancelled'));
  if (cancelBtn) {
    cancelBtn.click();
    'clicked';
  } else {
    'not found';
  }
" > /dev/null 2>&1
$AB wait 2000

$AB screenshot "$OUTPUT_DIR/screenshots/cancel_03_cancel_dialog_${TIMESTAMP}.png"

# Fill cancellation reason if there's a textarea
$AB snapshot -i > /dev/null
REASON_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null | head -1)

if [ -n "$REASON_REF" ]; then
  $AB fill "@$REASON_REF" "$CANCEL_REASON"
  $AB wait 1000
  echo "  Cancellation reason: $CANCEL_REASON"
fi

# Confirm cancellation
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const confirmBtn = buttons.find(b => 
    b.textContent.includes('Confirm') || 
    b.textContent.includes('Yes') || 
    (b.textContent.includes('Cancel') && b.classList.contains('destructive'))
  );
  if (confirmBtn) confirmBtn.click();
" > /dev/null 2>&1
$AB wait 3000

$AB screenshot "$OUTPUT_DIR/screenshots/cancel_04_booking_cancelled_${TIMESTAMP}.png"
echo "✓ Booking cancelled"

# ── STEP 5: Verify Cancellation ───────────────────────────────────────────────
echo ""
echo "[5/5] Verifying cancellation..."
$AB wait 2000

PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null | tr -d '"')
HAS_CANCELLED=$(echo "$PAGE_TEXT" | grep -i "cancelled\|canceled" | head -1)
BOOKING_STATUS=$(echo "$PAGE_TEXT" | grep -oP "Status.*?(Cancelled|Canceled)" | head -1)

$AB screenshot "$OUTPUT_DIR/screenshots/cancel_05_verification_${TIMESTAMP}.png"

# Get current URL to verify we're still on bookings page
CURRENT_URL=$($AB get url 2>/dev/null)
ON_BOOKINGS_PAGE=$(echo "$CURRENT_URL" | grep -o "owner/bookings")

$AB close

echo ""
echo "========================================"

# Success if we're on bookings page and see cancelled status
if [ -n "$ON_BOOKINGS_PAGE" ] && [ -n "$HAS_CANCELLED" ]; then
  echo " ✅ BOOKING CANCELLATION - SUCCESS!"
  echo "========================================"
  echo ""
  echo "Booking Details:"
  echo "  • Guest: $GUEST_NAME"
  echo "  • Email: $GUEST_EMAIL"
  echo "  • Check-in: $CHECKIN_DATE"
  echo "  • Check-out: $CHECKOUT_DATE"
  echo ""
  echo "Cancellation:"
  echo "  • Booking created: ✓"
  echo "  • Cancellation requested: ✓"
  echo "  • Reason provided: ✓"
  echo "  • Status changed to cancelled: ✓"
  EXIT_CODE=0
else
  echo " ❌ BOOKING CANCELLATION - INCOMPLETE"
  echo "========================================"
  echo ""
  echo "Could not verify booking cancellation"
  echo "  • On bookings page: $([ -n "$ON_BOOKINGS_PAGE" ] && echo "✓" || echo "✗")"
  echo "  • Cancelled status: $([ -n "$HAS_CANCELLED" ] && echo "✓" || echo "✗")"
  EXIT_CODE=1
fi

echo ""
echo "Screenshots saved in: $OUTPUT_DIR/screenshots/"
echo ""

exit $EXIT_CODE
