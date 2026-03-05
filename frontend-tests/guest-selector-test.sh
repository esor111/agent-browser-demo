#!/bin/bash

###############################################################################
# GUEST SELECTOR AUTOMATION TEST
# Tests the guest count selector functionality:
# - Click on search bar to expand
# - Click on guests button
# - Increase adult count
# - Increase children count
# - Increase room count
# - Verify selections
###############################################################################

AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
OUTPUT_DIR="./frontend-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$OUTPUT_DIR/screenshots"
mkdir -p "$OUTPUT_DIR/snapshots"

echo ""
echo "========================================"
echo " GUEST SELECTOR TEST"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""

# ── STEP 1: Open hotels page ──────────────────────────────────────────────────
echo "[1/9] Opening hotels page..."
$AB --headed open "$FRONTEND_URL/hotels"
$AB wait 3000
echo "✓ Hotels page loaded"

# Take initial screenshot
$AB screenshot "$OUTPUT_DIR/screenshots/guest_initial_${TIMESTAMP}.png"

# ── STEP 2: Click on search bar to expand ─────────────────────────────────────
echo "[2/9] Expanding search bar..."

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

# ── STEP 3: Find and click guests button ──────────────────────────────────────
echo "[3/9] Opening guest selector..."
$AB snapshot -i > /dev/null
$AB wait 500

# Find the Guests button
GUESTS_BUTTON=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Guests.*Adults.*Room"; "i"))
  | .key
' | head -1)

if [ -z "$GUESTS_BUTTON" ]; then
  echo "✗ Guests button not found"
  $AB close
  exit 1
fi

echo "  Found guests button: @$GUESTS_BUTTON"
$AB click "@$GUESTS_BUTTON"
$AB wait 1000
echo "✓ Guest selector opened"

# Take screenshot of guest selector
$AB screenshot "$OUTPUT_DIR/screenshots/guest_opened_${TIMESTAMP}.png"

# ── STEP 4: Get initial guest counts ──────────────────────────────────────────
echo "[4/9] Reading initial guest counts..."

INITIAL_STATE=$($AB eval "
  const text = document.body.innerText;
  const adultsMatch = text.match(/Adults[\\s\\S]*?Ages 13\\+[\\s\\S]*?(\\d+)/);
  const childrenMatch = text.match(/Children[\\s\\S]*?Ages 0-12[\\s\\S]*?(\\d+)/);
  const roomsMatch = text.match(/Rooms[\\s\\S]*?Max 5[\\s\\S]*?(\\d+)/);
  
  JSON.stringify({
    adults: adultsMatch ? parseInt(adultsMatch[1]) : 0,
    children: childrenMatch ? parseInt(childrenMatch[1]) : 0,
    rooms: roomsMatch ? parseInt(roomsMatch[1]) : 0
  });
" 2>/dev/null)

echo "  Initial state: $INITIAL_STATE"

# Parse JSON properly by removing outer quotes if present
INITIAL_ADULTS=$(echo "$INITIAL_STATE" | sed 's/^"//;s/"$//' | jq -r '.adults' 2>/dev/null || echo "2")
INITIAL_CHILDREN=$(echo "$INITIAL_STATE" | sed 's/^"//;s/"$//' | jq -r '.children' 2>/dev/null || echo "0")
INITIAL_ROOMS=$(echo "$INITIAL_STATE" | sed 's/^"//;s/"$//' | jq -r '.rooms' 2>/dev/null || echo "1")

# ── STEP 5: Find +/- buttons ──────────────────────────────────────────────────
echo "[5/9] Finding +/- buttons..."

# Get all button refs with null names (these are the +/- buttons)
BUTTON_REFS=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "button" and .value.name == null)
  | .key
' | head -10)

echo "  Found button refs:"
echo "$BUTTON_REFS" | head -6

# Assume pattern: e14=adults-, e15=adults+, e16=children-, e17=children+, e18=rooms-, e19=rooms+
ADULTS_PLUS=$(echo "$BUTTON_REFS" | sed -n '2p')
CHILDREN_PLUS=$(echo "$BUTTON_REFS" | sed -n '4p')
ROOMS_PLUS=$(echo "$BUTTON_REFS" | sed -n '6p')

echo "  Adults + button: @$ADULTS_PLUS"
echo "  Children + button: @$CHILDREN_PLUS"
echo "  Rooms + button: @$ROOMS_PLUS"

# ── STEP 6: Increase adult count ──────────────────────────────────────────────
echo "[6/9] Increasing adult count..."
$AB click "@$ADULTS_PLUS"
$AB wait 500
echo "✓ Adult count increased"

