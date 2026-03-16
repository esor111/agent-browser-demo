#!/bin/bash

###############################################################################
# BOOKING FLOW AUTOMATION TEST
# Tests the complete booking flow including:
# - Navigate to booking page with hotel and dates
# - Fill guest details form (firstName, lastName, email, phone)
# - Fill special requests (optional)
# - Agree to terms
# - Submit booking
# - Verify confirmation page and extract confirmation code
###############################################################################

AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
OUTPUT_DIR="./frontend-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$OUTPUT_DIR/screenshots"
mkdir -p "$OUTPUT_DIR/snapshots"

# Test data
HOTEL_ID="00000000-0000-4000-a000-000000000100"  # Hotel Yak & Yeti from seed
CHECK_IN="2026-03-10"
CHECK_OUT="2026-03-12"
GUESTS="2"
ROOMS="1"

# Guest details
FIRST_NAME="John"
LAST_NAME="Doe"
EMAIL="john.doe@test.com"
PHONE="9841234567"
SPECIAL_REQUESTS="Please provide a room with mountain view and extra pillows."

echo ""
echo "========================================"
echo " BOOKING FLOW TEST"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""
echo "Test Data:"
echo "  Hotel ID: $HOTEL_ID"
echo "  Check-in: $CHECK_IN"
echo "  Check-out: $CHECK_OUT"
echo "  Guests: $GUESTS"
echo "  Guest: $FIRST_NAME $LAST_NAME"
echo "  Email: $EMAIL"
echo "  Phone: $PHONE"
echo ""

# ── STEP 1: Navigate to booking page ──────────────────────────────────────────
echo "[1/12] Opening booking page..."
BOOKING_URL="$FRONTEND_URL/booking?hotelId=$HOTEL_ID&checkIn=$CHECK_IN&checkOut=$CHECK_OUT&guests=$GUESTS&rooms=$ROOMS"
echo "  URL: $BOOKING_URL"
$AB --headed open "$BOOKING_URL"
$AB wait 4000  # Initial wait for page load

# Wait for loading to complete - check multiple times
for i in {1..5}; do
  IS_LOADING=$($AB eval "document.body.innerText?.includes('Loading') || document.querySelector('[class*=\"animate-spin\"]') ? 'yes' : 'no'" 2>/dev/null)
  echo "  Loading check $i/5: $IS_LOADING"
  
  if [ "$IS_LOADING" = "no" ]; then
    break
  fi
  
  $AB wait 3000
done

echo "✓ Booking page loaded"

# Take initial screenshot
$AB screenshot "$OUTPUT_DIR/screenshots/booking_initial_${TIMESTAMP}.png"

# ── STEP 2: Verify page loaded correctly ──────────────────────────────────────
echo "[2/12] Verifying page loaded..."
CURRENT_URL=$($AB get url 2>/dev/null)
echo "  Current URL: $CURRENT_URL"

PAGE_TITLE=$($AB get title 2>/dev/null)
echo "  Page title: $PAGE_TITLE"

# Check for Next.js error overlay
HAS_ERROR=$($AB eval "document.querySelector('[data-nextjs-dialog-overlay]') ? 'yes' : 'no'" 2>/dev/null)
echo "  Has error overlay: $HAS_ERROR"

