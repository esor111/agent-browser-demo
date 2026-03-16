#!/bin/bash
###############################################################################
# DYNAMIC TEST DATA GENERATORS
# Functions to generate unique test data at runtime
###############################################################################

# Generate unique email
# Usage: generate_email "prefix"
# Example: generate_email "test" → test_20260306_143022@test.com
generate_email() {
    local prefix="${1:-test}"
    local timestamp=$(date +%Y%m%d_%H%M%S)
    echo "${prefix}_${timestamp}@${TEST_EMAIL_DOMAIN:-test.com}"
}

# Generate unique phone number
# Usage: generate_phone "prefix"
# Example: generate_phone "984" → 9841234567
generate_phone() {
    local prefix="${1:-984}"
    local random=$(shuf -i 1000000-9999999 -n 1)
    echo "${prefix}${random}"
}

# Generate unique guest name
# Usage: generate_guest_name "prefix"
# Example: generate_guest_name "Guest" → Guest_143022
generate_guest_name() {
    local prefix="${TEST_NAME_PREFIX:-Guest}"
    local timestamp=$(date +%H%M%S)
    echo "${prefix}_${timestamp}"
}

# Generate unique room number
# Usage: generate_room_number
# Example: generate_room_number → 143047
generate_room_number() {
    local timestamp=$(date +%H%M)
    local random=$(shuf -i 10-99 -n 1)
    echo "${timestamp}${random}"
}

# Generate future date (days from now)
# Usage: generate_future_date days_ahead
# Example: generate_future_date 7 → 2026-03-13
generate_future_date() {
    local days_ahead="${1:-7}"
    date -d "+${days_ahead} days" +%Y-%m-%d
}

# Generate date range (checkin and checkout dates)
# Usage: generate_date_range start_days duration
# Example: generate_date_range 7 3 → "2026-03-13 2026-03-16"
generate_date_range() {
    local start_days="${1:-7}"
    local duration="${2:-3}"
    local checkin=$(date -d "+${start_days} days" +%Y-%m-%d)
    local checkout=$(date -d "+$((start_days + duration)) days" +%Y-%m-%d)
    echo "$checkin $checkout"
}

# Generate unique property code
# Usage: generate_property_code "prefix"
# Example: generate_property_code "PROP" → PROP143022
generate_property_code() {
    local prefix="${1:-PROP}"
    local timestamp=$(date +%H%M%S)
    echo "${prefix}${timestamp}"
}

# Generate unique booking reference
# Usage: generate_booking_ref
# Example: generate_booking_ref → BK20260306143022
generate_booking_ref() {
    local timestamp=$(date +%Y%m%d%H%M%S)
    echo "BK${timestamp}"
}
