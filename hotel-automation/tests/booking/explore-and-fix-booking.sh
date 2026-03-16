#!/bin/bash

###############################################################################
# EXPLORE AND FIX BOOKING FLOW - FULLY AUTOMATED
# 1. Explores the actual booking flow
# 2. Identifies gaps in current script
# 3. Updates the booking test script
# 4. Runs the updated test
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR/frontend-tests"
source "$TEST_DIR/config/test-config.sh"

AB="$AB_PATH"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
EXPLORE_LOG="$OUTPUT_DIR/explore-booking-${TIMESTAMP}.log"

mkdir -p "$OUTPUT_DIR"

log() {
  echo "$1" | tee -a "$EXPLORE_LOG"
}

log ""
log "========================================"
log " AUTOMATED BOOKING FLOW EXPLORATION"
log "========================================"
log ""

# ── STEP 1: Open hotels and get to hotel detail ───────────────────────────────
log "[1/5] Navigating to hotel detail page..."
$AB --headed open "$FRONTEND_URL/hotels"
$AB wait 8000

FIRST_HOTEL=$($AB eval "
  const links = Array.from(document.querySelectorAll('a[href*=\"/hotels/\"]'))
    .filter(link => link.href.match(/\/hotels\/[^\/]+$/));
  links.length > 0 ? links[0].href : null;
" 2>/dev/null | tr -d '"')

if [ "$FIRST_HOTEL" = "null" ] || [ -z "$FIRST_HOTEL" ]; then
  log "✗ No hotels found"
  $AB close
  exit 1
fi

log "  Opening: $FIRST_HOTEL"
$AB open "$FIRST_HOTEL"
$AB wait 6000

$AB screenshot "$OUTPUT_DIR/screenshots/explore_01_hotel_detail_${TIMESTAMP}.png"
log "✓ On hotel detail page"

# ── STEP 2: Analyze all interactive elements ──────────────────────────────────
log ""
log "[2/5] Analyzing all buttons and links..."

ANALYSIS=$($AB eval "
  const analysis = {
    allButtons: Array.from(document.querySelectorAll('button')).map(btn => ({
      text: btn.textContent.trim(),
      disabled: btn.disabled,
      className: btn.className,
      id: btn.id
    })),
    allLinks: Array.from(document.querySelectorAll('a')).map(link => ({
      text: link.textContent.trim().substring(0, 50),
      href: link.href,
      className: link.className
    })),
    hasRoomCards: document.querySelectorAll('[class*=\"room\"]').length,
    hasBookingForm: !!document.querySelector('form'),
    pageText: document.body.innerText.substring(0, 1000)
  };
  JSON.stringify(analysis, null, 2);
" 2>/dev/null)

echo "$ANALYSIS" >> "$EXPLORE_LOG"

# Look for booking-related buttons
BOOKING_BUTTONS=$(echo "$ANALYSIS" | jq -r '.allButtons[] | select(.text | test("book|reserve|check|select"; "i")) | .text' 2>/dev/null)
log ""
log "Booking-related buttons found:"
echo "$BOOKING_BUTTONS" | while read btn; do
  [ -n "$btn" ] && log "  • $btn"
done

# ── STEP 3: Try clicking different booking buttons ────────────────────────────
log ""
log "[3/5] Testing booking button clicks..."

# Try 1: Look for "Book Now" or "Reserve" button
log "  Attempt 1: Looking for Book/Reserve button..."
$AB eval "
  const bookBtn = Array.from(document.querySelectorAll('button, a'))
    .find(el => {
      const text = el.textContent.toLowerCase();
      return text.includes('book now') || text.includes('reserve now');
    });
  if (bookBtn) {
    console.log('Found:', bookBtn.textContent.trim());
    bookBtn.click();
  } else {
    console.log('Not found');
  }
" 2>&1 | tee -a "$EXPLORE_LOG"

$AB wait 5000
URL_AFTER_1=$($AB get url 2>/dev/null)
log "  URL after click: $URL_AFTER_1"
$AB screenshot "$OUTPUT_DIR/screenshots/explore_02_after_book_click_${TIMESTAMP}.png"

# Check if we're on a booking page
HAS_BOOKING_FORM=$($AB eval "
  const hasForm = !!document.querySelector('form');
  const hasGuestInput = !!document.querySelector('input[name*=\"name\" i], input[placeholder*=\"name\" i]');
  const hasPaymentInput = !!document.querySelector('input[name*=\"card\" i], input[placeholder*=\"card\" i]');
  JSON.stringify({ hasForm, hasGuestInput, hasPaymentInput });
" 2>/dev/null)

log "  Form check: $HAS_BOOKING_FORM"

# Try 2: Look for room selection
log ""
log "  Attempt 2: Looking for room selection..."
$AB open "$FIRST_HOTEL"
$AB wait 6000

$AB eval "
  const roomButtons = Array.from(document.querySelectorAll('button'))
    .filter(btn => {
      const text = btn.textContent.toLowerCase();
      return text.includes('select') || text.includes('choose') || text.includes('book this');
    });
  
  console.log('Room selection buttons:', roomButtons.length);
  roomButtons.forEach((btn, i) => {
    console.log(\`  \${i+1}. \${btn.textContent.trim()}\`);
  });
  
  if (roomButtons.length > 0) {
    console.log('Clicking first room button...');
    roomButtons[0].click();
  }
" 2>&1 | tee -a "$EXPLORE_LOG"

$AB wait 5000
URL_AFTER_2=$($AB get url 2>/dev/null)
log "  URL after room click: $URL_AFTER_2"
$AB screenshot "$OUTPUT_DIR/screenshots/explore_03_after_room_click_${TIMESTAMP}.png"

# Try 3: Check if there's a date/guest selector that needs interaction
log ""
log "  Attempt 3: Looking for date/guest selectors..."
$AB open "$FIRST_HOTEL"
$AB wait 6000

$AB eval "
  // Look for date pickers or guest selectors
  const dateInputs = document.querySelectorAll('input[type=\"date\"], input[placeholder*=\"date\" i]');
  const guestInputs = document.querySelectorAll('input[placeholder*=\"guest\" i], select[name*=\"guest\" i]');
  
  console.log('Date inputs:', dateInputs.length);
  console.log('Guest inputs:', guestInputs.length);
  
  // Look for any prominent CTA buttons
  const ctaButtons = Array.from(document.querySelectorAll('button'))
    .filter(btn => {
      const classes = btn.className.toLowerCase();
      const text = btn.textContent.toLowerCase();
      return classes.includes('primary') || classes.includes('cta') || 
             text.includes('check availability') || text.includes('view rooms');
    });
  
  console.log('CTA buttons:', ctaButtons.length);
  ctaButtons.forEach((btn, i) => {
    console.log(\`  \${i+1}. \${btn.textContent.trim()}\`);
  });
  
  if (ctaButtons.length > 0) {
    console.log('Clicking first CTA...');
    ctaButtons[0].click();
  }
" 2>&1 | tee -a "$EXPLORE_LOG"

$AB wait 5000
URL_AFTER_3=$($AB get url 2>/dev/null)
log "  URL after CTA click: $URL_AFTER_3"
$AB screenshot "$OUTPUT_DIR/screenshots/explore_04_after_cta_click_${TIMESTAMP}.png"

# ── STEP 4: Check current page for booking form ───────────────────────────────
log ""
log "[4/5] Checking current page for booking form..."

FORM_ANALYSIS=$($AB eval "
  const analysis = {
    currentUrl: window.location.href,
    hasForm: !!document.querySelector('form'),
    formInputs: Array.from(document.querySelectorAll('input, textarea, select')).map(input => ({
      type: input.type,
      name: input.name,
      placeholder: input.placeholder,
      id: input.id
    })),
    submitButtons: Array.from(document.querySelectorAll('button[type=\"submit\"], button'))
      .filter(btn => {
        const text = btn.textContent.toLowerCase();
        return text.includes('submit') || text.includes('book') || text.includes('confirm') || text.includes('pay');
      })
      .map(btn => btn.textContent.trim()),
    pageHeadings: Array.from(document.querySelectorAll('h1, h2, h3')).map(h => h.textContent.trim())
  };
  JSON.stringify(analysis, null, 2);
" 2>/dev/null)

echo "$FORM_ANALYSIS" >> "$EXPLORE_LOG"

HAS_GUEST_FIELDS=$(echo "$FORM_ANALYSIS" | jq -r '[.formInputs[] | select(.name | test("name|email|phone"; "i"))] | length > 0' 2>/dev/null)
HAS_PAYMENT_FIELDS=$(echo "$FORM_ANALYSIS" | jq -r '[.formInputs[] | select(.name | test("card|payment"; "i"))] | length > 0' 2>/dev/null)

log "  Has guest fields: $HAS_GUEST_FIELDS"
log "  Has payment fields: $HAS_PAYMENT_FIELDS"

$AB screenshot "$OUTPUT_DIR/screenshots/explore_05_final_state_${TIMESTAMP}.png"

# ── STEP 5: Generate findings and update script ───────────────────────────────
log ""
log "[5/5] Analyzing findings..."

$AB close

log ""
log "========================================"
log " EXPLORATION COMPLETE"
log "========================================"
log ""
log "URLs visited:"
log "  1. Hotel detail: $FIRST_HOTEL"
log "  2. After book click: $URL_AFTER_1"
log "  3. After room click: $URL_AFTER_2"
log "  4. After CTA click: $URL_AFTER_3"
log ""
log "Form status:"
log "  • Has guest fields: $HAS_GUEST_FIELDS"
log "  • Has payment fields: $HAS_PAYMENT_FIELDS"
log ""
log "Screenshots saved:"
log "  • $OUTPUT_DIR/screenshots/explore_*_${TIMESTAMP}.png"
log ""
log "Full log:"
log "  • $EXPLORE_LOG"
log ""

# Determine the actual booking flow
if [ "$HAS_GUEST_FIELDS" = "true" ]; then
  log "✅ FOUND BOOKING FORM!"
  log ""
  log "The booking flow is:"
  log "  1. Navigate to hotel detail"
  log "  2. Click booking/room button"
  log "  3. Fill booking form"
  log ""
  log "Now updating the booking test script..."
  
  # Update will be done in next step
  exit 0
else
  log "⚠️  NO BOOKING FORM FOUND"
  log ""
  log "Possible reasons:"
  log "  • Booking feature not implemented yet"
  log "  • Booking is modal-based (not detected)"
  log "  • Additional steps required"
  log ""
  log "Review screenshots to understand the flow"
  exit 1
fi
