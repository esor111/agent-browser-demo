#!/bin/bash

###############################################################################
# COMPLETE END-TO-END BOOKING FLOW AUTOMATION
# Tests the entire customer journey from search to confirmation:
# 1. Open hotels page
# 2. Set check-in date
# 3. Set check-out date
# 4. Click on first hotel
# 5. Click "See availability"
# 6. Navigate to hotel detail page
# 7. Click "Reserve Now"
# 8. Fill guest details form
# 9. Fill special requests
# 10. Agree to terms
# 11. Submit booking
# 12. Verify confirmation code
###############################################################################

AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
OUTPUT_DIR="./frontend-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$OUTPUT_DIR/screenshots"
mkdir -p "$OUTPUT_DIR/snapshots"

# Test data
FIRST_NAME="John"
LAST_NAME="Doe"
EMAIL="john.doe@test.com"
PHONE="9841234567"
SPECIAL_REQUESTS="Please provide a room with mountain view and extra pillows"

echo ""
echo "========================================"
echo " COMPLETE BOOKING FLOW TEST"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""
echo "Guest Information:"
echo "  Name: $FIRST_NAME $LAST_NAME"
echo "  Email: $EMAIL"
echo "  Phone: $PHONE"
echo ""

# ── STEP 1: Open hotels page ──────────────────────────────────────────────────
echo "[1/15] Opening hotels page..."
$AB --headed open "$FRONTEND_URL/hotels"
$AB wait 3000
echo "✓ Hotels page loaded"

$AB screenshot "$OUTPUT_DIR/screenshots/flow_01_hotels_${TIMESTAMP}.png"

# ── STEP 2: Expand search bar ─────────────────────────────────────────────────
echo "[2/15] Expanding search bar..."

SEARCH_BAR_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Anywhere|Any week|Adults|Room"; "i"))
  | .key
' 2>/dev/null | head -1)

if [ -n "$SEARCH_BAR_REF" ]; then
  $AB click "@$SEARCH_BAR_REF"
  $AB wait 1000
  echo "✓ Search bar expanded"
fi

# ── STEP 3: Open date picker ──────────────────────────────────────────────────
echo "[3/15] Opening date picker..."

DATES_BUTTON=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Dates|Select dates"; "i"))
  | .key
' 2>/dev/null | head -1)

$AB click "@$DATES_BUTTON"
$AB wait 1000
echo "✓ Date picker opened"

# ── STEP 4: Select check-in date (day 10) ─────────────────────────────────────
echo "[4/15] Selecting check-in date (March 10)..."

CHECKIN_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "button" and .value.name == "10")
  | .key
' 2>/dev/null | head -1)

$AB click "@$CHECKIN_BTN"
$AB wait 500
echo "✓ Check-in date selected"

# ── STEP 5: Select check-out date (day 15) ────────────────────────────────────
echo "[5/15] Selecting check-out date (March 15)..."

CHECKOUT_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "button" and .value.name == "15")
  | .key
' 2>/dev/null | head -1)

$AB click "@$CHECKOUT_BTN"
$AB wait 1000
echo "✓ Check-out date selected"

$AB screenshot "$OUTPUT_DIR/screenshots/flow_02_dates_selected_${TIMESTAMP}.png"

# ── STEP 6: Click "See availability" on first hotel ───────────────────────────
echo "[6/15] Clicking 'See availability' on first hotel..."

$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const seeAvailBtn = buttons.find(btn => btn.innerText?.includes('See availability'));
  if (seeAvailBtn) {
    seeAvailBtn.click();
  }
" > /dev/null 2>&1

$AB wait 5000
echo "✓ Navigated to hotel detail page"

HOTEL_URL=$($AB get url 2>/dev/null)
echo "  Hotel URL: $HOTEL_URL"

$AB screenshot "$OUTPUT_DIR/screenshots/flow_03_hotel_detail_${TIMESTAMP}.png"

# ── STEP 7: Click "Reserve Now" button ────────────────────────────────────────
echo "[7/15] Clicking 'Reserve Now' button..."

