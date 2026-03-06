# Hotel Automation - Quick Start Guide

## 🚀 Get Started in 3 Steps

### 1. Start Services
```bash
# Terminal 1 - Backend
cd hostel-backend
npm run start:dev

# Terminal 2 - Frontend  
cd hostel-frontend
npm run dev
```

### 2. Run Tests
```bash
cd hotel-automation
bash run-production-tests.sh
```

### 3. View Results
```bash
# Open HTML report
xdg-open test-results/production-test-report-*.html

# Or view text report
cat test-results/production-test-report-*.txt
```

## 📊 Current Status

✅ **100% Pass Rate** (6/6 tests)  
⏱️ **5m 38s** execution time  
🎯 **Production Ready**

## 🧪 Available Test Suites

### Production Suite (Recommended)
```bash
bash run-production-tests.sh
```
- 6 critical tests
- Automatic retries
- HTML reports
- Browser cleanup

### Critical Tests Only
```bash
bash run-critical-tests.sh
```
- 5 core tests
- Faster execution
- No retries

### All Tests
```bash
bash run-all-tests.sh
```
- 10+ tests
- Full coverage
- Longer runtime

### Individual Tests
```bash
# Login
bash frontend-tests/tests/auth/login-test-improved.sh

# Hotel Search
bash frontend-tests/tests/customer/hotel-search-test.sh

# Add Rooms
bash frontend-tests/add-rooms-to-property.sh
```

## 🔧 Troubleshooting

### Services Not Running
```bash
# Check status
curl http://localhost:3001  # Frontend
curl http://localhost:3000  # Backend

# Restart if needed
# (See step 1 above)
```

### Tests Failing
```bash
# Run diagnostics
bash test-diagnostics.sh

# Check for zombie processes
pkill -f agent-browser

# Clean up old results
rm -rf frontend-results/screenshots/*
rm -rf frontend-results/snapshots/*
```

### Browser Issues
```bash
# Kill all browser processes
pkill -f agent-browser
pkill -f chrome
pkill -f chromium

# Verify agent-browser
ls -lh node_modules/agent-browser/bin/
```

## 📁 Important Files

| File | Purpose |
|------|---------|
| `run-production-tests.sh` | Main test runner (use this!) |
| `test-diagnostics.sh` | System health check |
| `FINAL_STATUS.md` | Complete status report |
| `PRODUCTION_READINESS_REPORT.md` | Detailed analysis |

## 🎯 Test Coverage

- ✅ Login & Authentication
- ✅ Property Onboarding
- ✅ Room Management
- ✅ Booking Lifecycle
- ✅ Payment Recording
- ✅ Rate Plans

## 💡 Pro Tips

1. **Always run diagnostics first** if tests fail
2. **Check HTML reports** for visual results
3. **Use production suite** for reliable results
4. **Clean up between runs** if issues occur
5. **Wait 3-5 seconds** between manual test runs

## 📞 Need Help?

1. Run diagnostics: `bash test-diagnostics.sh`
2. Check logs: `ls -lh test-results/`
3. View screenshots: `ls -lh frontend-results/screenshots/`
4. Read reports: `FINAL_STATUS.md` and `PRODUCTION_READINESS_REPORT.md`

---

**Last Updated:** March 6, 2026  
**Status:** ✅ Production Ready  
**Pass Rate:** 100%
