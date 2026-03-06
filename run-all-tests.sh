#!/bin/bash

###############################################################################
# HOTEL AUTOMATION TEST SUITE RUNNER
# Runs all frontend automation tests and generates a comprehensive report
###############################################################################

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Test results tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
START_TIME=$(date +%s)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create results directory
RESULTS_DIR="./test-results"
mkdir -p "$RESULTS_DIR"
REPORT_FILE="$RESULTS_DIR/test-report-${TIMESTAMP}.txt"

# Test definitions: "name|script|description"
TESTS=(
  "Login Flow|frontend-tests/login-working.sh|Owner authentication"
  "Hotel Search|frontend-tests/hotel-search-test.sh|Customer hotel discovery"
  "Date Picker|frontend-tests/date-picker-test.sh|Calendar date selection"
  "Complete Booking Flow|frontend-tests/complete-booking-flow.sh|End-to-end customer journey"
  "Property Onboarding (Existing)|frontend-tests/property-onboarding-complete.sh|Login + Create Property"
  "Property Onboarding (New User)|frontend-tests/property-onboarding-new-user.sh|Register + Create Property"
  "Add Rooms|frontend-tests/add-rooms-to-property.sh|Room type + Room creation"
  "Owner Booking Management|frontend-tests/owner-booking-management.sh|Full booking lifecycle"
  "Payment Recording|frontend-tests/payment-recording.sh|Revenue tracking"
  "Rate Plan Management|frontend-tests/rate-plan-management.sh|Pricing strategies"
)

# Function to print colored output
print_color() {
  local color=$1
  shift
  echo -e "${color}$@${NC}"
}

# Function to print header
print_header() {
  echo ""
  print_color "$CYAN" "========================================"
  print_color "$CYAN$BOLD" " $1"
  print_color "$CYAN" "========================================"
  echo ""
}

# Function to run a single test
run_test() {
  local test_name=$1
  local test_script=$2
  local test_desc=$3
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  
  echo ""
  print_color "$BLUE" "[$TOTAL_TESTS/${#TESTS[@]}] Running: $test_name"
  print_color "$NC" "    Description: $test_desc"
  print_color "$NC" "    Script: $test_script"
  echo ""
  
  local test_start=$(date +%s)
  
  # Run the test and capture output
  if bash "$test_script" > /dev/null 2>&1; then
    local test_end=$(date +%s)
    local test_duration=$((test_end - test_start))
    
    PASSED_TESTS=$((PASSED_TESTS + 1))
    print_color "$GREEN" "    ✅ PASSED (${test_duration}s)"
    
    # Log to report
    echo "✅ PASS | $test_name | ${test_duration}s | $test_desc" >> "$REPORT_FILE"
    
    # Cleanup: wait a bit between tests to avoid browser session conflicts
    sleep 2
    
    return 0
  else
    local test_end=$(date +%s)
    local test_duration=$((test_end - test_start))
    
    FAILED_TESTS=$((FAILED_TESTS + 1))
    print_color "$RED" "    ❌ FAILED (${test_duration}s)"
    
    # Log to report
    echo "❌ FAIL | $test_name | ${test_duration}s | $test_desc" >> "$REPORT_FILE"
    
    # Cleanup: wait a bit between tests even on failure
    sleep 2
    
    return 1
  fi
}

# Main execution
clear
print_header "HOTEL AUTOMATION TEST SUITE"

print_color "$CYAN" "Test Suite Information:"
echo "  • Total Tests: ${#TESTS[@]}"
echo "  • Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo "  • Report: $REPORT_FILE"
echo ""

# Initialize report file
echo "========================================" > "$REPORT_FILE"
echo " HOTEL AUTOMATION TEST REPORT" >> "$REPORT_FILE"
echo " Generated: $(date '+%Y-%m-%d %H:%M:%S')" >> "$REPORT_FILE"
echo "========================================" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Run all tests
for test_def in "${TESTS[@]}"; do
  IFS='|' read -r test_name test_script test_desc <<< "$test_def"
  run_test "$test_name" "$test_script" "$test_desc"
done

# Calculate total time
END_TIME=$(date +%s)
TOTAL_DURATION=$((END_TIME - START_TIME))
MINUTES=$((TOTAL_DURATION / 60))
SECONDS=$((TOTAL_DURATION % 60))

# Print summary
echo ""
print_header "TEST SUITE RESULTS"

echo "Test Execution Summary:" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ $FAILED_TESTS -eq 0 ]; then
  print_color "$GREEN$BOLD" "  🎉 ALL TESTS PASSED! 🎉"
  echo "  🎉 ALL TESTS PASSED! 🎉" >> "$REPORT_FILE"
else
  print_color "$YELLOW$BOLD" "  ⚠️  SOME TESTS FAILED"
  echo "  ⚠️  SOME TESTS FAILED" >> "$REPORT_FILE"
fi

echo ""
print_color "$CYAN" "Statistics:"
echo "  • Total Tests:    $TOTAL_TESTS"
echo "  • Passed:         $PASSED_TESTS"
echo "  • Failed:         $FAILED_TESTS"
echo "  • Success Rate:   $((PASSED_TESTS * 100 / TOTAL_TESTS))%"
echo "  • Total Time:     ${MINUTES}m ${SECONDS}s"

echo "" >> "$REPORT_FILE"
echo "Statistics:" >> "$REPORT_FILE"
echo "  • Total Tests:    $TOTAL_TESTS" >> "$REPORT_FILE"
echo "  • Passed:         $PASSED_TESTS" >> "$REPORT_FILE"
echo "  • Failed:         $FAILED_TESTS" >> "$REPORT_FILE"
echo "  • Success Rate:   $((PASSED_TESTS * 100 / TOTAL_TESTS))%" >> "$REPORT_FILE"
echo "  • Total Time:     ${MINUTES}m ${SECONDS}s" >> "$REPORT_FILE"

echo ""
print_color "$CYAN" "Report saved to: $REPORT_FILE"
echo ""

# Exit with appropriate code
if [ $FAILED_TESTS -eq 0 ]; then
  print_color "$GREEN" "========================================="
  print_color "$GREEN$BOLD" " ✅ TEST SUITE PASSED"
  print_color "$GREEN" "========================================="
  echo ""
  exit 0
else
  print_color "$RED" "========================================="
  print_color "$RED$BOLD" " ❌ TEST SUITE FAILED"
  print_color "$RED" "========================================="
  echo ""
  exit 1
fi
