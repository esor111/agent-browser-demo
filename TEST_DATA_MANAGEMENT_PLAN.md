# Test Data Management Implementation Plan

## Executive Summary

This plan outlines a phased approach to externalize hardcoded test data from 21 bash automation scripts into a centralized, maintainable configuration system. The implementation follows industry best practices for test automation data management while maintaining backward compatibility.

**Current State:**
- 21 test scripts with hardcoded data (credentials, emails, dates, room numbers)
- Data conflicts when running tests concurrently
- Difficult to maintain and update test data
- No environment-specific configurations

**Target State:**
- Centralized test data configuration
- Dynamic data generation to avoid conflicts
- Environment-specific configs (dev, staging, prod)
- Reusable data generators and utilities
- Backward compatible during migration

---

## 1. Recommended Folder Structure

Based on industry best practices for test automation projects, here's the proposed structure:

```
hotel-automation/
├── frontend-tests/
│   ├── tests/                          # Test scripts (organized by feature)
│   │   ├── auth/
│   │   │   ├── login-test.sh
│   │   │   └── login-working.sh
│   │   ├── booking/
│   │   │   ├── booking-flow-test.sh
│   │   │   ├── booking-cancellation.sh
│   │   │   └── complete-booking-flow.sh
│   │   ├── property/
│   │   │   ├── property-onboarding-complete.sh
│   │   │   ├── add-rooms-to-property.sh
│   │   │   └── rate-plan-management.sh
│   │   ├── customer/
│   │   │   ├── hotel-search-test.sh
│   │   │   ├── customer-filters.sh
│   │   │   └── date-picker-test.sh
│   │   └── management/
│   │       ├── guest-management.sh
│   │       ├── owner-booking-management.sh
│   │       ├── payment-recording.sh
│   │       └── dashboard-analytics.sh
│   │
│   ├── config/                         # Configuration files
│   │   ├── environments/
│   │   │   ├── dev.env                # Development environment
│   │   │   ├── staging.env            # Staging environment
│   │   │   └── prod.env               # Production environment
│   │   ├── test-data.json             # Shared test data (static)
│   │   └── test-config.sh             # Main config loader
│   │
│   ├── lib/                            # Shared utilities and libraries
│   │   ├── data-generators.sh         # Dynamic data generation functions
│   │   ├── test-helpers.sh            # Common test utilities
│   │   ├── assertions.sh              # Assertion functions
│   │   └── browser-utils.sh           # Browser automation helpers
│   │
│   ├── fixtures/                       # Test fixtures and sample data
│   │   ├── users.json                 # User test data
│   │   ├── properties.json            # Property test data
│   │   └── bookings.json              # Booking test data
│   │
│   └── frontend-results/               # Test results (existing)
│       ├── screenshots/
│       └── snapshots/
│
├── run-all-tests.sh                    # Test runner (existing)
└── run-critical-tests.sh               # Critical tests runner (existing)
```

### Key Design Decisions:

1. **Feature-based organization**: Tests grouped by feature area (auth, booking, property, etc.)
2. **Separation of concerns**: Config, libraries, fixtures, and tests are separate
3. **Environment configs**: Support for multiple environments (dev/staging/prod)
4. **Reusable libraries**: Shared utilities to reduce code duplication
5. **JSON for complex data**: Easy to parse and maintain structured data
6. **Shell scripts for simple config**: Native bash sourcing for simple key-value pairs

---

## 2. Data Management Strategy

### 2.1 Types of Test Data

| Data Type | Storage Method | Example | Rationale |
|-----------|---------------|---------|-----------|
| **Static Credentials** | Environment files (.env) | Owner login, API keys | Secure, environment-specific |
| **Dynamic Data** | Generated at runtime | Emails, timestamps, room numbers | Avoid conflicts, unique per run |
| **Reference Data** | JSON fixtures | Property types, room categories | Reusable, structured |
| **Configuration** | Shell config files | URLs, timeouts, paths | Easy to source in bash |

### 2.2 Data Generation Patterns

**Timestamp-based uniqueness:**
```bash
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
EMAIL="test_${TIMESTAMP}@example.com"
ROOM_NUMBER="${TIMESTAMP:8:4}$(shuf -i 10-99 -n 1)"  # HHMM + random
```

**UUID-based uniqueness:**
```bash
UUID=$(uuidgen | cut -d'-' -f1)
GUEST_NAME="Guest_${UUID}"
```

