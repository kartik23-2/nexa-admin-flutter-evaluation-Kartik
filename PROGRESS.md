# NEXA Admin Lite - Implementation Progress & Tracking

A comprehensive tracking checklist and execution guide based on the **NEXA Admin Lite Flutter Internship Evaluation PRD**.

---

## 📌 Project Overview & Specifications

- **Project:** NEXA Admin Lite (Enterprise Admin Mobile App)
- **Role:** Admin Only
- **Tech Stack:** Flutter, Cloud Firestore, Firebase Authentication, Firebase Storage, Firebase Cloud Messaging (FCM)
- **Duration:** 1 Working Day (~8 hours)
- **Output Artifacts:** Working APK (`NEXA_Admin_<CandidateName>.apk`), Git Repository, `README.md`, Firebase Security Rules

---

## 🚦 Overall Status Summary

| Phase / Module | Total Tasks | Completed | In Progress | Pending | Status |
| :--- | :---: | :---: | :---: | :---: | :---: |
| 1. Project Setup & Architecture | 7 | 7 | 0 | 0 | 🟢 Completed |
| 2. Firebase Configuration & Rules | 6 | 6 | 0 | 0 | 🟢 Completed |
| 3. Authentication & Session | 7 | 7 | 0 | 0 | 🟢 Completed |
| 4. Core UI & Theming | 6 | 6 | 0 | 0 | 🟢 Completed |
| 5. Dashboard & Analytics | 7 | 7 | 0 | 0 | 🟢 Completed |
| 6. Employee Management | 9 | 9 | 0 | 0 | 🟢 Completed |
| 7. Branch & Geofence Management | 8 | 8 | 0 | 0 | 🟢 Completed |
| 8. Attendance & GPS Geofence Test | 9 | 9 | 0 | 0 | 🟢 Completed |
| 9. Customer / Lead Management | 8 | 8 | 0 | 0 | 🟢 Completed |
| 10. Document Upload (ID Proof) | 7 | 7 | 0 | 0 | 🟢 Completed |
| 11. Approval Workflow (Expenses) | 8 | 8 | 0 | 0 | 🟢 Completed |
| 12. FCM Push Notifications | 6 | 6 | 0 | 0 | 🟢 Completed |
| 13. Centralized Audit Logging | 6 | 6 | 0 | 0 | 🟢 Completed |
| 14. Error States & Edge Cases | 8 | 0 | 0 | 8 | ⬜ Not Started |
| 15. Testing, Verification & Submission | 7 | 0 | 0 | 7 | ⬜ Not Started |
| **Total** | **109** | **94** | **0** | **15** | **86.2% Completed** |

---

## 📋 Detailed Task Breakdown

### 1. Project Setup & Architecture
- [x] Initialize Flutter project with clean package naming
- [x] Configure suggested directory structure:
  - `lib/core/` (theme, constants, utilities, routes)
  - `lib/models/` (typed data models with `toMap`/`fromMap`)
  - `lib/services/` (auth, firestore, storage, location, notification)
  - `lib/screens/` (feature screens)
  - `lib/widgets/` (reusable UI components)
  - `lib/state/` (chosen state management solution)
- [x] Add and resolve essential dependencies in `pubspec.yaml`:
  - `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage`, `firebase_messaging`
  - `geolocator`, `google_maps_flutter` (or map package)
  - `image_picker`, `cached_network_image`, `intl`
  - State management package (e.g. `provider`, `riverpod`, or `bloc`)
- [x] Setup Android configuration (`minSdkVersion 21+`, multiDex, permissions)
- [x] Add `.gitignore` safeguarding secrets, signing keys, and service account JSONs
- [x] Setup app routing and global navigation keys
- [x] Configure dependency injection / service locator if applicable

### 2. Firebase Configuration & Security Rules
- [x] Create & configure Firebase project
- [x] Add Android app and configure `google-services.json`
- [x] Create Firestore collections and indexes schema:
  - `users`, `employees`, `branches`, `attendance`, `customers`, `documents`, `expenses`, `audit_logs`, `notifications`
- [x] Write `firestore.rules`:
  - Enforce Firebase Auth requirement across all business collections
  - Validate write permissions and data constraints
  - Reject unauthenticated access
