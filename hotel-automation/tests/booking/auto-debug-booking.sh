#!/bin/bash

###############################################################################
# AUTOMATED BOOKING FLOW DEBUGGER
# Fully automated - explores the booking flow and reports findings
# No manual intervention required
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/frontend-tests/config/test-config.sh"

AB="$AB_PATH"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DEBUG_LOG="$OUTPUT_DIR/debug-booking-${TIMESTAMP}.log"

# Create log file
mkdir -p "$OUTPUT_DIR"
echo "Booking Flow Debug Report - $TIMESTAMP" > "$DEBUG_LOG"
echo "========================================" >> "$DEBUG_LOG"
echo "" >> "$DEBUG_LOG"

log() {
  echo "$1" | tee -a "$DEBUG_LOG"
}

log_section() {
  echo "" >> "$DEBUG_LOG"
  echo "──────────────────────────────────────" >> "$DEBUG_LOG"
  echo "$1" >> "$DEBUG_LOG"
  echo "──────────────────────────────────────" >> "$DEBUG_LOG"
  echo "" | tee -a "$DEBUG_LOG"
}

log ""
log "========================================"
log " AUTOMATED BOOKING FLOW DEBUGGER"
log "========================================"
log ""

# ── STEP 1: Open hotels page ──────────────────────────────────────────────────
log_section "STEP 1: Hotels Search Page"
log "[1/10] Opening hotels page..."

$AB --headed open "$FRONTEND_URL/hotels" 2>&1 | tee -a "$DEBUG_LOG"
$AB wait 3000

HOTELS_URL=$($AB get url 2>/dev/null)
log "✓ URL: $HOTELS_URL"

# Capture page info
$AB eval "
  const info = {
    title: document.title,
    url: window.location.href,
    hotelElements: document.querySelectorAll('[class*=\"hotel\"], [class*=\"card\"], [class*=\"property\"]').length,
    hotelLinks: document.querySelectorAll('a[href*=\"/hotels/\"]').length,
    buttons: document.querySelectorAll('button').length,
    forms: document.querySelectorAll('form').length
  };
  JSON.stringify(info, null, 2);
" 2>/dev/null >> "$DEBUG_LOG"

$AB screenshot "$OUTPUT_DIR/screenshots/autodebug_01_hotels_${TIMESTAMP}.png"
log "✓ Screenshot saved"

# ── STEP 2: Analyze hotel links ───────────────────────────────────────────────
log_section "STEP 2: Hotel Links Analysis"
log "[2/10] Analyzing hotel links..."

