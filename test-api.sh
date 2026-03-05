#!/bin/bash

AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"

echo "Testing API endpoint..."
$AB --headed open "http://localhost:3001/hotels"
$AB wait 5000

# Get hotel data
HOTELS=$($AB eval "
  fetch('http://localhost:3000/public/hotels')
    .then(r => r.json())
    .then(data => JSON.stringify(data, null, 2))
    .catch(err => 'Error: ' + err.message);
" 2>/dev/null)

echo "Hotels API response:"
echo "$HOTELS"

$AB close
