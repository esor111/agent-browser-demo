#!/bin/bash

###############################################################################
# MANUAL STEP-BY-STEP: Property Onboarding
# Interactive script to test each step manually and document what works
###############################################################################

AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
OUTPUT_DIR="./frontend-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
mkdir -p "$OUTPUT_DIR/screenshots"

# Test credentials
PHONE="9800000001"
PASSWORD="password123"

echo ""
echo "========================================"
echo " MANUAL ONBOARDING TEST"
echo " Step-by-Step Interactive Testing"
echo "========================================"
echo ""

# ── STEP 1: Open and Login ────────────────────────────────────────────────────
echo "STEP 1: Opening onboarding page and logging in..."
echo ""
$AB --headed open "$FRONTEND_URL/onboarding"
$AB wait 4000
$AB screenshot "$OUTPUT_DIR/screenshots/manual_01_initial_${TIMESTAMP}.png"

echo "Press Enter to click 'Sign in' tab..."
read

$AB snapshot -i > /dev/null
SIGNIN_TAB=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button" and .value.name == "Sign in")
  | .key
' 2>/dev/null | head -1)

echo "Sign in tab ref: $SIGNIN_TAB"
$AB click "@$SIGNIN_TAB"
$AB wait 1000

echo "Press Enter to fill phone and password..."
read

$AB snapshot -i > /dev/null
PHONE_INPUT=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null | head -1)
PASSWORD_INPUT=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox") | .key' 2>/dev/null | tail -1)

echo "Phone ref: $PHONE_INPUT"
echo "Password ref: $PASSWORD_INPUT"

$AB fill "@$PHONE_INPUT" "$PHONE"
$AB wait 500
$AB fill "@$PASSWORD_INPUT" "$PASSWORD"
$AB wait 1000
$AB screenshot "$OUTPUT_DIR/screenshots/manual_02_login_filled_${TIMESTAMP}.png"

echo "Press Enter to click login button..."
read

$AB snapshot -i > /dev/null
LOGIN_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Sign in.*continue"; "i"))
  | .key
' 2>/dev/null | head -1)

echo "Login button ref: $LOGIN_BTN"
$AB click "@$LOGIN_BTN"
$AB wait 5000
$AB screenshot "$OUTPUT_DIR/screenshots/manual_03_after_login_${TIMESTAMP}.png"

echo ""
echo "✓ Login complete!"
echo ""

# ── STEP 2: Property Type ─────────────────────────────────────────────────────
echo "STEP 2: Property Type"
echo ""
echo "Current page should show property types (Hotel, Resort, Hostel, etc.)"
echo ""

$AB snapshot -i > /dev/null
echo "Available property types:"
$AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Hotel|Resort|Hostel|Guest House|Apartment|Villa"; "i"))
  | "\(.key): \(.value.name)"
' 2>/dev/null

echo ""
echo "Press Enter to select 'Hotel'..."
read

HOTEL_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name == "Hotel")
  | .key
' 2>/dev/null | head -1)

echo "Hotel button ref: $HOTEL_BTN"
$AB click "@$HOTEL_BTN"
$AB wait 1000
$AB screenshot "$OUTPUT_DIR/screenshots/manual_04_hotel_selected_${TIMESTAMP}.png"

echo ""
echo "Press Enter to click 'Continue'..."
read

$AB snapshot -i > /dev/null
CONTINUE_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Continue|Next"; "i"))
  | .key
' 2>/dev/null | head -1)

echo "Continue button ref: $CONTINUE_BTN"
$AB click "@$CONTINUE_BTN"
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/manual_05_property_name_${TIMESTAMP}.png"

echo ""
echo "✓ Property type selected!"
echo ""

# ── STEP 3: Property Name ─────────────────────────────────────────────────────
echo "STEP 3: Property Name"
echo ""
echo "Current page should have a text input for property name"
echo ""

$AB snapshot -i > /dev/null
echo "Text inputs found:"
$AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "textbox")
  | "\(.key): \(.value.name)"
' 2>/dev/null

echo ""
echo "Press Enter to fill property name 'Test Automation Hotel'..."
read

NAME_INPUT=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "textbox")
  | .key
' 2>/dev/null | head -1)

echo "Name input ref: $NAME_INPUT"
$AB fill "@$NAME_INPUT" "Test Automation Hotel"
$AB wait 1000
$AB screenshot "$OUTPUT_DIR/screenshots/manual_06_name_filled_${TIMESTAMP}.png"

echo ""
echo "Press Enter to click 'Continue'..."
read

$AB snapshot -i > /dev/null
CONTINUE_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Continue|Next"; "i"))
  | .key
' 2>/dev/null | head -1)

echo "Continue button ref: $CONTINUE_BTN"
$AB click "@$CONTINUE_BTN"
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/manual_07_location_${TIMESTAMP}.png"

echo ""
echo "✓ Property name entered!"
echo ""

# ── STEP 4: Location ──────────────────────────────────────────────────────────
echo "STEP 4: Location"
echo ""
echo "Current page should have location/address fields"
echo ""

$AB snapshot -i > /dev/null
echo "All form fields found:"
$AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "textbox" or .value.role == "combobox")
  | "\(.key): \(.value.name)"
' 2>/dev/null

echo ""
echo "I'll now show you the page. Please manually fill in the location fields."
echo "Then press Enter when done..."
read

