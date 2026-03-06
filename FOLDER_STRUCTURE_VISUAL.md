# Proposed Folder Structure - Visual Guide

## 🎨 Complete Structure

```
hotel-automation/
│
├── 📁 frontend-tests/                    # Main test directory
│   │
│   ├── 📁 tests/                         # All test scripts (organized by feature)
│   │   │
│   │   ├── 📁 auth/                      # Authentication tests
│   │   │   ├── 📄 login-test.sh
│   │   │   ├── 📄 login-working.sh
│   │   │   └── 📄 login-debug.sh
│   │   │
│   │   ├── 📁 booking/                   # Booking-related tests
│   │   │   ├── 📄 booking-flow-test.sh
│   │   │   ├── 📄 booking-cancellation.sh
│   │   │   └── 📄 complete-booking-flow.sh
│   │   │
│   │   ├── 📁 property/                  # Property management tests
│   │   │   ├── 📄 property-onboarding-complete.sh
│   │   │   ├── 📄 property-onboarding-final.sh
│   │   │   ├── 📄 property-onboarding-new-user.sh
│   │   │   ├── 📄 property-onboarding-working.sh
│   │   │   ├── 📄 property-onboarding.sh
│   │   │   ├── 📄 add-rooms-to-property.sh
│   │   │   └── 📄 rate-plan-management.sh
│   │   │
│   │   ├── 📁 customer/                  # Customer-facing tests
│   │   │   ├── 📄 hotel-search-test.sh
│   │   │   ├── 📄 customer-filters.sh
│   │   │   ├── 📄 date-picker-test.sh
│   │   │   └── 📄 guest-selector-test.sh
│   │   │
│   │   └── 📁 management/                # Owner/staff management tests
│   │       ├── 📄 guest-management.sh
│   │       ├── 📄 owner-booking-management.sh
│   │       ├── 📄 payment-recording.sh
│   │       └── 📄 dashboard-analytics.sh
│   │
│   ├── 📁 config/                        # Configuration files
│   │   │
│   │   ├── 📄 test-config.sh            # ⭐ Main config loader (source this!)
│   │   ├── 📄 README.md                 # Config documentation
│   │   │
│   │   ├── 📁 environments/             # Environment-specific configs
│   │   │   ├── 📄 dev.env              # Development settings
│   │   │   ├── 📄 staging.env          # Staging settings
│   │   │   ├── 📄 prod.env             # Production settings
│   │   │   └── 📄 .env.template        # Template for new environments
│   │   │
│   │   └── 📄 test-data.json            # Shared static test data
│   │
│   ├── 📁 lib/                           # Shared libraries and utilities
│   │   │
│   │   ├── 📄 data-generators.sh        # ⭐ Dynamic data generation functions
│   │   ├── 📄 test-helpers.sh           # Common test utilities
│   │   ├── 📄 browser-utils.sh          # Browser automation helpers
│   │   ├── 📄 assertions.sh             # Test assertion functions
│   │   └── 📄 README.md                 # Library API documentation
│   │
│   ├── 📁 fixtures/                      # Test fixtures and sample data
│   │   │
│   │   ├── 📄 users.json                # User test data templates
│   │   ├── 📄 properties.json           # Property test data templates
│   │   ├── 📄 bookings.json             # Booking test data templates
│   │   └── 📄 README.md                 # Fixtures documentation
│   │
│   └── 📁 frontend-results/              # Test execution results
│       ├── 📁 screenshots/              # Test screenshots
│       └── 📁 snapshots/                # Page snapshots (JSON)
│
├── 📄 run-all-tests.sh                   # Main test runner
├── 📄 run-critical-tests.sh              # Critical tests runner
├── 📄 run-tests-staging.sh               # Staging environment runner
├── 📄 run-tests-prod.sh                  # Production environment runner
├── 📄 validate-config.sh                 # Configuration validator
├── 📄 cleanup-test-data.sh               # Test data cleanup utility
│
├── 📄 TEST_DATA_MANAGEMENT_PLAN.md       # 📖 Full implementation plan
├── 📄 MIGRATION_QUICK_REFERENCE.md       # 📖 Quick reference guide
├── 📄 FOLDER_STRUCTURE_VISUAL.md         # 📖 This file
└── 📄 README-MIGRATION.md                # 📖 Migration guide (to be created)
```

---

## 🎯 Key Directories Explained

### 📁 `tests/` - Test Scripts
**Purpose:** All test scripts organized by feature area

**Benefits:**
- Easy to find related tests
- Clear separation of concerns
- Scalable structure
- Logical grouping

**Categories:**
- `auth/` - Login, authentication, authorization
- `booking/` - Booking creation, cancellation, management
- `property/` - Property onboarding, room management, rates
- `customer/` - Customer-facing features (search, filters, selectors)
- `management/` - Owner/staff management features

---

### 📁 `config/` - Configuration
**Purpose:** Centralized configuration management

**Key Files:**
- `test-config.sh` - Main loader, sources environment and libraries
- `environments/*.env` - Environment-specific settings
- `test-data.json` - Shared static data

**Usage:**
```bash
# In your test script:
source "$(dirname "$0")/../../config/test-config.sh"
```

---

### 📁 `lib/` - Shared Libraries
**Purpose:** Reusable functions and utilities

**Key Files:**
- `data-generators.sh` - Generate unique test data
- `test-helpers.sh` - Common test operations
- `browser-utils.sh` - Browser automation helpers
- `assertions.sh` - Test assertions

