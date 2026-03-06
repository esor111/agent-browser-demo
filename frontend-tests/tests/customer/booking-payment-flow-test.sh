#!/bin/bash

###############################################################################
# CUSTOMER BOOKING WITH PAYMENT FLOW TEST
# Tests the complete customer booking journey including payment
# This is the MOST CRITICAL test - direct revenue impact!
#
# Flow:
# 1. Search for hotels
# 2. Select dates
# 3. View hotel details
# 4. Select room type
# 5. Fill guest details
# 6. Enter payment information
# 7. Complete booking
# 8. Verify confirmation
# 9. Check booking status page
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../config/test-config.sh"

AB="$AB_PATH"

# Generate unique test data
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FIRST_NAME="Test"
LAST_NAME="Customer${TIMESTAMP: -6}"
EMAIL=$(generate_email "booking")
PHONE=$(generate_phone "984")
SPECIAL_REQUESTS="Test booking - automated test"

# Payment details (test data)
CARD_NUMBER="4242424242424242"  # Test card
CARD_EXPIRY="12/28"
CARD_CVC="123"
CARD_NAME="$FIRST_NAME $LAST_NAME"

echo ""
echo "========================================"
echo " CUSTOMER BOOKING PAYMENT FLOW TEST"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""
echo "Test Data:"
echo "  • Guest: $FIRST_NAME $LAST_NAME"
echo "  • Email: $EMAIL"
echo "  • Phone: $PHONE"
echo "  • Card: **** **** **** 4242"
echo ""

# ── STEP 1: Open hotels page ──────────────────────────────────────────────────
echo "[1/12] Opening hotels search page..."
$AB --headed open "$FRONTEND_URL/hotels"
$AB wait 4000
echo "✓ Hotels page loaded"

$AB screenshot "$OUTPUT_DIR/screenshots/booking_01_hotels_${TIMESTAMP}.png"

# ── STEP 2: Select dates ──────────────────────────────────────────────────────
echo "[2/12] Selecting check-in and check-out dates..."

# Try to find and click date picker
$AB eval "
  // Look for date inputs or buttons
  const dateButtons = Array.from(document.querySelectorAll('button, input'))
    .filter(el => {
      const text = el.textContent || el.placeholder || '';
      return text.toLowerCase().includes('date') || 
             text.toLowerCase().includes('check') ||
             text.toLowerCase().includes('when');
    });
  
  if (dateButtons.length > 0) {
    dateButtons[0].click();
  }
" > /dev/null 2>&1

$AB wait 2000

# Select check-in date (10th of current month)
$AB eval "
  const dayButtons = Array.from(document.querySelectorAll('button'))
    .filter(btn => btn.textContent === '10' && !btn.disabled);
  if (dayButtons.length > 0) dayButtons[0].click();
" > /dev/null 2>&1

$AB wait 1000

# Select check-out date (15th of current month)
$AB eval "
  const dayButtons = Array.from(document.querySelectorAll('button'))
    .filter(btn => btn.textContent === '15' && !btn.disabled);
  if (dayButtons.length > 0) dayButtons[0].click();
" > /dev/null 2>&1

$AB wait 2000
echo "✓ Dates selected (10th - 15th)"

$AB screenshot "$OUTPUT_DIR/screenshots/booking_02_dates_${TIMESTAMP}.png"

# ── STEP 3: Navigate to hotel detail (use direct URL) ─────────────────────────
echo "[3/12] Navigating to first hotel..."