$AB screenshot "$OUTPUT_DIR/screenshots/manual_08_location_filled_${TIMESTAMP}.png"

echo ""
echo "Press Enter to click 'Continue'..."
read

$AB snapshot -i > /dev/null
CONTINUE_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Continue|Next"; "i"))
  | .key
' 2>/dev/null | head -1)

echo "Continue button ref: $CONTINUE_BTN"
$AB click "@$CONTINUE_BTN"
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/manual_09_contact_${TIMESTAMP}.png"

echo ""
echo "✓ Location step complete!"
echo ""

# ── STEP 5: Contact ───────────────────────────────────────────────────────────
echo "STEP 5: Contact"
echo ""
echo "Current page should have contact fields (phone, email, website)"
echo ""

$AB snapshot -i > /dev/null
echo "Contact fields found:"
$AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "textbox")
  | "\(.key): \(.value.name)"
' 2>/dev/null

echo ""
echo "Please manually fill in the contact fields."
echo "Then press Enter when done..."
read

$AB screenshot "$OUTPUT_DIR/screenshots/manual_10_contact_filled_${TIMESTAMP}.png"

echo ""
echo "Press Enter to click 'Continue'..."
read

$AB snapshot -i > /dev/null
CONTINUE_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Continue|Next"; "i"))
  | .key
' 2>/dev/null | head -1)

echo "Continue button ref: $CONTINUE_BTN"
$AB click "@$CONTINUE_BTN"
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/manual_11_operations_${TIMESTAMP}.png"

echo ""
echo "✓ Contact step complete!"
echo ""

# ── STEP 6: Operations ────────────────────────────────────────────────────────
echo "STEP 6: Operations"
echo ""
echo "Current page should have operational details (check-in/out times, description, etc.)"
echo ""

$AB snapshot -i > /dev/null
echo "Operations fields found:"
$AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "textbox")
  | "\(.key): \(.value.name)"
' 2>/dev/null | head -10

echo ""
echo "Please manually fill in the operations fields."
echo "Then press Enter when done..."
read

$AB screenshot "$OUTPUT_DIR/screenshots/manual_12_operations_filled_${TIMESTAMP}.png"

echo ""
echo "Press Enter to click 'Continue'..."
read

$AB snapshot -i > /dev/null
CONTINUE_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Continue|Next"; "i"))
  | .key
' 2>/dev/null | head -1)

echo "Continue button ref: $CONTINUE_BTN"
$AB click "@$CONTINUE_BTN"
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/manual_13_plan_${TIMESTAMP}.png"

echo ""
echo "✓ Operations step complete!"
echo ""

# ── STEP 7: Plan Selector ─────────────────────────────────────────────────────
echo "STEP 7: Plan Selector"
echo ""
echo "Current page should show subscription plans"
echo ""

$AB snapshot -i > /dev/null
echo "Plan buttons found:"
$AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | "\(.key): \(.value.name)"
' 2>/dev/null | head -10

echo ""
echo "Please select a plan."
echo "Then press Enter when done..."
read

$AB screenshot "$OUTPUT_DIR/screenshots/manual_14_plan_selected_${TIMESTAMP}.png"

echo ""
echo "Press Enter to click 'Continue'..."
read

$AB snapshot -i > /dev/null
CONTINUE_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Continue|Next"; "i"))
  | .key
' 2>/dev/null | head -1)

echo "Continue button ref: $CONTINUE_BTN"
$AB click "@$CONTINUE_BTN"
$AB wait 3000
$AB screenshot "$OUTPUT_DIR/screenshots/manual_15_review_${TIMESTAMP}.png"

echo ""
echo "✓ Plan selected!"
echo ""

# ── STEP 8: Review ────────────────────────────────────────────────────────────
echo "STEP 8: Review & Submit"
echo ""
echo "Current page should show a review of all entered data"
echo ""

$AB snapshot -i > /dev/null
echo "Buttons found:"
$AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | "\(.key): \(.value.name)"
' 2>/dev/null

echo ""
echo "Review the data. If everything looks good, press Enter to submit..."
read

SUBMIT_BTN=$($AB snapshot -i --json 2>/dev/null | jq -r '
  .data.refs | to_entries[]
  | select(.value.role == "button")
  | select(.value.name | test("Submit|Create|Finish|Complete"; "i"))
  | .key
' 2>/dev/null | head -1)

echo "Submit button ref: $SUBMIT_BTN"

if [ -n "$SUBMIT_BTN" ]; then
  $AB click "@$SUBMIT_BTN"
  echo "Waiting for submission..."
  $AB wait 8000
  $AB screenshot "$OUTPUT_DIR/screenshots/manual_16_success_${TIMESTAMP}.png"
else
  echo "⚠️  No submit button found!"
fi

echo ""
echo "✓ Submitted!"
echo ""

# ── Check Result ──────────────────────────────────────────────────────────────
echo "Checking result..."
CURRENT_URL=$($AB get url 2>/dev/null)
echo "Current URL: $CURRENT_URL"

PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null | tr -d '"')
echo ""
echo "Page text preview:"
echo "$PAGE_TEXT" | head -20

echo ""
echo "========================================"
echo " MANUAL TEST COMPLETE"
echo "========================================"
echo ""
echo "Screenshots saved in: $OUTPUT_DIR/screenshots/"
echo ""
echo "Press Enter to close browser..."
read

$AB close
echo "✓ Browser closed"