- [x] Write `storage.rules`:
  - Enforce authenticated read/write
  - Limit file size and allowed image/document mime types
- [x] Document security rules and schema in `README.md`

### 3. Authentication & Session Management
- [x] Create Admin Login screen with email & password inputs
- [x] Implement Firebase Authentication sign-in flow
- [x] Implement session persistence & Auth state listener (`StreamBuilder` / Auth gate)
- [x] Implement Logout flow (ensure clean redirection and clear cached session)
- [x] Implement Forgot Password / Password Reset email flow
- [x] Add input validation (valid email format, password minimum length)
- [x] Map and display meaningful Firebase Auth error messages (e.g., user-not-found, wrong-password, network-request-failed)

### 4. Core UI, Theming & Reusable Widgets
- [x] Define comprehensive `AppTheme` (Color palette, typography, button styles, input decorations)
- [x] Implement custom reusable app bar, drawer, and bottom navigation bar
- [x] Implement `LoadingView` / shimmer indicators for async operations
- [x] Implement `EmptyStateWidget` with descriptive messaging and illustrations
- [x] Implement `ErrorStateWidget` with retry button callback
- [x] Implement confirmation modals, snackbars, and status badges

### 5. Dashboard & Analytics
- [x] Design and build Dashboard layout with responsive grid/list
- [x] Implement KPI Card: **Total Employees**
- [x] Implement KPI Card: **Today's Present/Absent Count**
- [x] Implement KPI Card: **Total Customers / Leads**
- [x] Implement KPI Card: **Pending Approvals Count**
- [x] Implement KPI Card: **Today's Collections Amount**
- [x] Add pull-to-refresh (`RefreshIndicator`) querying real Firestore data

### 6. Employee Management Module
- [x] Employee model (`id`, `name`, `mobile`, `email`, `designation`, `branchId`, `status`, `photoUrl`, `createdAt`)
- [x] Employee list screen with real-time Firestore stream/query
- [x] Search employees by name (instant query/filter)
- [x] Filter employees by status (`Active` / `Inactive`)
- [x] Add Employee form with validation (required fields, phone format, email format)
- [x] Edit Employee form and update logic
- [x] Activate / Deactivate employee toggle
- [x] Profile photo selection & upload to Firebase Storage
- [x] Employee detail view showing complete employee profile and assigned branch

### 7. Branch & Geofence Configuration
- [x] Branch model (`id`, `name`, `latitude`, `longitude`, `radius`, `createdAt`)
- [x] Branch CRUD screens (list, add, edit, delete)
- [x] Interactive Map screen displaying branch coordinates
- [x] Render visual geofence circle overlay representing configured radius
- [x] Interactive picker / manual entry to adjust latitude, longitude, and radius (in meters)
- [x] Form validation for GPS coordinates and minimum radius
- [x] Persist branch configuration in Firestore
- [x] Audit log trigger on branch creation or geofence boundary change

### 8. Attendance & GPS Geofence Test (Core Challenge)
- [x] Attendance model (`id`, `employeeId`, `branchId`, `timestamp`, `latitude`, `longitude`, `distanceMeters`, `status`, `verificationNote`)
- [x] Location permission flow (handle `denied`, `deniedForever`, and `granted`)
- [x] Device GPS availability check (prompt user if GPS is disabled)
- [x] Fetch high-accuracy current GPS position
- [x] Distance calculation engine comparing current position with target branch coordinates
- [x] Geofence verification logic:
  - If `distance <= radius` ➔ Accept attendance & record in Firestore
  - If `distance > radius` ➔ Reject attendance with clear explanation of distance delta
- [x] Attendance log screen with date and status filters
- [x] Visual Test Check-In UI demonstrating clear pass/fail status and distance indicators
- [x] Comprehensive error handling preventing app crashes on location failure

### 9. Customer / Lead Management
- [x] Customer model (`id`, `name`, `mobile`, `email`, `status`, `notes`, `createdAt`, `updatedAt`)
- [x] Customer list screen populated from Firestore
- [x] Search customers by name or mobile number
- [x] Filter customers by status (`New`, `Contacted`, `Interested`, `Converted`, `Rejected`)
- [x] Create Customer form with validation
- [x] Edit Customer details and status transition
- [x] Customer Detail screen displaying contact info, status timeline, and documents
- [x] Audit log trigger on customer creation/update