**Sequential numbering:**
```bash
COUNTER_FILE="/tmp/test_counter"
COUNTER=$(($(cat $COUNTER_FILE 2>/dev/null || echo 0) + 1))
echo $COUNTER > $COUNTER_FILE
```

---

## 3. Step-by-Step Implementation Plan

### Phase 1: Foundation Setup (Week 1)

**Goal:** Create infrastructure without breaking existing tests

#### Step 1.1: Create Directory Structure
```bash
cd hotel-automation/frontend-tests
mkdir -p config/environments lib fixtures tests/{auth,booking,property,customer,management}
```

**Validation:** Directories exist, no tests broken

#### Step 1.2: Create Base Configuration Files

**File: `config/test-config.sh`**
```bash
#!/bin/bash
# Main configuration loader

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR"

# Load environment (default to dev)
TEST_ENV="${TEST_ENV:-dev}"
ENV_FILE="$CONFIG_DIR/environments/${TEST_ENV}.env"

if [ -f "$ENV_FILE" ]; then
    set -a  # Auto-export variables
    source "$ENV_FILE"
    set +a
    echo "✓ Loaded environment: $TEST_ENV"
else
    echo "⚠ Environment file not found: $ENV_FILE"
    exit 1
fi

# Load data generators
source "$SCRIPT_DIR/../lib/data-generators.sh"

# Export common paths
export OUTPUT_DIR="${OUTPUT_DIR:-./frontend-results}"
export TIMESTAMP=$(date +%Y%m%d_%H%M%S)
```

**File: `config/environments/dev.env`**
```bash
# Development Environment Configuration

# Application URLs
FRONTEND_URL=http://localhost:3001
API_URL=http://localhost:3000

# Browser Configuration
AB_PATH=/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64
BROWSER_HEADED=true

# Test Credentials (Owner)
OWNER_PHONE=9800000001
OWNER_PASSWORD=password123

# Test Credentials (Customer)
CUSTOMER_PHONE=9841234567
CUSTOMER_PASSWORD=password123

# Timeouts (milliseconds)
TIMEOUT_SHORT=1000
TIMEOUT_MEDIUM=3000
TIMEOUT_LONG=5000
TIMEOUT_LOAD=10000

# Test Data Prefixes
TEST_EMAIL_DOMAIN=test.com
TEST_NAME_PREFIX=AutoTest
```

**Validation:** 
- Source the config: `source config/test-config.sh`
- Verify variables: `echo $FRONTEND_URL`


#### Step 1.3: Create Data Generators Library

**File: `lib/data-generators.sh`**
```bash
#!/bin/bash
# Dynamic test data generators

# Generate unique email
generate_email() {
    local prefix="${1:-test}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    echo "${prefix}_${timestamp}@${TEST_EMAIL_DOMAIN:-test.com}"
}

# Generate unique phone number
generate_phone() {
    local prefix="${1:-984}"
    local random=$(shuf -i 1000000-9999999 -n 1)
    echo "${prefix}${random}"
}

# Generate unique guest name
generate_guest_name() {
    local prefix="${TEST_NAME_PREFIX:-Guest}"
    local timestamp=$(date +%H%M%S)
    echo "${prefix}_${timestamp}"
}

# Generate unique room number
generate_room_number() {
    local timestamp=$(date +%H%M)
    local random=$(shuf -i 10-99 -n 1)
    echo "${timestamp}${random}"
}

# Generate future date (days from now)
generate_future_date() {
    local days_ahead="${1:-7}"
    date -d "+${days_ahead} days" +%Y-%m-%d
}

# Generate date range
generate_date_range() {
    local start_days="${1:-7}"
    local duration="${2:-3}"
    local checkin=$(date -d "+${start_days} days" +%Y-%m-%d)
    local checkout=$(date -d "+$((start_days + duration)) days" +%Y-%m-%d)
    echo "$checkin $checkout"
}

# Generate unique property code
generate_property_code() {
    local prefix="${1:-PROP}"
    local timestamp=$(date +%H%M%S)
    echo "${prefix}${timestamp}"
}
```

**Validation:**
- Source the library: `source lib/data-generators.sh`
- Test functions: `generate_email "booking"` → `booking_20260306_143022@test.com`

---

### Phase 2: Pilot Migration (Week 2)

**Goal:** Migrate 2 simple scripts to validate approach

#### Scripts Selected for Pilot:
1. **login-test.sh** - Simplest, only uses credentials
2. **hotel-search-test.sh** - No data creation, read-only

