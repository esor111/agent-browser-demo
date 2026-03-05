#!/bin/bash

AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
HOTEL_ID="00000000-0000-4000-a000-000000000100"

echo "Opening booking page..."
$AB --headed open "$FRONTEND_URL/booking?hotelId=$HOTEL_ID&checkIn=2026-03-10&checkOut=2026-03-12&guests=2&rooms=1"
$AB wait 10000

echo ""
echo "Page HTML structure:"
$AB eval "document.body.innerHTML.substring(0, 2000)" 2>/dev/null

echo ""
echo ""
echo "All visible text:"
$AB eval "document.body.innerText" 2>/dev/null

echo ""
echo ""
echo "Press Enter to close..."
read

$AB close
