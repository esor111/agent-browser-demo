#!/bin/bash

###############################################################################
# DARAZ SEARCH AUTOMATION
# Built following the agent-browser SKILL workflow exactly:
#   open → snapshot -i (get @refs) → fill @ref → wait --load → re-snapshot → extract
###############################################################################

AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
PRODUCT="${1:-MacBook Pro M5}"
OUTPUT_DIR="./automation-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DARAZ_URL="https://www.daraz.com.np"
mkdir -p "$OUTPUT_DIR"

echo ""
echo "========================================"
echo " DARAZ SEARCH: $PRODUCT"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""

# ── STEP 1: Navigate ──────────────────────────────────────────────────────────
echo "[1/6] Opening Daraz..."
$AB --headed open "$DARAZ_URL"
echo "✓ Page opened"

# ── STEP 2: Snapshot to find the search box @ref ──────────────────────────────
# The skill says: snapshot -i returns elements with refs like @e1, @e2
echo "[2/6] Snapshotting page to find search input ref..."
RAW_SNAPSHOT=$($AB snapshot -i --json 2>/dev/null)
echo "$RAW_SNAPSHOT" > "$OUTPUT_DIR/snapshot_home_${TIMESTAMP}.json"

# Parse the ref of the searchbox from snapshot JSON
# Actual structure: {"success":true, "data":{"refs":{"e1":{"name":"...","role":"..."}}}}
SEARCH_REF=$(echo "$RAW_SNAPSHOT" | jq -r '
  .data.refs
  | to_entries[]
  | select(
      .value.role == "searchbox" or
      .value.role == "textbox" or
      (.value.name // "" | test("earch|query"; "i"))
    )
  | .key
' 2>/dev/null | head -1)

if [ -z "$SEARCH_REF" ]; then
  echo "  ⚠ Could not find searchbox ref from snapshot, falling back to @e1"
  SEARCH_REF="e1"
fi
echo "✓ Search input found: @$SEARCH_REF"

# ── STEP 3: Fill the search box using the @ref ────────────────────────────────
# The skill says: agent-browser fill @e2 "text" — Clear and type
echo "[3/6] Filling search: \"$PRODUCT\""
$AB fill "@$SEARCH_REF" "$PRODUCT"
echo "✓ Search text entered"

# ── STEP 4: Find the search button ref and click it ───────────────────────────
# The skill says: snapshot -i, get button ref, then click @ref
echo "[4/6] Finding and clicking Search button..."
BTN_REF=$(echo "$RAW_SNAPSHOT" | jq -r '
  .data.refs
  | to_entries[]
  | select(.value.role == "button" and ((.value.name // "") | test("earch"; "i")))
  | .key
' 2>/dev/null | head -1)

if [ -n "$BTN_REF" ]; then
  echo "  Found search button: @$BTN_REF"
  $AB click "@$BTN_REF"
else
  echo "  No button ref found, using Enter key"
  $AB press Enter
fi

# ── STEP 5: Wait properly using agent-browser wait (NOT sleep) ────────────────
# The skill says: agent-browser wait --load networkidle
echo "[5/6] Waiting for results to load..."
$AB wait --load networkidle 2>/dev/null || $AB wait 4000
echo "✓ Results page loaded"

# ── STEP 6: Re-snapshot results page, extract price data ─────────────────────
# The skill says: Re-snapshot after navigation or significant DOM changes
echo "[6/6] Re-snapshotting results page and extracting prices..."
# Scroll down to trigger lazy-loaded price renders, then wait for API responses
$AB scroll down 600 2>/dev/null || true
$AB wait 3000
$AB scroll down 600 2>/dev/null || true
$AB wait 2000
RESULTS_SNAPSHOT=$($AB snapshot -i --json 2>/dev/null)
echo "$RESULTS_SNAPSHOT" > "$OUTPUT_DIR/snapshot_results_${TIMESTAMP}.json"

# Take screenshot of results
$AB screenshot "$OUTPUT_DIR/screenshot_${TIMESTAMP}.png"
echo "✓ Screenshot saved"

# Use snapshot refs to get product names via: agent-browser get text @ref
# Product link refs start at e14 in the results snapshot (e1-e13 are nav elements)
PRODUCT_REFS=$(echo "$RESULTS_SNAPSHOT" | jq -r '
  .data.refs
  | to_entries[]
  | select(
      .value.role == "link" and
      (.value.name // "" | test("MacBook|macbook|laptop|mac"; "i"))
    )
  | .key
' 2>/dev/null | head -5)

# Build product list using get text @ref (skill-native command)
PRODUCT_NAMES_JSON="["
FIRST=true
for REF in $PRODUCT_REFS; do
  NAME=$($AB get text "@$REF" 2>/dev/null | tr '\n' ' ' | xargs)
  if [ -n "$NAME" ] && [ "$FIRST" = true ]; then
    PRODUCT_NAMES_JSON="$PRODUCT_NAMES_JSON\"$NAME\""
    FIRST=false
  elif [ -n "$NAME" ]; then
    PRODUCT_NAMES_JSON="$PRODUCT_NAMES_JSON,\"$NAME\""
  fi
done
PRODUCT_NAMES_JSON="$PRODUCT_NAMES_JSON]"

# Use eval to extract full product data including prices
# Use innerText to get visible text from parent card element of each product link
PRICE_DATA=$($AB eval "
const links = Array.from(document.querySelectorAll('a[href*=\"/products/\"]'))
  .filter(el => el.textContent?.trim().length > 10)  // skip image-only links
  .filter((el, i, arr) => arr.findIndex(a => a.href === el.href) === i)
  .slice(0, 5);

const products = links.map((link, i) => {
  const card = link.closest('li') || link.closest('[class]') || link.parentElement;
  const cardText = card?.innerText || '';
  // Price pattern: must start with Rs/NRs/NPR currency symbol
  const priceMatch = cardText.match(/(?:Rs\.?\s*|NRs\.?\s*|NPR\s*)[\d,]+/i);
  return {
    rank: i + 1,
    name: link.textContent?.trim()?.substring(0, 80) || link.title || 'N/A',
    price: priceMatch ? (Array.isArray(priceMatch) ? priceMatch[0] : priceMatch[0]).trim() : (
      card?.querySelector('[class*=\"price\"],[class*=\"Price\"]')?.innerText?.trim() || 'N/A'
    ),
    link: link.href
  };
});

JSON.stringify({
  searched_for: '$PRODUCT',
  url: window.location.href,
  title: document.title,
  total_found: products.length,
  products: products
}, null, 2);
" 2>/dev/null)

echo "$PRICE_DATA" > "$OUTPUT_DIR/prices_${TIMESTAMP}.json"

# ── Close ─────────────────────────────────────────────────────────────────────
$AB close
echo "✓ Browser closed"

# ── Print results ─────────────────────────────────────────────────────────────
echo ""
echo "========================================"
echo " ✅ RESULTS"
echo "========================================"

if echo "$PRICE_DATA" | jq -e '.total_found > 0' > /dev/null 2>&1; then
  echo ""
  echo "Products found for: $PRODUCT"
  echo ""
  echo "$PRICE_DATA" | jq -r '.products[] | "  #\(.rank)  \(.name)\n       Price: \(.price)\n"'
  echo ""
  echo "Total results on page: $(echo "$PRICE_DATA" | jq -r '.total_found')"
else
  echo ""
  echo "⚠ No products matched - raw data:"
  cat "$OUTPUT_DIR/prices_${TIMESTAMP}.json"
fi

echo ""
echo "Files saved:"
echo "  📸  $OUTPUT_DIR/screenshot_${TIMESTAMP}.png"
echo "  📊  $OUTPUT_DIR/prices_${TIMESTAMP}.json"
echo "  📋  $OUTPUT_DIR/snapshot_results_${TIMESTAMP}.json"
echo ""
