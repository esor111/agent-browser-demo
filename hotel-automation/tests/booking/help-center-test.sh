#!/bin/bash

###############################################################################
# HELP CENTER PAGE NAVIGATION TEST
# Simple test to verify help center page loads and displays correctly
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../config/test-config.sh"

AB="$AB_PATH"

echo ""
echo "========================================"
echo " HELP CENTER PAGE TEST"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""

# ── STEP 1: Navigate to Help Center ───────────────────────────────────────
echo "[1/3] Opening help center page..."
$AB --headed open "$FRONTEND_URL/help"
$AB wait 4000

CURRENT_URL=$($AB get url 2>/dev/null)
echo "  Current URL: $CURRENT_URL"

$AB screenshot "$OUTPUT_DIR/screenshots/help_center_${TIMESTAMP}.png"
echo "✓ Screenshot taken"

# ── STEP 2: Verify Page Content ───────────────────────────────────────────
echo "[2/3] Verifying page content..."

PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null)
PAGE_TITLE=$($AB eval "document.title" 2>/dev/null)

HAS_HELP=$(echo "$PAGE_TEXT" | grep -iE "help|faq|support|question|contact|guide" | wc -l)
HAS_CONTENT=$(echo "$PAGE_TEXT" | wc -w)

echo "  Page title: $PAGE_TITLE"
echo "  Help keywords found: $HAS_HELP"
echo "  Total words: $HAS_CONTENT"

HELP_ELEMENTS=$($AB eval "
  const elements = {
    hasHeading: !!document.querySelector('h1, h2'),
    hasSearchBox: !!document.querySelector('input[type=\"search\"], input[placeholder*=\"search\" i]'),
    hasLinks: document.querySelectorAll('a').length,
    hasCards: document.querySelectorAll('[class*=\"card\"]').length,
    hasAccordion: document.querySelectorAll('[class*=\"accordion\"]').length,
    hasFAQ: document.body.innerText.toLowerCase().includes('faq')
  };
  JSON.stringify(elements, null, 2);
" 2>/dev/null)

echo ""
echo "Page elements:"
echo "$HELP_ELEMENTS" | jq '.' 2>/dev/null || echo "$HELP_ELEMENTS"

# ── STEP 3: Verify Success ────────────────────────────────────────────────
echo ""
echo "[3/3] Verifying test success..."

ON_HELP_PAGE=$(echo "$CURRENT_URL" | grep -o "help")
HAS_MIN_CONTENT=$([ "$HAS_CONTENT" -gt 100 ] && echo "yes" || echo "no")

$AB close
echo "✓ Browser closed"

echo ""
echo "========================================"
if [ -n "$ON_HELP_PAGE" ] && [ "$HAS_MIN_CONTENT" = "yes" ]; then
  echo " ✅ HELP CENTER TEST PASSED"
  echo "========================================"
  echo ""
  echo "Verification:"
  echo "  • On help page: ✓"
  echo "  • Has content: ✓ ($HAS_CONTENT words)"
  echo "  • Help keywords: $HAS_HELP"
  echo ""
  echo "Screenshot: $OUTPUT_DIR/screenshots/help_center_${TIMESTAMP}.png"
  echo ""
  exit 0
else
  echo " ❌ HELP CENTER TEST FAILED"
  echo "========================================"
  echo ""
  echo "Issues:"
  echo "  • On help page: $([ -n "$ON_HELP_PAGE" ] && echo "✓" || echo "✗")"
  echo "  • Has content: $([ "$HAS_MIN_CONTENT" = "yes" ] && echo "✓" || echo "✗")"
  echo ""
  exit 1
fi