#### Step 2.1: Migrate login-test.sh

**Changes:**
```bash
# OLD (hardcoded):
PHONE="9800000001"
PASSWORD="password123"
AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"

# NEW (from config):
source "$(dirname "$0")/../config/test-config.sh"
PHONE="$OWNER_PHONE"
PASSWORD="$OWNER_PASSWORD"
AB="$AB_PATH"
# FRONTEND_URL already loaded from config
```

**Testing Strategy:**
1. Run original script: `./login-test.sh` → Record results
2. Move to new location: `mv login-test.sh tests/auth/`
3. Update script with config sourcing
4. Run migrated script: `./tests/auth/login-test.sh` → Compare results
5. Verify screenshots match, exit codes match

**Rollback Plan:** Keep backup of original script until validated

#### Step 2.2: Migrate hotel-search-test.sh

**Changes:**
```bash
# OLD:
AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
OUTPUT_DIR="./frontend-results"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# NEW:
source "$(dirname "$0")/../config/test-config.sh"
# AB_PATH, FRONTEND_URL, OUTPUT_DIR, TIMESTAMP already loaded
AB="$AB_PATH"
```

**Testing Strategy:** Same as login-test.sh

**Success Criteria:**
- Both scripts run successfully from new location
- All tests pass with same results
- No hardcoded values remain
- Screenshots generated correctly

---

### Phase 3: Data Generation Migration (Week 3)

**Goal:** Migrate scripts that create data to use generators

#### Scripts for Phase 3 (in order of complexity):
1. **guest-selector-test.sh** - Simple UI interaction, no data creation
2. **date-picker-test.sh** - Simple UI interaction, no data creation
3. **booking-cancellation.sh** - Creates booking with hardcoded data
4. **add-rooms-to-property.sh** - Creates rooms with timestamp-based uniqueness

#### Step 3.1: Migrate booking-cancellation.sh

**Current Hardcoded Data:**
```bash
GUEST_NAME="Cancellation Test Guest"
GUEST_EMAIL="canceltest${TIMESTAMP}@test.com"
GUEST_PHONE="9841234567"
CHECKIN_DATE="2026-03-10"
CHECKOUT_DATE="2026-03-15"
ADULTS="2"
```

**New Dynamic Data:**
```bash
source "$(dirname "$0")/../config/test-config.sh"

# Generate unique guest data
GUEST_NAME=$(generate_guest_name "CancelTest")
GUEST_EMAIL=$(generate_email "cancel")
GUEST_PHONE=$(generate_phone)

# Generate future dates
read CHECKIN_DATE CHECKOUT_DATE <<< $(generate_date_range 7 5)
ADULTS="2"
```

**Testing:**
1. Run script 3 times concurrently
2. Verify no conflicts (unique emails, names)
3. Verify all bookings created successfully
4. Check database for unique records

#### Step 3.2: Migrate add-rooms-to-property.sh

**Current Data:**
```bash
ROOM_TYPE_CODE="STD${TIMESTAMP}"
ROOM_TYPE_NAME="Standard Room ${TIMESTAMP}"
ROOM_NUMBER="$(date +%H%M)$(shuf -i 10-99 -n 1)"
```

**New Dynamic Data:**
```bash
source "$(dirname "$0")/../config/test-config.sh"

ROOM_TYPE_CODE=$(generate_property_code "STD")
ROOM_TYPE_NAME="Standard Room $(date +%H%M%S)"
ROOM_NUMBER=$(generate_room_number)
```

**Success Criteria:**
- Scripts run concurrently without conflicts
- All data is unique per run
- Tests pass consistently
- No hardcoded dates or identifiers

---

### Phase 4: Complex Scripts Migration (Week 4)

**Goal:** Migrate remaining complex scripts

#### Scripts for Phase 4 (by complexity):
1. **customer-filters.sh** - Read-only, no data creation
2. **dashboard-analytics.sh** - Read-only, verification only
3. **guest-management.sh** - Search and view, minimal data
4. **payment-recording.sh** - Creates booking + payment
5. **owner-booking-management.sh** - Full booking lifecycle
6. **rate-plan-management.sh** - Creates rate plans
7. **property-onboarding-complete.sh** - Complex multi-step flow
8. **complete-booking-flow.sh** - End-to-end customer flow

#### Migration Pattern for Complex Scripts:

**Example: owner-booking-management.sh**