HOTEL_LINKS=$($AB eval "
  const links = Array.from(document.querySelectorAll('a[href*=\"/hotels/\"]'))
    .filter(link => link.href.match(/\/hotels\/[^\/]+$/));
  
  const analysis = {
    totalLinks: links.length,
    firstFiveLinks: links.slice(0, 5).map(link => ({
      href: link.href,
      text: link.textContent.trim().substring(0, 50)
    }))
  };
  
  JSON.stringify(analysis, null, 2);
" 2>/dev/null)

echo "$HOTEL_LINKS" >> "$DEBUG_LOG"
LINK_COUNT=$(echo "$HOTEL_LINKS" | jq -r '.totalLinks' 2>/dev/null || echo "0")
log "✓ Found $LINK_COUNT hotel links"

# ── STEP 3: Navigate to first hotel ───────────────────────────────────────────
log_section "STEP 3: Hotel Detail Page"
log "[3/10] Navigating to first hotel..."

FIRST_HOTEL_URL=$($AB eval "
  const links = Array.from(document.querySelectorAll('a[href*=\"/hotels/\"]'))
    .filter(link => link.href.match(/\/hotels\/[^\/]+$/));
  links.length > 0 ? links[0].href : null;
" 2>/dev/null | tr -d '"')

if [ "$FIRST_HOTEL_URL" = "null" ] || [ -z "$FIRST_HOTEL_URL" ]; then
  log "✗ ERROR: No hotel links found!"
  $AB close
  exit 1
fi

log "  Navigating to: $FIRST_HOTEL_URL"
$AB open "$FIRST_HOTEL_URL"
$AB wait 5000

DETAIL_URL=$($AB get url 2>/dev/null)
log "✓ Current URL: $DETAIL_URL"

$AB screenshot "$OUTPUT_DIR/screenshots/autodebug_02_hotel_detail_${TIMESTAMP}.png"

# ── STEP 4: Analyze hotel detail page ─────────────────────────────────────────
log_section "STEP 4: Hotel Detail Analysis"
log "[4/10] Analyzing hotel detail page..."

DETAIL_ANALYSIS=$($AB eval "
  const buttons = Array.from(document.querySelectorAll('button, a'));
  const bookingButtons = buttons.filter(el => {
    const text = (el.textContent || '').toLowerCase();
    return text.includes('book') || 
           text.includes('reserve') || 
           text.includes('check availability') ||
           text.includes('select');
  });
  
  const analysis = {
    totalButtons: buttons.length,
    bookingButtons: bookingButtons.map(btn => ({
      tag: btn.tagName,
      text: btn.textContent.trim(),
      href: btn.href || null,
      disabled: btn.disabled || false
    })),
    hasRoomTypes: document.querySelectorAll('[class*=\"room\"]').length > 0,
    roomTypeCount: document.querySelectorAll('[class*=\"room\"]').length,
    pageText: {
      hasBooking: document.body.innerText.toLowerCase().includes('booking'),
      hasReserve: document.body.innerText.toLowerCase().includes('reserve'),
      hasAvailability: document.body.innerText.toLowerCase().includes('availability')
    }
  };
  
  JSON.stringify(analysis, null, 2);
" 2>/dev/null)

echo "$DETAIL_ANALYSIS" >> "$DEBUG_LOG"
BOOKING_BTN_COUNT=$(echo "$DETAIL_ANALYSIS" | jq -r '.bookingButtons | length' 2>/dev/null || echo "0")
log "✓ Found $BOOKING_BTN_COUNT booking-related buttons"

# ── STEP 5: Click first booking button ────────────────────────────────────────
log_section "STEP 5: Click Booking Button"
log "[5/10] Clicking first booking button..."

CLICKED=$($AB eval "
  const bookButtons = Array.from(document.querySelectorAll('button, a'))
    .filter(el => {
      const text = (el.textContent || '').toLowerCase();
      return text.includes('book') || text.includes('reserve');
    });
  
  if (bookButtons.length > 0) {
    const btn = bookButtons[0];
    btn.click();
    JSON.stringify({
      clicked: true,
      buttonText: btn.textContent.trim(),
      buttonHref: btn.href || null
    });
  } else {
    JSON.stringify({ clicked: false, reason: 'No booking button found' });
  }
" 2>/dev/null)

echo "$CLICKED" >> "$DEBUG_LOG"
log "✓ Button clicked"

$AB wait 5000

AFTER_CLICK_URL=$($AB get url 2>/dev/null)
log "✓ URL after click: $AFTER_CLICK_URL"

$AB screenshot "$OUTPUT_DIR/screenshots/autodebug_03_after_click_${TIMESTAMP}.png"

# ── STEP 6: Analyze current page ──────────────────────────────────────────────
log_section "STEP 6: Current Page Analysis"
log "[6/10] Analyzing current page..."

PAGE_ANALYSIS=$($AB eval "
  const analysis = {
    url: window.location.href,
    pathname: window.location.pathname,
    isBookingPage: window.location.pathname.includes('booking'),
    isHotelDetail: window.location.pathname.includes('hotels/'),
    formInputs: {
      total: document.querySelectorAll('input, textarea, select').length,
      firstName: !!document.querySelector('input[name=\"firstName\"]'),
      lastName: !!document.querySelector('input[name=\"lastName\"]'),
      email: !!document.querySelector('input[type=\"email\"]'),
      phone: !!document.querySelector('input[type=\"tel\"]'),
      cardNumber: !!document.querySelector('input[name=\"cardNumber\"]'),
      expiry: !!document.querySelector('input[name=\"expiry\"]'),
      cvc: !!document.querySelector('input[name=\"cvc\"]')
    },
    pageContent: {
      hasPayment: document.body.innerText.toLowerCase().includes('payment'),
      hasCard: document.body.innerText.toLowerCase().includes('card'),
      hasGuest: document.body.innerText.toLowerCase().includes('guest'),
      hasConfirm: document.body.innerText.toLowerCase().includes('confirm')
    },
    submitButtons: Array.from(document.querySelectorAll('button[type=\"submit\"], button'))
      .slice(0, 5)
      .map(btn => btn.textContent.trim())
  };
  
  JSON.stringify(analysis, null, 2);
" 2>/dev/null)

echo "$PAGE_ANALYSIS" >> "$DEBUG_LOG"
IS_BOOKING_PAGE=$(echo "$PAGE_ANALYSIS" | jq -r '.isBookingPage' 2>/dev/null)
log "✓ Is booking page: $IS_BOOKING_PAGE"

# ── STEP 7: Try direct booking URL ────────────────────────────────────────────
log_section "STEP 7: Direct Booking URL Test"
log "[7/10] Testing direct booking URL..."

HOTEL_ID=$(echo "$DETAIL_URL" | grep -oP '/hotels/\K[^/]+' | head -1)

if [ -n "$HOTEL_ID" ]; then
  log "  Hotel ID: $HOTEL_ID"
  
  # Try different URL patterns
  PATTERNS=(
    "$FRONTEND_URL/booking/$HOTEL_ID"
    "$FRONTEND_URL/hotels/$HOTEL_ID/booking"
    "$FRONTEND_URL/book/$HOTEL_ID"
    "$FRONTEND_URL/reserve/$HOTEL_ID"
  )
  
  for PATTERN in "${PATTERNS[@]}"; do
    log "  Testing: $PATTERN"
    $AB open "$PATTERN"
    $AB wait 3000
    
    RESULT_URL=$($AB get url 2>/dev/null)
    IS_404=$($AB eval "document.body.innerText.toLowerCase().includes('404') || document.body.innerText.toLowerCase().includes('not found')" 2>/dev/null)
    
    if [ "$IS_404" = "false" ]; then
      log "  ✓ Success: $RESULT_URL"
      echo "  Working URL: $PATTERN" >> "$DEBUG_LOG"
      break
    else
      log "  ✗ Failed (404 or not found)"
    fi
  done
  
  $AB screenshot "$OUTPUT_DIR/screenshots/autodebug_04_direct_url_${TIMESTAMP}.png"
else
  log "✗ Could not extract hotel ID"
fi

# ── STEP 8: Check for booking form ────────────────────────────────────────────
log_section "STEP 8: Booking Form Check"
log "[8/10] Checking for booking form elements..."

FORM_CHECK=$($AB eval "
  const formCheck = {
    guestFields: {
      firstName: !!document.querySelector('input[name=\"firstName\"], input[placeholder*=\"First\" i]'),
      lastName: !!document.querySelector('input[name=\"lastName\"], input[placeholder*=\"Last\" i]'),
      email: !!document.querySelector('input[type=\"email\"]'),
      phone: !!document.querySelector('input[type=\"tel\"]')
    },
    paymentFields: {
      cardNumber: !!document.querySelector('input[name=\"cardNumber\"], input[placeholder*=\"card\" i]'),
      expiry: !!document.querySelector('input[name=\"expiry\"], input[placeholder*=\"expiry\" i]'),
      cvc: !!document.querySelector('input[name=\"cvc\"], input[name=\"cvv\"]'),
      cardName: !!document.querySelector('input[name=\"cardName\"]')
    },
    hasSubmitButton: Array.from(document.querySelectorAll('button')).some(btn => 
      btn.textContent.toLowerCase().includes('book') || 
      btn.textContent.toLowerCase().includes('confirm') ||
      btn.textContent.toLowerCase().includes('pay')
    ),
    allInputs: Array.from(document.querySelectorAll('input')).map(input => ({
      type: input.type,
      name: input.name,
      placeholder: input.placeholder
    }))
  };
  
  JSON.stringify(formCheck, null, 2);
" 2>/dev/null)

echo "$FORM_CHECK" >> "$DEBUG_LOG"

HAS_GUEST_FIELDS=$(echo "$FORM_CHECK" | jq -r '[.guestFields[]] | any' 2>/dev/null)
HAS_PAYMENT_FIELDS=$(echo "$FORM_CHECK" | jq -r '[.paymentFields[]] | any' 2>/dev/null)

log "✓ Has guest fields: $HAS_GUEST_FIELDS"
log "✓ Has payment fields: $HAS_PAYMENT_FIELDS"

$AB screenshot "$OUTPUT_DIR/screenshots/autodebug_05_form_check_${TIMESTAMP}.png"

# ── STEP 9: Check routing structure ───────────────────────────────────────────
log_section "STEP 9: Routing Structure"
log "[9/10] Checking application routing..."

ROUTING_INFO=$($AB eval "
  const routingInfo = {
    hasNextData: !!document.getElementById('__NEXT_DATA__'),
    hasNextRoot: !!document.getElementById('__next'),
    allLinks: Array.from(document.querySelectorAll('a[href]'))
      .map(a => a.href)
      .filter(href => href.includes('/book') || href.includes('/reserve'))
      .slice(0, 10),
    navLinks: Array.from(document.querySelectorAll('nav a, header a'))
      .map(a => ({ href: a.href, text: a.textContent.trim() }))
  };
  
  JSON.stringify(routingInfo, null, 2);
" 2>/dev/null)

echo "$ROUTING_INFO" >> "$DEBUG_LOG"
log "✓ Routing info captured"

# ── STEP 10: Generate report ──────────────────────────────────────────────────
log_section "STEP 10: Final Report"
log "[10/10] Generating report..."

$AB close

log ""
log "========================================"
log " DEBUGGING COMPLETE"
log "========================================"
log ""
log "Key Findings:"
log "  • Hotels page: $LINK_COUNT hotels found"
log "  • Hotel detail: $BOOKING_BTN_COUNT booking buttons"
log "  • After click: $([ "$IS_BOOKING_PAGE" = "true" ] && echo "Booking page" || echo "Still on detail")"
log "  • Guest fields: $HAS_GUEST_FIELDS"
log "  • Payment fields: $HAS_PAYMENT_FIELDS"
log ""
log "Files Generated:"
log "  📄 $DEBUG_LOG"
log "  📸 $OUTPUT_DIR/screenshots/autodebug_*_${TIMESTAMP}.png"
log ""

# Analyze and provide recommendations
log "Recommendations:"
if [ "$IS_BOOKING_PAGE" = "true" ] && [ "$HAS_GUEST_FIELDS" = "true" ]; then
  log "  ✅ Booking flow is working - update test with correct selectors"
elif [ "$IS_BOOKING_PAGE" = "false" ]; then
  log "  ⚠️  Booking button doesn't navigate to booking page"
  log "     → Check if booking requires date selection first"
  log "     → Check if booking is modal-based instead of page navigation"
elif [ "$HAS_GUEST_FIELDS" = "false" ]; then
  log "  ⚠️  Booking page exists but missing form fields"
  log "     → Check if form loads dynamically"
  log "     → Check if additional steps are required"
fi

log ""
log "✅ Debug complete! Review the log file for details."
log ""

exit 0
