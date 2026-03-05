# 🤖 Frontend Automation Plan - Kaha Stays Nepal

**Date**: March 5, 2026  
**Purpose**: Automated testing and validation of frontend features using Agent Browser

---

## 🎯 Overview

Based on the complete codebase analysis, we can automate **50+ user flows** across:
- **Guest-facing features** (booking, search, hotel browsing)
- **Owner dashboard** (property management, bookings, rates, payments)
- **Platform admin** (user management, property approval, audit logs)

---

## 📋 Automation Categories

### 1️⃣ **Authentication & Onboarding** (Priority: HIGH)

#### A. Login Flow
**URL**: `http://localhost:3001/login`

**Test Cases**:
1. ✅ **Successful Login**
   - Fill phone number
   - Fill password
   - Click login button
   - Verify redirect to dashboard
   - Check for auth token in localStorage

2. ❌ **Failed Login - Invalid Credentials**
   - Fill wrong phone/password
   - Click login
   - Verify error message appears

3. ❌ **Failed Login - Empty Fields**
   - Click login without filling
   - Verify validation errors

**Automation Script**: `login-test.sh`
```bash
# Open login page
agent-browser --headed open http://localhost:3001/login
agent-browser snapshot -i

# Fill credentials
agent-browser fill "@e2" "+9779841234567"  # phone field ref
agent-browser fill "@e3" "password123"      # password field ref

# Click login
agent-browser click "@e5"  # login button ref

# Wait for redirect
agent-browser wait --load networkidle

# Verify dashboard loaded
agent-browser get url  # Should be /owner/dashboard
agent-browser screenshot login-success.png
```

#### B. Property Onboarding (7-Step Wizard)
**URL**: `http://localhost:3001/onboarding`

**Test Cases**:
1. ✅ **Complete Onboarding Flow**
   - Step 1: Select property type, room count
   - Step 2: Enter property name
   - Step 3: Fill location details
   - Step 4: Add contact info
   - Step 5: Set operations (check-in/out times)
   - Step 6: Choose subscription plan
   - Step 7: Review and submit

**Automation Script**: `onboarding-test.sh`

---

### 2️⃣ **Guest-Facing Features** (Priority: HIGH)

#### A. Hotel Search & Browse
**URL**: `http://localhost:3001/hotels`

**Test Cases**:
1. ✅ **Search Hotels by Location**
   - Enter location in search box
   - Select check-in/check-out dates
   - Enter guest count
   - Click search
   - Verify results appear

2. ✅ **Apply Filters**
   - Filter by price range
   - Filter by amenities (WiFi, parking, pool)
   - Filter by star rating
   - Verify filtered results

3. ✅ **Sort Results**
   - Sort by price (low to high)
   - Sort by rating
   - Verify order changes

**Automation Script**: `hotel-search-test.sh`

#### B. Hotel Detail Page
**URL**: `http://localhost:3001/hotels/[id]`

**Test Cases**:
1. ✅ **View Hotel Details**
   - Navigate to hotel detail
   - Verify hotel name, description, amenities
   - Check room types displayed
   - Verify reviews section
   - Check map location

2. ✅ **Check Room Availability**
   - Select dates
   - View available rooms
   - Check pricing

**Automation Script**: `hotel-detail-test.sh`

#### C. Booking Flow (CRITICAL)
**URL**: `http://localhost:3001/booking`

**Test Cases**:
1. ✅ **Complete Booking**
   - Select hotel and room
   - Choose check-in/check-out dates
   - Enter guest count
   - Fill guest information:
     - First name
     - Last name
     - Email
     - Phone
     - Special requests (optional)
   - Review booking summary
   - Submit booking
   - Verify confirmation code received
   - Check booking status page

2. ❌ **Booking Validation Errors**
   - Submit with missing required fields
   - Verify error messages
   - Submit with invalid email
   - Submit with invalid phone

**Automation Script**: `booking-flow-test.sh`
```bash
# Navigate to booking page
agent-browser --headed open "http://localhost:3001/booking?hotelId=123"
agent-browser snapshot -i

# Select dates
agent-browser click "@e5"  # check-in date picker
agent-browser click "@e10" # select date
agent-browser click "@e6"  # check-out date picker
agent-browser click "@e12" # select date

# Fill guest info
agent-browser fill "@e15" "John"                    # first name
agent-browser fill "@e16" "Doe"                     # last name
agent-browser fill "@e17" "john@example.com"        # email
agent-browser fill "@e18" "+9779841234567"          # phone
agent-browser fill "@e19" "Early check-in please"   # special requests

# Submit booking
agent-browser click "@e25"  # submit button
agent-browser wait --load networkidle

# Extract confirmation code
CONFIRMATION=$(agent-browser eval "document.querySelector('.confirmation-code')?.textContent")
echo "Booking confirmed: $CONFIRMATION"

# Take screenshot
agent-browser screenshot booking-success.png
```