```bash
#!/bin/bash
# Source configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../config/test-config.sh"

# Generate test data
GUEST_NAME=$(generate_guest_name "Owner")
GUEST_EMAIL=$(generate_email "owner_booking")
GUEST_PHONE=$(generate_phone)
read CHECKIN_DATE CHECKOUT_DATE <<< $(generate_date_range 3 4)

# Use environment variables
AB="$AB_PATH"
# ... rest of script
```

**Testing Strategy for Each:**
1. Create backup of original
2. Migrate to new structure
3. Run original vs migrated side-by-side
4. Compare outputs (screenshots, logs, exit codes)
5. Run 3 times to verify consistency
6. Mark as complete when validated

---

### Phase 5: Test Runners Update (Week 5)

**Goal:** Update test runners to work with new structure

#### Step 5.1: Update run-all-tests.sh

**Changes:**
```bash
#!/bin/bash
# Load configuration
source "$(dirname "$0")/frontend-tests/config/test-config.sh"

# Run tests from new locations
echo "Running authentication tests..."
./frontend-tests/tests/auth/login-test.sh

echo "Running booking tests..."
./frontend-tests/tests/booking/booking-flow-test.sh
./frontend-tests/tests/booking/booking-cancellation.sh

# ... etc
```

#### Step 5.2: Create Environment-Specific Runners

**File: `run-tests-staging.sh`**
```bash
#!/bin/bash
export TEST_ENV=staging
./run-all-tests.sh
```

**File: `run-tests-prod.sh`**
```bash
#!/bin/bash
export TEST_ENV=prod
./run-all-tests.sh
```

---

## 4. Migration Order (Easiest to Hardest)

### Tier 1: Simple (No Data Creation) - Week 2
1. ✅ **login-test.sh** - Only credentials
2. ✅ **login-working.sh** - Only credentials
3. ✅ **login-debug.sh** - Only credentials
4. ✅ **hotel-search-test.sh** - Read-only
5. ✅ **guest-selector-test.sh** - UI interaction only
6. ✅ **date-picker-test.sh** - UI interaction only

**Effort:** 1-2 days | **Risk:** Low

### Tier 2: Moderate (Simple Data Creation) - Week 3
7. ✅ **customer-filters.sh** - Read-only with filters
8. ✅ **dashboard-analytics.sh** - Read-only verification
9. ✅ **guest-management.sh** - Search and view
10. ✅ **booking-cancellation.sh** - Creates one booking
11. ✅ **add-rooms-to-property.sh** - Creates room type + room

**Effort:** 3-4 days | **Risk:** Medium

### Tier 3: Complex (Multiple Data Dependencies) - Week 4
12. ✅ **booking-flow-test.sh** - Customer booking flow
13. ✅ **payment-recording.sh** - Booking + payment
14. ✅ **rate-plan-management.sh** - Rate plan creation
15. ✅ **owner-booking-management.sh** - Full lifecycle
16. ✅ **complete-booking-flow.sh** - End-to-end flow

**Effort:** 4-5 days | **Risk:** Medium-High

### Tier 4: Very Complex (Multi-Step Flows) - Week 5
17. ✅ **property-onboarding.sh** - Multi-step onboarding
18. ✅ **property-onboarding-working.sh** - Variant
19. ✅ **property-onboarding-complete.sh** - Full flow
20. ✅ **property-onboarding-final.sh** - Final version
21. ✅ **property-onboarding-new-user.sh** - New user flow

**Effort:** 5-6 days | **Risk:** High

---

## 5. Potential Issues & Solutions

### Issue 1: Path Resolution
**Problem:** Scripts moved to subdirectories, relative paths break

**Solution:**
```bash
# Get script directory dynamically
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../config/test-config.sh"
```

### Issue 2: Concurrent Test Conflicts
**Problem:** Multiple tests creating data with same identifiers

**Solution:**
- Use timestamp + random for uniqueness
- Add process ID: `${TIMESTAMP}_$$`
- Use UUID: `$(uuidgen | cut -d'-' -f1)`

### Issue 3: Environment Variable Conflicts
**Problem:** Variables from different tests overwriting each other

**Solution:**
- Use unique prefixes per test
- Unset variables after test
- Use subshells for isolation: `( source config; run_test )`

### Issue 4: Backward Compatibility
**Problem:** Existing scripts in root directory still need to work

**Solution:**
- Keep symlinks in root during migration
- Create wrapper scripts that call new locations
- Update gradually, one tier at a time

### Issue 5: Data Cleanup
**Problem:** Generated test data accumulates in database

