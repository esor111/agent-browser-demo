#!/bin/bash

###############################################################################
# QUICK BOOKING TEST
# Assumes property already exists, just tests the booking flow
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR/frontend-tests"
source "$TEST_DIR/config/test-config.sh"

AB="$AB_PATH"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo ""
echo "========================================"
echo " QUICK BOOKING FLOW TEST"
echo "========================================"
echo ""

# Check if hotels exist
echo "[1/2] Checking for hotels..."
$AB --headed open "$FRONTEND_URL/hotels"
$AB wait 5000

HOTEL_COUNT=$($AB eval "
  const text = document.body.innerText;
  const match = text.match(/All Properties: (\d+)/);
  match ? match[1] : '0';
" 2>/dev/null | tr -d '"')

echo "  Properties found: $HOTEL_COUNT"

if [ "$HOTEL_COUNT" = "0" ]; then
  echo "  ✗ No hotels found!"
  echo ""
  echo "Please run one of these first:"
  echo "  1. bash frontend-tests/property-onboarding-new-user.sh"
  echo "  2. bash frontend-tests/add-rooms-to-property.sh"
  echo ""
  $AB close
  exit 1
fi

# Get detailed info about hotels
echo ""
echo "Analyzing hotels page..."
$AB eval "
  const links = Array.from(document.querySelectorAll('a[href*=\"/hotels/\"]'))
    .filter(link => link.href.match(/\/hotels\/[^\/]+$/));
  
  console.log('Hotel links found:', links.length);
  
  if (links.length > 0) {
    console.log('First hotel:', links[0].href);
    console.log('Hotel text:', links[0].textContent.trim().substring(0, 50));
  }
  
  // Check for hotel cards
  const cards = document.querySelectorAll('[class*=\"card\"], [class*=\"property\"]');
  console.log('Card elements:', cards.length);
"

$AB screenshot "$OUTPUT_DIR/screenshots/quick_booking_01_hotels_${TIMESTAMP}.png"

# Try to click first hotel
echo ""
echo "[2/2] Navigating to first hotel..."

FIRST_HOTEL=$($AB eval "
  const links = Array.from(document.querySelectorAll('a[href*=\"/hotels/\"]'))
    .filter(link => link.href.match(/\/hotels\/[^\/]+$/));
  
  if (links.length > 0) {
    links[0].click();
    links[0].href;
  } else {
    null;
  }
" 2>/dev/null | tr -d '"')

if [ "$FIRST_HOTEL" = "null" ] || [ -z "$FIRST_HOTEL" ]; then
  echo "  ✗ Could not find hotel link to click"
  $AB screenshot "$OUTPUT_DIR/screenshots/quick_booking_error_${TIMESTAMP}.png"
  $AB close
  exit 1
fi

echo "  Clicked: $FIRST_HOTEL"
$AB wait 5000

CURRENT_URL=$($AB get url 2>/dev/null)
echo "  Current URL: $CURRENT_URL"

$AB screenshot "$OUTPUT_DIR/screenshots/quick_booking_02_hotel_detail_${TIMESTAMP}.png"

# Check what's on the hotel detail page
echo ""
echo "Analyzing hotel detail page..."
$AB eval "
  const bookButtons = Array.from(document.querySelectorAll('button, a'))
    .filter(el => {
      const text = (el.textContent || '').toLowerCase();
      return text.includes('book') || text.includes('reserve') || text.includes('check availability');
    });
  
  console.log('Booking buttons found:', bookButtons.length);
  bookButtons.forEach((btn, i) => {
    console.log(\`  \${i+1}. \${btn.tagName}: \${btn.textContent.trim()}\`);
  });
  
  // Check for room types
  const rooms = document.querySelectorAll('[class*=\"room\"]');
  console.log('Room elements:', rooms.length);
  
  // Check page content
  const text = document.body.innerText.toLowerCase();
  console.log('Has \"available\":', text.includes('available'));
  console.log('Has \"price\":', text.includes('price'));
  console.log('Has \"per night\":', text.includes('per night'));
"

$AB close

echo ""
echo "========================================"
echo " ANALYSIS COMPLETE"
echo "========================================"
echo ""
echo "Screenshots:"
echo "  • $OUTPUT_DIR/screenshots/quick_booking_01_hotels_${TIMESTAMP}.png"
echo "  • $OUTPUT_DIR/screenshots/quick_booking_02_hotel_detail_${TIMESTAMP}.png"
echo ""
echo "Next: Review screenshots to understand the booking flow"
echo ""

exit 0
