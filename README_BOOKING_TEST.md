# Booking Flow Test - Complete Guide

## 🎯 Current Status

**Test Status:** ⚠️ Ready but blocked by database  
**Blocker:** PostgreSQL not running  
**Solution:** Install PostgreSQL and seed database  
**Time to Fix:** ~20 minutes

## 📋 Quick Start

### If PostgreSQL is Already Installed

```bash
cd hotel-automation
bash run-booking-test-with-backend-check.sh
```

The script will:
- ✅ Check if backend is running
- ✅ Check if hotels exist
- ✅ Run diagnostic
- ✅ Execute booking test
- ✅ Show results

### If PostgreSQL is NOT Installed

```bash
# 1. Install PostgreSQL
sudo apt update
sudo apt install postgresql postgresql-contrib

# 2. Setup database
cd hotel-automation
bash setup-postgresql.sh

# 3. Run test
bash run-booking-test-with-backend-check.sh
```

## 🔍 What We Found

### The Problem
The booking payment flow test was failing because:
1. Frontend shows "0 properties found"
2. Backend process is running but not serving requests
3. PostgreSQL database is not running
4. Backend can't connect to database

### The Solution
Install PostgreSQL, create database, run migrations, seed data.

## 🛠️ Tools Created

### 1. Smart Test Runner
**File:** `run-booking-test-with-backend-check.sh`

Automatically checks:
- Is backend running?
- Are hotels available?
- Is system ready?

Then runs the booking test.

### 2. Diagnostic Tool
**File:** `diagnose-booking-readiness.sh`

Checks all prerequisites:
- Property exists
- Rooms added
- Rate plans set
- Visible to customers

### 3. Automated Debugger
**File:** `auto-debug-booking.sh`

Explores the booking flow automatically:
- Takes screenshots at each step
- Captures page state
- Generates JSON logs
- No manual intervention needed

### 4. PostgreSQL Setup
**File:** `setup-postgresql.sh`

Helps setup database:
- Checks if PostgreSQL installed
- Creates database
- Runs migrations
- Seeds test data

### 5. Quick Checks
**File:** `quick-booking-test.sh`

Fast validation:
- Checks if hotels visible
- Navigates to hotel detail
- Analyzes booking buttons

### 6. Full Orchestrator
**File:** `setup-and-test-booking.sh`

End-to-end:
- Creates property if needed
- Adds rooms
- Runs booking test

## 📊 System Requirements

### Required Services
- ✅ Frontend (Next.js) on port 3001
- ✅ Backend (NestJS) on port 3000
- ❌ PostgreSQL on port 5432 ← **MISSING**

### Test Data Needed
- Owner account: `9800000001` / `password123`
- Test hotels with rooms
- Rate plans configured

## 🚀 Setup Instructions

### Step 1: Install PostgreSQL

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
```

### Step 2: Start PostgreSQL

```bash
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

### Step 3: Create Database

```bash
sudo -u postgres psql
CREATE DATABASE hms_db;
ALTER USER postgres WITH PASSWORD 'postgres';
GRANT ALL PRIVILEGES ON DATABASE hms_db TO postgres;
\q
```

### Step 4: Setup Backend

```bash
cd hostel-backend

# Install dependencies (if needed)
npm install

# Run migrations
npm run migration:run

# Seed database
npm run seed

# Backend should auto-restart via --watch
# If not, start it:
npm run start:dev
```

### Step 5: Verify Setup

```bash
# Check backend health
curl http://localhost:3000/health

# Check hotels
curl http://localhost:3000/public/hotels

# Should return JSON with hotels
```

### Step 6: Run Booking Test

```bash
cd hotel-automation
bash run-booking-test-with-backend-check.sh
```

## 📸 What the Test Does

### Booking Flow Steps

1. **Open hotels page** (`/hotels`)
   - Verify hotels are visible
   - Count available properties

2. **Navigate to hotel detail**
   - Click first hotel
   - Load hotel detail page

