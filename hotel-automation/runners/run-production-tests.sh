#!/bin/bash

###############################################################################
# PRODUCTION TEST RUNNER
# Enhanced version with retry logic and better error handling
###############################################################################

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

# Test results
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
RETRIED_TESTS=0
START_TIME=$(date +%s)
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create results directory
RESULTS_DIR="./test-results"
mkdir -p "$RESULTS_DIR"
REPORT_FILE="$RESULTS_DIR/production-test-report-${TIMESTAMP}.txt"
REPORT_HTML="$RESULTS_DIR/production-test-report-${TIMESTAMP}.html"

# Production-critical tests
TESTS=(
  "Login Flow|frontend-tests/tests/auth/login-test-improved.sh|Owner authentication"
  "Property Onboarding|frontend-tests/property-onboarding-new-user.sh|Register + Create Property"
  "Add Rooms|frontend-tests/add-rooms-to-property.sh|Room type + Room creation"
  "Owner Booking Management|frontend-tests/owner-booking-management.sh|Full booking lifecycle"
  "Payment Recording|frontend-tests/payment-recording.sh|Revenue tracking"
  "Rate Plan Management|frontend-tests/rate-plan-management.sh|Pricing strategies"
)

print_color() {
  local color=$1
  shift
  echo -e "${color}$@${NC}"
}

cleanup_browser() {
  pkill -f agent-browser 2>/dev/null || true
  sleep 1
}

run_test() {
  local test_name=$1
  local test_script=$2
  local test_desc=$3
  local retry=${4:-false}
  
  TOTAL_TESTS=$((TOTAL_TESTS + 1))
  
  if [ "$retry" = "true" ]; then
    echo ""
    print_color "$YELLOW" "  🔄 RETRY: $test_name"
  else
    echo ""
    print_color "$CYAN" "[$TOTAL_TESTS/${#TESTS[@]}] $test_name"
    print_color "$NC" "    Description: $test_desc"
  fi
  
  local test_start=$(date +%s)
  
  # Cleanup before test
  cleanup_browser
  
  # Run the test
  local test_output=$(bash "$test_script" 2>&1)
  local test_exit_code=$?
  
  local test_end=$(date +%s)
  local test_duration=$((test_end - test_start))
  
  if [ $test_exit_code -eq 0 ]; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
    print_color "$GREEN" "    ✅ PASSED (${test_duration}s)"
    
    # Log to report
    echo "✅ PASS | $test_name | ${test_duration}s | $test_desc" >> "$REPORT_FILE"
    
    # Cleanup after test
    cleanup_browser
    sleep 3
    
    return 0
  else
    # Test failed - try retry if not already retrying
    if [ "$retry" != "true" ]; then
      print_color "$YELLOW" "    ⚠️  FAILED (${test_duration}s) - Will retry..."
      
      # Wait before retry
      sleep 5
      
      # Retry the test
      RETRIED_TESTS=$((RETRIED_TESTS + 1))
      if run_test "$test_name" "$test_script" "$test_desc" "true"; then
        return 0
      fi
    fi
    
    FAILED_TESTS=$((FAILED_TESTS + 1))
    print_color "$RED" "    ❌ FAILED (${test_duration}s)"
    
    # Log to report
    echo "❌ FAIL | $test_name | ${test_duration}s | $test_desc" >> "$REPORT_FILE"
    
    # Save failure details
    echo "$test_output" > "$RESULTS_DIR/failure-${test_name// /-}-${TIMESTAMP}.log"
    
    # Cleanup after failure
    cleanup_browser
    sleep 3
    
    return 1
  fi
}

# Main execution
clear
print_color "$CYAN$BOLD" "========================================="
print_color "$CYAN$BOLD" " PRODUCTION TEST SUITE"
print_color "$CYAN$BOLD" "========================================="
echo ""

print_color "$CYAN" "Test Suite Information:"
echo "  • Total Tests: ${#TESTS[@]}"
echo "  • Timestamp: $(date '+%Y-%m-%d %H:%M:%S')"
echo "  • Report: $REPORT_FILE"
echo "  • HTML Report: $REPORT_HTML"
echo ""

# Initialize report file
echo "========================================" > "$REPORT_FILE"
echo " PRODUCTION TEST REPORT" >> "$REPORT_FILE"
echo " Generated: $(date '+%Y-%m-%d %H:%M:%S')" >> "$REPORT_FILE"
echo "========================================" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Pre-flight checks
print_color "$CYAN" "Pre-flight Checks:"
FRONTEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3001)
BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000)

if [ "$FRONTEND_STATUS" = "200" ]; then
  echo "  ✅ Frontend is running"
else
  print_color "$RED" "  ❌ Frontend is NOT running - tests will fail!"
fi

if [ "$BACKEND_STATUS" = "401" ] || [ "$BACKEND_STATUS" = "200" ]; then
  echo "  ✅ Backend is running"
else
  print_color "$RED" "  ❌ Backend is NOT running - tests will fail!"
fi

echo ""
print_color "$CYAN" "Starting test execution..."

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
print_color "$CYAN$BOLD" "========================================="
print_color "$CYAN$BOLD" " TEST SUITE RESULTS"
print_color "$CYAN$BOLD" "========================================="
echo ""

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
echo "  • Retried:        $RETRIED_TESTS"
echo "  • Success Rate:   $((PASSED_TESTS * 100 / TOTAL_TESTS))%"
echo "  • Total Time:     ${MINUTES}m ${SECONDS}s"

