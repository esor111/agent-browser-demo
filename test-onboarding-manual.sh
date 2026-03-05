#!/bin/bash

###############################################################################
# MANUAL TEST: Property Onboarding Flow - Step by Step
# 8 Steps: Account → Property Type → Name → Location → Contact → Operations → Plan → Review
###############################################################################

AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
OUTPUT_DIR="./frontend-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$OUTPUT_DIR/screenshots"

echo ""
echo "========================================"
echo " PROPERTY ONBOARDING - MANUAL TEST"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""

# ── STEP 1: Open onboarding page ──────────────────────────────────────────────
echo "[1] Opening onboarding page..."
$AB --headed open "$FRONTEND_URL/onboarding"
$AB wait 4000
$AB screenshot "$OUTPUT_DIR/screenshots/onboard_step1_account_${TIMESTAMP}.png"
echo "✓ Onboarding page loaded"

# Get snapshot to see what's on the page
echo ""
echo "[2] Getting page snapshot..."
$AB snapshot -i > /dev/null

# Check if we're on Step 1 (Account) or Step 2 (Property Type)
PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null | tr -d '"')
echo "Page contains 'Account': $(echo "$PAGE_TEXT" | grep -i 'account' | head -1)"
echo "Page contains 'Property Type': $(echo "$PAGE_TEXT" | grep -i 'property type' | head -1)"
echo "Page contains 'Login': $(echo "$PAGE_TEXT" | grep -i 'login' | head -1)"
echo "Page contains 'Register': $(echo "$PAGE_TEXT" | grep -i 'register' | head -1)"

# Get all buttons and inputs
echo ""
echo "Form elements found:"
$AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "textbox" or .value.role == "button" or .value.role == "radio")
  | "\(.key): \(.value.role) - \(.value.name)"
' 2>/dev/null | head -20

echo ""
echo "========================================"
echo " Browser is open for inspection"
echo "========================================"
echo ""
echo "Next steps to test manually:"
echo "  1. If on Account step: Login with 9800000001 / password123"
echo "  2. If on Property Type: Select a property type"
echo "  3. Continue through all 8 steps"
echo ""
echo "Press Enter to close browser..."
read

$AB close
echo "✓ Browser closed"
