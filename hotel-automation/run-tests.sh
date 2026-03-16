#!/bin/bash

# Hotel Automation Test Suite Master Runner
# Organized test execution for hotel management system

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Test execution function
run_test_category() {
    local category=$1
    local description=$2
    
    log_info "Running $description tests..."
    
    if [ -d "tests/$category" ]; then
        local test_count=0
        local success_count=0
        
        for test_file in tests/$category/*.sh; do
            if [ -f "$test_file" ]; then
                test_count=$((test_count + 1))
                log_info "Executing: $(basename "$test_file")"
                
                if bash "$test_file"; then
                    success_count=$((success_count + 1))
                    log_success "✓ $(basename "$test_file")"
                else
                    log_error "✗ $(basename "$test_file")"
                fi
            fi
        done
        
        log_info "$description: $success_count/$test_count tests passed"
        echo ""
    else
        log_warning "No tests found in $category category"
    fi
}

# Main execution
main() {
    log_info "Starting Hotel Automation Test Suite"
    log_info "======================================="
    echo ""
    
    # Check if specific category requested
    if [ $# -eq 1 ]; then
        case $1 in
            "auth")
                run_test_category "auth" "Authentication"
                ;;
            "property")
                run_test_category "property" "Property Management"
                ;;
            "booking")
                run_test_category "booking" "Booking Flow"
                ;;
            "payment")
                run_test_category "payment" "Payment Processing"
                ;;
            "management")
                run_test_category "management" "Management & Analytics"
                ;;
            "all")
                run_test_category "auth" "Authentication"
                run_test_category "property" "Property Management"
                run_test_category "booking" "Booking Flow"
                run_test_category "payment" "Payment Processing"
                run_test_category "management" "Management & Analytics"
                ;;
            *)
                log_error "Unknown category: $1"
                log_info "Available categories: auth, property, booking, payment, management, all"
                exit 1
                ;;
        esac
    else
        # Run all tests by default
        run_test_category "auth" "Authentication"
        run_test_category "property" "Property Management"
        run_test_category "booking" "Booking Flow"
        run_test_category "payment" "Payment Processing"
        run_test_category "management" "Management & Analytics"
    fi
    
    log_success "Hotel Automation Test Suite completed!"
}

# Show usage if help requested
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Hotel Automation Test Suite"
    echo ""
    echo "Usage: $0 [category]"
    echo ""
    echo "Categories:"
    echo "  auth        - Authentication tests"
    echo "  property    - Property management tests"
    echo "  booking     - Booking flow tests"
    echo "  payment     - Payment processing tests"
    echo "  management  - Management and analytics tests"
    echo "  all         - Run all test categories"
    echo ""
    echo "Examples:"
    echo "  $0              # Run all tests"
    echo "  $0 booking      # Run only booking tests"
    echo "  $0 auth         # Run only authentication tests"
    exit 0
fi

main "$@"