RESERVE_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Reserve Now"; "i"))
  | .key
' 2>/dev/null | head -1)

if [ -n "$RESERVE_BTN" ]; then
  $AB click "@$RESERVE_BTN"
  $AB wait 5000
  echo "✓ Navigated to booking page"
else
  echo "✗ Reserve Now button not found"
  $AB close
  exit 1
fi

BOOKING_URL=$($AB get url 2>/dev/null)
echo "  Booking URL: $BOOKING_URL"

$AB screenshot "$OUTPUT_DIR/screenshots/flow_04_booking_page_${TIMESTAMP}.png"

# ── STEP 8: Wait for booking page to load ─────────────────────────────────────
echo "[8/15] Waiting for booking page to load..."
$AB wait 3000

# Check if page loaded
PAGE_CHECK=$($AB eval "document.body.innerText?.includes('Guest details') ? 'loaded' : 'not loaded'" 2>/dev/null | tr -d '"')
echo "  Page status: $PAGE_CHECK"

if [ "$PAGE_CHECK" != "loaded" ]; then
  echo "✗ Booking page did not load properly"
  $AB screenshot "$OUTPUT_DIR/screenshots/flow_error_${TIMESTAMP}.png"
  $AB close
  exit 1
fi

# ── STEP 9: Fill first name ───────────────────────────────────────────────────
echo "[9/15] Filling guest details..."

# Get form field refs
$AB snapshot -i > /dev/null

FIRSTNAME_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "textbox")
  | select(.value.name | test("John"; "i"))
  | .key
' 2>/dev/null | head -1)

LASTNAME_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "textbox")
  | select(.value.name | test("Doe"; "i"))
  | .key
' 2>/dev/null | head -1)

EMAIL_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "textbox")
  | select(.value.name | test("email"; "i"))
  | .key
' 2>/dev/null | head -1)

PHONE_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "textbox")
  | select(.value.name | test("977|98X"; "i"))
  | .key
' 2>/dev/null | head -1)

REQUESTS_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "textbox")
  | select(.value.name | test("mountain view|pillows"; "i"))
  | .key
' 2>/dev/null | head -1)

echo "  Filling first name..."
$AB fill "@$FIRSTNAME_REF" "$FIRST_NAME"
$AB wait 500

echo "  Filling last name..."
$AB fill "@$LASTNAME_REF" "$LAST_NAME"
$AB wait 500

echo "  Filling email..."
$AB fill "@$EMAIL_REF" "$EMAIL"
$AB wait 500

echo "  Filling phone..."
$AB fill "@$PHONE_REF" "$PHONE"
$AB wait 500

echo "  Filling special requests..."
$AB fill "@$REQUESTS_REF" "$SPECIAL_REQUESTS"
$AB wait 1000

echo "✓ Guest details filled"

$AB screenshot "$OUTPUT_DIR/screenshots/flow_05_form_filled_${TIMESTAMP}.png"

# ── STEP 10: Verify form was filled ───────────────────────────────────────────
echo "[10/15] Verifying form data..."

FORM_CHECK=$($AB eval "
  const firstName = document.querySelector('input[placeholder*=\"John\"]')?.value || '';
  const lastName = document.querySelector('input[placeholder*=\"Doe\"]')?.value || '';
  const email = document.querySelector('input[type=\"email\"]')?.value || '';
  const phone = document.querySelector('input[type=\"tel\"]')?.value || '';
  
  JSON.stringify({
    firstName: firstName,
    lastName: lastName,
    email: email,
    phone: phone,
    allFilled: firstName && lastName && email && phone
  });
" 2>/dev/null)

echo "  Form data: $FORM_CHECK"

ALL_FILLED=$(echo "$FORM_CHECK" | sed 's/^"//;s/"$//' | jq -r '.allFilled' 2>/dev/null)

if [ "$ALL_FILLED" != "true" ]; then
  echo "⚠️  Warning: Some fields may not be filled"
fi

# ── STEP 11: Agree to terms ───────────────────────────────────────────────────
echo "[11/15] Agreeing to terms..."

TERMS_CHECKBOX=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "checkbox")
  | .key
