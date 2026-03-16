#!/bin/bash

###############################################################################
# EXPLORE: Property Registration/Onboarding Flow
# Non-interactive exploration of the onboarding flow
###############################################################################

AB="./node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
OUTPUT_DIR="./frontend-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$OUTPUT_DIR/screenshots"

echo ""
echo "========================================"
echo " EXPLORING: Property Onboarding"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""

# ── STEP 1: Open homepage ─────────────────────────────────────────────────────
echo "[1] Opening homepage..."
$AB --headed open "$FRONTEND_URL"
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_01_homepage_${TIMESTAMP}.png"
echo "✓ Homepage loaded"

# ── STEP 2: Get all links on homepage ─────────────────────────────────────────
echo ""
echo "[2] Getting all links on homepage..."
$AB snapshot -i > /dev/null

ALL_LINKS=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "link" or .value.role == "button")
  | "\(.key): \(.value.name)"
' 2>/dev/null)

echo "All links/buttons found:"
echo "$ALL_LINKS"

# ── STEP 3: Try /onboarding URL ───────────────────────────────────────────────
echo ""
echo "[3] Trying /onboarding URL..."
$AB open "$FRONTEND_URL/onboarding"
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_02_onboarding_${TIMESTAMP}.png"

CURRENT_URL=$($AB get url 2>/dev/null)
echo "Current URL: $CURRENT_URL"

PAGE_TITLE=$($AB eval "document.title" 2>/dev/null | tr -d '"')
echo "Page title: $PAGE_TITLE"

# ── STEP 4: Try /owner/onboarding URL ─────────────────────────────────────────
echo ""
echo "[4] Trying /owner/onboarding URL..."
$AB open "$FRONTEND_URL/owner/onboarding"
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_03_owner_onboarding_${TIMESTAMP}.png"

CURRENT_URL=$($AB get url 2>/dev/null)
echo "Current URL: $CURRENT_URL"

PAGE_TITLE=$($AB eval "document.title" 2>/dev/null | tr -d '"')
echo "Page title: $PAGE_TITLE"

# Get form fields if any
$AB snapshot -i > /dev/null
FORM_FIELDS=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "textbox" or .value.role == "button" or .value.role == "combobox" or .value.role == "checkbox")
  | "\(.key): \(.value.role) - \(.value.name)"
' 2>/dev/null | head -20)

echo ""
echo "Form fields found:"
echo "$FORM_FIELDS"

# ── STEP 5: Try /property/register URL ────────────────────────────────────────
echo ""
echo "[5] Trying /property/register URL..."
$AB open "$FRONTEND_URL/property/register"
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_04_property_register_${TIMESTAMP}.png"

CURRENT_URL=$($AB get url 2>/dev/null)
echo "Current URL: $CURRENT_URL"

PAGE_TITLE=$($AB eval "document.title" 2>/dev/null | tr -d '"')
echo "Page title: $PAGE_TITLE"

# ── STEP 6: Check the frontend codebase for onboarding routes ────────────────
echo ""
echo "[6] Checking frontend for onboarding routes..."
echo ""

$AB close
echo "✓ Browser closed"

echo ""
echo "========================================"
echo " EXPLORATION COMPLETE"
echo "========================================"
echo ""
echo "Screenshots saved in: $OUTPUT_DIR/screenshots/"
echo ""