if [ "$HAS_ERROR" = "yes" ]; then
  echo ""
  echo "⚠️  Next.js Runtime Error Detected!"
  echo ""
  
  # Extract error message
  ERROR_TITLE=$($AB eval "document.querySelector('[data-nextjs-dialog-header]')?.innerText || ''" 2>/dev/null)
  echo "Error: $ERROR_TITLE"
  echo ""
  
  # Extract error details
  ERROR_BODY=$($AB eval "
    const body = document.querySelector('[data-nextjs-dialog-body]');
    if (body) {
      return body.innerText.substring(0, 1000);
    }
    return 'Could not extract error details';
  " 2>/dev/null)
  echo "$ERROR_BODY"
  echo ""
  
  $AB screenshot "$OUTPUT_DIR/screenshots/error_overlay_${TIMESTAMP}.png"
  $AB close
  exit 1
fi

# Check if hotel name is visible
HOTEL_NAME=$($AB eval "document.querySelector('h2')?.innerText?.trim() || 'Not found'" 2>/dev/null)
echo "  Hotel name: $HOTEL_NAME"

# Check page content to debug
PAGE_CONTENT=$($AB eval "
  const headings = Array.from(document.querySelectorAll('h1,h2,h3'))
    .map(el => el.innerText?.trim())
    .filter(text => text && text.length > 0)
    .slice(0, 10);
  JSON.stringify(headings, null, 2);
" 2>/dev/null)
echo "  Page headings: $PAGE_CONTENT"

# Check body text
BODY_TEXT=$($AB eval "document.body.innerText?.substring(0, 500)" 2>/dev/null)
echo "  Body text (first 500 chars): $BODY_TEXT"

# ── STEP 3: Get page snapshot to find form elements ───────────────────────────
echo "[3/12] Getting form structure..."
$AB snapshot -i > /dev/null
$AB wait 2000

# Take snapshot for debugging
BOOKING_SNAPSHOT=$($AB snapshot -i --json 2>/dev/null)
echo "$BOOKING_SNAPSHOT" > "$OUTPUT_DIR/snapshots/booking_form_${TIMESTAMP}.json"
echo "✓ Form structure captured"

# ── STEP 4: Fill first name ───────────────────────────────────────────────────
echo "[4/12] Filling first name..."

# Use a more robust method for React controlled inputs
$AB eval "
  const input = document.querySelector('input[placeholder*=\"John\"],input[placeholder*=\"First\"]');
  if (input) {
    // Focus the input
    input.focus();
    
    // Set the value using React's internal setter
    const nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    nativeInputValueSetter.call(input, '$FIRST_NAME');
    
    // Trigger React events
    const inputEvent = new Event('input', { bubbles: true });
    input.dispatchEvent(inputEvent);
    
    const changeEvent = new Event('change', { bubbles: true });
    input.dispatchEvent(changeEvent);
  }
" 2>/dev/null

$AB wait 500

# Verify
FIRST_NAME_FILLED=$($AB eval "document.querySelector('input[placeholder*=\"John\"],input[placeholder*=\"First\"]')?.value || 'empty'" 2>/dev/null)
echo "  First name filled: $FIRST_NAME_FILLED"

# ── STEP 5: Fill last name ────────────────────────────────────────────────────
echo "[5/12] Filling last name..."

$AB eval "
  const input = document.querySelector('input[placeholder*=\"Doe\"],input[placeholder*=\"Last\"]');
  if (input) {
    input.focus();
    const nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    nativeInputValueSetter.call(input, '$LAST_NAME');
    input.dispatchEvent(new Event('input', { bubbles: true }));
    input.dispatchEvent(new Event('change', { bubbles: true }));
  }
" 2>/dev/null

$AB wait 500

LAST_NAME_FILLED=$($AB eval "document.querySelector('input[placeholder*=\"Doe\"],input[placeholder*=\"Last\"]')?.value || 'empty'" 2>/dev/null)
echo "  Last name filled: $LAST_NAME_FILLED"

# ── STEP 6: Fill email ────────────────────────────────────────────────────────
echo "[6/12] Filling email..."

$AB eval "
  const input = document.querySelector('input[type=\"email\"]');
  if (input) {
    input.focus();
    const nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    nativeInputValueSetter.call(input, '$EMAIL');
    input.dispatchEvent(new Event('input', { bubbles: true }));
    input.dispatchEvent(new Event('change', { bubbles: true }));
  }
" 2>/dev/null

$AB wait 500

EMAIL_FILLED=$($AB eval "document.querySelector('input[type=\"email\"]')?.value || 'empty'" 2>/dev/null)
echo "  Email filled: $EMAIL_FILLED"

# ── STEP 7: Fill phone ────────────────────────────────────────────────────────
echo "[7/12] Filling phone..."

$AB eval "
  const input = document.querySelector('input[type=\"tel\"]');
  if (input) {
    input.focus();
    const nativeInputValueSetter = Object.getOwnPropertyDescriptor(window.HTMLInputElement.prototype, 'value').set;
    nativeInputValueSetter.call(input, '$PHONE');
    input.dispatchEvent(new Event('input', { bubbles: true }));
    input.dispatchEvent(new Event('change', { bubbles: true }));
  }
" 2>/dev/null

$AB wait 500

PHONE_FILLED=$($AB eval "document.querySelector('input[type=\"tel\"]')?.value || 'empty'" 2>/dev/null)
echo "  Phone filled: $PHONE_FILLED"

# ── STEP 8: Fill special requests (optional) ──────────────────────────────────
echo "[8/12] Filling special requests..."

$AB eval "
  const textarea = document.querySelector('textarea');
  if (textarea) {
    textarea.focus();
    const nativeTextAreaValueSetter = Object.getOwnPropertyDescriptor(window.HTMLTextAreaElement.prototype, 'value').set;
    nativeTextAreaValueSetter.call(textarea, '$SPECIAL_REQUESTS');
    textarea.dispatchEvent(new Event('input', { bubbles: true }));
    textarea.dispatchEvent(new Event('change', { bubbles: true }));
  }
" 2>/dev/null

$AB wait 500

SPECIAL_REQUESTS_FILLED=$($AB eval "document.querySelector('textarea')?.value ? 'filled' : 'empty'" 2>/dev/null)
echo "  Special requests: $SPECIAL_REQUESTS_FILLED"

# ── STEP 9: Verify all fields are filled ──────────────────────────────────────
echo "[9/12] Verifying form data..."

FORM_STATE=$($AB eval "
  JSON.stringify({
    firstName: document.querySelector('input[placeholder*=\"John\"],input[placeholder*=\"First\"]')?.value || 'empty',
    lastName: document.querySelector('input[placeholder*=\"Doe\"],input[placeholder*=\"Last\"]')?.value || 'empty',
    email: document.querySelector('input[type=\"email\"]')?.value || 'empty',
    phone: document.querySelector('input[type=\"tel\"]')?.value || 'empty',
    specialRequests: document.querySelector('textarea')?.value ? 'filled' : 'empty'
  }, null, 2);
" 2>/dev/null)

echo ""
echo "Form state:"
echo "$FORM_STATE" | jq '.' 2>/dev/null || echo "$FORM_STATE"
echo ""

# Take screenshot before agreeing to terms
$AB screenshot "$OUTPUT_DIR/screenshots/booking_form_filled_${TIMESTAMP}.png"

# ── STEP 10: Agree to terms ───────────────────────────────────────────────────
echo "[10/12] Agreeing to terms..."

TERMS_CHECKED=$($AB eval "
  const checkbox = document.querySelector('input[type=\"checkbox\"]');
  if (checkbox) {
    checkbox.checked = true;
    checkbox.dispatchEvent(new Event('change', { bubbles: true }));
    return checkbox.checked;
  }
  return false;
" 2>/dev/null)

$AB wait 1000
echo "  Terms checkbox: $TERMS_CHECKED"

# Take screenshot after agreeing to terms
$AB screenshot "$OUTPUT_DIR/screenshots/booking_before_submit_${TIMESTAMP}.png"

# ── STEP 11: Submit booking ───────────────────────────────────────────────────
echo "[11/12] Submitting booking..."

# Find and click the submit button
SUBMIT_RESULT=$($AB eval "
  // Look for the Complete Booking button
  const buttons = Array.from(document.querySelectorAll('button'));
  const submitBtn = buttons.find(btn => 
    btn.innerText?.includes('Complete Booking') || 
    btn.innerText?.includes('Complete') ||
    btn.innerText?.includes('Book Now')
  );
  
  if (submitBtn && !submitBtn.disabled) {
    submitBtn.click();
    return 'clicked';
  } else if (submitBtn && submitBtn.disabled) {
    return 'button disabled';
  }
  return 'button not found';
" 2>/dev/null)

echo "  Submit button: $SUBMIT_RESULT"
echo "  Waiting for API response and confirmation page..."
$AB wait 10000  # Wait for API call and redirect to confirmation

# ── STEP 12: Verify confirmation page ─────────────────────────────────────────
echo "[12/12] Verifying confirmation..."

FINAL_URL=$($AB get url 2>/dev/null)
echo "  Final URL: $FINAL_URL"

# Take screenshot of confirmation page
$AB screenshot "$OUTPUT_DIR/screenshots/booking_confirmation_${TIMESTAMP}.png"

# Extract confirmation code
CONFIRMATION_DATA=$($AB eval "
  // Look for confirmation code
  const codeElement = document.querySelector('p[class*=\"tracking\"]');
  const confirmationCode = codeElement?.innerText?.trim() || 'Not found';
  
  // Look for success message
  const successHeading = document.querySelector('h1')?.innerText?.trim() || '';
  
  // Check if we're on confirmation page
  const isConfirmationPage = successHeading.toLowerCase().includes('confirmed') || 
                             successHeading.toLowerCase().includes('success');
  
  // Extract booking details
  const hotelName = Array.from(document.querySelectorAll('h3'))
    .map(el => el.innerText?.trim())
    .find(text => text && text.length > 5) || 'Not found';
  
  JSON.stringify({
    isConfirmationPage: isConfirmationPage,
    successHeading: successHeading,
    confirmationCode: confirmationCode,
    hotelName: hotelName,
    email: '$EMAIL'
  }, null, 2);
" 2>/dev/null)

echo ""
echo "Confirmation Details:"
echo "$CONFIRMATION_DATA" | jq '.' 2>/dev/null || echo "$CONFIRMATION_DATA"
echo ""

# Extract confirmation code for exit status
CONFIRMATION_CODE=$(echo "$CONFIRMATION_DATA" | jq -r '.confirmationCode' 2>/dev/null)
IS_CONFIRMED=$(echo "$CONFIRMATION_DATA" | jq -r '.isConfirmationPage' 2>/dev/null)

# ── Close browser ─────────────────────────────────────────────────────────────
$AB close
echo "✓ Browser closed"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "========================================"
if [ "$IS_CONFIRMED" = "true" ] && [ "$CONFIRMATION_CODE" != "Not found" ]; then
  echo " ✅ BOOKING FLOW TEST PASSED"
  echo "========================================"
  echo ""
  echo "Booking Details:"
  echo "  • Guest: $FIRST_NAME $LAST_NAME"
  echo "  • Email: $EMAIL"
  echo "  • Phone: $PHONE"
  echo "  • Confirmation Code: $CONFIRMATION_CODE"
  echo "  • Check-in: $CHECK_IN"
  echo "  • Check-out: $CHECK_OUT"
  echo "  • Guests: $GUESTS"
  EXIT_CODE=0
else
  echo " ❌ BOOKING FLOW TEST FAILED"
  echo "========================================"
  echo ""
  echo "Issues:"
  if [ "$IS_CONFIRMED" != "true" ]; then
    echo "  • Did not reach confirmation page"
  fi
  if [ "$CONFIRMATION_CODE" = "Not found" ]; then
    echo "  • Confirmation code not found"
  fi
  echo ""
  echo "Form State:"
  echo "$FORM_STATE" | jq '.' 2>/dev/null || echo "$FORM_STATE"
  EXIT_CODE=1
fi

echo ""
echo "Screenshots saved:"
echo "  📸 $OUTPUT_DIR/screenshots/booking_initial_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/booking_form_filled_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/booking_before_submit_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/booking_confirmation_${TIMESTAMP}.png"
echo ""
echo "Snapshots saved:"
echo "  📋 $OUTPUT_DIR/snapshots/booking_form_${TIMESTAMP}.json"
echo ""

exit $EXIT_CODE