**Usage:**
```bash
# After sourcing config, generators are available:
EMAIL=$(generate_email "test")
PHONE=$(generate_phone)
```

---

### 📁 `fixtures/` - Test Fixtures
**Purpose:** Static test data templates

**Format:** JSON for structured data
```json
{
  "users": [
    {
      "role": "owner",
      "phone": "9800000001",
      "password": "password123"
    }
  ]
}
```

**Usage:**
```bash
# Parse with jq
OWNER_DATA=$(cat fixtures/users.json | jq '.users[] | select(.role=="owner")')
```

---

## 🔄 Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│                     Test Script Execution                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  1. Source config/test-config.sh                            │
│     ├── Load environment (dev/staging/prod)                 │
│     ├── Load data generators                                │
│     └── Set common variables                                │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  2. Use Environment Variables                               │
│     ├── FRONTEND_URL                                        │
│     ├── OWNER_PHONE, OWNER_PASSWORD                         │
│     ├── AB_PATH                                             │
│     └── TIMEOUT_* values                                    │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  3. Generate Dynamic Data                                   │
│     ├── generate_email()                                    │
│     ├── generate_phone()                                    │
│     ├── generate_guest_name()                               │
│     └── generate_date_range()                               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  4. Execute Test Logic                                      │
│     ├── Open browser                                        │
│     ├── Perform actions                                     │
│     ├── Take screenshots                                    │
│     └── Verify results                                      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│  5. Save Results                                            │
│     ├── Screenshots → frontend-results/screenshots/         │
│     ├── Snapshots → frontend-results/snapshots/             │
│     └── Exit with status code                               │
└─────────────────────────────────────────────────────────────┘
```

---

## 📊 Before vs After Comparison

### ❌ Before (Current State)

```
hotel-automation/
├── frontend-tests/
│   ├── add-rooms-to-property.sh          # Hardcoded data
│   ├── booking-cancellation.sh           # Hardcoded data
│   ├── customer-filters.sh               # Hardcoded data
│   ├── dashboard-analytics.sh            # Hardcoded data
│   ├── ... (17 more scripts)             # All with hardcoded data
│   └── frontend-results/
```

**Problems:**
- ❌ Hardcoded credentials in every script
- ❌ Hardcoded URLs in every script
- ❌ Static test data causes conflicts
- ❌ No organization by feature
- ❌ Difficult to maintain
- ❌ Can't run tests concurrently
- ❌ No environment-specific configs

---

### ✅ After (Proposed State)

```
hotel-automation/
├── frontend-tests/
│   ├── tests/                            # Organized by feature
│   │   ├── auth/
│   │   ├── booking/
│   │   ├── property/
│   │   ├── customer/
│   │   └── management/
│   ├── config/                           # Centralized config
│   │   ├── test-config.sh
│   │   └── environments/
│   ├── lib/                              # Reusable utilities
│   │   ├── data-generators.sh
│   │   └── test-helpers.sh
│   └── fixtures/                         # Test data templates
```

**Benefits:**
- ✅ No hardcoded credentials
- ✅ Environment-specific configs
- ✅ Dynamic data generation
- ✅ Clear organization
- ✅ Easy to maintain
- ✅ Concurrent execution safe
- ✅ Reusable components

---

## 🚀 Migration Path

```
Current Structure          Intermediate State         Final Structure
─────────────────         ──────────────────         ───────────────

frontend-tests/           frontend-tests/            frontend-tests/
├── script1.sh     ──┐    ├── script1.sh (old)      ├── tests/
├── script2.sh     ──┤    ├── script2.sh (old)      │   ├── auth/
├── script3.sh     ──┤    ├── config/ (new)         │   │   └── script1.sh
└── ...            ──┘    ├── lib/ (new)            │   ├── booking/
                          ├── tests/ (new)           │   │   └── script2.sh
                          │   ├── auth/              │   └── ...
                          │   │   └── script1.sh     ├── config/
                          │   └── ...                ├── lib/
                          └── ...                    └── fixtures/

   Week 0                    Weeks 1-3                  Week 5
```

**Strategy:**
1. Create new structure alongside old
2. Migrate scripts gradually (tier by tier)
3. Keep old scripts as backup
4. Remove old scripts after validation

---

## 📝 File Naming Conventions

### Test Scripts
- Use descriptive names: `booking-cancellation.sh`
- Use hyphens for spaces: `add-rooms-to-property.sh`
- Include test type if needed: `login-test.sh`

### Configuration Files
- Environment files: `{env}.env` (e.g., `dev.env`)
- Config scripts: `{purpose}-config.sh`
- Templates: `{name}.template`

### Library Files
- Descriptive names: `data-generators.sh`
- Plural for collections: `test-helpers.sh`
- Suffix with `.sh`: `browser-utils.sh`

### Fixture Files
- Use JSON format: `users.json`
- Plural names: `properties.json`, `bookings.json`
- Descriptive: `sample-data.json`

---

## 🎓 Best Practices

### ✅ DO:
- Organize tests by feature
- Use environment variables
- Generate dynamic data
- Keep configs separate
- Document your code
- Use meaningful names
- Version control everything

### ❌ DON'T:
- Hardcode credentials
- Hardcode URLs
- Use static test data
- Mix test logic with config
- Duplicate code
- Use absolute paths
- Commit sensitive data

---

**Visual Guide Version: 1.0**  
*Last Updated: 2026-03-06*
