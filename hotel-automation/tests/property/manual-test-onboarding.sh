#!/bin/bash

###############################################################################
# MANUAL TEST: Property Registration/Onboarding Flow
# This script helps us explore the onboarding flow manually
###############################################################################

AB="./node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
OUTPUT_DIR="./frontend-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$OUTPUT_DIR/screenshots"

echo ""
echo "========================================"
echo " MANUAL TEST: Property Onboarding"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""

# ── STEP 1: Open homepage ─────────────────────────────────────────────────────
echo "[1] Opening homepage..."
$AB --headed open "$FRONTEND_URL"
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_01_homepage_${TIMESTAMP}.png"
echo "✓ Homepage loaded"

# ── STEP 2: Get snapshot and find owner/registration link ─────────────────────
echo "[2] Looking for property registration link..."
$AB snapshot -i > /dev/null

# Try to find "Kaha Owner" or similar link
OWNER_LINK=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "link" or .value.role == "button")
  | select(.value.name | test("Owner|Register|List.*Property|Add.*Property"; "i"))
  | "\(.key): \(.value.name)"
' 2>/dev/null)

echo "Found links:"
echo "$OWNER_LINK"

# Also check the page text for any onboarding-related content
PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null | tr -d '"')
echo ""
echo "Page contains 'onboarding': $(echo "$PAGE_TEXT" | grep -i onboarding | head -3)"
echo "Page contains 'owner': $(echo "$PAGE_TEXT" | grep -i owner | head -3)"
echo "Page contains 'register': $(echo "$PAGE_TEXT" | grep -i register | head -3)"

# ── STEP 3: Try to navigate to /onboarding directly ───────────────────────────
echo ""
echo "[3] Trying to navigate to /onboarding directly..."
$AB open "$FRONTEND_URL/onboarding"
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_02_onboarding_page_${TIMESTAMP}.png"

ONBOARDING_URL=$($AB get url 2>/dev/null)
echo "Current URL: $ONBOARDING_URL"

# Check if we're on the onboarding page
ONBOARDING_CHECK=$($AB eval "document.body.innerText?.includes('onboarding') || document.body.innerText?.includes('property') || document.body.innerText?.includes('registration')" 2>/dev/null | tr -d '"')
echo "Onboarding page loaded: $ONBOARDING_CHECK"

# Get snapshot of onboarding page
echo ""
echo "[4] Getting snapshot of current page..."
$AB snapshot -i > /dev/null

FORM_FIELDS=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "textbox" or .value.role == "button" or .value.role == "combobox")
  | "\(.key): \(.value.role) - \(.value.name)"
' 2>/dev/null)

echo "Form fields found:"
echo "$FORM_FIELDS"

# ── STEP 5: Keep browser open for manual inspection ───────────────────────────
echo ""
echo "========================================"
echo " Browser is open for manual inspection"
echo "========================================"
echo ""
echo "Screenshots saved:"
echo "  📸 $OUTPUT_DIR/screenshots/onboard_01_homepage_${TIMESTAMP}.png"
echo "  📸 $OUTPUT_DIR/screenshots/onboard_02_onboarding_page_${TIMESTAMP}.png"
echo ""
echo "Press Enter to close browser..."
read

$AB close
echo "✓ Browser closed"
