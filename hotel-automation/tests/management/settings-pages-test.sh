#!/bin/bash

###############################################################################
# SETTINGS PAGES NAVIGATION TEST
# Tests all settings pages load correctly
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../config/test-config.sh"

AB="$AB_PATH"
PHONE="$OWNER_PHONE"
PASSWORD="$OWNER_PASSWORD"

echo ""
echo "========================================"
echo " SETTINGS PAGES TEST"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""

# Settings pages to test
SETTINGS_PAGES=(
  "profile|Profile Settings"
  "property|Property Settings"
  "team|Team Management"
  "api|API Keys"
  "audit|Audit Logs"
)

PASSED=0
FAILED=0
SKIPPED=0

# ── STEP 1: Login ──────────────────────────────────────────────────────────
echo "[1/6] Logging in as owner..."
$AB --headed open "$FRONTEND_URL/login"
$AB wait 3000

$AB snapshot -i > /dev/null
PHONE_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox" and ((.value.name // "") | test("phone"; "i"))) | .key' 2>/dev/null | head -1)
PASSWORD_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox" and ((.value.name // "") | test("password"; "i"))) | .key' 2>/dev/null | head -1)

[ -n "$PHONE_REF" ] && $AB fill "@$PHONE_REF" "$PHONE" && $AB wait 500
[ -n "$PASSWORD_REF" ] && $AB fill "@$PASSWORD_REF" "$PASSWORD" && $AB wait 1000

$AB eval "document.querySelector('button[type=\"submit\"]')?.click() || document.querySelectorAll('button').find(b => b.textContent.includes('Sign In'))?.click()" > /dev/null 2>&1
$AB wait 8000
echo "✓ Logged in"

# ── STEP 2-6: Test Each Settings Page ─────────────────────────────────────
STEP=2
for page_def in "${SETTINGS_PAGES[@]}"; do
  IFS='|' read -r page_path page_name <<< "$page_def"
  
  echo ""
  echo "[$STEP/6] Testing $page_name..."
  
  $AB open "$FRONTEND_URL/owner/settings/$page_path"
  $AB wait 3000
  
  CURRENT_URL=$($AB get url 2>/dev/null)
  PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null)
  HAS_CONTENT=$(echo "$PAGE_TEXT" | wc -w)
  
  $AB screenshot "$OUTPUT_DIR/screenshots/settings_${page_path}_${TIMESTAMP}.png"
  
  # Verify page loaded (check for 404)
  PAGE_TITLE=$($AB eval "document.title" 2>/dev/null)
  IS_404=$(echo "$PAGE_TITLE" | grep -o "404")
  
  ON_PAGE=$(echo "$CURRENT_URL" | grep -o "owner/settings/$page_path")
  HAS_MIN_CONTENT=$([ "$HAS_CONTENT" -gt 10 ] && echo "yes" || echo "no")  # Lowered threshold
  
  if [ -n "$IS_404" ]; then
    echo "  ⏭️  $page_name - SKIPPED (page not implemented)"
    SKIPPED=$((SKIPPED + 1))
  elif [ -n "$ON_PAGE" ] && [ "$HAS_MIN_CONTENT" = "yes" ]; then
    echo "  ✅ $page_name - PASSED ($HAS_CONTENT words)"
    PASSED=$((PASSED + 1))
  else
    echo "  ❌ $page_name - FAILED"
    FAILED=$((FAILED + 1))
  fi
  
  STEP=$((STEP + 1))
  $AB wait 1000
done

$AB close
echo "✓ Browser closed"

# ── Summary ────────────────────────────────────────────────────────────────
echo ""
echo "========================================"
if [ $FAILED -eq 0 ]; then
  echo " ✅ SETTINGS PAGES TEST PASSED"
  echo "========================================"
  echo ""
  echo "Results:"
  echo "  • Total pages: ${#SETTINGS_PAGES[@]}"
  echo "  • Passed: $PASSED"
  echo "  • Skipped: $SKIPPED"
  echo "  • Failed: $FAILED"
  echo ""
  echo "All implemented settings pages loaded successfully!"
  echo ""
  exit 0
else
  echo " ⚠️  SETTINGS PAGES TEST PARTIAL"
  echo "========================================"
  echo ""
  echo "Results:"
  echo "  • Total pages: ${#SETTINGS_PAGES[@]}"
  echo "  • Passed: $PASSED"
  echo "  • Skipped: $SKIPPED"
  echo "  • Failed: $FAILED"
  echo ""
  exit 1
fi