' 2>/dev/null | head -1)

$AB check "@$TERMS_CHECKBOX"
$AB wait 1000
echo "✓ Terms accepted"

$AB screenshot "$OUTPUT_DIR/screenshots/flow_06_before_submit_${TIMESTAMP}.png"

# ── STEP 12: Click "Complete Booking" button ──────────────────────────────────
echo "[12/15] Submitting booking..."

SUBMIT_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Complete Booking"; "i"))
  | .key
' 2>/dev/null | head -1)

$AB click "@$SUBMIT_BTN"
echo "  Waiting for confirmation..."
$AB wait 8000

# ── STEP 13: Check for confirmation ───────────────────────────────────────────
echo "[13/15] Checking for confirmation..."

CONFIRMATION_CHECK=$($AB eval "
  const text = document.body.innerText;
  const confirmed = text.includes('Booking Confirmed') || text.includes('confirmed');
  const codeMatch = text.match(/BK-[A-Z0-9]+/);
  
  JSON.stringify({
    isConfirmed: confirmed,
    confirmationCode: codeMatch ? codeMatch[0] : null,
    email: '$EMAIL'
  });
" 2>/dev/null)

echo "  Confirmation data: $CONFIRMATION_CHECK"

IS_CONFIRMED=$(echo "$CONFIRMATION_CHECK" | sed 's/^"//;s/"$//' | sed 's/\\"/"/g' | jq -r '.isConfirmed' 2>/dev/null)
CONFIRMATION_CODE=$(echo "$CONFIRMATION_CHECK" | sed 's/^"//;s/"$//' | sed 's/\\"/"/g' | jq -r '.confirmationCode' 2>/dev/null)

# ── STEP 14: Take final screenshot ────────────────────────────────────────────
echo "[14/15] Taking final screenshot..."
$AB screenshot "$OUTPUT_DIR/screenshots/flow_07_confirmation_${TIMESTAMP}.png"

# ── STEP 15: Close browser ────────────────────────────────────────────────────
echo "[15/15] Closing browser..."
$AB close
echo "✓ Browser closed"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "========================================"

if [ "$IS_CONFIRMED" = "true" ] && [ "$CONFIRMATION_CODE" != "null" ] && [ -n "$CONFIRMATION_CODE" ]; then
  echo " ✅ COMPLETE BOOKING FLOW - SUCCESS!"
  echo "========================================"
  echo ""
  echo "Booking Details:"
  echo "  • Guest: $FIRST_NAME $LAST_NAME"
  echo "  • Email: $EMAIL"
  echo "  • Phone: $PHONE"
  echo "  • Confirmation Code: $CONFIRMATION_CODE"
  echo "  • Check-in: March 10, 2026"
  echo "  • Check-out: March 15, 2026"
  echo "  • Duration: 5 nights"
  EXIT_CODE=0
else
  echo " ❌ COMPLETE BOOKING FLOW - FAILED"
  echo "========================================"
  echo ""
  echo "Issues:"
  [ "$IS_CONFIRMED" != "true" ] && echo "  • Booking was not confirmed"
  [ "$CONFIRMATION_CODE" = "null" ] || [ -z "$CONFIRMATION_CODE" ] && echo "  • Confirmation code not found"
  echo ""
  echo "Form Data:"
  echo "$FORM_CHECK" | sed 's/^"//;s/"$//' | jq '.' 2>/dev/null || echo "$FORM_CHECK"
  EXIT_CODE=1
fi

echo ""
echo "Screenshots saved:"
echo "  📸 $OUTPUT_DIR/screenshots/flow_01_hotels_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/flow_02_dates_selected_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/flow_03_hotel_detail_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/flow_04_booking_page_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/flow_05_form_filled_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/flow_06_before_submit_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/flow_07_confirmation_${TIMESTAMP}.png"
echo ""

exit $EXIT_CODE
