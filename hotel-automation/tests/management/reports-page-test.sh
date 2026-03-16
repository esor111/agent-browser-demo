#!/bin/bash

###############################################################################
# REPORTS PAGE NAVIGATION TEST
# Simple test to verify reports page loads and displays correctly
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../config/test-config.sh"

AB="$AB_PATH"
PHONE="$OWNER_PHONE"
PASSWORD="$OWNER_PASSWORD"

echo ""
echo "========================================"
echo " REPORTS PAGE TEST"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""

# ── STEP 1: Login ──────────────────────────────────────────────────────────
echo "[1/4] Logging in as owner..."
$AB --headed open "$FRONTEND_URL/login"
$AB wait 3000

# Quick login
$AB snapshot -i > /dev/null
PHONE_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox" and ((.value.name // "") | test("phone"; "i"))) | .key' 2>/dev/null | head -1)
PASSWORD_REF=$($AB snapshot -i --json 2>/dev/null | jq -r '.data.refs | to_entries[] | select(.value.role == "textbox" and ((.value.name // "") | test("password"; "i"))) | .key' 2>/dev/null | head -1)

[ -n "$PHONE_REF" ] && $AB fill "@$PHONE_REF" "$PHONE" && $AB wait 500
[ -n "$PASSWORD_REF" ] && $AB fill "@$PASSWORD_REF" "$PASSWORD" && $AB wait 1000

$AB eval "document.querySelector('button[type=\"submit\"]')?.click() || document.querySelectorAll('button').find(b => b.textContent.includes('Sign In'))?.click()" > /dev/null 2>&1
$AB wait 8000
echo "✓ Logged in"

# ── STEP 2: Navigate to Reports ───────────────────────────────────────────
echo "[2/4] Navigating to Reports page..."
$AB open "$FRONTEND_URL/owner/reports"
$AB wait 4000

CURRENT_URL=$($AB get url 2>/dev/null)
echo "  Current URL: $CURRENT_URL"

$AB screenshot "$OUTPUT_DIR/screenshots/reports_page_${TIMESTAMP}.png"
echo "✓ Screenshot taken"

# ── STEP 3: Verify Page Content ───────────────────────────────────────────
echo "[3/4] Verifying page content..."

PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null)
PAGE_TITLE=$($AB eval "document.title" 2>/dev/null)

# Check for report-related keywords
HAS_REPORTS=$(echo "$PAGE_TEXT" | grep -iE "report|occupancy|revenue|analytics" | wc -l)
HAS_CONTENT=$(echo "$PAGE_TEXT" | wc -w)

echo "  Page title: $PAGE_TITLE"
echo "  Report keywords found: $HAS_REPORTS"
echo "  Total words: $HAS_CONTENT"

# Look for common report elements
REPORT_ELEMENTS=$($AB eval "
  const elements = {
    hasHeading: !!document.querySelector('h1, h2'),
    hasButtons: document.querySelectorAll('button').length,
    hasLinks: document.querySelectorAll('a').length,
    hasTables: document.querySelectorAll('table').length,
    hasCards: document.querySelectorAll('[class*=\"card\"]').length
  };
  JSON.stringify(elements, null, 2);
" 2>/dev/null)

echo ""
echo "Page elements:"
echo "$REPORT_ELEMENTS" | jq '.' 2>/dev/null || echo "$REPORT_ELEMENTS"

# ── STEP 4: Verify Success ────────────────────────────────────────────────
echo ""
echo "[4/4] Verifying test success..."

ON_REPORTS_PAGE=$(echo "$CURRENT_URL" | grep -o "owner/reports")
HAS_MIN_CONTENT=$([ "$HAS_CONTENT" -gt 50 ] && echo "yes" || echo "no")

$AB close
echo "✓ Browser closed"

echo ""
echo "========================================"
if [ -n "$ON_REPORTS_PAGE" ] && [ "$HAS_MIN_CONTENT" = "yes" ]; then
  echo " ✅ REPORTS PAGE TEST PASSED"
  echo "========================================"
  echo ""
  echo "Verification:"
  echo "  • On reports page: ✓"
  echo "  • Has content: ✓ ($HAS_CONTENT words)"
  echo "  • Report keywords: $HAS_REPORTS"
  echo ""
  echo "Screenshot: $OUTPUT_DIR/screenshots/reports_page_${TIMESTAMP}.png"
  echo ""
  exit 0
else
  echo " ❌ REPORTS PAGE TEST FAILED"
  echo "========================================"
  echo ""
  echo "Issues:"
  echo "  • On reports page: $([ -n "$ON_REPORTS_PAGE" ] && echo "✓" || echo "✗")"
  echo "  • Has content: $([ "$HAS_MIN_CONTENT" = "yes" ] && echo "✓" || echo "✗")"
  echo ""
  exit 1
fi
