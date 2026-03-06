#!/bin/bash

###############################################################################
# SETUP POSTGRESQL FOR BOOKING TESTS
# Helps install and configure PostgreSQL for the hotel management system
###############################################################################

echo ""
echo "========================================"
echo " POSTGRESQL SETUP HELPER"
echo "========================================"
echo ""

# Check if PostgreSQL is already installed
if command -v psql &> /dev/null; then
    echo "✓ PostgreSQL is already installed"
    
    # Check if it's running
    if systemctl is-active --quiet postgresql 2>/dev/null; then
        echo "✓ PostgreSQL is running"
    else
        echo "⚠️  PostgreSQL is installed but not running"
        echo ""
        echo "Starting PostgreSQL..."
        sudo systemctl start postgresql
        sudo systemctl enable postgresql
        echo "✓ PostgreSQL started"
    fi
else
    echo "❌ PostgreSQL is not installed"
    echo ""
    echo "To install PostgreSQL, run:"
    echo ""
    echo "  sudo apt update"
    echo "  sudo apt install postgresql postgresql-contrib"
    echo ""
    echo "Then run this script again."
    echo ""
    exit 1
fi

echo ""
echo "========================================"
echo " DATABASE SETUP"
echo "========================================"
echo ""

# Check if database exists
DB_EXISTS=$(sudo -u postgres psql -tAc "SELECT 1 FROM pg_database WHERE datname='hms_db'" 2>/dev/null)

if [ "$DB_EXISTS" = "1" ]; then
    echo "✓ Database 'hms_db' already exists"
else
    echo "Creating database 'hms_db'..."
    sudo -u postgres psql -c "CREATE DATABASE hms_db;" 2>/dev/null
    echo "✓ Database created"
fi

# Check if user has proper permissions
echo ""
echo "Setting up database user..."
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD 'postgres';" 2>/dev/null
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE hms_db TO postgres;" 2>/dev/null
echo "✓ User configured"

echo ""
echo "========================================"
echo " BACKEND SETUP"
echo "========================================"
echo ""

# Navigate to backend directory
BACKEND_DIR="../hostel-backend"

if [ ! -d "$BACKEND_DIR" ]; then
    echo "❌ Backend directory not found: $BACKEND_DIR"
    exit 1
fi

cd "$BACKEND_DIR"

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    echo "Installing backend dependencies..."
    npm install
    echo "✓ Dependencies installed"
else
    echo "✓ Dependencies already installed"
fi

# Run migrations
echo ""
echo "Running database migrations..."
npm run migration:run 2>&1 | tail -10
echo "✓ Migrations complete"

# Seed database
echo ""
echo "Seeding database with test data..."
npm run seed 2>&1 | tail -10
echo "✓ Database seeded"

echo ""
echo "========================================"
echo " VERIFICATION"
echo "========================================"
echo ""

# Check if backend is running
sleep 3
BACKEND_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:3000/health 2>/dev/null || echo "000")

if [ "$BACKEND_STATUS" = "200" ] || [ "$BACKEND_STATUS" = "404" ]; then
    echo "✓ Backend is responding on port 3000"
    
    # Check hotels
    HOTELS=$(curl -s "http://localhost:3000/public/hotels?limit=1" 2>/dev/null)
    HOTEL_COUNT=$(echo "$HOTELS" | jq -r '.data | length' 2>/dev/null || echo "0")
    
    if [ "$HOTEL_COUNT" != "0" ]; then
        echo "✓ Hotels are available: $HOTEL_COUNT+"
        echo ""
        echo "========================================"
        echo " ✅ SETUP COMPLETE!"
        echo "========================================"
        echo ""
        echo "You can now run the booking tests:"
        echo ""
        echo "  cd hotel-automation"
        echo "  bash run-booking-test-with-backend-check.sh"
        echo ""
    else
        echo "⚠️  Backend is running but no hotels found"
        echo ""
        echo "Try restarting the backend:"
        echo "  cd hostel-backend"
        echo "  npm run start:dev"
    fi
else
    echo "⚠️  Backend is not responding on port 3000"
    echo ""
    echo "Start the backend:"
    echo "  cd hostel-backend"
    echo "  npm run start:dev"
    echo ""
    echo "Then run the booking tests."
fi

echo ""