#### D. Booking Status Tracking
**URL**: `http://localhost:3001/booking/status?code=ABC123`

**Test Cases**:
1. ✅ **View Booking Status**
   - Enter confirmation code
   - View booking details
   - Check status (pending, confirmed, etc.)

**Automation Script**: `booking-status-test.sh`

---

### 3️⃣ **Owner Dashboard** (Priority: HIGH)

#### A. Dashboard Overview
**URL**: `http://localhost:3001/owner/dashboard`

**Test Cases**:
1. ✅ **View Dashboard Metrics**
   - Verify total bookings count
   - Check revenue display
   - Check occupancy rate
   - View recent bookings widget
   - Check room status overview

**Automation Script**: `dashboard-test.sh`

#### B. Booking Management
**URL**: `http://localhost:3001/owner/bookings`

**Test Cases**:
1. ✅ **View Bookings List**
   - Load bookings page
   - Verify bookings displayed
   - Check pagination

2. ✅ **Filter Bookings**
   - Filter by status (pending, confirmed, checked-in, etc.)
   - Search by guest name
   - Search by confirmation code

3. ✅ **Booking Actions**
   - Confirm pending booking
   - Check-in confirmed booking
   - Check-out checked-in booking
   - Extend booking
   - Cancel booking
   - Add charges to booking

4. ✅ **View Booking Detail**
   - Click booking row
   - Verify detail panel opens
   - Check guest info, room info, payment info

**Automation Script**: `booking-management-test.sh`
```bash
# Login first
./login-test.sh

# Navigate to bookings
agent-browser open http://localhost:3001/owner/bookings
agent-browser wait --load networkidle
agent-browser snapshot -i

# Filter by status
agent-browser click "@e10"  # status dropdown
agent-browser click "@e12"  # select "Pending"
agent-browser wait 2000

# Search by guest name
agent-browser fill "@e5" "John Doe"
agent-browser press Enter
agent-browser wait 2000

# Click first booking
agent-browser click "@e20"  # first booking row
agent-browser wait 1000

# Confirm booking
agent-browser click "@e30"  # confirm button
agent-browser wait 2000

# Take screenshot
agent-browser screenshot booking-confirmed.png
```

#### C. Guest Management
**URL**: `http://localhost:3001/owner/guests`

**Test Cases**:
1. ✅ **View Guests List**
2. ✅ **Create New Guest**
   - Click "Add Guest" button
   - Fill name, email, phone, address
   - Submit
   - Verify guest appears in list

3. ✅ **Edit Guest**
   - Click edit button
   - Update fields
   - Save
   - Verify changes

4. ✅ **Delete Guest**
   - Click delete button
   - Confirm deletion
   - Verify guest removed

**Automation Script**: `guest-management-test.sh`

#### D. Room Management
**URL**: `http://localhost:3001/owner/rooms`

**Test Cases**:
1. ✅ **View Rooms List**
2. ✅ **Create New Room**
   - Click "Add Room"
   - Fill room number, type, capacity
   - Select amenities
   - Add description
   - Submit

3. ✅ **Update Room Status**
   - Click room
   - Change status (available → occupied → cleaning → maintenance)
   - Verify status updated

4. ✅ **Kanban Board View**
   - Navigate to `/owner/rooms/board`
   - View rooms by status
   - Drag-drop room to change status

**Automation Script**: `room-management-test.sh`

#### E. Rate Management
**URL**: `http://localhost:3001/owner/rates/plans`

**Test Cases**:
1. ✅ **Create Rate Plan**
   - Click "Create Plan"
   - Fill plan name, base rate
   - Set seasonal adjustments
   - Submit

2. ✅ **Daily Rate Overrides**
   - Navigate to `/owner/rates/daily`
   - Select date range
   - Set override rates
   - Bulk create

3. ✅ **Fee Templates**
   - Navigate to `/owner/rates/fees`
   - Create fee (fixed or percentage)
   - Set applicability

