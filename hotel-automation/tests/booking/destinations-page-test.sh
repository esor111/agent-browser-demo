#!/bin/bash

###############################################################################
# DESTINATIONS PAGE NAVIGATION TEST
# Simple test to verify destinations page loads and displays correctly
###############################################################################

# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../config/test-config.sh"

AB="$AB_PATH"

echo ""
echo "========================================"
echo " DESTINATIONS PAGE TEST"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""

# ── STEP 1: Navigate to Destinations ──────────────────────────────────────
echo "[1/3] Opening destinations page..."
$AB --headed open "$FRONTEND_URL/destinations"
$AB wait 4000

CURRENT_URL=$($AB get url 2>/dev/null)
echo "  Current URL: $CURRENT_URL"

$AB screenshot "$OUTPUT_DIR/screenshots/destinations_page_${TIMESTAMP}.png"
echo "✓ Screenshot taken"

# ── STEP 2: Verify Page Content ───────────────────────────────────────────
echo "[2/3] Verifying page content..."

PAGE_TEXT=$($AB eval "document.body.innerText" 2>/dev/null)
PAGE_TITLE=$($AB eval "document.title" 2>/dev/null)

HAS_DESTINATIONS=$(echo "$PAGE_TEXT" | grep -iE "kathmandu|pokhara|chitwan|destination|explore" | wc -l)
HAS_CONTENT=$(echo "$PAGE_TEXT" | wc -w)

echo "  Page title: $PAGE_TITLE"
echo "  Destination keywords found: $HAS_DESTINATIONS"
echo "  Total words: $HAS_CONTENT"

DEST_ELEMENTS=$($AB eval "
  const elements = {
    hasHeading: !!document.querySelector('h1, h2'),
    hasImages: document.querySelectorAll('img').length,
    hasLinks: document.querySelectorAll('a[href*=\"hotels\"]').length,
    hasCards: document.querySelectorAll('[class*=\"card\"]').length,
    destinationCount: document.querySelectorAll('a[href*=\"destination\"]').length
  };
  JSON.stringify(elements, null, 2);
" 2>/dev/null)

echo ""
echo "Page elements:"
echo "$DEST_ELEMENTS" | jq '.' 2>/dev/null || echo "$DEST_ELEMENTS"

# ── STEP 3: Verify Success ────────────────────────────────────────────────
echo ""
echo "[3/3] Verifying test success..."

ON_DESTINATIONS_PAGE=$(echo "$CURRENT_URL" | grep -o "destinations")
HAS_MIN_CONTENT=$([ "$HAS_CONTENT" -gt 100 ] && echo "yes" || echo "no")

$AB close
echo "✓ Browser closed"

echo ""
echo "========================================"
if [ -n "$ON_DESTINATIONS_PAGE" ] && [ "$HAS_MIN_CONTENT" = "yes" ]; then
  echo " ✅ DESTINATIONS PAGE TEST PASSED"
  echo "========================================"
  echo ""
  echo "Verification:"
  echo "  • On destinations page: ✓"
  echo "  • Has content: ✓ ($HAS_CONTENT words)"
  echo "  • Destination keywords: $HAS_DESTINATIONS"
  echo ""
  echo "Screenshot: $OUTPUT_DIR/screenshots/destinations_page_${TIMESTAMP}.png"
  echo ""
  exit 0
else
  echo " ❌ DESTINATIONS PAGE TEST FAILED"
  echo "========================================"
  echo ""
  echo "Issues:"
  echo "  • On destinations page: $([ -n "$ON_DESTINATIONS_PAGE" ] && echo "✓" || echo "✗")"
  echo "  • Has content: $([ "$HAS_MIN_CONTENT" = "yes" ] && echo "✓" || echo "✗")"
  echo ""
  exit 1
fi