**Solution:**
- Add cleanup functions to data-generators.sh
- Create cleanup script: `cleanup-test-data.sh`
- Use test data prefixes for easy identification
- Schedule periodic cleanup job

### Issue 6: Configuration Drift
**Problem:** Different environments get out of sync

**Solution:**
- Version control all config files
- Document required variables in README
- Add validation script to check config completeness
- Use template files: `dev.env.template`

---

## 6. Testing Strategy for Each Step

### Validation Checklist (Per Script)

```bash
# 1. Backup original
cp script.sh script.sh.backup

# 2. Run original and capture results
./script.sh > original_output.txt 2>&1
ORIGINAL_EXIT=$?

# 3. Migrate script
# ... make changes ...

# 4. Run migrated script
./tests/category/script.sh > migrated_output.txt 2>&1
MIGRATED_EXIT=$?

# 5. Compare results
echo "Exit codes: Original=$ORIGINAL_EXIT, Migrated=$MIGRATED_EXIT"
diff original_output.txt migrated_output.txt

# 6. Verify screenshots exist
ls -la frontend-results/screenshots/*$(date +%Y%m%d)*

# 7. Run 3 times for consistency
for i in 1 2 3; do
    ./tests/category/script.sh
    echo "Run $i: Exit code $?"
done

# 8. Test concurrent execution (if applicable)
./tests/category/script.sh &
./tests/category/script.sh &
./tests/category/script.sh &
wait
echo "All concurrent runs completed"
```

### Acceptance Criteria

✅ **Must Have:**
- Script runs successfully from new location
- Exit code matches original behavior
- All screenshots generated
- No hardcoded credentials or URLs
- Configuration loaded correctly

✅ **Should Have:**
- Dynamic data generation works
- Concurrent execution without conflicts
- Proper error handling
- Logging and debugging info

✅ **Nice to Have:**
- Performance same or better
- Code more readable
- Reusable functions extracted

---

## 7. Files to Create First

### Priority 1 (Foundation) - Day 1
1. `config/test-config.sh` - Main config loader
2. `config/environments/dev.env` - Development config
3. `lib/data-generators.sh` - Data generation functions
4. `README-MIGRATION.md` - Migration guide

### Priority 2 (Utilities) - Day 2
5. `lib/test-helpers.sh` - Common utilities
6. `lib/browser-utils.sh` - Browser helpers
7. `config/environments/staging.env` - Staging config
8. `validate-config.sh` - Config validation script

### Priority 3 (Fixtures) - Day 3
9. `fixtures/users.json` - User test data
10. `fixtures/properties.json` - Property data
11. `fixtures/bookings.json` - Booking templates
12. `cleanup-test-data.sh` - Cleanup script

---

## 8. Implementation Timeline

### Week 1: Foundation
- **Day 1-2:** Create directory structure and base config files
- **Day 3:** Create data generators library
- **Day 4:** Create test helpers and utilities
- **Day 5:** Documentation and validation scripts

**Deliverables:**
- Complete folder structure
- Working config system
- Data generators library
- Migration guide

### Week 2: Pilot Migration
- **Day 1:** Migrate Tier 1 auth scripts (3 scripts)
- **Day 2:** Migrate Tier 1 read-only scripts (3 scripts)
- **Day 3:** Testing and validation
- **Day 4:** Fix issues, refine approach
- **Day 5:** Document lessons learned

**Deliverables:**
- 6 migrated scripts
- Validated migration process
- Updated documentation

### Week 3: Data Generation Migration
- **Day 1-2:** Migrate Tier 2 scripts (5 scripts)
- **Day 3:** Concurrent testing
- **Day 4:** Fix data conflicts
- **Day 5:** Validation and documentation

**Deliverables:**
- 11 total migrated scripts
- Proven concurrent execution
- Data generation patterns

### Week 4: Complex Scripts
- **Day 1-3:** Migrate Tier 3 scripts (5 scripts)
- **Day 4:** End-to-end testing
- **Day 5:** Performance validation

**Deliverables:**
- 16 total migrated scripts
- Complex flow validation
- Performance benchmarks

### Week 5: Final Migration & Cleanup
- **Day 1-3:** Migrate Tier 4 scripts (5 scripts)
- **Day 4:** Update test runners
- **Day 5:** Final validation and cleanup

**Deliverables:**
- All 21 scripts migrated
- Updated test runners
- Complete documentation
- Cleanup of old files

---