4. ✅ **Tax Rules**
   - Navigate to `/owner/rates/tax`
   - Create tax rule
   - Set rate percentage

**Automation Script**: `rate-management-test.sh`

#### F. Payment & Invoice Management
**URL**: `http://localhost:3001/owner/payments`

**Test Cases**:
1. ✅ **Record Payment**
   - Click "Record Payment"
   - Search for booking
   - Select payment method
   - Enter amount
   - Submit

2. ✅ **View Invoices**
   - Navigate to `/owner/payments/invoices`
   - View invoice list
   - Click invoice to view detail

3. ✅ **Generate Invoice**
   - Select booking
   - Click "Generate Invoice"
   - Verify invoice created

4. ✅ **Manage Refunds**
   - Navigate to `/owner/payments/refunds`
   - Create refund request
   - Approve/reject refund

**Automation Script**: `payment-management-test.sh`

#### G. Reports & Analytics
**URL**: `http://localhost:3001/owner/reports`

**Test Cases**:
1. ✅ **View Occupancy Reports**
   - Select date range
   - View daily occupancy
   - View monthly occupancy
   - View by room type

2. ✅ **View Revenue Reports**
   - Select date range
   - View revenue summary
   - View by payment method
   - View by booking source

**Automation Script**: `reports-test.sh`

#### H. Team Management
**URL**: `http://localhost:3001/owner/settings/team`

**Test Cases**:
1. ✅ **Invite Team Member**
   - Click "Invite Member"
   - Enter email
   - Select role
   - Send invitation

2. ✅ **Update Member Role**
   - Click member
   - Change role
   - Save

3. ✅ **Remove Team Member**
   - Click remove
   - Confirm
   - Verify removed

**Automation Script**: `team-management-test.sh`

---

### 4️⃣ **Platform Admin** (Priority: MEDIUM)

#### A. User Management
**URL**: `http://localhost:3001/platform/users`

**Test Cases**:
1. ✅ **View Users List**
2. ✅ **Create User**
3. ✅ **Edit User**
4. ✅ **Delete User**
5. ✅ **Deactivate User**

**Automation Script**: `admin-users-test.sh`

#### B. Property Management
**URL**: `http://localhost:3001/platform/properties`

**Test Cases**:
1. ✅ **View Properties List**
2. ✅ **Approve Property**
3. ✅ **Reject Property**
4. ✅ **Edit Property**

**Automation Script**: `admin-properties-test.sh`

#### C. Role Management
**URL**: `http://localhost:3001/platform/roles`

**Test Cases**:
1. ✅ **Create Role**
2. ✅ **Assign Permissions**
3. ✅ **Edit Role**
4. ✅ **Delete Role**

**Automation Script**: `admin-roles-test.sh`

#### D. Audit Logs
**URL**: `http://localhost:3001/platform/audit`

**Test Cases**:
1. ✅ **View Audit Logs**
2. ✅ **Filter by User**
3. ✅ **Filter by Action**
4. ✅ **Filter by Date Range**

**Automation Script**: `admin-audit-test.sh`

---

## 🚀 Implementation Priority

### Phase 1: Critical User Flows (Week 1)
1. ✅ Login flow
2. ✅ Booking flow (end-to-end)
3. ✅ Hotel search and browse
4. ✅ Dashboard overview

### Phase 2: Owner Features (Week 2)
1. ✅ Booking management (confirm, check-in, check-out)
2. ✅ Guest management (CRUD)
3. ✅ Room management (CRUD + status updates)
4. ✅ Payment recording

### Phase 3: Advanced Features (Week 3)
1. ✅ Rate management (plans, daily rates, fees, taxes)
2. ✅ Reports and analytics
3. ✅ Team management
4. ✅ Property onboarding

### Phase 4: Admin Features (Week 4)
1. ✅ User management
2. ✅ Property approval
3. ✅ Role management
4. ✅ Audit logs

---

## 📁 Automation Script Structure

