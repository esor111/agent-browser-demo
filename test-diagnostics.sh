#!/bin/bash

###############################################################################
# TEST DIAGNOSTICS SCRIPT
# Identifies gaps and issues in the test automation setup
###############################################################################

echo "========================================="
echo " TEST AUTOMATION DIAGNOSTICS"
echo "========================================="
echo ""

# Check if services are running
echo "[1/8] Checking if services are running..."
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3001)
BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000)

if [ "$FRONTEND_STATUS" = "200" ]; then
  echo "  ✓ Frontend is running (HTTP $FRONTEND_STATUS)"
else
  echo "  ✗ Frontend is NOT running (HTTP $FRONTEND_STATUS)"
fi

if [ "$BACKEND_STATUS" = "401" ] || [ "$BACKEND_STATUS" = "200" ]; then
  echo "  ✓ Backend is running (HTTP $BACKEND_STATUS)"
else
  echo "  ✗ Backend is NOT running (HTTP $BACKEND_STATUS)"
fi

# Check agent-browser
echo ""
echo "[2/8] Checking agent-browser..."
AB_PATH="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
if [ -f "$AB_PATH" ] && [ -x "$AB_PATH" ]; then
  echo "  ✓ agent-browser found and executable"
else
  echo "  ✗ agent-browser NOT found or not executable"
fi

# Check test configuration
echo ""
echo "[3/8] Checking test configuration..."
if [ -f "frontend-tests/config/environments/dev.env" ]; then
  echo "  ✓ dev.env found"
  source frontend-tests/config/environments/dev.env
  echo "    - Frontend URL: $FRONTEND_URL"
  echo "    - Backend URL: $API_URL"
  echo "    - Owner Phone: $OWNER_PHONE"
else
  echo "  ✗ dev.env NOT found"
fi

# Check output directories
echo ""
echo "[4/8] Checking output directories..."
if [ -d "frontend-results/screenshots" ]; then
  SCREENSHOT_COUNT=$(ls -1 frontend-results/screenshots/ 2>/dev/null | wc -l)
  echo "  ✓ Screenshots directory exists ($SCREENSHOT_COUNT files)"
else
  echo "  ✗ Screenshots directory NOT found"
fi

if [ -d "frontend-results/snapshots" ]; then
  SNAPSHOT_COUNT=$(ls -1 frontend-results/snapshots/ 2>/dev/null | wc -l)
  echo "  ✓ Snapshots directory exists ($SNAPSHOT_COUNT files)"
else
  echo "  ✗ Snapshots directory NOT found"
fi

# Test API connectivity
echo ""
echo "[5/8] Testing API connectivity..."
API_HEALTH=$(curl -s http://localhost:3000 2>&1)
if echo "$API_HEALTH" | grep -q "Unauthorized\|success"; then
  echo "  ✓ API is responding"
else
  echo "  ✗ API is NOT responding properly"
  echo "    Response: $API_HEALTH"
fi

# Check if test user exists
echo ""
echo "[6/8] Checking test user authentication..."
LOGIN_RESPONSE=$(curl -s -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"phone\":\"$OWNER_PHONE\",\"password\":\"$OWNER_PASSWORD\"}" 2>&1)

if echo "$LOGIN_RESPONSE" | grep -q "accessToken\|token"; then
  echo "  ✓ Test user can authenticate"
  echo "    Response: $(echo $LOGIN_RESPONSE | jq -r '.success' 2>/dev/null || echo 'Success')"
else
  echo "  ✗ Test user CANNOT authenticate"
  echo "    Response: $LOGIN_RESPONSE"
fi

# Check test scripts
echo ""
echo "[7/8] Checking test scripts..."
TEST_SCRIPTS=(
  "frontend-tests/tests/auth/login-test.sh"
  "frontend-tests/tests/customer/hotel-search-test.sh"
  "frontend-tests/add-rooms-to-property.sh"
  "run-all-tests.sh"
  "run-critical-tests.sh"
)

for script in "${TEST_SCRIPTS[@]}"; do
  if [ -f "$script" ] && [ -x "$script" ]; then
    echo "  ✓ $script (executable)"
  elif [ -f "$script" ]; then
    echo "  ⚠ $script (not executable)"
  else
    echo "  ✗ $script (missing)"
  fi
done

# Check data generators
echo ""
echo "[8/8] Checking data generators..."
if [ -f "frontend-tests/lib/data-generators.sh" ]; then
  source frontend-tests/lib/data-generators.sh
  TEST_EMAIL=$(generate_email "test")
  TEST_PHONE=$(generate_phone "984")
  echo "  ✓ Data generators loaded"
  echo "    Sample email: $TEST_EMAIL"
  echo "    Sample phone: $TEST_PHONE"
else
  echo "  ✗ Data generators NOT found"
fi

# Summary
echo ""
echo "========================================="
echo " DIAGNOSTICS COMPLETE"
echo "========================================="
echo ""
echo "Next steps:"
echo "  1. Ensure both frontend and backend are running"
echo "  2. Verify test user credentials in dev.env"
echo "  3. Make all test scripts executable: chmod +x frontend-tests/**/*.sh"
echo "  4. Run a simple test: bash frontend-tests/tests/auth/login-test.sh"
echo ""
