#!/bin/bash

###############################################################################
# DIAGNOSE BOOKING READINESS
# Checks all prerequisites for booking flow testing
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR/frontend-tests"
source "$TEST_DIR/config/test-config.sh"

AB="$AB_PATH"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo ""
echo "========================================"
echo " BOOKING READINESS DIAGNOSTIC"
echo "========================================"
echo ""

# 1. Check customer-facing hotels page
echo "[1/4] Checking customer hotels page..."
$AB --headed open "$FRONTEND_URL/hotels"
$AB wait 5000

HOTEL_COUNT=$($AB eval "
  const text = document.body.innerText;
  const match = text.match(/All Properties: (\d+)/);
  match ? match[1] : '0';
" 2>/dev/null | tr -d '"')

echo "  ✓ Hotels visible to customers: $HOTEL_COUNT"
$AB screenshot "$OUTPUT_DIR/screenshots/diag_01_customer_hotels_${TIMESTAMP}.png"

# 2. Check owner dashboard
echo ""
echo "[2/4] Checking owner dashboard..."
$AB open "$FRONTEND_URL/login"
$AB wait 3000

$AB eval "
  const phoneInput = document.querySelector('input[type=\"tel\"]');
  const passwordInput = document.querySelector('input[type=\"password\"]');
  if (phoneInput) {
    phoneInput.value = '$OWNER_PHONE';
    phoneInput.dispatchEvent(new Event('input', { bubbles: true }));
  }
  if (passwordInput) {
    passwordInput.value = '$OWNER_PASSWORD';
    passwordInput.dispatchEvent(new Event('input', { bubbles: true }));
  }
  const signInBtn = Array.from(document.querySelectorAll('button'))
    .find(b => b.textContent.includes('Sign In'));
  if (signInBtn) signInBtn.click();
" > /dev/null 2>&1

$AB wait 8000

DASHBOARD_URL=$($AB get url 2>/dev/null)
echo "  ✓ After login URL: $DASHBOARD_URL"

HAS_DASHBOARD=$(echo "$DASHBOARD_URL" | grep -o "owner/dashboard")
if [ -n "$HAS_DASHBOARD" ]; then
  echo "  ✓ Owner has property"
else
  echo "  ✗ Owner doesn't have property yet"
fi

$AB screenshot "$OUTPUT_DIR/screenshots/diag_02_owner_dashboard_${TIMESTAMP}.png"

# 3. Check rooms
echo ""
echo "[3/4] Checking rooms..."
$AB open "$FRONTEND_URL/owner/rooms"
$AB wait 5000

ROOM_INFO=$($AB eval "
  const text = document.body.innerText;
  JSON.stringify({
    hasRooms: text.includes('Room Number') || text.includes('Available'),
    roomCount: (text.match(/Room \d+/g) || []).length,
    hasRoomTypes: text.includes('Room Type'),
    pageText: text.substring(0, 500)
  });
" 2>/dev/null)

echo "$ROOM_INFO" | jq '.' 2>/dev/null || echo "$ROOM_INFO"
$AB screenshot "$OUTPUT_DIR/screenshots/diag_03_rooms_${TIMESTAMP}.png"

# 4. Check rate plans
echo ""
echo "[4/4] Checking rate plans..."
$AB open "$FRONTEND_URL/owner/rates"
$AB wait 5000

RATE_INFO=$($AB eval "
  const text = document.body.innerText;
  JSON.stringify({
    hasRatePlans: text.includes('Rate Plan') || text.includes('Base Rate'),
    rateCount: (text.match(/Rs\. \d+/g) || []).length,
    pageText: text.substring(0, 500)
  });
" 2>/dev/null)

echo "$RATE_INFO" | jq '.' 2>/dev/null || echo "$RATE_INFO"
$AB screenshot "$OUTPUT_DIR/screenshots/diag_04_rates_${TIMESTAMP}.png"

$AB close

# Summary
echo ""
echo "========================================"
echo " DIAGNOSTIC SUMMARY"
echo "========================================"
echo ""

HAS_ROOMS=$(echo "$ROOM_INFO" | jq -r '.hasRooms' 2>/dev/null)
HAS_RATES=$(echo "$RATE_INFO" | jq -r '.hasRatePlans' 2>/dev/null)

echo "Prerequisites for booking:"
echo "  1. Property exists: $([ -n "$HAS_DASHBOARD" ] && echo "✓" || echo "✗")"
echo "  2. Rooms added: $([ "$HAS_ROOMS" = "true" ] && echo "✓" || echo "✗")"
echo "  3. Rate plans set: $([ "$HAS_RATES" = "true" ] && echo "✓" || echo "✗")"
echo "  4. Visible to customers: $([ "$HOTEL_COUNT" != "0" ] && echo "✓" || echo "✗")"
echo ""

if [ "$HOTEL_COUNT" != "0" ]; then
  echo "✅ READY FOR BOOKING TESTS!"
  echo ""
  echo "Run: bash frontend-tests/tests/customer/booking-payment-flow-test.sh"
  EXIT_CODE=0
else
  echo "⚠️  NOT READY FOR BOOKING TESTS"
  echo ""
  echo "Missing requirements:"
  [ -z "$HAS_DASHBOARD" ] && echo "  • Create property (run property onboarding)"
  [ "$HAS_ROOMS" != "true" ] && echo "  • Add rooms (run: bash frontend-tests/add-rooms-to-property.sh)"
  [ "$HAS_RATES" != "true" ] && echo "  • Set rate plans (run: bash frontend-tests/rate-plan-management.sh)"
  [ "$HOTEL_COUNT" = "0" ] && echo "  • Property not published or missing data"
  echo ""
  echo "Possible issues:"
  echo "  • Property might need to be 'published' or 'active'"
  echo "  • Property might need minimum data (photos, description, etc.)"
  echo "  • There might be a backend issue preventing property listing"
  EXIT_CODE=1
fi

echo "Screenshots saved:"
echo "  • $OUTPUT_DIR/screenshots/diag_*_${TIMESTAMP}.png"
echo ""

exit $EXIT_CODE