```
hotel-automation/
├── frontend-tests/
│   ├── auth/
│   │   ├── login-test.sh
│   │   ├── logout-test.sh
│   │   └── onboarding-test.sh
│   ├── guest/
│   │   ├── hotel-search-test.sh
│   │   ├── hotel-detail-test.sh
│   │   ├── booking-flow-test.sh
│   │   └── booking-status-test.sh
│   ├── owner/
│   │   ├── dashboard-test.sh
│   │   ├── booking-management-test.sh
│   │   ├── guest-management-test.sh
│   │   ├── room-management-test.sh
│   │   ├── rate-management-test.sh
│   │   ├── payment-management-test.sh
│   │   ├── reports-test.sh
│   │   └── team-management-test.sh
│   ├── admin/
│   │   ├── admin-users-test.sh
│   │   ├── admin-properties-test.sh
│   │   ├── admin-roles-test.sh
│   │   └── admin-audit-test.sh
│   └── run-all-tests.sh
└── frontend-results/
    ├── screenshots/
    ├── snapshots/
    └── test-reports/
```

---

## 🎯 Test Data Requirements

### Test Users
```json
{
  "owner": {
    "phone": "+9779841234567",
    "password": "owner123",
    "role": "owner"
  },
  "manager": {
    "phone": "+9779841234568",
    "password": "manager123",
    "role": "manager"
  },
  "front_desk": {
    "phone": "+9779841234569",
    "password": "frontdesk123",
    "role": "front_desk"
  },
  "admin": {
    "phone": "+9779841234570",
    "password": "admin123",
    "role": "platform_admin"
  }
}
```

### Test Properties
```json
{
  "property1": {
    "id": "uuid-1",
    "name": "Test Hotel Kathmandu",
    "location": "Thamel, Kathmandu"
  }
}
```

### Test Bookings
```json
{
  "booking1": {
    "confirmationCode": "TEST123",
    "guestName": "John Doe",
    "checkIn": "2026-03-10",
    "checkOut": "2026-03-12"
  }
}
```

---

## 🔧 Automation Utilities

### Helper Functions
```bash
# login-helper.sh
login_as_owner() {
  agent-browser open http://localhost:3001/login
  agent-browser snapshot -i
  agent-browser fill "@e2" "+9779841234567"
  agent-browser fill "@e3" "owner123"
  agent-browser click "@e5"
  agent-browser wait --load networkidle
}

# verify-helper.sh
verify_element_exists() {
  local ref=$1
  agent-browser is visible "@$ref"
}

verify_url_contains() {
  local expected=$1
  local actual=$(agent-browser get url)
  [[ "$actual" == *"$expected"* ]]
}

# screenshot-helper.sh
take_screenshot() {
  local name=$1
  local timestamp=$(date +%Y%m%d_%H%M%S)
  agent-browser screenshot "frontend-results/screenshots/${name}_${timestamp}.png"
}
```

---

## 📊 Expected Outcomes

### Success Metrics
- ✅ All critical user flows automated (login, booking, search)
- ✅ 50+ test scenarios covered
- ✅ Automated regression testing capability
- ✅ Visual validation via screenshots
- ✅ Data extraction for validation

### Benefits
1. **Faster Testing** - Automated tests run in minutes vs hours of manual testing
2. **Regression Prevention** - Catch bugs before deployment
3. **Documentation** - Tests serve as living documentation
4. **Confidence** - Deploy with confidence knowing features work
5. **CI/CD Integration** - Run tests automatically on every commit

---

## 🎬 Next Steps

### Immediate (Today)
1. ✅ Create `frontend-tests/` directory structure
2. ✅ Write `login-test.sh` script
3. ✅ Write `booking-flow-test.sh` script
4. ✅ Test both scripts in headed mode

### This Week
1. Complete Phase 1 scripts (critical flows)
2. Create helper utilities
3. Set up test data in backend
4. Document test results

### This Month
1. Complete all 50+ test scenarios
2. Integrate with CI/CD pipeline
3. Create test report dashboard
4. Train team on running tests

---

## 💡 Advanced Automation Ideas

### 1. Visual Regression Testing
- Take screenshots of all pages
- Compare with baseline images
- Detect UI changes automatically

### 2. Performance Testing
- Measure page load times
- Track API response times
- Monitor resource usage

### 3. Accessibility Testing
- Check for ARIA labels
- Verify keyboard navigation
- Test screen reader compatibility

### 4. Cross-Browser Testing
- Run tests in Chrome, Firefox, Safari
- Verify consistent behavior

### 5. Mobile Testing
- Test responsive design
- Verify mobile-specific features

---

**Status**: 📋 **Plan Complete - Ready for Implementation**  
**Total Test Scenarios**: 50+  
**Estimated Implementation Time**: 4 weeks  
**Priority**: HIGH - Critical for production readiness