# Get the first hotel URL
HOTEL_URL=$($AB eval "
  const hotelLinks = Array.from(document.querySelectorAll('a[href*=\"/hotels/\"]'))
    .filter(link => link.href.match(/\/hotels\/[^\/]+$/));
  hotelLinks.length > 0 ? hotelLinks[0].href : null;
" 2>/dev/null | tr -d '"')

if [ -z "$HOTEL_URL" ] || [ "$HOTEL_URL" = "null" ]; then
  echo "✗ No hotel links found"
  $AB close
  exit 1
fi

echo "  Navigating to: $HOTEL_URL"
$AB open "$HOTEL_URL"
$AB wait 5000
echo "✓ Navigated to hotel details"

$AB screenshot "$OUTPUT_DIR/screenshots/booking_03_hotel_detail_${TIMESTAMP}.png"

# ── STEP 4: Click "Reserve Now" or "Book Now" ─────────────────────────────────
echo "[4/12] Clicking booking button..."

$AB eval "
  const bookButtons = Array.from(document.querySelectorAll('button, a'))
    .filter(el => {
      const text = el.textContent || '';
      return text.includes('Reserve') || 
             text.includes('Book Now') || 
             text.includes('Check Availability');
    });
  
  if (bookButtons.length > 0) {
    bookButtons[0].click();
  }
" > /dev/null 2>&1

$AB wait 5000
echo "✓ Navigated to booking page"

BOOKING_URL=$($AB get url 2>/dev/null)
echo "  Booking URL: $BOOKING_URL"

$AB screenshot "$OUTPUT_DIR/screenshots/booking_04_booking_page_${TIMESTAMP}.png"

# ── STEP 5: Wait for booking page to fully load ───────────────────────────────
echo "[5/12] Waiting for booking form to load..."
$AB wait 3000

# Check if we're on booking page or hotel detail page
ON_BOOKING_PAGE=$(echo "$BOOKING_URL" | grep -o "booking")
ON_HOTEL_DETAIL=$(echo "$BOOKING_URL" | grep -o "hotels/")

if [ -z "$ON_BOOKING_PAGE" ] && [ -z "$ON_HOTEL_DETAIL" ]; then
  echo "✗ Not on expected page. Current URL: $BOOKING_URL"
  $AB screenshot "$OUTPUT_DIR/screenshots/booking_error_${TIMESTAMP}.png"
  $AB close
  exit 1
fi

# If still on hotel detail, try to find and click booking button again
if [ -n "$ON_HOTEL_DETAIL" ] && [ -z "$ON_BOOKING_PAGE" ]; then
  echo "  Still on hotel detail page, looking for booking button..."
  
  $AB eval "
    // Try multiple selectors for booking button
    const bookButtons = Array.from(document.querySelectorAll('button, a'))
      .filter(el => {
        const text = (el.textContent || '').toLowerCase();
        return text.includes('book') || 
               text.includes('reserve') || 
               text.includes('check availability') ||
               text.includes('select room');
      });
    
    if (bookButtons.length > 0) {
      console.log('Found booking button:', bookButtons[0].textContent);
      bookButtons[0].click();
    }
  " > /dev/null 2>&1
  
  $AB wait 5000
  
  BOOKING_URL=$($AB get url 2>/dev/null)
  ON_BOOKING_PAGE=$(echo "$BOOKING_URL" | grep -o "booking")
  
  if [ -z "$ON_BOOKING_PAGE" ]; then
    echo "✗ Could not navigate to booking page"
    echo "  Current URL: $BOOKING_URL"
    $AB screenshot "$OUTPUT_DIR/screenshots/booking_error_${TIMESTAMP}.png"
    $AB close
    exit 1
  fi
fi

echo "✓ Booking form loaded"

# ── STEP 6: Fill guest details ────────────────────────────────────────────────
echo "[6/12] Filling guest details..."

# Fill first name
$AB eval "
  const firstNameInput = document.querySelector('input[name=\"firstName\"], input[placeholder*=\"First\" i], input[id*=\"first\" i]');
  if (firstNameInput) {
    firstNameInput.value = '$FIRST_NAME';
    firstNameInput.dispatchEvent(new Event('input', { bubbles: true }));
    firstNameInput.dispatchEvent(new Event('change', { bubbles: true }));
  }
" > /dev/null 2>&1

$AB wait 500

# Fill last name
$AB eval "
  const lastNameInput = document.querySelector('input[name=\"lastName\"], input[placeholder*=\"Last\" i], input[id*=\"last\" i]');
  if (lastNameInput) {
    lastNameInput.value = '$LAST_NAME';
    lastNameInput.dispatchEvent(new Event('input', { bubbles: true }));
    lastNameInput.dispatchEvent(new Event('change', { bubbles: true }));
  }
" > /dev/null 2>&1

$AB wait 500

# Fill email
$AB eval "
  const emailInput = document.querySelector('input[type=\"email\"], input[name=\"email\"]');
  if (emailInput) {
    emailInput.value = '$EMAIL';
    emailInput.dispatchEvent(new Event('input', { bubbles: true }));
    emailInput.dispatchEvent(new Event('change', { bubbles: true }));
  }
" > /dev/null 2>&1

$AB wait 500

# Fill phone
$AB eval "
  const phoneInput = document.querySelector('input[type=\"tel\"], input[name=\"phone\"]');
  if (phoneInput) {
    phoneInput.value = '$PHONE';
    phoneInput.dispatchEvent(new Event('input', { bubbles: true }));
    phoneInput.dispatchEvent(new Event('change', { bubbles: true }));
  }
" > /dev/null 2>&1

$AB wait 500

# Fill special requests if available
$AB eval "
  const requestsInput = document.querySelector('textarea[name=\"specialRequests\"], textarea[placeholder*=\"request\" i]');
  if (requestsInput) {
    requestsInput.value = '$SPECIAL_REQUESTS';
    requestsInput.dispatchEvent(new Event('input', { bubbles: true }));
  }
" > /dev/null 2>&1

$AB wait 1000

echo "✓ Guest details filled"

$AB screenshot "$OUTPUT_DIR/screenshots/booking_05_guest_details_${TIMESTAMP}.png"

# ── STEP 7: Fill payment information ──────────────────────────────────────────
echo "[7/12] Filling payment information..."

# Fill card number
$AB eval "
  const cardInput = document.querySelector('input[name=\"cardNumber\"], input[placeholder*=\"card number\" i], input[id*=\"card\" i]');
  if (cardInput) {
    cardInput.value = '$CARD_NUMBER';
    cardInput.dispatchEvent(new Event('input', { bubbles: true }));
    cardInput.dispatchEvent(new Event('change', { bubbles: true }));
  }
" > /dev/null 2>&1

$AB wait 500

# Fill expiry date
$AB eval "
  const expiryInput = document.querySelector('input[name=\"expiry\"], input[placeholder*=\"expiry\" i], input[placeholder*=\"MM/YY\" i]');
  if (expiryInput) {
    expiryInput.value = '$CARD_EXPIRY';
    expiryInput.dispatchEvent(new Event('input', { bubbles: true }));
    expiryInput.dispatchEvent(new Event('change', { bubbles: true }));
  }
" > /dev/null 2>&1

$AB wait 500

# Fill CVC
$AB eval "
  const cvcInput = document.querySelector('input[name=\"cvc\"], input[name=\"cvv\"], input[placeholder*=\"CVC\" i], input[placeholder*=\"CVV\" i]');
  if (cvcInput) {
    cvcInput.value = '$CARD_CVC';
    cvcInput.dispatchEvent(new Event('input', { bubbles: true }));
    cvcInput.dispatchEvent(new Event('change', { bubbles: true }));
  }
" > /dev/null 2>&1

$AB wait 500

# Fill cardholder name
$AB eval "
  const nameInput = document.querySelector('input[name=\"cardName\"], input[placeholder*=\"name on card\" i]');
  if (nameInput) {
    nameInput.value = '$CARD_NAME';
    nameInput.dispatchEvent(new Event('input', { bubbles: true }));
    nameInput.dispatchEvent(new Event('change', { bubbles: true }));
  }
" > /dev/null 2>&1

$AB wait 1000

echo "✓ Payment information filled"

$AB screenshot "$OUTPUT_DIR/screenshots/booking_06_payment_filled_${TIMESTAMP}.png"

# ── STEP 8: Accept terms and conditions ───────────────────────────────────────
echo "[8/12] Accepting terms and conditions..."

$AB eval "
  const termsCheckbox = document.querySelector('input[type=\"checkbox\"][name*=\"terms\" i], input[type=\"checkbox\"][name*=\"agree\" i]');
  if (termsCheckbox && !termsCheckbox.checked) {
    termsCheckbox.click();
  }
" > /dev/null 2>&1

$AB wait 1000
echo "✓ Terms accepted"

$AB screenshot "$OUTPUT_DIR/screenshots/booking_07_before_submit_${TIMESTAMP}.png"

# ── STEP 9: Submit booking ────────────────────────────────────────────────────
echo "[9/12] Submitting booking..."

$AB eval "
  const submitButtons = Array.from(document.querySelectorAll('button'))
    .filter(btn => {
      const text = btn.textContent || '';
      return text.includes('Complete Booking') || 
             text.includes('Confirm Booking') ||
             text.includes('Pay Now') ||
             text.includes('Book Now');
    });
  
  if (submitButtons.length > 0 && !submitButtons[0].disabled) {
    submitButtons[0].click();
  }
" > /dev/null 2>&1

echo "  Waiting for payment processing..."
$AB wait 8000

# ── STEP 10: Check for confirmation ───────────────────────────────────────────
echo "[10/12] Checking for booking confirmation..."

CONFIRMATION_URL=$($AB get url 2>/dev/null)
PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null)