## 9. Success Metrics

### Quantitative Metrics
- ✅ 100% of scripts migrated (21/21)
- ✅ 0 hardcoded credentials in scripts
- ✅ 0 data conflicts in concurrent runs
- ✅ <5% performance degradation
- ✅ 100% test pass rate maintained

### Qualitative Metrics
- ✅ Easier to add new tests
- ✅ Faster to update test data
- ✅ Clear separation of concerns
- ✅ Better code reusability
- ✅ Improved maintainability

---

## 10. Rollback Plan

### If Migration Fails:

1. **Keep backups:** All original scripts backed up with `.backup` extension
2. **Symlinks:** Create symlinks from new to old locations during transition
3. **Parallel running:** Run both old and new versions until validated
4. **Quick revert:** Script to restore all backups:

```bash
#!/bin/bash
# rollback-migration.sh
for backup in frontend-tests/**/*.backup; do
    original="${backup%.backup}"
    cp "$backup" "$original"
    echo "Restored: $original"
done
```

### Rollback Triggers:
- >20% test failure rate
- Critical tests failing
- Performance degradation >10%
- Data corruption issues
- Team unable to use new structure

---

## 11. Next Steps After Implementation

### Immediate (Week 6)
1. Remove backup files after 2 weeks of stable operation
2. Add CI/CD integration for automated testing
3. Create test data cleanup automation
4. Document best practices for new tests

### Short-term (Month 2)
1. Add more sophisticated data generators
2. Implement test data versioning
3. Create test data snapshots for debugging
4. Add performance monitoring

### Long-term (Quarter 2)
1. Implement test data as code (TDaC)
2. Add test data analytics
3. Create self-healing test data
4. Implement smart test data generation based on production patterns

---

## 12. Resources & References

### Industry Best Practices
- Test data should be separate from test logic ([source](https://jignect.tech/the-complete-guide-to-reading-different-files-in-test-automation/))
- Use configuration files for environment-specific settings ([source](https://8gwifi.org/tutorials/bash/practices-configuration.jsp))
- Organize tests by feature for better maintainability ([source](https://autonoma-9e2c48c0.mintlify.app/test-organization-and-naming-conventions))

### Tools & Utilities
- `jq` - JSON parsing in bash
- `yq` - YAML parsing (if needed)
- `uuidgen` - UUID generation
- `shuf` - Random number generation

### Documentation
- Migration guide: `README-MIGRATION.md` (to be created)
- Config reference: `config/README.md` (to be created)
- Data generators API: `lib/README.md` (to be created)

---

## Appendix A: Example Migrated Script

### Before (Original):
```bash
#!/bin/bash
AB="/home/ishwor/Desktop/work/kiro-hotel/hotel-automation/node_modules/agent-browser/bin/agent-browser-linux-x64"
FRONTEND_URL="http://localhost:3001"
OWNER_PHONE="9800000001"
OWNER_PASSWORD="password123"
GUEST_EMAIL="test@example.com"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

$AB --headed open "$FRONTEND_URL/login"
# ... rest of script
```

### After (Migrated):
```bash
#!/bin/bash
# Load configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../config/test-config.sh"

# Use environment variables
AB="$AB_PATH"
# FRONTEND_URL, OWNER_PHONE, OWNER_PASSWORD loaded from config

# Generate dynamic data
GUEST_EMAIL=$(generate_email "test")
# TIMESTAMP already loaded from config

$AB --headed open "$FRONTEND_URL/login"
# ... rest of script
```

### Benefits:
- ✅ No hardcoded paths or credentials
- ✅ Environment-specific configuration
- ✅ Dynamic data generation
- ✅ Reusable across environments
- ✅ Easier to maintain

---

## Appendix B: Quick Start Guide

### For Developers Adding New Tests:

1. **Create your test script:**
```bash
cd hotel-automation/frontend-tests/tests/your-feature
nano your-test.sh
```

2. **Start with template:**
```bash
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../../config/test-config.sh"

# Your test logic here
AB="$AB_PATH"
$AB --headed open "$FRONTEND_URL"
```

3. **Use data generators:**
```bash
EMAIL=$(generate_email "mytest")
PHONE=$(generate_phone)
NAME=$(generate_guest_name "MyTest")
```

4. **Run your test:**
```bash
chmod +x your-test.sh
./your-test.sh
```

---

**End of Implementation Plan**

*Document Version: 1.0*  
*Created: 2026-03-06*  
*Author: Test Automation Team*
