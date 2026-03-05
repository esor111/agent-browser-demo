#!/bin/bash

###############################################################################
# MANUAL PAYMENT RECORDING TEST
# Testing the payment recording flow manually before automation
###############################################################################

AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"

# Owner credentials
OWNER_PHONE="9800000001"
OWNER_PASSWORD="password123"

echo "========================================="
echo " MANUAL PAYMENT RECORDING TEST"
echo "========================================="
echo ""

# Step 1: Login
echo "[1] Opening login page..."
$AB --headed open "$FRONTEND_URL/login"
$AB wait 3000

echo "[2] Logging in..."
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

# Step 2: Navigate to bookings
echo ""
echo "[3] Opening bookings page..."
$AB open "$FRONTEND_URL/owner/bookings"
$AB wait 4000

echo ""
echo "========================================="
echo " EXPLORE THE PAGE"
echo "========================================="
echo ""
echo "Now explore the bookings page to find:"
echo "  1. A checked-out booking"
echo "  2. The 'Record Payment' or 'Add Payment' button"
echo "  3. The payment form fields"
echo ""
echo "Commands to use:"
echo "  \$AB snapshot -i              # See all interactive elements"
echo "  \$AB screenshot test.png      # Take a screenshot"
echo "  \$AB eval 'document.body.innerText'  # See page text"
echo ""
echo "Browser is open and waiting..."
echo "Press Ctrl+C when done exploring"
echo ""

# Keep browser open for manual exploration
while true; do
  sleep 1
done
