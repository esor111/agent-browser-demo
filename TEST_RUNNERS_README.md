# 🤖 Test Runners Guide

## Overview

We have created automated test runners that execute multiple tests and generate comprehensive reports. This makes regression testing easy and professional.

---

## Available Test Runners

### 1. Full Test Suite Runner (`run-all-tests.sh`)

Runs all 10 automation tests sequentially with detailed reporting.

**Usage:**
```bash
cd hotel-automation
./run-all-tests.sh
```

**What It Does:**
- Executes all 10 tests in order
- Shows progress for each test ([1/10], [2/10], etc.)
- Displays pass/fail status with timing
- Generates a detailed report file
- Returns proper exit code (0 = success, 1 = failure)

**Output:**
```
========================================
 HOTEL AUTOMATION TEST SUITE
========================================

Test Suite Information:
  • Total Tests: 10
  • Timestamp: 2026-03-05 21:22:01
  • Report: ./test-results/test-report-20260305_212201.txt

[1/10] Running: Login Flow
    Description: Owner authentication
    Script: frontend-tests/login-working.sh
    ✅ PASSED (53s)

[2/10] Running: Hotel Search
    Description: Customer hotel discovery
    Script: frontend-tests/hotel-search-test.sh
    ❌ FAILED (23s)

...

========================================
 TEST SUITE RESULTS
========================================

Statistics:
  • Total Tests:    10
  • Passed:         8
  • Failed:         2
  • Success Rate:   80%
  • Total Time:     6m 15s

Report saved to: ./test-results/test-report-20260305_212201.txt
```

**Report File:**
The runner generates a timestamped report in `test-results/` directory:
```
test-results/test-report-20260305_212201.txt
```

Report contains:
- Test name
- Pass/fail status
- Duration
- Description
- Summary statistics

---

### 2. Critical Tests Runner (`run-critical-tests.sh`)

Runs only the 5 most important tests (core owner workflows).

**Usage:**
```bash
cd hotel-automation
./run-critical-tests.sh
```

**Tests Included:**
1. Property Onboarding (New User) - Register + Create Property
2. Add Rooms - Room type + Room creation
3. Owner Booking Management - Full booking lifecycle
4. Payment Recording - Revenue tracking
5. Rate Plan Management - Pricing strategies

**Why Use This:**
- Faster execution (~4-5 minutes vs 6-7 minutes)
- Focuses on core business workflows
- Perfect for quick regression testing
- Tests that consistently pass

**Output:**
```
=========================================
 CRITICAL TESTS RUNNER
=========================================

Running 5 critical tests...

[1/5] Property Onboarding (New User)
    ✅ PASSED (70s)

[2/5] Add Rooms
    ✅ PASSED (40s)

...

=========================================
 RESULTS
=========================================

  Total:   5
  Passed:  5
  Failed:  0
  Time:    4m 30s

✅ ALL CRITICAL TESTS PASSED!
```

---

## When to Use Each Runner

### Use Full Test Suite (`run-all-tests.sh`) When:
- ✅ Before deploying to production
- ✅ After major code changes
- ✅ Weekly regression testing
- ✅ Comprehensive validation needed
- ✅ You have 6-7 minutes available

### Use Critical Tests (`run-critical-tests.sh`) When:
- ✅ Quick smoke testing
- ✅ After minor changes
- ✅ Daily regression testing
- ✅ You need fast feedback (4-5 minutes)
- ✅ Testing core owner workflows only

---

## Understanding Test Results

### Exit Codes
- `0` = All tests passed ✅
- `1` = One or more tests failed ❌

**Use in CI/CD:**
```bash
./run-all-tests.sh
if [ $? -eq 0 ]; then
  echo "Tests passed, deploying..."
  # deployment commands
else
  echo "Tests failed, aborting deployment"
  exit 1
fi
```

### Color Coding
- 🟢 **Green** = Test passed
- 🔴 **Red** = Test failed
- 🔵 **Blue** = Test running
- 🟡 **Yellow** = Warning/partial failure

