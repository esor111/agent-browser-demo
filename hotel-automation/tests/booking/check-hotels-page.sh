#!/bin/bash

###############################################################################
# CHECK HOTELS PAGE - Deep inspection
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/frontend-tests/config/test-config.sh"

AB="$AB_PATH"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo ""
echo "========================================"
echo " HOTELS PAGE DEEP INSPECTION"
echo "========================================"
echo ""

$AB --headed open "$FRONTEND_URL/hotels"
$AB wait 5000

echo "Current URL:"
$AB get url

echo ""
echo "Page Title:"
$AB eval "document.title"

echo ""
echo "=== CHECKING FOR HOTELS ==="
echo ""

echo "1. Looking for any links with 'hotel' in href:"
$AB eval "
  const hotelLinks = Array.from(document.querySelectorAll('a'))
    .filter(a => a.href.toLowerCase().includes('hotel'));
  console.log('Found', hotelLinks.length, 'links with hotel in href');
  hotelLinks.slice(0, 5).forEach((link, i) => {
    console.log(\`  \${i+1}. \${link.href}\`);
  });
"

echo ""
echo "2. Looking for any cards or property elements:"
$AB eval "
  const cards = document.querySelectorAll('[class*=\"card\"], [class*=\"property\"], [class*=\"hotel\"], [class*=\"listing\"]');
  console.log('Found', cards.length, 'card-like elements');
"

echo ""
echo "3. Checking page text for 'no results' or 'empty':"
$AB eval "
  const text = document.body.innerText.toLowerCase();
  console.log('Has \"no results\":', text.includes('no results'));
  console.log('Has \"no hotels\":', text.includes('no hotels'));
  console.log('Has \"no properties\":', text.includes('no properties'));
  console.log('Has \"empty\":', text.includes('empty'));
  console.log('Has \"not found\":', text.includes('not found'));
"

echo ""
echo "4. Getting first 500 characters of page text:"
$AB eval "document.body.innerText.substring(0, 500)"

echo ""
echo "5. Checking if data is loading:"
$AB eval "
  const loading = document.querySelectorAll('[class*=\"loading\"], [class*=\"spinner\"], [class*=\"skeleton\"]');
  console.log('Loading indicators:', loading.length);
"

echo ""
echo "6. Checking for error messages:"
$AB eval "
  const errors = document.querySelectorAll('[class*=\"error\"], [role=\"alert\"]');
  console.log('Error elements:', errors.length);
  Array.from(errors).forEach(err => {
    console.log('  Error:', err.textContent.trim());
  });
"

echo ""
echo "7. Checking all main content divs:"
$AB eval "
  const main = document.querySelector('main, [role=\"main\"], #__next > div');
  if (main) {
    console.log('Main content classes:', main.className);
    console.log('Main content children:', main.children.length);
    console.log('Main content text (first 200 chars):', main.innerText.substring(0, 200));
  } else {
    console.log('No main content found');
  }
"

echo ""
echo "8. Checking for API calls in console (network):"
$AB eval "
  // Check if there's any indication of API calls
  console.log('Window fetch available:', typeof window.fetch);
  console.log('XMLHttpRequest available:', typeof XMLHttpRequest);
"

echo ""
echo "9. Looking for all images (hotel photos):"
$AB eval "
  const images = document.querySelectorAll('img');
  console.log('Total images:', images.length);
  Array.from(images).slice(0, 5).forEach((img, i) => {
    console.log(\`  \${i+1}. \${img.src}\`);
    console.log(\`     alt: \${img.alt}\`);
  });
"

echo ""
echo "10. Dumping all links on page:"
$AB eval "
  const allLinks = Array.from(document.querySelectorAll('a[href]'));
  console.log('Total links:', allLinks.length);
  allLinks.slice(0, 20).forEach((link, i) => {
    console.log(\`  \${i+1}. \${link.href} - \${link.textContent.trim().substring(0, 30)}\`);
  });
"

$AB screenshot "$OUTPUT_DIR/screenshots/hotels_page_inspection_${TIMESTAMP}.png"

echo ""
echo "Screenshot saved: $OUTPUT_DIR/screenshots/hotels_page_inspection_${TIMESTAMP}.png"
echo ""

$AB close

echo "✅ Inspection complete!"
echo ""
