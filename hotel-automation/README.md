# Hotel Automation Test Suite

A comprehensive automation testing suite for hotel management system covering the complete workflow from property registration to guest bookings and payments.

## Directory Structure

```
hotel-automation/
├── tests/
│   ├── auth/           # Authentication & Login Tests
│   ├── property/       # Property Onboarding & Management
│   ├── booking/        # Guest Booking Flows
│   ├── payment/        # Payment Processing
│   └── management/     # Owner/Admin Management
├── config/             # Test Configurations
├── lib/                # Shared Utilities & Data Generators
├── results/            # Test Results & Screenshots
└── runners/            # Test Execution Scripts
```

## Test Categories

### Authentication (`tests/auth/`)
- Login functionality
- User authentication flows
- Session management

### Property Management (`tests/property/`)
- Property onboarding workflows
- Room setup and management
- Rate plan configuration
- Property registration flows

### Booking Flows (`tests/booking/`)
- Guest booking processes
- Hotel search functionality
- Date picker interactions
- Customer filters
- Complete booking workflows

### Payment Processing (`tests/payment/`)
- Payment recording
- Transaction processing
- Payment verification

### Management (`tests/management/`)
- Owner booking management
- Dashboard analytics
- Guest management
- Administrative functions

## Quick Start

### Run All Tests
```bash
./runners/run-all-tests.sh
```

### Run Production Tests
```bash
./runners/run-production-tests.sh
```

### Run Critical Path Tests
```bash
./runners/run-critical-tests.sh
```

### Run Quick Wins
```bash
./runners/run-quick-wins.sh
```

## Configuration

Test configurations are stored in `config/` directory:
- Environment settings
- Test data configurations
- Browser settings

## Utilities

Shared utilities and data generators are in `lib/` directory:
- Data generation functions
- Common test utilities
- Helper functions

## Results

Test results, screenshots, and reports are stored in `results/` directory:
- Frontend test results
- Screenshots from test runs
- Test reports and logs

## Contributing

When adding new tests:
1. Place them in the appropriate category directory
2. Follow existing naming conventions
3. Update this README if adding new categories
4. Ensure tests are executable and well-documented