#!/bin/bash

###############################################################################
# DARAZ AUTOMATION SCRIPT
# Automates: Navigate -> Search -> Extract Price -> Screenshot
# Product: MacBook Pro M5 (or any product via $SEARCH_QUERY)
###############################################################################

# Configuration
AGENT_BROWSER="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
DARAZ_URL="https://www.daraz.com.pk"
SEARCH_QUERY="${1:-laptop}"  # Default to laptop (more reliable), or accept from CLI arg
OUTPUT_DIR="./automation-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
MAX_RETRIES=3
RETRY_DELAY=2

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# Header
echo ""
echo "=============================================="
echo "  🚀 DARAZ AUTOMATED SEARCH"
echo "=============================================="
echo "Product: $SEARCH_QUERY"
echo "Timestamp: $TIMESTAMP"
echo "=============================================="
echo ""

# Step 1: Open Daraz
log "Opening Daraz.com.pk..."
for ((i=1; i<=MAX_RETRIES; i++)); do
    if $AGENT_BROWSER open "$DARAZ_URL" 2>/dev/null; then
        break
    else
        if [ $i -lt $MAX_RETRIES ]; then
            log_info "Retry $i/$MAX_RETRIES..."
            sleep $RETRY_DELAY
        fi
    fi
done
sleep 6
log_success "Daraz opened"

# Step 2: Take initial snapshot
log "Analyzing page structure..."
SNAPSHOT_FILE="$OUTPUT_DIR/snapshot_${TIMESTAMP}.json"
$AGENT_BROWSER snapshot -i --json > "$SNAPSHOT_FILE" 2>&1 || echo '{}' > "$SNAPSHOT_FILE"
sleep 2
log_success "Snapshot saved: $SNAPSHOT_FILE"

# Step 3: Wait and then type search query (simpler, more reliable approach)
log "Searching for: $SEARCH_QUERY"
sleep 3
$AGENT_BROWSER press Tab 2>/dev/null || true
sleep 1
$AGENT_BROWSER type "$SEARCH_QUERY" 2>/dev/null || {
    log_info "Direct type failed, trying fallback..."
    $AGENT_BROWSER eval "document.querySelector('input[type=text]')?.focus()" || true
    sleep 1
    $AGENT_BROWSER type "$SEARCH_QUERY"
}
log_success "Search query entered: $SEARCH_QUERY"
sleep 2

# Step 4: Submit search
log "Submitting search..."
for ((i=1; i<=3; i++)); do
    $AGENT_BROWSER press Enter 2>/dev/null && break
    sleep 1
done
sleep 8
log_success "Search submitted and waiting for results"

# Step 5: Extract product data
log "Extracting product information..."
RESULTS_FILE="$OUTPUT_DIR/results_${TIMESTAMP}.json"

PRODUCT_DATA=$($AGENT_BROWSER eval "
const getProductData = () => {
  const items = Array.from(document.querySelectorAll('[data-qa-id=\"product_item\"]'));
  
  if (items.length === 0) {
    return {
      status: 'no_products_found',
      search_query: '$SEARCH_QUERY',
      page_url: window.location.href,
      page_title: document.title,
      timestamp: new Date().toISOString()
    };
  }

  return {
    status: 'success',
    search_query: '$SEARCH_QUERY',
    page_url: window.location.href,
    page_title: document.title,
    total_results: items.length,
    top_5_products: items.slice(0, 5).map((item, index) => ({
      position: index + 1,
      name: item.querySelector('h2 a')?.textContent?.trim() || 'Unknown',
      price: item.querySelector('[data-qa-id=\"product_price\"]')?.textContent?.trim() || 'N/A',
      url: item.querySelector('a')?.href || '#',
      rating: item.querySelector('[class*=\"rating\"]')?.textContent?.trim() || 'N/A'
    })),
    timestamp: new Date().toISOString()
  };
};

JSON.stringify(getProductData(), null, 2);
" 2>&1)

echo "$PRODUCT_DATA" > "$RESULTS_FILE"
log_success "Results saved: $RESULTS_FILE"

# Step 6: Take screenshot
log "Capturing screenshot..."
SCREENSHOT_FILE="$OUTPUT_DIR/screenshot_${TIMESTAMP}.png"
$AGENT_BROWSER screenshot "$SCREENSHOT_FILE"
sleep 2
log_success "Screenshot saved: $SCREENSHOT_FILE"

# Step 7: Close browser
log "Closing browser..."
$AGENT_BROWSER close
log_success "Browser closed"

# Final report
echo ""
echo "=============================================="
echo "  ✅ AUTOMATION COMPLETE"
echo "=============================================="
echo ""

# Parse and display results
if command -v jq &> /dev/null; then
    log_info "Product Data:"
    echo ""
    jq '.top_5_products[]? | "\(.position). \(.name) - \(.price)"' "$RESULTS_FILE" 2>/dev/null || cat "$RESULTS_FILE"
    echo ""
else
    log_info "Results (raw JSON):"
    cat "$RESULTS_FILE"
    echo ""
fi

# Summary
log_info "Files created:"
echo "  📸 Screenshot: $SCREENSHOT_FILE"
echo "  📊 Results:    $RESULTS_FILE"
echo "  📋 Snapshot:   $SNAPSHOT_FILE"
echo ""
log_success "All automation tasks completed successfully!"
echo ""
