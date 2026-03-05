#!/bin/bash

###############################################################################
# LOGIN DEBUG - Figure out what's on the page after login attempt
###############################################################################

AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Test credentials
PHONE="9800000001"
PASSWORD="password123"

echo ""
echo "========================================"
echo " LOGIN DEBUG TEST"
echo "========================================"
echo ""

# Open login page
echo "[1] Opening login page..."
$AB --headed open "$FRONTEND_URL/login"
$AB wait 3000

# Get snapshot
echo "[2] Getting page snapshot..."
$AB snapshot -i > /dev/null

# Fill form
echo "[3] Filling credentials..."
$AB fill "@e1" "$PHONE"
$AB wait 1000
$AB fill "@e3" "$PASSWORD"
$AB wait 1000

# Take screenshot before submit
$AB screenshot "login-before.png"
echo "✓ Screenshot: login-before.png"

# Click login
echo "[4] Clicking login..."
$AB click "@e5"
$AB wait 5000

# Take screenshot after submit
$AB screenshot "login-after.png"
echo "✓ Screenshot: login-after.png"

# Get current URL
CURRENT_URL=$($AB get url 2>/dev/null)
echo ""
echo "Current URL: $CURRENT_URL"

# Get page title
TITLE=$($AB get title 2>/dev/null)
echo "Page title: $TITLE"

# Check for any visible text that might be an error
echo ""
echo "Checking for errors or messages..."
MESSAGES=$($AB eval "
  // Look for error messages
  const errors = Array.from(document.querySelectorAll('[class*=\"error\"],[role=\"alert\"],[class*=\"alert\"]'))
    .map(el => ({type: 'error', text: el.innerText?.trim()}))
    .filter(item => item.text && item.text.length > 0);
  
  // Look for any toast/notification messages
  const toasts = Array.from(document.querySelectorAll('[class*=\"toast\"],[class*=\"notification\"],[class*=\"message\"]'))
    .map(el => ({type: 'toast', text: el.innerText?.trim()}))
    .filter(item => item.text && item.text.length > 0);
  
  // Look for validation messages near inputs
  const validations = Array.from(document.querySelectorAll('input + *'))
    .map(el => ({type: 'validation', text: el.innerText?.trim()}))
    .filter(item => item.text && item.text.length > 5);
  
  // Get all visible text on page (first 500 chars)
  const bodyText = document.body.innerText?.substring(0, 500);
  
  JSON.stringify({
    errors: errors,
    toasts: toasts,
    validations: validations,
    bodyPreview: bodyText
  }, null, 2);
" 2>/dev/null)

echo "$MESSAGES" | jq '.' 2>/dev/null || echo "$MESSAGES"

# Check if still on login page or redirected
if [[ "$CURRENT_URL" == *"/login"* ]]; then
  echo ""
  echo "❌ Still on login page - login failed"
  
  # Get form values to see if they were filled
  echo ""
  echo "Checking form state..."
  FORM_STATE=$($AB eval "
    const phoneInput = document.querySelector('input[type=\"tel\"],input[name*=\"phone\"]');
    const passwordInput = document.querySelector('input[type=\"password\"]');
    JSON.stringify({
      phoneValue: phoneInput?.value || 'not found',
      passwordValue: passwordInput?.value ? '***filled***' : 'empty',
      phoneInputExists: !!phoneInput,
      passwordInputExists: !!passwordInput
    }, null, 2);
  " 2>/dev/null)
  echo "$FORM_STATE" | jq '.' 2>/dev/null || echo "$FORM_STATE"
  
else
  echo ""
  echo "✅ Redirected away from login page"
  echo "New location: $CURRENT_URL"
fi

# Get final snapshot
echo ""
echo "Getting final page snapshot..."
$AB snapshot -i --json > "login-final-snapshot.json"
echo "✓ Saved to: login-final-snapshot.json"

# Close
$AB close
echo ""
echo "✓ Browser closed"
echo ""
