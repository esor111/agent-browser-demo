# Test Data Management - Quick Reference

## 🎯 Quick Start

### Run Tests with Different Environments
```bash
# Development (default)
./run-all-tests.sh

# Staging
TEST_ENV=staging ./run-all-tests.sh

# Production
TEST_ENV=prod ./run-all-tests.sh
```

### Create New Test Script
```bash
#!/bin/bash
# 1. Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../config/test-config.sh"

# 2. Use environment variables
AB="$AB_PATH"
# FRONTEND_URL, credentials, etc. already loaded

# 3. Generate dynamic data
EMAIL=$(generate_email "mytest")
PHONE=$(generate_phone)
NAME=$(generate_guest_name)
read CHECKIN CHECKOUT <<< $(generate_date_range 7 3)

# 4. Your test logic
$AB --headed open "$FRONTEND_URL"
```

---

## 📁 Folder Structure at a Glance

```
frontend-tests/
├── config/              # Configuration files
│   ├── test-config.sh   # Main loader (source this!)
│   └── environments/    # Environment-specific configs
│       ├── dev.env
│       ├── staging.env
│       └── prod.env
├── lib/                 # Shared utilities
│   ├── data-generators.sh  # Data generation functions
│   ├── test-helpers.sh     # Common utilities
│   └── browser-utils.sh    # Browser helpers
├── fixtures/            # Static test data
│   ├── users.json
│   ├── properties.json
│   └── bookings.json
└── tests/               # Test scripts (organized by feature)
    ├── auth/
    ├── booking/
    ├── property/
    ├── customer/
    └── management/
```

---

## 🔧 Data Generator Functions

```bash
# Email generation
generate_email "prefix"           # → prefix_20260306_143022@test.com

# Phone generation
generate_phone "984"              # → 9841234567

# Name generation
generate_guest_name "TestUser"   # → TestUser_143022

# Room number generation
generate_room_number             # → 143047

# Date generation
generate_future_date 7           # → 2026-03-13 (7 days from now)
generate_date_range 7 3          # → 2026-03-13 2026-03-16 (checkin checkout)

# Property code generation
generate_property_code "PROP"    # → PROP143022
```

---

## 🔑 Environment Variables

### Available in All Scripts (after sourcing config)

| Variable | Description | Example |
|----------|-------------|---------|
| `FRONTEND_URL` | Application URL | `http://localhost:3001` |
| `API_URL` | API endpoint | `http://localhost:3000` |
| `AB_PATH` | Agent browser path | `/path/to/agent-browser` |
| `OWNER_PHONE` | Owner credentials | `9800000001` |
| `OWNER_PASSWORD` | Owner password | `password123` |
| `CUSTOMER_PHONE` | Customer credentials | `9841234567` |
| `CUSTOMER_PASSWORD` | Customer password | `password123` |
| `TIMEOUT_SHORT` | Short wait (ms) | `1000` |
| `TIMEOUT_MEDIUM` | Medium wait (ms) | `3000` |
| `TIMEOUT_LONG` | Long wait (ms) | `5000` |
| `OUTPUT_DIR` | Results directory | `./frontend-results` |
| `TIMESTAMP` | Current timestamp | `20260306_143022` |
| `TEST_EMAIL_DOMAIN` | Email domain | `test.com` |
| `TEST_NAME_PREFIX` | Name prefix | `AutoTest` |

---

## 📝 Migration Checklist

### For Each Script:

- [ ] Backup original: `cp script.sh script.sh.backup`
- [ ] Move to appropriate category folder
- [ ] Add config sourcing at top
- [ ] Replace hardcoded values with variables
- [ ] Replace static data with generators
- [ ] Update relative paths
- [ ] Test original vs migrated
- [ ] Run 3 times for consistency
- [ ] Test concurrent execution (if applicable)
- [ ] Update test runner
- [ ] Document any issues

---

## 🚨 Common Issues & Quick Fixes

### Issue: "Config file not found"
```bash
# Fix: Check your path to config
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../config/test-config.sh"  # Adjust ../../ based on depth
```

### Issue: "Variable not set"
```bash
# Fix: Make sure config is sourced before using variables
source config/test-config.sh
echo $FRONTEND_URL  # Now it works
```

### Issue: "Data conflicts in concurrent runs"
```bash
# Fix: Use data generators instead of static values
# BAD:
EMAIL="test@example.com"

# GOOD:
EMAIL=$(generate_email "test")
```

### Issue: "Screenshots not saving"
```bash
# Fix: Use OUTPUT_DIR from config
$AB screenshot "$OUTPUT_DIR/screenshots/my_screenshot_${TIMESTAMP}.png"
```

---

## 🎯 Migration Priority Order

### ✅ Tier 1: Simple (Week 2)
1. login-test.sh
2. login-working.sh
3. login-debug.sh
4. hotel-search-test.sh
5. guest-selector-test.sh
6. date-picker-test.sh

### ✅ Tier 2: Moderate (Week 3)
7. customer-filters.sh
8. dashboard-analytics.sh
9. guest-management.sh
10. booking-cancellation.sh
11. add-rooms-to-property.sh

### ✅ Tier 3: Complex (Week 4)
12. booking-flow-test.sh
13. payment-recording.sh
14. rate-plan-management.sh
15. owner-booking-management.sh
16. complete-booking-flow.sh

### ✅ Tier 4: Very Complex (Week 5)
17-21. property-onboarding-*.sh (5 variants)

---

## 🧪 Testing Commands

```bash
# Test single script
./tests/auth/login-test.sh

# Test with specific environment
TEST_ENV=staging ./tests/auth/login-test.sh

# Test concurrent execution
for i in {1..3}; do ./tests/booking/booking-flow-test.sh & done; wait

# Validate configuration
./validate-config.sh

# Cleanup test data
./cleanup-test-data.sh
```

---

## 📚 Additional Resources

- **Full Plan:** `TEST_DATA_MANAGEMENT_PLAN.md`
- **Migration Guide:** `README-MIGRATION.md` (to be created)
- **Config Reference:** `config/README.md` (to be created)
- **API Documentation:** `lib/README.md` (to be created)

---

**Quick Reference Version: 1.0**  
*Last Updated: 2026-03-06*