echo "" >> "$REPORT_FILE"
echo "Statistics:" >> "$REPORT_FILE"
echo "  • Total Tests:    $TOTAL_TESTS" >> "$REPORT_FILE"
echo "  • Passed:         $PASSED_TESTS" >> "$REPORT_FILE"
echo "  • Failed:         $FAILED_TESTS" >> "$REPORT_FILE"
echo "  • Retried:        $RETRIED_TESTS" >> "$REPORT_FILE"
echo "  • Success Rate:   $((PASSED_TESTS * 100 / TOTAL_TESTS))%" >> "$REPORT_FILE"
echo "  • Total Time:     ${MINUTES}m ${SECONDS}s" >> "$REPORT_FILE"

# Generate HTML report
cat > "$REPORT_HTML" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Production Test Report</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #333; border-bottom: 3px solid #4CAF50; padding-bottom: 10px; }
        .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 30px 0; }
        .stat-card { background: #f9f9f9; padding: 20px; border-radius: 6px; border-left: 4px solid #4CAF50; }
        .stat-card.failed { border-left-color: #f44336; }
        .stat-card h3 { margin: 0 0 10px 0; color: #666; font-size: 14px; }
        .stat-card .value { font-size: 32px; font-weight: bold; color: #333; }
        .test-results { margin-top: 30px; }
        .test-item { padding: 15px; margin: 10px 0; border-radius: 6px; background: #f9f9f9; }
        .test-item.passed { border-left: 4px solid #4CAF50; }
        .test-item.failed { border-left: 4px solid #f44336; }
        .test-name { font-weight: bold; font-size: 16px; }
        .test-desc { color: #666; font-size: 14px; margin-top: 5px; }
        .test-duration { float: right; color: #999; }
        .badge { display: inline-block; padding: 4px 12px; border-radius: 12px; font-size: 12px; font-weight: bold; }
        .badge.passed { background: #4CAF50; color: white; }
        .badge.failed { background: #f44336; color: white; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🧪 Production Test Report</h1>
        <p><strong>Generated:</strong> TIMESTAMP_PLACEHOLDER</p>
        
        <div class="stats">
            <div class="stat-card">
                <h3>Total Tests</h3>
                <div class="value">TOTAL_PLACEHOLDER</div>
            </div>
            <div class="stat-card">
                <h3>Passed</h3>
                <div class="value">PASSED_PLACEHOLDER</div>
            </div>
            <div class="stat-card failed">
                <h3>Failed</h3>
                <div class="value">FAILED_PLACEHOLDER</div>
            </div>
            <div class="stat-card">
                <h3>Success Rate</h3>
                <div class="value">SUCCESS_RATE_PLACEHOLDER%</div>
            </div>
            <div class="stat-card">
                <h3>Duration</h3>
                <div class="value">DURATION_PLACEHOLDER</div>
            </div>
            <div class="stat-card">
                <h3>Retries</h3>
                <div class="value">RETRIED_PLACEHOLDER</div>
            </div>
        </div>
        
        <div class="test-results">
            <h2>Test Results</h2>
            RESULTS_PLACEHOLDER
        </div>
    </div>
</body>
</html>
EOF

# Replace placeholders in HTML
sed -i "s/TIMESTAMP_PLACEHOLDER/$(date '+%Y-%m-%d %H:%M:%S')/g" "$REPORT_HTML"
sed -i "s/TOTAL_PLACEHOLDER/$TOTAL_TESTS/g" "$REPORT_HTML"
sed -i "s/PASSED_PLACEHOLDER/$PASSED_TESTS/g" "$REPORT_HTML"
sed -i "s/FAILED_PLACEHOLDER/$FAILED_TESTS/g" "$REPORT_HTML"
sed -i "s/SUCCESS_RATE_PLACEHOLDER/$((PASSED_TESTS * 100 / TOTAL_TESTS))/g" "$REPORT_HTML"
sed -i "s/DURATION_PLACEHOLDER/${MINUTES}m ${SECONDS}s/g" "$REPORT_HTML"
sed -i "s/RETRIED_PLACEHOLDER/$RETRIED_TESTS/g" "$REPORT_HTML"

# Generate test results HTML
RESULTS_HTML=""
while IFS='|' read -r status name duration desc; do
  status=$(echo "$status" | xargs)
  if [[ "$status" == "✅ PASS" ]]; then
    RESULTS_HTML+="<div class='test-item passed'><span class='badge passed'>PASSED</span> <span class='test-name'>$name</span><span class='test-duration'>$duration</span><div class='test-desc'>$desc</div></div>"
  else
    RESULTS_HTML+="<div class='test-item failed'><span class='badge failed'>FAILED</span> <span class='test-name'>$name</span><span class='test-duration'>$duration</span><div class='test-desc'>$desc</div></div>"
  fi
done < <(grep -E "^(✅|❌)" "$REPORT_FILE")

sed -i "s|RESULTS_PLACEHOLDER|$RESULTS_HTML|g" "$REPORT_HTML"

echo ""
print_color "$CYAN" "Reports generated:"
echo "  📄 Text: $REPORT_FILE"
echo "  🌐 HTML: $REPORT_HTML"
echo ""

# Exit with appropriate code
if [ $FAILED_TESTS -eq 0 ]; then
  print_color "$GREEN$BOLD" "========================================="
  print_color "$GREEN$BOLD" " ✅ TEST SUITE PASSED"
  print_color "$GREEN$BOLD" "========================================="
  echo ""
  exit 0
else
  print_color "$RED$BOLD" "========================================="
  print_color "$RED$BOLD" " ❌ TEST SUITE FAILED"
  print_color "$RED$BOLD" "========================================="
  echo ""
  print_color "$YELLOW" "Failed test logs saved in: $RESULTS_DIR/"
  echo ""
  exit 1
fi
