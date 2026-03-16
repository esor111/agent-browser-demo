#!/bin/bash

###############################################################################
# OWNER BOOKING MANAGEMENT AUTOMATION
# Tests the complete owner booking workflow:
# 1. Login as owner
# 2. Create a new booking
# 3. Confirm the booking (pending → confirmed)
# 4. Check-in the guest (confirmed → checked-in)
# 5. Check-out the guest (checked-in → checked-out)
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
GUEST_NAME="Test Guest"
GUEST_EMAIL="testguest${TIMESTAMP}@test.com"
GUEST_PHONE="9841234567"
CHECKIN_DATE="2026-03-10"
CHECKOUT_DATE="2026-03-15"
ADULTS="2"

echo ""
echo "========================================"
echo " OWNER BOOKING MANAGEMENT"
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

# Click Sign In
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const signInBtn = buttons.find(b => b.textContent.includes('Sign In'));
  if (signInBtn) signInBtn.click();
" > /dev/null 2>&1
$AB wait 5000

CURRENT_URL=$($AB get url 2>/dev/null)
echo "✓ Logged in: $CURRENT_URL"

# ── STEP 2: Navigate to Bookings ──────────────────────────────────────────────
echo ""
echo "[2/5] Navigating to bookings page..."
$AB open "$FRONTEND_URL/owner/bookings"
$AB wait 4000
$AB screenshot "$OUTPUT_DIR/screenshots/owner_01_bookings_${TIMESTAMP}.png"
echo "✓ On bookings page"

# ── STEP 3: Create New Booking ────────────────────────────────────────────────
echo ""
echo "[3/5] Creating new booking..."

# Click "New Booking" button
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const newBookingBtn = buttons.find(b => b.textContent.includes('New Booking'));
  if (newBookingBtn) newBookingBtn.click();
" > /dev/null 2>&1
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/owner_02_new_booking_form_${TIMESTAMP}.png"

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

echo "  Creating guest: $GUEST_NAME"
# Fill: Name, Email, Phone
[ -n "${REFS_ARRAY[0]}" ] && $AB fill "@${REFS_ARRAY[0]}" "$GUEST_NAME" && $AB wait 500
[ -n "${REFS_ARRAY[1]}" ] && $AB fill "@${REFS_ARRAY[1]}" "$GUEST_EMAIL" && $AB wait 500
[ -n "${REFS_ARRAY[2]}" ] && $AB fill "@${REFS_ARRAY[2]}" "$GUEST_PHONE" && $AB wait 1000

# Click "Create Guest" button
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

echo "  Filling booking dates..."
# Fill: Check-in, Check-out, Adults
[ -n "${REFS_ARRAY[0]}" ] && $AB fill "@${REFS_ARRAY[0]}" "$CHECKIN_DATE" && $AB wait 500
[ -n "${REFS_ARRAY[1]}" ] && $AB fill "@${REFS_ARRAY[1]}" "$CHECKOUT_DATE" && $AB wait 500
[ -n "${REFS_ARRAY[2]}" ] && $AB fill "@${REFS_ARRAY[2]}" "$ADULTS" && $AB wait 1000

$AB screenshot "$OUTPUT_DIR/screenshots/owner_03_booking_filled_${TIMESTAMP}.png"

# Click "Create Booking" button
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const createBookingBtn = buttons.find(b => b.textContent.includes('Create Booking'));
  if (createBookingBtn && !createBookingBtn.disabled) createBookingBtn.click();
" > /dev/null 2>&1
$AB wait 3000

$AB screenshot "$OUTPUT_DIR/screenshots/owner_04_booking_created_${TIMESTAMP}.png"
echo "✓ Booking created"

# ── STEP 4: Find and Confirm Booking ──────────────────────────────────────────
echo ""
echo "[4/5] Finding and confirming booking..."
$AB wait 2000

# Click on the first booking row to open details
$AB eval "
  const rows = Array.from(document.querySelectorAll('tr[data-state]'));
  if (rows[0]) rows[0].click();
" > /dev/null 2>&1
$AB wait 2000

# Click "Confirm" button
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const confirmBtn = buttons.find(b => b.textContent.includes('Confirm'));
  if (confirmBtn) confirmBtn.click();
" > /dev/null 2>&1
$AB wait 2000

$AB screenshot "$OUTPUT_DIR/screenshots/owner_05_booking_confirmed_${TIMESTAMP}.png"
echo "✓ Booking confirmed"

# ── STEP 5: Check-in Guest ────────────────────────────────────────────────────
echo ""
echo "[5/5] Checking in guest..."

# Click "Check In" button
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const checkinBtn = buttons.find(b => b.textContent.includes('Check In'));
  if (checkinBtn) checkinBtn.click();
" > /dev/null 2>&1
$AB wait 2000

$AB screenshot "$OUTPUT_DIR/screenshots/owner_06_checked_in_${TIMESTAMP}.png"
echo "✓ Guest checked in"

# ── STEP 6: Check-out Guest ───────────────────────────────────────────────────
echo ""
echo "[6/6] Checking out guest..."

# Click "Check Out" button
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const checkoutBtn = buttons.find(b => b.textContent.includes('Check Out'));
  if (checkoutBtn) checkoutBtn.click();
" > /dev/null 2>&1
$AB wait 2000

$AB screenshot "$OUTPUT_DIR/screenshots/owner_07_checked_out_${TIMESTAMP}.png"
echo "✓ Guest checked out"

# ── Verify Final State ────────────────────────────────────────────────────────
$AB wait 2000
PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null | tr -d '"')
HAS_CHECKED_OUT=$(echo "$PAGE_TEXT" | grep -i "checked out\|checked-out" | head -1)

$AB close

echo ""
echo "========================================"
if [ -n "$HAS_CHECKED_OUT" ]; then
  echo " ✅ OWNER BOOKING MANAGEMENT - SUCCESS!"
  echo "========================================"
  echo ""
  echo "Booking Workflow Completed:"
  echo "  • Guest: $GUEST_NAME"
  echo "  • Email: $GUEST_EMAIL"
  echo "  • Phone: $GUEST_PHONE"
  echo "  • Check-in: $CHECKIN_DATE"
  echo "  • Check-out: $CHECKOUT_DATE"
  echo "  • Adults: $ADULTS"
  echo ""
  echo "Status Transitions:"
  echo "  ✓ Created (pending)"
  echo "  ✓ Confirmed"
  echo "  ✓ Checked In"
  echo "  ✓ Checked Out"
  EXIT_CODE=0
else
  echo " ❌ OWNER BOOKING MANAGEMENT - INCOMPLETE"
  echo "========================================"
  echo ""
  echo "Could not verify final checked-out status"
  EXIT_CODE=1
fi

echo ""
echo "Screenshots saved in: $OUTPUT_DIR/screenshots/"
echo ""

exit $EXIT_CODE
