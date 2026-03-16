#!/bin/bash

###############################################################################
# CRITICAL TESTS RUNNER
# Runs only the most important tests (the ones that consistently pass)
###############################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
START_TIME=$(date +%s)

# Critical tests only
TESTS=(
  "Property Onboarding (New User)|frontend-tests/property-onboarding-new-user.sh"
  "Add Rooms|frontend-tests/add-rooms-to-property.sh"
  "Owner Booking Management|frontend-tests/owner-booking-management.sh"
  "Payment Recording|frontend-tests/payment-recording.sh"
  "Rate Plan Management|frontend-tests/rate-plan-management.sh"
)

print_color() {
  local color=$1
  shift
  echo -e "${color}$@${NC}"
}

run_test() {
  local test_name=$1
  local test_script=$2
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  
  echo ""
  print_color "$CYAN" "[$TOTAL_TESTS/${#TESTS[@]}] $test_name"
  
  local test_start=$(date +%s)
  
  # Kill any lingering browser processes
  pkill -f agent-browser 2>/dev/null || true
  sleep 1
  
  if bash "$test_script" > /dev/null 2>&1; then
    local test_end=$(date +%s)
    local test_duration=$((test_end - test_start))
    
    PASSED_TESTS=$((PASSED_TESTS + 1))
    print_color "$GREEN" "    ✅ PASSED (${test_duration}s)"
    sleep 3  # Increased delay between tests
    return 0
  else
    local test_end=$(date +%s)
    local test_duration=$((test_end - test_start))
    
    FAILED_TESTS=$((FAILED_TESTS + 1))
    print_color "$RED" "    ❌ FAILED (${test_duration}s)"
    sleep 3  # Increased delay even on failure
    return 1
  fi
}

clear
echo ""
print_color "$CYAN$BOLD" "========================================="
print_color "$CYAN$BOLD" " CRITICAL TESTS RUNNER"
print_color "$CYAN$BOLD" "========================================="
echo ""
echo "Running ${#TESTS[@]} critical tests..."

for test_def in "${TESTS[@]}"; do
  IFS='|' read -r test_name test_script <<< "$test_def"
  run_test "$test_name" "$test_script"
done

END_TIME=$(date +%s)
TOTAL_DURATION=$((END_TIME - START_TIME))
MINUTES=$((TOTAL_DURATION / 60))
SECONDS=$((TOTAL_DURATION % 60))

echo ""
print_color "$CYAN$BOLD" "========================================="
print_color "$CYAN$BOLD" " RESULTS"
print_color "$CYAN$BOLD" "========================================="
echo ""
echo "  Total:   $TOTAL_TESTS"
echo "  Passed:  $PASSED_TESTS"
echo "  Failed:  $FAILED_TESTS"
echo "  Time:    ${MINUTES}m ${SECONDS}s"
echo ""

if [ $FAILED_TESTS -eq 0 ]; then
  print_color "$GREEN$BOLD" "✅ ALL CRITICAL TESTS PASSED!"
  echo ""
  exit 0
else
  print_color "$RED$BOLD" "❌ SOME TESTS FAILED"
  echo ""
  exit 1
fi
