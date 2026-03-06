#!/bin/bash

###############################################################################
# MANUAL BOOKING FLOW DEBUGGER
# Interactive script to manually explore the booking flow
# Pauses at each step so we can inspect what's happening
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/frontend-tests/config/test-config.sh"

AB="$AB_PATH"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo ""
echo "========================================"
echo " MANUAL BOOKING FLOW DEBUGGER"
echo " Press ENTER to proceed through steps"
echo "========================================"
echo ""

# Helper function to pause
pause() {
  echo ""
  echo ">>> $1"
  read -p "Press ENTER to continue..."
  echo ""
}

# ── STEP 1: Open hotels page ──────────────────────────────────────────────────
echo "[STEP 1] Opening hotels search page..."
$AB --headed open "$FRONTEND_URL/hotels"
$AB wait 3000

pause "Hotels page loaded. Check if page looks correct."

# Get page info
echo "Current URL:"
$AB get url

echo ""
echo "Page title:"
$AB eval "document.title"

echo ""
echo "Looking for hotel cards..."
HOTEL_COUNT=$($AB eval "document.querySelectorAll('[class*=\"hotel\"], [class*=\"card\"], [class*=\"property\"]').length" 2>/dev/null)
echo "Found $HOTEL_COUNT potential hotel elements"

$AB screenshot "$OUTPUT_DIR/screenshots/debug_01_hotels_${TIMESTAMP}.png"

pause "Inspect the page. Are hotels visible?"

# ── STEP 2: Find hotel links ──────────────────────────────────────────────────
echo "[STEP 2] Finding hotel links..."