# Take screenshot
$AB screenshot "$OUTPUT_DIR/screenshots/guest_adults_${TIMESTAMP}.png"

# ── STEP 7: Increase children count ───────────────────────────────────────────
echo "[7/9] Increasing children count..."
$AB click "@$CHILDREN_PLUS"
$AB wait 500
echo "✓ Children count increased"

# Take screenshot
$AB screenshot "$OUTPUT_DIR/screenshots/guest_children_${TIMESTAMP}.png"

# ── STEP 8: Increase room count ───────────────────────────────────────────────
echo "[8/9] Increasing room count..."
$AB click "@$ROOMS_PLUS"
$AB wait 500
echo "✓ Room count increased"

# Take screenshot
$AB screenshot "$OUTPUT_DIR/screenshots/guest_rooms_${TIMESTAMP}.png"

# ── STEP 9: Verify final counts ───────────────────────────────────────────────
echo "[9/9] Verifying final guest counts..."

FINAL_STATE=$($AB eval "
  const text = document.body.innerText;
  const adultsMatch = text.match(/Adults[\\s\\S]*?Ages 13\\+[\\s\\S]*?(\\d+)/);
  const childrenMatch = text.match(/Children[\\s\\S]*?Ages 0-12[\\s\\S]*?(\\d+)/);
  const roomsMatch = text.match(/Rooms[\\s\\S]*?Max 5[\\s\\S]*?(\\d+)/);
  
  JSON.stringify({
    adults: adultsMatch ? parseInt(adultsMatch[1]) : 0,
    children: childrenMatch ? parseInt(childrenMatch[1]) : 0,
    rooms: roomsMatch ? parseInt(roomsMatch[1]) : 0
  });
" 2>/dev/null)

echo "  Final state: $FINAL_STATE"

# Parse JSON properly by removing outer quotes if present
FINAL_ADULTS=$(echo "$FINAL_STATE" | sed 's/^"//;s/"$//' | jq -r '.adults' 2>/dev/null || echo "0")
FINAL_CHILDREN=$(echo "$FINAL_STATE" | sed 's/^"//;s/"$//' | jq -r '.children' 2>/dev/null || echo "0")
FINAL_ROOMS=$(echo "$FINAL_STATE" | sed 's/^"//;s/"$//' | jq -r '.rooms' 2>/dev/null || echo "0")

# Take final screenshot
$AB screenshot "$OUTPUT_DIR/screenshots/guest_final_${TIMESTAMP}.png"

# ── Close browser ─────────────────────────────────────────────────────────────
$AB close
echo "✓ Browser closed"

# ── Summary ───────────────────────────────────────────────────────────────────
echo ""
echo "========================================"

# Check if counts increased
ADULTS_INCREASED=$((FINAL_ADULTS > INITIAL_ADULTS))
CHILDREN_INCREASED=$((FINAL_CHILDREN > INITIAL_CHILDREN))
ROOMS_INCREASED=$((FINAL_ROOMS > INITIAL_ROOMS))

if [ $ADULTS_INCREASED -eq 1 ] && [ $CHILDREN_INCREASED -eq 1 ] && [ $ROOMS_INCREASED -eq 1 ]; then
  echo " ✅ GUEST SELECTOR TEST PASSED"
  echo "========================================"
  echo ""
  echo "Guest Count Changes:"
  echo "  • Adults: $INITIAL_ADULTS → $FINAL_ADULTS ✓"
  echo "  • Children: $INITIAL_CHILDREN → $FINAL_CHILDREN ✓"
  echo "  • Rooms: $INITIAL_ROOMS → $FINAL_ROOMS ✓"
  EXIT_CODE=0
else
  echo " ❌ GUEST SELECTOR TEST FAILED"
  echo "========================================"
  echo ""
  echo "Issues:"
  [ $ADULTS_INCREASED -eq 0 ] && echo "  • Adults count did not increase ($INITIAL_ADULTS → $FINAL_ADULTS)"
  [ $CHILDREN_INCREASED -eq 0 ] && echo "  • Children count did not increase ($INITIAL_CHILDREN → $FINAL_CHILDREN)"
  [ $ROOMS_INCREASED -eq 0 ] && echo "  • Rooms count did not increase ($INITIAL_ROOMS → $FINAL_ROOMS)"
  EXIT_CODE=1
fi

echo ""
echo "Screenshots saved:"
echo "  📸 $OUTPUT_DIR/screenshots/guest_initial_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/guest_opened_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/guest_adults_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/guest_children_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/guest_rooms_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/guest_final_${TIMESTAMP}.png"
echo ""

exit $EXIT_CODE
