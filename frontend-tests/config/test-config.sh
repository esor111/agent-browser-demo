#!/bin/bash
###############################################################################
# TEST CONFIGURATION LOADER
# Main configuration file that loads environment-specific settings and libraries
# Usage: source "$(dirname "$0")/../../config/test-config.sh"
###############################################################################

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
if [ -f "$SCRIPT_DIR/../lib/data-generators.sh" ]; then
    source "$SCRIPT_DIR/../lib/data-generators.sh"
    echo "✓ Loaded data generators"
else
    echo "⚠ Data generators not found"
fi

# Export common paths
export OUTPUT_DIR="${OUTPUT_DIR:-./frontend-results}"
export TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Create output directories if they don't exist
mkdir -p "$OUTPUT_DIR/screenshots"
mkdir -p "$OUTPUT_DIR/snapshots"

echo "✓ Configuration loaded successfully"