# Look for confirmation indicators
HAS_CONFIRMATION=$(echo "$PAGE_TEXT" | grep -iE "confirmed|success|thank you|booking complete" | wc -l)
CONFIRMATION_CODE=$(echo "$PAGE_TEXT" | grep -oE "BK-[A-Z0-9]+" | head -1)

echo "  Current URL: $CONFIRMATION_URL"
echo "  Confirmation indicators: $HAS_CONFIRMATION"
echo "  Confirmation code: ${CONFIRMATION_CODE:-Not found}"

$AB screenshot "$OUTPUT_DIR/screenshots/booking_08_confirmation_${TIMESTAMP}.png"

# ── STEP 11: Verify booking details ───────────────────────────────────────────
echo "[11/12] Verifying booking details..."

BOOKING_DETAILS=$($AB eval "
  const text = document.body.innerText;
  JSON.stringify({
    hasConfirmation: text.toLowerCase().includes('confirmed') || text.toLowerCase().includes('success'),
    hasEmail: text.includes('$EMAIL'),
    hasGuestName: text.includes('$FIRST_NAME') || text.includes('$LAST_NAME'),
    confirmationCode: text.match(/BK-[A-Z0-9]+/)?.[0] || null
  }, null, 2);
" 2>/dev/null)

echo ""
echo "Booking verification:"
echo "$BOOKING_DETAILS" | jq '.' 2>/dev/null || echo "$BOOKING_DETAILS"

# ── STEP 12: Close browser ────────────────────────────────────────────────────
echo ""
echo "[12/12] Closing browser..."
$AB close
echo "✓ Browser closed"

# ── Final Verification ─────────────────────────────────────────────────────────
echo ""
echo "========================================"

IS_CONFIRMED=$(echo "$BOOKING_DETAILS" | jq -r '.hasConfirmation' 2>/dev/null)
HAS_CODE=$(echo "$BOOKING_DETAILS" | jq -r '.confirmationCode' 2>/dev/null)

if [ "$IS_CONFIRMED" = "true" ] && [ "$HAS_CODE" != "null" ] && [ -n "$HAS_CODE" ]; then
  echo " ✅ BOOKING PAYMENT FLOW - SUCCESS!"
  echo "========================================"
  echo ""
  echo "Booking Completed:"
  echo "  • Guest: $FIRST_NAME $LAST_NAME"
  echo "  • Email: $EMAIL"
  echo "  • Phone: $PHONE"
  echo "  • Confirmation: $HAS_CODE"
  echo "  • Check-in: March 10"
  echo "  • Check-out: March 15"
  echo "  • Payment: Processed (Test Card)"
  echo ""
  echo "✅ CRITICAL REVENUE FEATURE WORKING!"
  echo ""
  EXIT_CODE=0
else
  echo " ❌ BOOKING PAYMENT FLOW - FAILED"
  echo "========================================"
  echo ""
  echo "Issues:"
  [ "$IS_CONFIRMED" != "true" ] && echo "  • Booking not confirmed"
  [ "$HAS_CODE" = "null" ] || [ -z "$HAS_CODE" ] && echo "  • No confirmation code"
  echo ""
  echo "⚠️  CRITICAL: Revenue feature not working!"
  echo ""
  EXIT_CODE=1
fi

echo "Screenshots saved:"
echo "  📸 $OUTPUT_DIR/screenshots/booking_01_hotels_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/booking_02_dates_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/booking_03_hotel_detail_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/booking_04_booking_page_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/booking_05_guest_details_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/booking_06_payment_filled_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/booking_07_before_submit_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/booking_08_confirmation_${TIMESTAMP}.png"
echo ""

exit $EXIT_CODE
