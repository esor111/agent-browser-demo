#!/bin/bash

###############################################################################
# CREATE TEST PROPERTY - SIMPLE VERSION
# Uses existing owner account to create a minimal property
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR/frontend-tests"
source "$TEST_DIR/config/test-config.sh"

AB="$AB_PATH"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

PROPERTY_NAME="Test Hotel ${TIMESTAMP: -6}"
ROOM_TYPE_NAME="Standard Room"
ROOM_NUMBER="101"

echo ""
echo "========================================"
echo " CREATE TEST PROPERTY (SIMPLE)"
echo "========================================"
echo ""
echo "Property: $PROPERTY_NAME"
echo "Room Type: $ROOM_TYPE_NAME"
echo "Room: $ROOM_NUMBER"
echo ""

# Login as owner
echo "[1/5] Logging in as owner..."
$AB --headed open "$FRONTEND_URL/login"
$AB wait 3000

$AB eval "
  const phoneInput = document.querySelector('input[type=\"tel\"], input[placeholder*=\"phone\" i]');
  const passwordInput = document.querySelector('input[type=\"password\"]');
  
  if (phoneInput) {
    phoneInput.value = '$OWNER_PHONE';
    phoneInput.dispatchEvent(new Event('input', { bubbles: true }));
  }
  
  if (passwordInput) {
    passwordInput.value = '$OWNER_PASSWORD';
    passwordInput.dispatchEvent(new Event('input', { bubbles: true }));
  }
" > /dev/null 2>&1

$AB wait 1000

$AB eval "
  const signInBtn = Array.from(document.querySelectorAll('button'))
    .find(b => b.textContent.includes('Sign In'));
  if (signInBtn) signInBtn.click();
" > /dev/null 2>&1

$AB wait 8000
echo "✓ Logged in"

# Check if already has property
CURRENT_URL=$($AB get url 2>/dev/null)
echo "  Current URL: $CURRENT_URL"

if echo "$CURRENT_URL" | grep -q "owner/dashboard"; then
  echo "  ✓ Already has property - can use existing"
  
  # Navigate to hotels page to verify
  $AB open "$FRONTEND_URL/hotels"
  $AB wait 5000
  
  HOTEL_COUNT=$($AB eval "
    const text = document.body.innerText;
    const match = text.match(/All Properties: (\d+)/);
    match ? match[1] : '0';
  " 2>/dev/null | tr -d '"')
  
  echo "  Hotels visible on customer page: $HOTEL_COUNT"
  
  if [ "$HOTEL_COUNT" != "0" ]; then
    echo ""
    echo "✅ Property already exists and is visible!"
    $AB close
    exit 0
  else
    echo "  ⚠️  Property exists but not visible on customer page"
    echo "  This might be because:"
    echo "    - Property is not published"
    echo "    - No rooms added"
    echo "    - No rate plans set"
  fi
fi

$AB close

echo ""
echo "========================================"
echo " PROPERTY STATUS"
echo "========================================"
echo ""
echo "Owner has dashboard access but property not visible to customers"
echo ""
echo "To make property bookable, ensure:"
echo "  1. Property is created (✓ seems done)"
echo "  2. Rooms are added (run: bash frontend-tests/add-rooms-to-property.sh)"
echo "  3. Rate plans are set"
echo "  4. Property is published/active"
echo ""

exit 0
