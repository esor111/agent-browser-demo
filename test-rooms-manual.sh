#!/bin/bash

AB="./node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"

echo "Testing room creation manually..."
echo ""

# Login
echo "Step 1: Login"
$AB --headed open "$FRONTEND_URL/login"
$AB wait 3000

$AB snapshot -i > /dev/null
PHONE_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null | head -1)
PASSWORD_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null | tail -1)

echo "Phone ref: $PHONE_REF"
echo "Password ref: $PASSWORD_REF"

[ -n "$PHONE_REF" ] && $AB fill "@$PHONE_REF" "9800000001" && $AB wait 500
[ -n "$PASSWORD_REF" ] && $AB fill "@$PASSWORD_REF" "password123" && $AB wait 1000

$AB eval "
  const buttons = Array.from(document.querySelectorAll('button'));
  const signInBtn = buttons.find(b => b.textContent.includes('Sign In'));
  if (signInBtn) signInBtn.click();
" > /dev/null 2>&1
$AB wait 5000

echo "✓ Logged in"
echo ""

# Go to rooms page
echo "Step 2: Navigate to rooms"
$AB open "$FRONTEND_URL/owner/rooms"
$AB wait 4000

CURRENT_URL=$($AB get url)
echo "Current URL: $CURRENT_URL"

PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null | tr -d '"')
echo ""
echo "Page content (first 500 chars):"
echo "$PAGE_TEXT" | head -c 500
echo ""
echo ""

# Check for Room Types tab
echo "Step 3: Looking for Room Types tab..."
$AB snapshot -i

echo ""
echo "Press Ctrl+C to exit"
read -p "Continue? "

$AB close
