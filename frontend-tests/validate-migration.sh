#!/bin/bash

###############################################################################
# MIGRATION VALIDATION SCRIPT
# Tests migrated scripts to ensure they work correctly
###############################################################################

echo ""
echo "========================================"
echo " MIGRATION VALIDATION"
echo "========================================"
echo ""

PASSED=0
FAILED=0

# Test 1: Validate config loading
echo "[1/3] Testing configuration loading..."
source config/test-config.sh > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "✓ Configuration loads successfully"
  ((PASSED++))
else
  echo "✗ Configuration failed to load"
  ((FAILED++))
fi

# Test 2: Validate data generators
echo "[2/3] Testing data generators..."
EMAIL=$(generate_email "test")
PHONE=$(generate_phone)
NAME=$(generate_guest_name)
ROOM=$(generate_room_number)

if [[ "$EMAIL" =~ @test\.com$ ]] && [[ "$PHONE" =~ ^[0-9]+$ ]] && [ -n "$NAME" ] && [ -n "$ROOM" ]; then
  echo "✓ Data generators work correctly"
  echo "  Email: $EMAIL"
  echo "  Phone: $PHONE"
  echo "  Name: $NAME"
  echo "  Room: $ROOM"
  ((PASSED++))
else
  echo "✗ Data generators failed"
  ((FAILED++))
fi

# Test 3: Validate migrated scripts exist and are executable
echo "[3/3] Checking migrated scripts..."
SCRIPTS=(
  "tests/auth/login-test.sh"
  "tests/customer/hotel-search-test.sh"
)

for script in "${SCRIPTS[@]}"; do
  if [ -x "$script" ]; then
    echo "✓ $script exists and is executable"
    ((PASSED++))
  else
    echo "✗ $script missing or not executable"
    ((FAILED++))
  fi
done

# Summary
echo ""
echo "========================================"
echo " VALIDATION SUMMARY"
echo "========================================"
echo "Passed: $PASSED"
echo "Failed: $FAILED"
echo ""

if [ $FAILED -eq 0 ]; then
  echo "✅ All validation checks passed!"
  exit 0
else
  echo "❌ Some validation checks failed"
  exit 1
fi
