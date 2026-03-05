#!/bin/bash

###############################################################################
# LOGIN TEST - Working version with proper waits and verification
###############################################################################

AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Test credentials from seed.ts
PHONE="9800000001"
PASSWORD="password123"

echo ""
echo "========================================"
echo " LOGIN TEST (Working Version)"
echo "========================================"
echo ""

# Open login page
echo "[1/7] Opening login page..."
$AB --headed open "$FRONTEND_URL/login"
$AB wait 4000
echo "✓ Page loaded"

# Get snapshot
echo "[2/7] Getting form elements..."
$AB snapshot -i > /dev/null
$AB wait 1000

# Click phone input to focus it
echo "[3/7] Filling phone number..."
$AB click "@e1"
$AB wait 500

# Use fill command instead of type
$AB fill "@e1" "$PHONE"
$AB wait 1000

# Verify phone was filled
PHONE_CHECK=$($AB eval "document.querySelector('input[type=\"tel\"]')?.value" 2>/dev/null)
echo "  Phone value: $PHONE_CHECK"

# Click password input to focus it
echo "[4/7] Filling password..."
$AB click "@e3"
$AB wait 500

# Use fill command for password
$AB fill "@e3" "$PASSWORD"
$AB wait 1000

# Verify password was filled
PWD_CHECK=$($AB eval "document.querySelector('input[type=\"password\"]')?.value ? '***filled***' : 'empty'" 2>/dev/null)
echo "  Password value: $PWD_CHECK"

# Take screenshot before submit
echo "[5/7] Taking screenshot before submit..."
$AB screenshot "login-before-submit.png"
$AB wait 500

# Click login button
echo "[6/7] Clicking login button..."
$AB click "@e5"
echo "  Waiting for response..."
$AB wait 8000  # Wait longer for API call and redirect

# Check result
echo "[7/7] Checking result..."
CURRENT_URL=$($AB get url 2>/dev/null)
echo "  Current URL: $CURRENT_URL"

# Take screenshot after
$AB screenshot "login-after-submit.png"

# Check if redirected
if [[ "$CURRENT_URL" == *"/owner/dashboard"* ]] || [[ "$CURRENT_URL" == *"/dashboard"* ]] || [[ "$CURRENT_URL" == *"/owner"* ]]; then
  echo ""
  echo "========================================"
  echo " ✅ LOGIN SUCCESS!"
  echo "========================================"
  echo ""
  echo "Redirected to: $CURRENT_URL"
  
  # Get page title
  TITLE=$($AB get title 2>/dev/null)
  echo "Page title: $TITLE"
  
  # Try to extract dashboard data
  echo ""
  echo "Dashboard content:"
  DASHBOARD_DATA=$($AB eval "
    const headings = Array.from(document.querySelectorAll('h1,h2,h3'))
      .map(el => el.innerText?.trim())
      .filter(text => text && text.length > 0)
      .slice(0, 5);
    JSON.stringify(headings, null, 2);
  " 2>/dev/null)
  echo "$DASHBOARD_DATA" | jq -r '.[]' 2>/dev/null || echo "$DASHBOARD_DATA"
  
  EXIT_CODE=0
else
  echo ""
  echo "========================================"
  echo " ❌ LOGIN FAILED"
  echo "========================================"
  echo ""
  echo "Still on: $CURRENT_URL"
  
  # Check for error messages
  ERROR=$($AB eval "
    const errors = Array.from(document.querySelectorAll('[class*=\"error\"],[role=\"alert\"]'))
      .map(el => el.innerText?.trim())
      .filter(text => text && text.length > 0);
    errors.join(' | ');
  " 2>/dev/null)
  
  if [ -n "$ERROR" ]; then
    echo ""
    echo "Error message: $ERROR"
  fi
  
  # Check form state
  echo ""
  echo "Form state after submit:"
  FORM_STATE=$($AB eval "
    JSON.stringify({
      phone: document.querySelector('input[type=\"tel\"]')?.value || 'empty',
      password: document.querySelector('input[type=\"password\"]')?.value ? '***filled***' : 'empty'
    });
  " 2>/dev/null)
  echo "$FORM_STATE" | jq '.' 2>/dev/null || echo "$FORM_STATE"
  
  EXIT_CODE=1
fi

# Close
$AB close
echo ""
echo "✓ Browser closed"
echo ""
echo "Screenshots saved:"
echo "  📸 login-before-submit.png"
echo "  📸 login-after-submit.png"
echo ""

exit $EXIT_CODE
