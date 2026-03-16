#!/bin/bash

###############################################################################
# RUN BOOKING TEST WITH BACKEND CHECK
# Checks if backend is running, provides instructions if not, then runs test
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_DIR="$SCRIPT_DIR/frontend-tests"

echo ""
echo "========================================"
echo " BOOKING TEST WITH BACKEND CHECK"
echo "========================================"
echo ""

# Check if backend is running
echo "[1/3] Checking if backend is running..."
BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/health 2>/dev/null || echo "000")

if [ "$BACKEND_STATUS" = "000" ]; then
  echo "  ✗ Backend is NOT running"
  echo ""
  echo "========================================"
  echo " BACKEND NOT RUNNING"
  echo "========================================"
  echo ""
  echo "The booking test requires the backend API to be running."
  echo ""
  echo "To start the backend:"
  echo ""
  echo "  cd hostel-backend"
  echo "  npm install              # If not done yet"
  echo "  npm run migration:run    # Run migrations"
  echo "  npm run seed             # Seed test data"
  echo "  npm run start:dev        # Start backend"
  echo ""
  echo "Then run this script again."
  echo ""
  echo "Or open a new terminal and run:"
  echo "  cd hostel-backend && npm run start:dev"
  echo ""
  exit 1
fi

echo "  ✓ Backend is running (HTTP $BACKEND_STATUS)"

# Check if hotels exist
echo ""
echo "[2/3] Checking if hotels are available..."
HOTELS_RESPONSE=$(curl -s "http://localhost:3000/public/hotels?limit=1" 2>/dev/null)
HOTEL_COUNT=$(echo "$HOTELS_RESPONSE" | jq -r '.data | length' 2>/dev/null || echo "0")

if [ "$HOTEL_COUNT" = "0" ] || [ -z "$HOTEL_COUNT" ]; then
  echo "  ✗ No hotels found in database"
  echo ""
  echo "========================================"
  echo " NO HOTELS IN DATABASE"
  echo "========================================"
  echo ""
  echo "The database might not be seeded."
  echo ""
  echo "To seed the database:"
  echo ""
  echo "  cd hostel-backend"
  echo "  npm run seed"
  echo ""
  echo "Then run this script again."
  echo ""
  exit 1
fi

echo "  ✓ Hotels available: $HOTEL_COUNT+"

# Run the diagnostic
echo ""
echo "[3/3] Running booking readiness diagnostic..."
bash "$SCRIPT_DIR/diagnose-booking-readiness.sh"
DIAG_RESULT=$?

if [ $DIAG_RESULT -ne 0 ]; then
  echo ""
  echo "========================================"
  echo " NOT READY FOR BOOKING TEST"
  echo "========================================"
  echo ""
  echo "See diagnostic output above for details."
  echo ""
  exit 1
fi

# Run the booking test
echo ""
echo "========================================"
echo " RUNNING BOOKING FLOW TEST"
echo "========================================"
echo ""

bash "$TEST_DIR/tests/customer/booking-payment-flow-test.sh"
TEST_RESULT=$?

echo ""
if [ $TEST_RESULT -eq 0 ]; then
  echo "✅ BOOKING FLOW TEST PASSED!"
else
  echo "❌ BOOKING FLOW TEST FAILED"
  echo ""
  echo "Check screenshots in:"
  echo "  $TEST_DIR/../frontend-results/screenshots/"
fi

exit $TEST_RESULT