$AB eval "
  const links = Array.from(document.querySelectorAll('a[href*=\"/hotels/\"]'));
  console.log('Total hotel links found:', links.length);
  
  links.slice(0, 5).forEach((link, i) => {
    console.log(\`Link \${i+1}: \${link.href}\`);
    console.log(\`  Text: \${link.textContent.trim().substring(0, 50)}\`);
  });
  
  links.length;
"

pause "Check console output above. Do we have hotel links?"

# ── STEP 3: Click first hotel ─────────────────────────────────────────────────
echo "[STEP 3] Clicking first hotel..."

$AB eval "
  const hotelLinks = Array.from(document.querySelectorAll('a[href*=\"/hotels/\"]'))
    .filter(link => link.href.match(/\/hotels\/[^\/]+$/));
  
  if (hotelLinks.length > 0) {
    console.log('Clicking:', hotelLinks[0].href);
    hotelLinks[0].click();
  } else {
    console.log('ERROR: No hotel links found!');
  }
"

$AB wait 5000

echo "Current URL after click:"
$AB get url

$AB screenshot "$OUTPUT_DIR/screenshots/debug_02_hotel_detail_${TIMESTAMP}.png"

pause "Are we on hotel detail page? Check the URL and page content."

# ── STEP 4: Explore hotel detail page ─────────────────────────────────────────
echo "[STEP 4] Exploring hotel detail page..."

echo ""
echo "Looking for booking buttons..."
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button, a'));
  const bookingButtons = buttons.filter(el => {
    const text = (el.textContent || '').toLowerCase();
    return text.includes('book') || 
           text.includes('reserve') || 
           text.includes('check availability') ||
           text.includes('select');
  });
  
  console.log('Found', bookingButtons.length, 'potential booking buttons:');
  bookingButtons.forEach((btn, i) => {
    console.log(\`  \${i+1}. \${btn.tagName}: \${btn.textContent.trim()}\`);
    console.log(\`     href: \${btn.href || 'N/A'}\`);
  });
  
  bookingButtons.length;
"

echo ""
echo "Looking for room types..."
$AB eval "
  const roomElements = Array.from(document.querySelectorAll('[class*=\"room\"]'));
  console.log('Found', roomElements.length, 'elements with \"room\" in class');
  
  roomElements.slice(0, 3).forEach((el, i) => {
    console.log(\`Room \${i+1}:\`, el.textContent.trim().substring(0, 100));
  });
"

pause "Check the console. What booking buttons and room types do we see?"

# ── STEP 5: Try to navigate to booking ────────────────────────────────────────
echo "[STEP 5] Attempting to navigate to booking page..."

echo "Method 1: Click first booking button..."
$AB eval "
  const bookButtons = Array.from(document.querySelectorAll('button, a'))
    .filter(el => {
      const text = (el.textContent || '').toLowerCase();
      return text.includes('book') || text.includes('reserve');
    });
  
  if (bookButtons.length > 0) {
    console.log('Clicking:', bookButtons[0].textContent.trim());
    bookButtons[0].click();
  } else {
    console.log('No booking button found!');
  }
"

$AB wait 5000

CURRENT_URL=$($AB get url 2>/dev/null)
echo ""
echo "Current URL: $CURRENT_URL"

$AB screenshot "$OUTPUT_DIR/screenshots/debug_03_after_click_${TIMESTAMP}.png"

pause "Did we navigate to a booking page? Or are we still on hotel detail?"

# ── STEP 6: Check what's on current page ──────────────────────────────────────
echo "[STEP 6] Analyzing current page..."

echo ""
echo "Page URL:"
echo "$CURRENT_URL"

echo ""
echo "Looking for form inputs..."
$AB eval "
  const inputs = document.querySelectorAll('input, textarea, select');
  console.log('Total form inputs:', inputs.length);
  
  Array.from(inputs).slice(0, 10).forEach((input, i) => {
    console.log(\`  \${i+1}. \${input.type || input.tagName}: name=\"\${input.name}\", placeholder=\"\${input.placeholder}\"\`);
  });
"

echo ""
echo "Looking for payment-related elements..."
$AB eval "
  const text = document.body.innerText.toLowerCase();
  console.log('Has \"payment\":', text.includes('payment'));
  console.log('Has \"card\":', text.includes('card'));
  console.log('Has \"guest\":', text.includes('guest'));
  console.log('Has \"booking\":', text.includes('booking'));
  console.log('Has \"confirm\":', text.includes('confirm'));
"

$AB screenshot "$OUTPUT_DIR/screenshots/debug_04_current_page_${TIMESTAMP}.png"

pause "Check the analysis. What page are we actually on?"

# ── STEP 7: Try direct booking URL ────────────────────────────────────────────
echo "[STEP 7] Trying direct booking URL..."

# Extract hotel ID from current URL
HOTEL_ID=$(echo "$CURRENT_URL" | grep -oP '/hotels/\K[^/]+' | head -1)

if [ -n "$HOTEL_ID" ]; then
  echo "Hotel ID: $HOTEL_ID"
  echo "Trying: $FRONTEND_URL/booking/$HOTEL_ID"
  
  $AB open "$FRONTEND_URL/booking/$HOTEL_ID"
  $AB wait 5000
  
  BOOKING_URL=$($AB get url 2>/dev/null)
  echo "Result URL: $BOOKING_URL"
  
  $AB screenshot "$OUTPUT_DIR/screenshots/debug_05_direct_booking_${TIMESTAMP}.png"
  
  pause "Did direct booking URL work?"
else
  echo "Could not extract hotel ID"
  pause "No hotel ID found. Check the URL pattern."
fi

# ── STEP 8: Check for booking form ────────────────────────────────────────────
echo "[STEP 8] Looking for booking form elements..."

echo ""
echo "Guest detail inputs:"
$AB eval "
  const guestInputs = [
    'input[name=\"firstName\"]',
    'input[name=\"lastName\"]',
    'input[type=\"email\"]',
    'input[type=\"tel\"]'
  ];
  
  guestInputs.forEach(selector => {
    const el = document.querySelector(selector);
    console.log(selector, ':', el ? 'FOUND' : 'NOT FOUND');
  });
"

echo ""
echo "Payment inputs:"
$AB eval "
  const paymentInputs = [
    'input[name=\"cardNumber\"]',
    'input[name=\"expiry\"]',
    'input[name=\"cvc\"]',
    'input[name=\"cardName\"]'
  ];
  
  paymentInputs.forEach(selector => {
    const el = document.querySelector(selector);
    console.log(selector, ':', el ? 'FOUND' : 'NOT FOUND');
  });
"

echo ""
echo "Submit buttons:"
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button[type=\"submit\"], button'));
  console.log('Total buttons:', buttons.length);
  buttons.slice(0, 5).forEach((btn, i) => {
    console.log(\`  \${i+1}. \${btn.textContent.trim()}\`);
  });
"

$AB screenshot "$OUTPUT_DIR/screenshots/debug_06_form_check_${TIMESTAMP}.png"

pause "Review the form elements. Is this a complete booking form?"

# ── STEP 9: Check page source ─────────────────────────────────────────────────
echo "[STEP 9] Checking page structure..."

echo ""
echo "Main sections on page:"
$AB eval "
  const sections = document.querySelectorAll('section, div[class*=\"section\"], main, article');
  console.log('Found', sections.length, 'main sections');
  
  Array.from(sections).slice(0, 5).forEach((section, i) => {
    const classes = section.className;
    const text = section.textContent.trim().substring(0, 50);
    console.log(\`  \${i+1}. \${section.tagName} class=\"\${classes}\"\`);
    console.log(\`     Content: \${text}...\`);
  });
"

echo ""
echo "Checking for React/Next.js routing:"
$AB eval "
  console.log('Has __NEXT_DATA__:', !!document.getElementById('__NEXT_DATA__'));
  console.log('Has React root:', !!document.getElementById('__next'));
"

pause "Check the page structure. Any clues about the routing?"

# ── STEP 10: Summary ───────────────────────────────────────────────────────────
echo ""
echo "========================================"
echo " DEBUGGING SUMMARY"
echo "========================================"
echo ""
echo "Screenshots saved in:"
echo "  $OUTPUT_DIR/screenshots/debug_*_${TIMESTAMP}.png"
echo ""
echo "Key findings to check:"
echo "  1. Can we find hotels on /hotels page?"
echo "  2. Can we navigate to hotel detail?"
echo "  3. What booking buttons exist on hotel detail?"
echo "  4. Where do booking buttons navigate to?"
echo "  5. Does a direct /booking/:id URL work?"
echo "  6. What form fields exist on booking page?"
echo ""

pause "Review all screenshots and console output. Ready to close?"

echo "Closing browser..."
$AB close

echo ""
echo "✅ Manual debugging complete!"
echo ""
echo "Next steps:"
echo "  1. Review all screenshots"
echo "  2. Identify the actual booking flow"
echo "  3. Update the test script with correct selectors"
echo "  4. Test again"
echo ""
