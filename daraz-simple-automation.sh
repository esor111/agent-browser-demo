#!/bin/bash

###############################################################################
# SIMPLIFIED DARAZ AUTOMATION
# Complete end-to-end automation with robust error handling
###############################################################################

# Configuration
AGENT_BROWSER="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
OUTPUT_DIR="./automation-results"
PRODUCT="${1:-laptop}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$OUTPUT_DIR"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo ""
echo "========================================"
echo "  ✨ DARAZ AUTOMATED SEARCH"
echo "========================================"
echo "Product: $PRODUCT"
echo "Time: $TIMESTAMP"
echo "========================================"
echo ""

# STEP 1: NAVIGATE
echo -e "${BLUE}[Step 1/7]${NC} Opening Daraz..."
$AGENT_BROWSER open https://www.daraz.com.pk
sleep 6
echo -e "${GREEN}✓${NC} Daraz loaded"

# STEP 2: SNAPSHOT
echo -e "${BLUE}[Step 2/7]${NC} Capturing page structure..."
$AGENT_BROWSER snapshot -i > "$OUTPUT_DIR/page_${TIMESTAMP}.json" 2>&1
sleep 2
echo -e "${GREEN}✓${NC} Snapshot captured"

# STEP 3: TYPE SEARCH
echo -e "${BLUE}[Step 3/7]${NC} Entering search: $PRODUCT"
$AGENT_BROWSER press Tab
sleep 1
$AGENT_BROWSER type "$PRODUCT"
sleep 2
echo -e "${GREEN}✓${NC} Search entered"

# STEP 4: SUBMIT
echo -e "${BLUE}[Step 4/7]${NC} Submitting search..."
$AGENT_BROWSER press Enter
sleep 8
echo -e "${GREEN}✓${NC} Search submitted"

# STEP 5: EXTRACT DATA
echo -e "${BLUE}[Step 5/7]${NC} Extracting product information..."
RESULT=$($AGENT_BROWSER eval "
JSON.stringify({
  product_searched: '$PRODUCT',
  total_results: document.querySelectorAll('[data-qa-id=\"product_item\"]').length,
  page_url: window.location.href,
  page_title: document.title,
  timestamp: new Date().toISOString(),
  top_3_products: Array.from(document.querySelectorAll('[data-qa-id=\"product_item\"]'))
    .slice(0, 3)
    .map((el, i) => ({
      rank: i + 1,
      name: el.querySelector('h2 a')?.textContent?.trim() || 'N/A',
      price: el.querySelector('[data-qa-id=\"product_price\"]')?.textContent?.trim() || 'N/A'
    }))
}, null, 2);
")
echo "$RESULT" > "$OUTPUT_DIR/products_${TIMESTAMP}.json"
sleep 2
echo -e "${GREEN}✓${NC} Data extracted"

# STEP 6: SCREENSHOT
echo -e "${BLUE}[Step 6/7]${NC} Saving screenshot..."
$AGENT_BROWSER screenshot "$OUTPUT_DIR/screenshot_${TIMESTAMP}.png"
sleep 2
echo -e "${GREEN}✓${NC} Screenshot saved"

# STEP 7: CLOSE
echo -e "${BLUE}[Step 7/7]${NC} Closing browser..."
$AGENT_BROWSER close
sleep 1
echo -e "${GREEN}✓${NC} Browser closed"

# RESULTS
echo ""
echo "========================================"
echo "  ✅ AUTOMATION COMPLETE!"
echo "========================================"
echo ""
echo -e "${YELLOW}📊 EXTRACTED DATA:${NC}"
echo ""
cat "$OUTPUT_DIR/products_${TIMESTAMP}.json" | grep -E '(total_results|rank|name|price)' | head -20
echo ""
echo -e "${YELLOW}📁 OUTPUT FILES:${NC}"
echo "  Screenshot: $OUTPUT_DIR/screenshot_${TIMESTAMP}.png"
echo "  Products:   $OUTPUT_DIR/products_${TIMESTAMP}.json"
echo "  Snapshot:   $OUTPUT_DIR/page_${TIMESTAMP}.json"
echo ""
echo -e "${GREEN}✓ All done! Check the files above for full results.${NC}"
echo ""
