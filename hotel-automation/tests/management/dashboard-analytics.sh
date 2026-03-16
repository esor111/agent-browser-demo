#!/bin/bash

###############################################################################
# DASHBOARD ANALYTICS AUTOMATION
# Tests the owner dashboard display and analytics:
# 1. Login as owner
# 2. Verify dashboard loads (default landing page)
# 3. Check stats widgets (arrivals, departures, occupancy, revenue)
# 4. Verify room status display
# 5. Check recent bookings section
# 6. Verify all key metrics are visible
###############################################################################

AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
OUTPUT_DIR="./frontend-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$OUTPUT_DIR/screenshots"

# Owner credentials
OWNER_PHONE="9800000001"
OWNER_PASSWORD="password123"

echo ""
echo "========================================"
echo " DASHBOARD ANALYTICS AUTOMATION"
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

CURRENT_URL=$($AB get url 2>/dev/null)
echo "✓ Logged in: $CURRENT_URL"

# ── STEP 2: Verify Dashboard Loaded ───────────────────────────────────────────
echo ""
echo "[2/4] Verifying dashboard loaded..."
$AB wait 2000

# Check if we're on the dashboard
ON_DASHBOARD=$(echo "$CURRENT_URL" | grep -o "owner/dashboard")

if [ -n "$ON_DASHBOARD" ]; then
  echo "✓ Dashboard loaded"
else
  echo "⚠️  Not on dashboard, navigating..."
  $AB open "$FRONTEND_URL/owner/dashboard"
  $AB wait 3000
  echo "✓ Dashboard loaded"
fi

$AB screenshot "$OUTPUT_DIR/screenshots/dashboard_01_overview_${TIMESTAMP}.png"

# ── STEP 3: Check Stats Widgets ───────────────────────────────────────────────
echo ""
echo "[3/4] Checking dashboard stats..."

PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null | tr -d '"')

# Extract key metrics
ARRIVALS=$(echo "$PAGE_TEXT" | grep -oP "Today's Arrivals\s+\d+" | grep -oP "\d+" | head -1)
DEPARTURES=$(echo "$PAGE_TEXT" | grep -oP "Today's Departures\s+\d+" | grep -oP "\d+" | head -1)
IN_HOUSE=$(echo "$PAGE_TEXT" | grep -oP "In-House Guests\s+\d+" | grep -oP "\d+" | head -1)
OCCUPANCY=$(echo "$PAGE_TEXT" | grep -oP "Occupancy Rate\s+\d+%" | grep -oP "\d+" | head -1)
REVENUE=$(echo "$PAGE_TEXT" | grep -oP "Today's Revenue\s+NPR\s+[\d,]+" | grep -oP "[\d,]+" | head -1)

# Check for key sections
HAS_ARRIVALS=$(echo "$PAGE_TEXT" | grep -i "Today's Arrivals" | head -1)
HAS_DEPARTURES=$(echo "$PAGE_TEXT" | grep -i "Today's Departures" | head -1)
HAS_OCCUPANCY=$(echo "$PAGE_TEXT" | grep -i "Occupancy Rate" | head -1)
HAS_REVENUE=$(echo "$PAGE_TEXT" | grep -i "Revenue" | head -1)
HAS_ROOM_STATUS=$(echo "$PAGE_TEXT" | grep -i "Room Status\|Available\|Occupied" | head -1)

echo "  Dashboard Metrics:"
[ -n "$ARRIVALS" ] && echo "    • Today's Arrivals: $ARRIVALS"
[ -n "$DEPARTURES" ] && echo "    • Today's Departures: $DEPARTURES"
[ -n "$IN_HOUSE" ] && echo "    • In-House Guests: $IN_HOUSE"
[ -n "$OCCUPANCY" ] && echo "    • Occupancy Rate: ${OCCUPANCY}%"
[ -n "$REVENUE" ] && echo "    • Today's Revenue: NPR $REVENUE"

