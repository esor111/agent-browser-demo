#!/bin/bash

###############################################################################
# PROPERTY ONBOARDING AUTOMATION - WORKING VERSION
# Successfully creates a new property through the 8-step onboarding process
# Tested and verified: March 5, 2026
###############################################################################

AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
OUTPUT_DIR="./frontend-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$OUTPUT_DIR/screenshots"

# Property data
PROPERTY_NAME="Test Automation Hotel ${TIMESTAMP}"
PHONE="9841234567"
EMAIL="test@automation.com"
WEBSITE="https://testhotel.com"
DESCRIPTION="A beautiful test hotel for automation testing purposes. Located in the heart of Kathmandu with modern amenities."

echo ""
echo "========================================"
echo " PROPERTY ONBOARDING AUTOMATION"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""
echo "Property Details:"
echo "  Name: $PROPERTY_NAME"
echo "  Type: Hotel (1-5 rooms)"
echo "  Location: Kathmandu, Bagmati"
echo "  Contact: $PHONE"
echo ""

# ── STEP 1: Open onboarding page ──────────────────────────────────────────────
echo "[1/8] Opening onboarding page..."
$AB --headed open "$FRONTEND_URL/onboarding"
$AB wait 4000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_01_initial_${TIMESTAMP}.png"
echo "✓ Page loaded"

# ── STEP 2: Property Type & Room Count ────────────────────────────────────────
echo ""
echo "[2/8] Selecting property type (Hotel) and room count (1-5)..."
$AB snapshot -i > /dev/null

# Click Hotel button
HOTEL_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Hotel.*Full-service"; "i"))
  | .key
' 2>/dev/null | head -1)

echo "  Hotel button: $HOTEL_BTN"
if [ -n "$HOTEL_BTN" ]; then
  $AB click "@$HOTEL_BTN"
  $AB wait 1000
fi

# Click room count (1-5)
$AB snapshot -i > /dev/null
ROOM_COUNT_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("1.*5.*Small"; "i"))
  | .key
' 2>/dev/null | head -1)

echo "  Room count button: $ROOM_COUNT_BTN"
if [ -n "$ROOM_COUNT_BTN" ]; then
  $AB click "@$ROOM_COUNT_BTN"
  $AB wait 1000
fi

# Click Continue
$AB snapshot -i > /dev/null
CONTINUE_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button" and .value.name == "Continue")
  | .key
' 2>/dev/null | head -1)

echo "  Continue button: $CONTINUE_BTN"
if [ -n "$CONTINUE_BTN" ]; then
  $AB click "@$CONTINUE_BTN"
  $AB wait 3000
fi
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_02_property_type_${TIMESTAMP}.png"
echo "✓ Property type selected"

# ── STEP 3: Property Name ─────────────────────────────────────────────────────
echo ""
echo "[3/8] Entering property name..."
$AB snapshot -i > /dev/null

NAME_INPUT=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "textbox")
  | .key
' 2>/dev/null | head -1)

echo "  Name input: $NAME_INPUT"
$AB fill "@$NAME_INPUT" "$PROPERTY_NAME"
$AB wait 1000

# Click Continue
$AB snapshot -i > /dev/null
CONTINUE_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button" and .value.name == "Continue")
  | .key
' 2>/dev/null | head -1)

$AB click "@$CONTINUE_BTN"
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_03_property_name_${TIMESTAMP}.png"
echo "✓ Property name entered: $PROPERTY_NAME"

# ── STEP 4: Location ──────────────────────────────────────────────────────────
echo ""
echo "[4/8] Filling location details..."
$AB snapshot -i > /dev/null

# Get all textboxes
ALL_INPUTS=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "textbox")
  | .key
' 2>/dev/null)

# Convert to array
INPUTS_ARRAY=($ALL_INPUTS)

# Fill location fields (city, street, state, district, postal)
echo "  Filling city..."
$AB fill "@${INPUTS_ARRAY[0]}" "Kathmandu"
$AB wait 500

echo "  Filling street address..."
$AB fill "@${INPUTS_ARRAY[1]}" "Thamel Street"
$AB wait 500

echo "  Filling state..."
$AB fill "@${INPUTS_ARRAY[2]}" "Bagmati"
$AB wait 500

echo "  Filling district..."
$AB fill "@${INPUTS_ARRAY[3]}" "Kathmandu"
$AB wait 500

echo "  Filling postal code..."
$AB fill "@${INPUTS_ARRAY[4]}" "44600"
$AB wait 1000

# Click Continue
$AB snapshot -i > /dev/null
CONTINUE_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button" and .value.name == "Continue")
  | .key
' 2>/dev/null | head -1)

$AB click "@$CONTINUE_BTN"
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_04_location_${TIMESTAMP}.png"
echo "✓ Location details filled"

# ── STEP 5: Contact ───────────────────────────────────────────────────────────
echo ""
echo "[5/8] Filling contact details..."
$AB snapshot -i > /dev/null

# Get all textboxes (phone, email, website)
ALL_INPUTS=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "textbox")
  | .key
' 2>/dev/null)

INPUTS_ARRAY=($ALL_INPUTS)

echo "  Filling phone..."
$AB fill "@${INPUTS_ARRAY[0]}" "$PHONE"
$AB wait 500

echo "  Filling email..."
$AB fill "@${INPUTS_ARRAY[1]}" "$EMAIL"
$AB wait 500