3. **Click booking button**
   - Find "Book Now" or "Reserve" button
   - Navigate to booking page

4. **Fill guest details**
   - First name, last name
   - Email, phone
   - Special requests

5. **Fill payment information**
   - Card number (test: 4242424242424242)
   - Expiry date
   - CVC code
   - Cardholder name

6. **Submit booking**
   - Click "Complete Booking"
   - Wait for processing

7. **Verify confirmation**
   - Check for success message
   - Look for confirmation code
   - Verify booking details

8. **Take screenshots**
   - At each step
   - For debugging
   - For verification

## 📁 Output Files

### Screenshots
Location: `frontend-results/screenshots/`

Files:
- `booking_01_hotels_*.png` - Hotels page
- `booking_02_dates_*.png` - Date selection
- `booking_03_hotel_detail_*.png` - Hotel detail
- `booking_04_booking_page_*.png` - Booking form
- `booking_05_guest_details_*.png` - Guest info filled
- `booking_06_payment_filled_*.png` - Payment info filled
- `booking_07_before_submit_*.png` - Before submission
- `booking_08_confirmation_*.png` - Confirmation page

### Debug Logs
Location: `frontend-results/`

Files:
- `debug-booking-*.log` - Detailed debug log
- JSON snapshots of page state
- Error messages if any

## 🐛 Troubleshooting

### Backend Not Responding

```bash
# Check if backend process is running
ps aux | grep nest

# Check if listening on port 3000
ss -tlnp | grep 3000

# Check backend logs
cd hostel-backend
# Look at terminal where backend is running
```

### No Hotels Found

```bash
# Check database
sudo -u postgres psql hms_db
SELECT COUNT(*) FROM properties;
\q

# Re-seed if needed
cd hostel-backend
npm run seed
```

### Login Fails

```bash
# Verify owner account exists
sudo -u postgres psql hms_db
SELECT phone, role FROM users WHERE phone = '9800000001';
\q

# Re-seed if needed
cd hostel-backend
npm run seed
```

### Test Fails

```bash
# Run diagnostic first
cd hotel-automation
bash diagnose-booking-readiness.sh

# Check screenshots
ls -lh frontend-results/screenshots/booking_*

# Run with more verbose output
bash -x frontend-tests/tests/customer/booking-payment-flow-test.sh
```

## 📚 Documentation Files

- `BOOKING_TEST_STATUS.md` - Current status and blockers
- `BOOKING_FLOW_DEBUG_RESULTS.md` - Debug findings
- `README_BOOKING_TEST.md` - This file
- `TODAYS_PROGRESS.md` - Daily progress log
- `COVERAGE_SUMMARY.md` - Test coverage overview

## ✅ Success Criteria

The booking test passes when:
1. ✅ Hotels are visible on `/hotels` page
2. ✅ Can navigate to hotel detail
3. ✅ Booking button exists and works
4. ✅ Booking form loads with all fields
5. ✅ Guest details can be filled
6. ✅ Payment information can be entered
7. ✅ Booking can be submitted
8. ✅ Confirmation page shows success
9. ✅ Confirmation code is displayed

## 🎉 What's Ready

Despite the database blocker:
- ✅ All test scripts created
- ✅ Automated debugging tools
- ✅ Comprehensive documentation
- ✅ Clear setup instructions
- ✅ Troubleshooting guide

## 📞 Summary

**What's Blocking:** PostgreSQL not running  
**How to Fix:** Install PostgreSQL and seed database  
**Time Needed:** ~20 minutes  
**What's Ready:** All test scripts and tools  
**Next Step:** Run `bash setup-postgresql.sh`

---

**Quick Command Reference:**

```bash
# Setup (one time)
bash setup-postgresql.sh

# Run test
bash run-booking-test-with-backend-check.sh

# Diagnostic
bash diagnose-booking-readiness.sh

# Debug
bash auto-debug-booking.sh
```

