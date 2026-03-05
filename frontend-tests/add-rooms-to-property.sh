#!/bin/bash

###############################################################################
# ADD ROOMS TO PROPERTY AUTOMATION
# Creates room types and rooms for a property
# This is a prerequisite for booking management
###############################################################################

AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
OUTPUT_DIR="./frontend-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$OUTPUT_DIR/screenshots"

# Owner credentials
OWNER_PHONE="9800000001"
OWNER_PASSWORD="password123"

# Room Type data
ROOM_TYPE_CODE="STD${TIMESTAMP}"
ROOM_TYPE_NAME="Standard Room ${TIMESTAMP}"
ROOM_CATEGORY="Standard"

# Room data - Use timestamp + random to ensure uniqueness
# Format: HHMM + random 2 digits (e.g., 2029 + 47 = 202947)
ROOM_NUMBER="$(date +%H%M)$(shuf -i 10-99 -n 1)"
FLOOR="1"

echo ""
echo "========================================"
echo " ADD ROOMS TO PROPERTY"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""

# ── STEP 1: Login as Owner ────────────────────────────────────────────────────
echo "[1/4] Logging in as owner..."
$AB --headed open "$FRONTEND_URL/login"
$AB wait 3000

$AB snapshot -i > /dev/null
PHONE_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null | head -1)
PASSWORD_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null | tail -1)

[ -n "$PHONE_REF" ] && $AB fill "@$PHONE_REF" "$OWNER_PHONE" && $AB wait 500
[ -n "$PASSWORD_REF" ] && $AB fill "@$PASSWORD_REF" "$OWNER_PASSWORD" && $AB wait 1000

$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const signInBtn = buttons.find(b => b.textContent.includes('Sign In'));
  if (signInBtn) signInBtn.click();
" > /dev/null 2>&1
$AB wait 5000

echo "✓ Logged in"

# ── STEP 2: Create Room Type ──────────────────────────────────────────────────
echo ""
echo "[2/4] Creating room type..."
$AB open "$FRONTEND_URL/owner/rooms"
$AB wait 4000

# Click "Room Types" tab
$AB eval "
  const links = Array.from(document.querySelectorAll('a, button'));
  const roomTypesLink = links.find(l => l.textContent.includes('Room Types'));
  if (roomTypesLink) roomTypesLink.click();
" > /dev/null 2>&1
$AB wait 3000

$AB screenshot "$OUTPUT_DIR/screenshots/rooms_01_room_types_${TIMESTAMP}.png"

# Click "New Room Type"
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const newRoomTypeBtn = buttons.find(b => b.textContent.includes('New Room Type'));
  if (newRoomTypeBtn) newRoomTypeBtn.click();
" > /dev/null 2>&1
$AB wait 3000

$AB screenshot "$OUTPUT_DIR/screenshots/rooms_02_new_room_type_form_${TIMESTAMP}.png"

# Fill room type form
$AB snapshot -i > /dev/null
REFS=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null)
REFS_ARRAY=($REFS)

echo "  Room Type: $ROOM_TYPE_NAME ($ROOM_TYPE_CODE)"
[ -n "${REFS_ARRAY[0]}" ] && $AB fill "@${REFS_ARRAY[0]}" "$ROOM_TYPE_CODE" && $AB wait 500
[ -n "${REFS_ARRAY[1]}" ] && $AB fill "@${REFS_ARRAY[1]}" "$ROOM_TYPE_NAME" && $AB wait 500

# Category is already selected as "Standard" by default

# Click "Create Room Type"
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const createBtn = buttons.find(b => b.textContent.includes('Create Room Type'));
  if (createBtn && !createBtn.disabled) createBtn.click();
" > /dev/null 2>&1
$AB wait 3000

$AB screenshot "$OUTPUT_DIR/screenshots/rooms_03_room_type_created_${TIMESTAMP}.png"
echo "✓ Room type created: $ROOM_TYPE_NAME"

# ── STEP 3: Create Room ───────────────────────────────────────────────────────
echo ""
echo "[3/4] Creating room..."

# Click "All Rooms" tab
$AB eval "
  const links = Array.from(document.querySelectorAll('a, button'));
  const allRoomsLink = links.find(l => l.textContent.includes('All Rooms'));
  if (allRoomsLink) allRoomsLink.click();
" > /dev/null 2>&1
$AB wait 3000