echo "  Filling website..."
$AB fill "@${INPUTS_ARRAY[2]}" "$WEBSITE"
$AB wait 1000

# Click Continue
$AB snapshot -i > /dev/null
CONTINUE_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button" and .value.name == "Continue")
  | .key
' 2>/dev/null | head -1)

$AB click "@$CONTINUE_BTN"
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_05_contact_${TIMESTAMP}.png"
echo "✓ Contact details filled"

# ── STEP 6: Operations ────────────────────────────────────────────────────────
echo ""
echo "[6/8] Setting operational details..."
$AB snapshot -i > /dev/null

# Select check-in time (2:00 PM)
CHECKIN_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button" and .value.name == "2:00 PM")
  | .key
' 2>/dev/null | head -1)

echo "  Check-in time: $CHECKIN_BTN"
$AB click "@$CHECKIN_BTN"
$AB wait 500

# Select check-out time (11:00 AM)
$AB snapshot -i > /dev/null
CHECKOUT_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button" and .value.name == "11:00 AM")
  | select(.key | test("e2[0-9]"))
  | .key
' 2>/dev/null | head -1)

echo "  Check-out time: $CHECKOUT_BTN"
$AB click "@$CHECKOUT_BTN"
$AB wait 500

# Select 4 stars
$AB snapshot -i > /dev/null
STAR_BTNS=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button" and .value.name == "")
  | .key
' 2>/dev/null)

STAR_ARRAY=($STAR_BTNS)
FOUR_STAR_BTN="${STAR_ARRAY[3]}"

echo "  4-star button: $FOUR_STAR_BTN"
$AB click "@$FOUR_STAR_BTN"
$AB wait 500

# Fill description
$AB snapshot -i > /dev/null
DESC_INPUT=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "textbox")
  | .key
' 2>/dev/null | head -1)

echo "  Description input: $DESC_INPUT"
$AB fill "@$DESC_INPUT" "$DESCRIPTION"
$AB wait 1000

# Click Continue
$AB snapshot -i > /dev/null
CONTINUE_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button" and .value.name == "Continue")
  | .key
' 2>/dev/null | head -1)

$AB click "@$CONTINUE_BTN"
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_06_operations_${TIMESTAMP}.png"
echo "✓ Operations details set"

# ── STEP 7: Plan Selector ─────────────────────────────────────────────────────
echo ""
echo "[7/8] Selecting subscription plan..."
$AB snapshot -i > /dev/null

# Select Free Trial plan
PLAN_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Free Trial"; "i"))
  | .key
' 2>/dev/null | head -1)

echo "  Plan button: $PLAN_BTN"
$AB click "@$PLAN_BTN"
$AB wait 1000

# Click Continue
$AB snapshot -i > /dev/null
CONTINUE_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button" and .value.name == "Continue")
  | .key
' 2>/dev/null | head -1)

$AB click "@$CONTINUE_BTN"
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_07_plan_${TIMESTAMP}.png"
echo "✓ Plan selected"

# ── STEP 8: Review & Submit ───────────────────────────────────────────────────
echo ""
echo "[8/8] Reviewing and submitting..."
$AB snapshot -i > /dev/null

# Click Register My Property button
SUBMIT_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Register My Property"; "i"))
  | .key
' 2>/dev/null | head -1)

echo "  Submit button: $SUBMIT_BTN"
$AB click "@$SUBMIT_BTN"
echo "  Waiting for submission..."
$AB wait 8000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_08_success_${TIMESTAMP}.png"
echo "✓ Property submitted"

# ── Check Success ─────────────────────────────────────────────────────────────
echo ""
echo "Checking result..."
CURRENT_URL=$($AB get url 2>/dev/null)
echo "Current URL: $CURRENT_URL"

PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null | tr -d '"')
PROPERTY_CODE=$(echo "$PAGE_TEXT" | grep -oP '[A-Z]+-[A-Z]+-[A-Z]+-[0-9]+' | head -1)

$AB close
echo "✓ Browser closed"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "========================================"

if [ "$CURRENT_URL" = "$FRONTEND_URL/onboarding/success" ] && [ -n "$PROPERTY_CODE" ]; then
  echo " ✅ PROPERTY ONBOARDING - SUCCESS!"
  echo "========================================"
  echo ""
  echo "Property Created:"
  echo "  • Name: $PROPERTY_NAME"
  echo "  • Code: $PROPERTY_CODE"
  echo "  • Type: Hotel (1-5 rooms)"
  echo "  • Location: Kathmandu, Bagmati"
  echo "  • Contact: $PHONE"
  echo "  • Email: $EMAIL"
  echo "  • Check-in: 2:00 PM"
  echo "  • Check-out: 11:00 AM"
  echo "  • Rating: 4 stars"
  EXIT_CODE=0
else
  echo " ❌ PROPERTY ONBOARDING - FAILED"
  echo "========================================"
  echo ""
  echo "Final URL: $CURRENT_URL"
  echo "Expected: $FRONTEND_URL/onboarding/success"
  EXIT_CODE=1
fi

echo ""
echo "Screenshots saved:"
ls -1 "$OUTPUT_DIR/screenshots/onboard_"*"_${TIMESTAMP}.png" 2>/dev/null | while read file; do
  echo "  📸 $(basename $file)"
done
echo ""

exit $EXIT_CODE