### 10. Document Upload (ID Proof)
- [x] Document model (`id`, `customerId`/`employeeId`, `type`, `fileUrl`, `fileName`, `uploadedAt`, `uploadedBy`)
- [x] Image selection modal (Camera vs. Gallery)
- [x] Image preview before initiating upload
- [x] Firebase Storage upload service with upload progress indicator
- [x] Store document metadata and download URL in Firestore
- [x] Upload failure error handling with retry capability
- [x] Document viewer / preview dialog for uploaded files

### 11. Approval Workflow (Expense Approvals)
- [x] Expense model (`id`, `employeeId`, `amount`, `category`, `description`, `receiptUrl`, `status`, `rejectionReason`, `approvedAt`)
- [x] Pending expenses list view with filter by date/amount
- [x] Expense detail view with receipt image preview
- [x] Approve action updating status to `Approved`
- [x] Reject action prompting mandatory rejection reason dialog
- [x] Anti-duplicate submission protection (debounce/disable buttons during execution)
- [x] Audit log recording for final approval/rejection decision
- [x] Status updates reflected in real-time on dashboard counters

### 12. Push Notification Workflow (FCM)
- [x] Initialize Firebase Cloud Messaging and request user permissions
- [x] Retrieve and store device FCM token
- [x] Foreground notification handler with in-app banner/snackbar
- [x] Background / terminated state notification handler
- [x] Payload configuration for new expense/approval event
- [x] Deep-link navigation: tapping notification opens target Expense Approval Detail screen

### 13. Centralized Audit Logging
- [x] Audit Log model (`id`, `action`, `entityType`, `entityId`, `adminId`, `adminEmail`, `timestamp`, `metadata`)
- [x] Centralized `AuditService.logAction(...)` utility
- [x] Log actions on:
  - Employee created / updated / deactivated
  - Branch or geofence created / updated
  - Expense approved / rejected
  - Customer created / updated
  - Document uploaded
- [x] Audit logs viewer screen for Admin with timeline view

### 14. Application States & Edge Case Hardening
- [ ] Full coverage of major UI states:
  - Loading / Progress state
  - Success feedback
  - Empty collection state
  - Error state with user retry
  - Uploading / Submitting state
  - Permission-denied fallback state
- [ ] Network & offline connectivity handling:
  - Connectivity listener (`connectivity_plus` or similar)
  - Prevent connectivity-dependent writes gracefully
  - Leverage Firestore offline persistence
- [ ] Hidden evaluator check hardening:
  - Location permission denied handled gracefully without crash
  - Outside-geofence rejection validated
  - No crash on sudden network loss
  - Double-tap approval prevention verified
  - Large image uploads handled with responsive UI
  - Route guard prevents back-navigation to protected screens after logout
  - Zero private credentials or keys committed to Git

### 15. Testing, Verification & Submission Deliverables
- [ ] Clean debug logs and unused imports
- [ ] Build release Android APK: `NEXA_Admin_<CandidateName>.apk`
- [ ] Install and verify APK on physical Android device
- [ ] Verify complete auth, CRUD, geofence, and upload flows on device
- [ ] Prepare comprehensive `README.md`:
  - Project Overview
  - Flutter & Dart versions
  - Packages and rationale
  - Firebase architecture & setup instructions
  - Build & run instructions
  - Firestore schema & security rules
  - Known limitations
- [ ] Prepare final submission message format
- [ ] Final Git commit and tree verification

---

## ⏱️ Recommended One-Day Timeline

```
0:00 - 0:30  | Phase 1: Flutter setup, Firebase connection, Authentication
0:30 - 1:30  | Phase 2: Navigation, AppTheme, Dashboard & Employee CRUD
1:30 - 2:30  | Phase 3: Customer CRUD & Firebase Storage upload
2:30 - 3:30  | Phase 4: Branch, Map & Geofence configuration
3:30 - 4:30  | Phase 5: Attendance / GPS Geofence test engine
4:30 - 5:30  | Phase 6: Expense Approval workflow & Audit Logging
5:30 - 6:15  | Phase 7: FCM Push Notification integration
6:15 - 7:15  | Phase 8: State handling, offline resilience & Security Rules
7:15 - 8:00  | Phase 9: Testing, APK build, README & Git finalization
```