# Click "New Room"
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const newRoomBtn = buttons.find(b => b.textContent.includes('New Room'));
  if (newRoomBtn) newRoomBtn.click();
" > /dev/null 2>&1
$AB wait 2000

$AB screenshot "$OUTPUT_DIR/screenshots/rooms_04_new_room_form_${TIMESTAMP}.png"

# Select room type from dropdown
$AB snapshot -i > /dev/null
ROOM_TYPE_DROPDOWN=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "combobox") | .key' 2>/dev/null | head -1)

if [ -n "$ROOM_TYPE_DROPDOWN" ]; then
  $AB click "@$ROOM_TYPE_DROPDOWN"
  $AB wait 1000
  
  # Click the room type option
  $AB eval "
    const options = Array.from(document.querySelectorAll('[role=\"option\"]'));
    const roomTypeOption = options.find(o => o.textContent.includes('$ROOM_TYPE_NAME'));
    if (roomTypeOption) roomTypeOption.click();
  " > /dev/null 2>&1
  $AB wait 500
fi

# Fill room details
$AB snapshot -i > /dev/null
REFS=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null)
REFS_ARRAY=($REFS)

echo "  Room Number: $ROOM_NUMBER, Floor: $FLOOR"
[ -n "${REFS_ARRAY[0]}" ] && $AB fill "@${REFS_ARRAY[0]}" "$ROOM_NUMBER" && $AB wait 500
[ -n "${REFS_ARRAY[1]}" ] && $AB fill "@${REFS_ARRAY[1]}" "$FLOOR" && $AB wait 500

$AB screenshot "$OUTPUT_DIR/screenshots/rooms_05_room_form_filled_${TIMESTAMP}.png"

# Click "Create Room"
$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const createBtn = buttons.find(b => b.textContent.includes('Create Room'));
  if (createBtn && !createBtn.disabled) createBtn.click();
" > /dev/null 2>&1
$AB wait 3000

$AB screenshot "$OUTPUT_DIR/screenshots/rooms_06_room_created_${TIMESTAMP}.png"
echo "✓ Room created: $ROOM_NUMBER"

# ── STEP 4: Verify ────────────────────────────────────────────────────────────
echo ""
echo "[4/4] Verifying..."
$AB wait 2000

# Get page content
PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null | tr -d '"')
CURRENT_URL=$($AB get url 2>/dev/null)

# Check if we're on the rooms page
ON_ROOMS_PAGE=$(echo "$CURRENT_URL" | grep -o "owner/rooms")

# Look for the room number in the page
HAS_ROOM=$(echo "$PAGE_TEXT" | grep -o "$ROOM_NUMBER")

# Look for success indicators
HAS_AVAILABLE=$(echo "$PAGE_TEXT" | grep -i "available")
HAS_ROOMS_LIST=$(echo "$PAGE_TEXT" | grep -E "Room Number|Room Type|Status")

$AB screenshot "$OUTPUT_DIR/screenshots/rooms_07_verification_${TIMESTAMP}.png"
$AB close

echo ""
echo "========================================"
if [ -n "$ON_ROOMS_PAGE" ] && [ -n "$HAS_ROOM" ]; then
  echo " ✅ ADD ROOMS - SUCCESS!"
  echo "========================================"
  echo ""
  echo "Room Type Created:"
  echo "  • Code: $ROOM_TYPE_CODE"
  echo "  • Name: $ROOM_TYPE_NAME"
  echo "  • Category: $ROOM_CATEGORY"
  echo ""
  echo "Room Created:"
  echo "  • Room Number: $ROOM_NUMBER"
  echo "  • Floor: $FLOOR"
  echo "  • Type: $ROOM_TYPE_NAME"
  echo "  • Status: Available"
  echo ""
  echo "Verification:"
  echo "  • Room found on page: ✓"
  echo "  • URL correct: ✓"
  EXIT_CODE=0
else
  echo " ❌ ADD ROOMS - INCOMPLETE"
  echo "========================================"
  echo ""
  echo "Could not verify room creation"
  echo "  • On rooms page: $([ -n "$ON_ROOMS_PAGE" ] && echo "✓" || echo "✗")"
  echo "  • Room $ROOM_NUMBER found: $([ -n "$HAS_ROOM" ] && echo "✓" || echo "✗")"
  EXIT_CODE=1
fi

echo ""
echo "Screenshots saved in: $OUTPUT_DIR/screenshots/"
echo ""

exit $EXIT_CODE
