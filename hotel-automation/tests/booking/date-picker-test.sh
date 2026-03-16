#!/bin/bash

###############################################################################
# DATE PICKER AUTOMATION TEST
# Tests the date picker functionality on the hotels search page:
# - Click on search bar to expand
# - Click on dates button
# - Select check-in date
# - Select check-out date
# - Verify dates were selected
###############################################################################

AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
OUTPUT_DIR="./frontend-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$OUTPUT_DIR/screenshots"
mkdir -p "$OUTPUT_DIR/snapshots"

echo ""
echo "========================================"
echo " DATE PICKER TEST"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""

# ── STEP 1: Open hotels page ──────────────────────────────────────────────────
echo "[1/8] Opening hotels page..."
$AB --headed open "$FRONTEND_URL/hotels"
$AB wait 3000
echo "✓ Hotels page loaded"

# Take initial screenshot
$AB screenshot "$OUTPUT_DIR/screenshots/datepicker_initial_${TIMESTAMP}.png"

# ── STEP 2: Click on search bar to expand ─────────────────────────────────────
echo "[2/8] Expanding search bar..."

# Get snapshot to find search bar
SEARCH_BAR_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Anywhere|Any week|Adults|Room"; "i"))
  | .key
' | head -1)

if [ -n "$SEARCH_BAR_REF" ]; then
  echo "  Found search bar: @$SEARCH_BAR_REF"
  $AB click "@$SEARCH_BAR_REF"
  $AB wait 1000
  echo "✓ Search bar expanded"
else
  echo "  Search bar already expanded or not found"
fi

# ── STEP 3: Get snapshot to find date picker elements ─────────────────────────
echo "[3/8] Finding date picker..."
$AB snapshot -i > /dev/null
$AB wait 500

# Find the Dates button
DATES_BUTTON=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Dates|Select dates"; "i"))
  | .key
' | head -1)

if [ -z "$DATES_BUTTON" ]; then
  echo "✗ Dates button not found"
  $AB close
  exit 1
fi

echo "  Found dates button: @$DATES_BUTTON"

# ── STEP 4: Click on dates button ─────────────────────────────────────────────
echo "[4/8] Opening date picker..."
$AB click "@$DATES_BUTTON"
$AB wait 1000
echo "✓ Date picker opened"

# Take screenshot of date picker
$AB screenshot "$OUTPUT_DIR/screenshots/datepicker_opened_${TIMESTAMP}.png"

# ── STEP 5: Find available date buttons ───────────────────────────────────────
echo "[5/8] Finding available dates..."

# Get all date buttons (looking for buttons with just numbers as names)
DATE_BUTTONS=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("^[0-9]+$"))
  | select(.value.disabled != true)
  | "\(.key):\(.value.name)"
' | head -20)

echo "  Available dates:"
echo "$DATE_BUTTONS" | head -10

# Get the first two available dates
CHECKIN_REF=$(echo "$DATE_BUTTONS" | head -1 | cut -d: -f1)
CHECKIN_DAY=$(echo "$DATE_BUTTONS" | head -1 | cut -d: -f2)

CHECKOUT_REF=$(echo "$DATE_BUTTONS" | head -6 | tail -1 | cut -d: -f1)
CHECKOUT_DAY=$(echo "$DATE_BUTTONS" | head -6 | tail -1 | cut -d: -f2)

if [ -z "$CHECKIN_REF" ] || [ -z "$CHECKOUT_REF" ]; then
  echo "✗ Could not find available dates"
  $AB close
  exit 1
fi

echo "  Check-in: Day $CHECKIN_DAY (@$CHECKIN_REF)"
echo "  Check-out: Day $CHECKOUT_DAY (@$CHECKOUT_REF)"

# ── STEP 6: Select check-in date ──────────────────────────────────────────────
echo "[6/8] Selecting check-in date (Day $CHECKIN_DAY)..."
$AB click "@$CHECKIN_REF"
$AB wait 1000
echo "✓ Check-in date selected"

# Take screenshot after check-in selection
$AB screenshot "$OUTPUT_DIR/screenshots/datepicker_checkin_${TIMESTAMP}.png"

# ── STEP 7: Select check-out date ─────────────────────────────────────────────
echo "[7/8] Selecting check-out date (Day $CHECKOUT_DAY)..."
$AB click "@$CHECKOUT_REF"
$AB wait 1000
echo "✓ Check-out date selected"

# Take screenshot after check-out selection
$AB screenshot "$OUTPUT_DIR/screenshots/datepicker_checkout_${TIMESTAMP}.png"

# ── STEP 8: Verify dates were selected ────────────────────────────────────────
echo "[8/8] Verifying date selection..."

# Check if the dates button text has changed
DATES_TEXT=$($AB eval "
  const button = document.querySelector('button');
  const buttons = Array.from(document.querySelectorAll('button'));
  const datesBtn = buttons.find(btn => 
    btn.innerText?.includes('Dates') || 
    btn.innerText?.includes('Select dates') ||
    btn.innerText?.match(/Mar.*Mar|[0-9].*[0-9]/)
  );
  datesBtn?.innerText || 'Not found';
" 2>/dev/null)

echo "  Dates button text: $DATES_TEXT"

# Check if dates are in the URL or page state
CURRENT_URL=$($AB get url 2>/dev/null)
echo "  Current URL: $CURRENT_URL"

# Take final screenshot
$AB screenshot "$OUTPUT_DIR/screenshots/datepicker_final_${TIMESTAMP}.png"

# ── Close browser ─────────────────────────────────────────────────────────────
$AB close
echo "✓ Browser closed"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "========================================"
if [[ "$DATES_TEXT" != "Select dates" ]] && [[ "$DATES_TEXT" != "Not found" ]]; then
  echo " ✅ DATE PICKER TEST PASSED"
  echo "========================================"
  echo ""
  echo "Date Selection:"
  echo "  • Check-in: Day $CHECKIN_DAY"
  echo "  • Check-out: Day $CHECKOUT_DAY"
  echo "  • Dates button: $DATES_TEXT"
  EXIT_CODE=0
else
  echo " ❌ DATE PICKER TEST FAILED"
  echo "========================================"
  echo ""
  echo "Issues:"
  echo "  • Dates may not have been selected properly"
  echo "  • Dates button text: $DATES_TEXT"
  EXIT_CODE=1
fi

echo ""
echo "Screenshots saved:"
echo "  📸 $OUTPUT_DIR/screenshots/datepicker_initial_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/datepicker_opened_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/datepicker_checkin_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/datepicker_checkout_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/datepicker_final_${TIMESTAMP}.png"
echo ""

exit $EXIT_CODE