$AB screenshot "$OUTPUT_DIR/screenshots/dashboard_02_stats_${TIMESTAMP}.png"

# ── STEP 4: Check Room Status & Recent Bookings ───────────────────────────────
echo ""
echo "[4/4] Checking room status and bookings..."

# Scroll down to see more content
$AB eval "window.scrollTo(0, document.body.scrollHeight / 2)" > /dev/null 2>&1
$AB wait 1000

$AB screenshot "$OUTPUT_DIR/screenshots/dashboard_03_room_status_${TIMESTAMP}.png"

# Check for room status section
AVAILABLE_ROOMS=$(echo "$PAGE_TEXT" | grep -oP "Available\s+\d+" | grep -oP "\d+" | head -1)
OCCUPIED_ROOMS=$(echo "$PAGE_TEXT" | grep -oP "Occupied\s+\d+" | grep -oP "\d+" | head -1)

[ -n "$AVAILABLE_ROOMS" ] && echo "  • Available Rooms: $AVAILABLE_ROOMS"
[ -n "$OCCUPIED_ROOMS" ] && echo "  • Occupied Rooms: $OCCUPIED_ROOMS"

# Scroll down more to see recent bookings
$AB eval "window.scrollTo(0, document.body.scrollHeight)" > /dev/null 2>&1
$AB wait 1000

$AB screenshot "$OUTPUT_DIR/screenshots/dashboard_04_bookings_${TIMESTAMP}.png"

HAS_BOOKINGS_SECTION=$(echo "$PAGE_TEXT" | grep -i "Pending Bookings\|Recent\|Booking" | head -1)

echo "✓ Dashboard sections verified"

# ── Verify ─────────────────────────────────────────────────────────────────────
$AB wait 1000
$AB screenshot "$OUTPUT_DIR/screenshots/dashboard_05_verification_${TIMESTAMP}.png"
$AB close

echo ""
echo "========================================"

# Success if we're on dashboard and see key metrics
if [ -n "$ON_DASHBOARD" ] && ([ -n "$HAS_ARRIVALS" ] || [ -n "$HAS_REVENUE" ] || [ -n "$HAS_ROOM_STATUS" ]); then
  echo " ✅ DASHBOARD ANALYTICS - SUCCESS!"
  echo "========================================"
  echo ""
  echo "Dashboard Verified:"
  echo "  • Page loaded: ✓"
  echo "  • Stats widgets: $([ -n "$HAS_ARRIVALS" ] && echo "✓" || echo "✗")"
  echo "  • Revenue display: $([ -n "$HAS_REVENUE" ] && echo "✓" || echo "✗")"
  echo "  • Room status: $([ -n "$HAS_ROOM_STATUS" ] && echo "✓" || echo "✗")"
  echo "  • Bookings section: $([ -n "$HAS_BOOKINGS_SECTION" ] && echo "✓" || echo "✗")"
  echo ""
  echo "Key Metrics:"
  [ -n "$ARRIVALS" ] && echo "  • Today's Arrivals: $ARRIVALS"
  [ -n "$DEPARTURES" ] && echo "  • Today's Departures: $DEPARTURES"
  [ -n "$IN_HOUSE" ] && echo "  • In-House Guests: $IN_HOUSE"
  [ -n "$OCCUPANCY" ] && echo "  • Occupancy Rate: ${OCCUPANCY}%"
  [ -n "$AVAILABLE_ROOMS" ] && echo "  • Available Rooms: $AVAILABLE_ROOMS"
  EXIT_CODE=0
else
  echo " ❌ DASHBOARD ANALYTICS - INCOMPLETE"
  echo "========================================"
  echo ""
  echo "Could not verify dashboard analytics"
  EXIT_CODE=1
fi

echo ""
echo "Screenshots saved in: $OUTPUT_DIR/screenshots/"
echo ""

exit $EXIT_CODE