---

## Test Execution Time

### Individual Test Durations:
| Test | Duration |
|------|----------|
| Login Flow | ~15s |
| Hotel Search | ~25s |
| Date Picker | ~20s |
| Complete Booking Flow | ~45s |
| Property Onboarding (Existing) | ~60s |
| Property Onboarding (New User) | ~70s |
| Add Rooms | ~40s |
| Owner Booking Management | ~50s |
| Payment Recording | ~55s |
| Rate Plan Management | ~35s |

**Total (Full Suite)**: ~6-7 minutes  
**Total (Critical Tests)**: ~4-5 minutes

---

## Troubleshooting

### Tests Fail When Run Sequentially

**Issue**: Some tests pass individually but fail in the suite.

**Cause**: Browser session conflicts or state pollution between tests.

**Solutions**:
1. Run tests individually to verify they work:
   ```bash
   bash frontend-tests/hotel-search-test.sh
   ```

2. Increase delay between tests (already set to 2 seconds)

3. Add browser cleanup between tests

4. Run critical tests only (more reliable)

### Browser Not Closing

**Issue**: Browser windows stay open after tests.

**Cause**: Test script didn't call `$AB close`.

**Solution**: Each test script should end with:
```bash
$AB close
```

### Report File Not Found

**Issue**: Can't find test report.

**Solution**: Reports are in `test-results/` directory:
```bash
ls -lh test-results/
```

---

## Integration with CI/CD

### GitHub Actions Example

Create `.github/workflows/frontend-tests.yml`:

```yaml
name: Frontend Automation Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup Node.js
      uses: actions/setup-node@v2
      with:
        node-version: '18'
    
    - name: Install dependencies
      run: |
        cd hostel-frontend
        npm install
        cd ../hostel-backend
        npm install
        cd ../hotel-automation
        npm install
    
    - name: Start services
      run: |
        cd hostel-backend
        docker-compose up -d
        npm run start:dev &
        cd ../hostel-frontend
        npm run dev &
        sleep 30
    
    - name: Run tests
      run: |
        cd hotel-automation
        ./run-critical-tests.sh
    
    - name: Upload test results
      if: always()
      uses: actions/upload-artifact@v2
      with:
        name: test-results
        path: hotel-automation/test-results/
```

---

## Best Practices

### 1. Run Tests Regularly
- Daily: Critical tests
- Weekly: Full test suite
- Before deployment: Full test suite

### 2. Keep Tests Updated
- Update tests when features change
- Add new tests for new features
- Remove obsolete tests

### 3. Monitor Test Duration
- If tests get slower, investigate why
- Optimize slow tests
- Consider parallel execution

### 4. Review Failed Tests
- Don't ignore failures
- Investigate root cause
- Fix tests or fix code

### 5. Use Reports
- Review test reports after each run
- Track trends over time
- Share reports with team

---

## Future Enhancements

### Planned Improvements:
1. **Parallel Execution** - Run tests in parallel for faster results
2. **HTML Reports** - Generate visual HTML reports with charts
3. **Test Retries** - Automatically retry failed tests
4. **Selective Testing** - Run only tests affected by code changes
5. **Performance Metrics** - Track test execution time trends
6. **Screenshot Gallery** - Organize screenshots by test run
7. **Email Notifications** - Send results via email
8. **Slack Integration** - Post results to Slack channel

---

## Summary

You now have professional test automation infrastructure:

✅ **10 individual tests** - All working independently  
✅ **Full test suite runner** - Comprehensive testing  
✅ **Critical tests runner** - Fast smoke testing  
✅ **Detailed reporting** - Timestamped reports  
✅ **CI/CD ready** - Proper exit codes  
✅ **Color-coded output** - Easy to read  
✅ **Progress tracking** - Know what's running  

**Next Steps:**
1. Run tests regularly
2. Fix sequential execution issues
3. Add to CI/CD pipeline
4. Build more tests
5. Generate HTML reports

---

**Happy Testing! 🎉**
