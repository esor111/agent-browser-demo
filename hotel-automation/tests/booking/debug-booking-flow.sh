#!/bin/bash

###############################################################################
# BOOKING FLOW DEBUG SCRIPT
# Manually step through the booking flow to identify bottlenecks
###############################################################################

AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo ""
echo "========================================"
echo " BOOKING FLOW DEBUG"
echo " Timestamp: $TIMESTAMP"
echo "========================================"
echo ""

# ── STEP 1: Open hotels page ──────────────────────────────────────────────────
echo "[DEBUG 1] Opening hotels page..."
$AB --headed open "$FRONTEND_URL/hotels"
$AB wait 4000

CURRENT_URL=$($AB get url 2>/dev/null)
echo "  URL: $CURRENT_URL"

# Take snapshot
SNAPSHOT=$($AB snapshot -i --json 2>/dev/null)
echo "$SNAPSHOT" > "./debug_hotels_snapshot.json"
echo "  Snapshot saved: debug_hotels_snapshot.json"

# Check what's on the page
PAGE_INFO=$($AB eval "
  JSON.stringify({
    title: document.title,
    hasHotels: document.querySelectorAll('a[href*=\"/hotels/\"]').length,
    hasButtons: document.querySelectorAll('button').length,
    buttonTexts: Array.from(document.querySelectorAll('button')).slice(0, 10).map(b => b.textContent?.trim()).filter(t => t)
  }, null, 2);
" 2>/dev/null)

echo ""
echo "Page Info:"
echo "$PAGE_INFO" | jq '.' 2>/dev/null

read -p "Press Enter to continue to hotel detail..."

# ── STEP 2: Click first hotel ─────────────────────────────────────────────────
echo ""
echo "[DEBUG 2] Clicking first hotel..."

$AB eval "
  const hotelLinks = Array.from(document.querySelectorAll('a[href*=\"/hotels/\"]'))
    .filter(link => link.href.match(/\/hotels\/[^\/]+$/));
  
  console.log('Found hotel links:', hotelLinks.length);
  
  if (hotelLinks.length > 0) {
    console.log('Clicking:', hotelLinks[0].href);
    hotelLinks[0].click();
  }
" 2>&1

$AB wait 5000

CURRENT_URL=$($AB get url 2>/dev/null)
echo "  URL: $CURRENT_URL"

# Check hotel detail page
HOTEL_INFO=$($AB eval "
  const bookButtons = Array.from(document.querySelectorAll('button, a'))
    .filter(el => {
      const text = (el.textContent || '').toLowerCase();
      return text.includes('book') || text.includes('reserve') || text.includes('availability');
    })
    .map(el => ({
      tag: el.tagName,
      text: el.textContent?.trim(),
      href: el.href || null,
      disabled: el.disabled || false
    }));
  
  JSON.stringify({
    title: document.title,
    url: window.location.href,
    hasRoomTypes: document.querySelectorAll('[class*=\"room\"]').length,
    bookingButtons: bookButtons,
    allButtons: Array.from(document.querySelectorAll('button')).slice(0, 15).map(b => b.textContent?.trim()).filter(t => t)
  }, null, 2);
" 2>/dev/null)

echo ""
echo "Hotel Detail Page Info:"
echo "$HOTEL_INFO" | jq '.' 2>/dev/null

read -p "Press Enter to try clicking booking button..."

# ── STEP 3: Try to navigate to booking ────────────────────────────────────────
echo ""
echo "[DEBUG 3] Attempting to navigate to booking..."

$AB eval "
  // Try multiple strategies
  const strategies = [
    // Strategy 1: Look for Reserve/Book buttons
    () => {
      const buttons = Array.from(document.querySelectorAll('button, a'))
        .filter(el => {
          const text = (el.textContent || '').toLowerCase();
          return text.includes('reserve') || text.includes('book now');
        });
      if (buttons.length > 0) {
        console.log('Strategy 1: Found button:', buttons[0].textContent);
        buttons[0].click();
        return true;
      }
      return false;
    },
    
    // Strategy 2: Look for room selection
    () => {
      const roomButtons = Array.from(document.querySelectorAll('button'))
        .filter(el => {
          const text = (el.textContent || '').toLowerCase();
          return text.includes('select') || text.includes('choose');
        });
      if (roomButtons.length > 0) {
        console.log('Strategy 2: Found room button:', roomButtons[0].textContent);
        roomButtons[0].click();
        return true;
      }
      return false;
    },
    
    // Strategy 3: Direct navigation
    () => {
      const bookingLinks = Array.from(document.querySelectorAll('a[href*=\"booking\"]'));
      if (bookingLinks.length > 0) {
        console.log('Strategy 3: Found booking link');
        bookingLinks[0].click();
        return true;
      }
      return false;
    }
  ];
  
  for (let i = 0; i < strategies.length; i++) {
    console.log('Trying strategy', i + 1);
    if (strategies[i]()) {
      console.log('Strategy', i + 1, 'succeeded');
      break;
    }
  }
" 2>&1

$AB wait 5000

CURRENT_URL=$($AB get url 2>/dev/null)
echo "  URL after click: $CURRENT_URL"

# Check what page we're on
CURRENT_PAGE=$($AB eval "
  JSON.stringify({
    title: document.title,
    url: window.location.href,
    pathname: window.location.pathname,
    hasBookingForm: !!document.querySelector('form'),
    hasGuestInputs: document.querySelectorAll('input[name*=\"name\" i], input[placeholder*=\"name\" i]').length,
    hasPaymentInputs: document.querySelectorAll('input[name*=\"card\" i], input[placeholder*=\"card\" i]').length,
    formInputs: Array.from(document.querySelectorAll('input')).slice(0, 10).map(i => ({
      name: i.name,
      type: i.type,
      placeholder: i.placeholder
    }))
  }, null, 2);
" 2>/dev/null)

echo ""
echo "Current Page Info:"
echo "$CURRENT_PAGE" | jq '.' 2>/dev/null

read -p "Press Enter to check booking page structure..."

# ── STEP 4: Analyze booking page structure ────────────────────────────────────
echo ""
echo "[DEBUG 4] Analyzing page structure..."

STRUCTURE=$($AB eval "
  JSON.stringify({
    // Check for booking page indicators
    isBookingPage: window.location.pathname.includes('booking'),
    isHotelDetail: window.location.pathname.includes('hotels/'),
    
    // Check for form elements
    forms: document.querySelectorAll('form').length,
    inputs: document.querySelectorAll('input').length,
    buttons: document.querySelectorAll('button').length,
    
    // Check for specific booking elements
    hasGuestDetails: document.body.innerText.toLowerCase().includes('guest details'),
    hasPaymentSection: document.body.innerText.toLowerCase().includes('payment'),
    hasConfirmation: document.body.innerText.toLowerCase().includes('confirm'),
    
    // Get all input fields
    allInputs: Array.from(document.querySelectorAll('input')).map(i => ({
      name: i.name || 'unnamed',
      type: i.type,
      placeholder: i.placeholder || '',
      id: i.id || ''
    })),
    
    // Get all buttons
    allButtons: Array.from(document.querySelectorAll('button')).map(b => ({
      text: b.textContent?.trim() || '',
      disabled: b.disabled,
      type: b.type
    }))
  }, null, 2);
" 2>/dev/null)

echo ""
echo "Page Structure:"
echo "$STRUCTURE" | jq '.' 2>/dev/null

echo ""
echo "========================================"
echo " DEBUG COMPLETE"
echo "========================================"
echo ""
echo "Analysis:"
echo "  1. Check debug_hotels_snapshot.json for initial page state"
echo "  2. Review the output above to understand the flow"
echo "  3. Identify where the booking button/link is"
echo "  4. Update the test script accordingly"
echo ""

read -p "Press Enter to close browser..."

$AB close
echo "✓ Browser closed"
