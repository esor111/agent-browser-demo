#!/bin/bash

###############################################################################
# SETUP AND TEST BOOKING FLOW
# 1. Creates a property with rooms (if needed)
# 2. Tests the customer booking flow
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR/frontend-tests"
source "$TEST_DIR/config/test-config.sh"

AB="$AB_PATH"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo ""
echo "========================================"
echo " SETUP AND TEST BOOKING FLOW"
echo "========================================"
echo ""

# ── STEP 1: Check if hotels exist ─────────────────────────────────────────────
echo "[1/3] Checking if hotels exist..."

$AB --headed open "$FRONTEND_URL/hotels"
$AB wait 5000

HOTEL_COUNT=$($AB eval "
  const text = document.body.innerText;
  const match = text.match(/All Properties: (\d+)/);
  match ? match[1] : '0';
" 2>/dev/null | tr -d '"')

echo "  Found $HOTEL_COUNT properties"

if [ "$HOTEL_COUNT" = "0" ]; then
  echo "  ⚠️  No hotels found - need to create test data"
  $AB close
  
  echo ""
  echo "[2/3] Creating test property with rooms..."
  echo "  Running property onboarding..."
  
  # Run property onboarding
  bash "$TEST_DIR/property-onboarding-complete.sh" || bash "$TEST_DIR/property-onboarding-new-user.sh"
  ONBOARD_RESULT=$?
  
  if [ $ONBOARD_RESULT -ne 0 ]; then
    echo "  ✗ Property onboarding failed"
    exit 1
  fi
  
  echo "  ✓ Property created"
  
  echo ""
  echo "  Adding rooms to property..."
  bash "$TEST_DIR/add-rooms-to-property.sh"
  ROOMS_RESULT=$?
  
  if [ $ROOMS_RESULT -ne 0 ]; then
    echo "  ✗ Room creation failed"
    exit 1
  fi
  
  echo "  ✓ Rooms added"
  
  # Wait a bit for data to be indexed
  echo "  Waiting for data to be indexed..."
  sleep 5
  
else
  echo "  ✓ Hotels exist, skipping setup"
  $AB close
fi

# ── STEP 2: Verify hotels are now visible ────────────────────────────────────
echo ""
echo "[3/3] Verifying hotels are visible..."

$AB --headed open "$FRONTEND_URL/hotels"
$AB wait 5000

HOTEL_COUNT=$($AB eval "
  const text = document.body.innerText;
  const match = text.match(/All Properties: (\d+)/);
  match ? match[1] : '0';
" 2>/dev/null | tr -d '"')

echo "  Properties found: $HOTEL_COUNT"

if [ "$HOTEL_COUNT" = "0" ]; then
  echo "  ✗ Still no hotels visible"
  $AB screenshot "$OUTPUT_DIR/screenshots/no_hotels_${TIMESTAMP}.png"
  $AB close
  exit 1
fi

# Get hotel links
HOTEL_LINKS=$($AB eval "
  const links = Array.from(document.querySelectorAll('a[href*=\"/hotels/\"]'))
    .filter(link => link.href.match(/\/hotels\/[^\/]+$/));
  JSON.stringify(links.map(l => l.href));
" 2>/dev/null)

LINK_COUNT=$(echo "$HOTEL_LINKS" | jq '. | length' 2>/dev/null || echo "0")

echo "  Hotel links found: $LINK_COUNT"

if [ "$LINK_COUNT" = "0" ]; then
  echo "  ✗ No hotel links found (but count shows $HOTEL_COUNT)"
  echo "  This might be a rendering issue"
  $AB screenshot "$OUTPUT_DIR/screenshots/hotels_no_links_${TIMESTAMP}.png"
  $AB close
  exit 1
fi

echo "  ✓ Hotels are visible and clickable"

$AB screenshot "$OUTPUT_DIR/screenshots/hotels_ready_${TIMESTAMP}.png"
$AB close

echo ""
echo "========================================"
echo " ✅ SETUP COMPLETE"
echo "========================================"
echo ""
echo "Ready to test booking flow!"
echo "  • Properties: $HOTEL_COUNT"
echo "  • Clickable links: $LINK_COUNT"
echo ""
echo "Now running booking flow test..."
echo ""

# ── STEP 3: Run booking flow test ─────────────────────────────────────────────
bash "$TEST_DIR/tests/customer/booking-payment-flow-test.sh"
BOOKING_RESULT=$?

echo ""
if [ $BOOKING_RESULT -eq 0 ]; then
  echo "✅ BOOKING FLOW TEST PASSED!"
else
  echo "❌ BOOKING FLOW TEST FAILED"
  echo "   Check screenshots for details"
fi

exit $BOOKING_RESULT
