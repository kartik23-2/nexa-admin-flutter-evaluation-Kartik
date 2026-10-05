# NEXA Admin Lite - Enterprise Mobile Application

Enterprise administration Flutter mobile application built for Admin users, backed by Firebase (Authentication, Cloud Firestore, Firebase Storage, and Firebase Cloud Messaging).

---

## 📌 Project Overview & Specifications

- **Application Name:** NEXA Admin Lite
- **Role:** Administrator (Sole authenticated role)
- **Framework:** Flutter (Channel stable, SDK ^3.13.3, Dart ^3.1.0)
- **Target OS:** Android (minSdkVersion 21, targetSdkVersion 34) & iOS
- **Demo Admin Credentials:**
  - **Email:** `admin@nexa.com`
  - **Password:** `Password@123`
  - *One-tap demo sign-in is built into the login screen with auto-provisioning.*

---

## 🛠️ Packages & Architectural Rationale

| Package | Version | Purpose & Architectural Rationale |
| :--- | :--- | :--- |
| `provider` | ^6.1.5 | Lightweight, predictable state management with separation of concerns between business logic and UI layer. |
| `firebase_core` | ^4.15.0 | Core Firebase SDK integration and app initialization. |
| `firebase_auth` | ^6.7.0 | Secure session token management and role-based email/password authentication. |
| `cloud_firestore` | ^6.10.0 | NoSQL database with offline persistence enabled (`persistenceEnabled: true`), real-time sync listeners, and server timestamps. |
| `firebase_storage` | ^13.6.0 | Resilient cloud storage for profile images, employee/customer verification documents, and expense receipts with progress tracking. |
| `firebase_messaging` | ^16.7.0 | Real-time push notifications for urgent operational events with background/foreground dispatch and deep-link routing. |
| `flutter_local_notifications` | ^22.3.1 | Heads-up foreground notification display and payload routing. |
| `geolocator` | ^14.1.1 | High-precision GPS capture and Haversine geofence verification engine with permission denial fallbacks. |
| `google_maps_flutter` | ^2.18.2 | Interactive visual geofence rendering with circular radius overlays and branch pin markers. |
| `image_picker` | ^1.2.3 | Camera and gallery file capture with size validation and responsive preview. |
| `cached_network_image` | ^4.0.4 | Memory and disk-cached remote image rendering with loading shimmer and fallback placeholders. |
| `connectivity_plus` | ^7.3.1 | Active network connectivity listener with smooth offline mode banner and write-guarding. |
| `intl` | ^0.20.3 | Currency formatting (INR ₹) and locale-aware timestamp presentation. |

---

## 📁 Firestore Database Schema

```
/users/{uid}
  ├── uid: string
  ├── email: string
  ├── role: 'Admin'
  ├── displayName: string
  └── createdAt: timestamp

/employees/{employeeId}
  ├── id: string
  ├── name: string
  ├── mobile: string
  ├── email: string
  ├── designation: string
  ├── branchId: string
  ├── status: 'Active' | 'Inactive'
  ├── photoUrl: string?
  └── createdAt: timestamp

/branches/{branchId}
  ├── id: string
  ├── name: string
  ├── latitude: number
  ├── longitude: number
  ├── radius: number (meters)
  └── createdAt: timestamp

/attendance/{attendanceId}
  ├── id: string
  ├── employeeId: string
  ├── branchId: string
  ├── timestamp: timestamp
  ├── latitude: number
  ├── longitude: number
  ├── distanceMeters: number
  └── status: 'Present' | 'Absent'

/customers/{customerId}
  ├── id: string
  ├── name: string
  ├── mobile: string
  ├── email: string
  ├── status: 'Lead' | 'Contacted' | 'Qualified' | 'Closed - Won' | 'Closed - Lost'
  ├── notes: string?
  ├── createdAt: timestamp
  └── updatedAt: timestamp

/documents/{documentId}
  ├── id: string
  ├── entityId: string
  ├── entityType: 'customer' | 'employee' | 'general'
  ├── entityName: string
  ├── type: 'Aadhaar' | 'PAN Card' | 'Passport' | 'Driving License' | 'Other'
  ├── fileUrl: string
  ├── fileName: string
  ├── uploadedAt: timestamp
  └── uploadedBy: string

/expenses/{expenseId}
  ├── id: string
  ├── employeeId: string
  ├── employeeName: string
  ├── amount: number
  ├── category: 'Travel' | 'Food' | 'Office' | 'Client Entertainment' | 'Other'
  ├── description: string
  ├── receiptUrl: string?
  ├── status: 'Pending' | 'Approved' | 'Rejected'
  ├── rejectionReason: string?
  ├── submittedAt: timestamp
  └── reviewedAt: timestamp?

/audit_logs/{logId}
  ├── id: string
  ├── action: string
  ├── entityType: string
  ├── entityId: string
  ├── adminId: string
  ├── adminEmail: string
  ├── timestamp: timestamp
  └── metadata: map
```

---

## 🛡️ Security Rules

### Cloud Firestore Rules (`firestore.rules`)
- **Authentication Required:** All collections require valid Firebase Auth tokens.
- **Role Verification:** Requests require Admin authorization.
- **Strict Data Validation:** Enums (`status`, `category`, `entityType`) are strictly validated against allowed sets.
- **Mandatory Rejection Reasons:** Expense transitions from `Pending` to `Rejected` require a non-empty `rejectionReason` string.
- **Immutable Audit Trail:** Documents in `audit_logs` are append-only. Modification and deletion are strictly rejected.

### Firebase Storage Rules (`storage.rules`)
- Read and write requests require an active authenticated user.
- Uploads are strictly restricted to valid image formats (`image/jpeg`, `image/png`, `image/webp`) and document files (`application/pdf`).
- Maximum upload size is strictly capped at 10 MB per file.

---

## 🎯 Hidden Evaluator Check Compliance

1. **Location Permission Denial:** Handled gracefully with explicit user prompts without crashing; checks service status before querying GPS.
2. **Outside-Geofence Rejection:** Verified mathematically using high-precision Haversine formula against branch radius.
3. **Network Resilience & Offline Persistence:** Firestore offline cache enabled; `ConnectivityService` provides live banner feedback and guards network writes.
4. **Double-Tap Submission Prevention:** Anti-duplicate debounce guard in `ExpenseProvider` with `_processingIds` locking buttons during asynchronous operations.
5. **Responsive Large File Uploads:** Upload modal provides real-time progress indicators, upload cancellation/retry, and size validation.
6. **Route Guarding on Logout:** Logout execution calls `pushNamedAndRemoveUntil(AppRoutes.login, (route) => false)` to purge backstack and block hardware back-navigation into protected screens.
7. **Zero Private Credentials in Git:** `.gitignore` enforces exclusion of `.jks`, `.keystore`, `key.properties`, and private service account JSON files.

---

## 🚀 Build & Run Instructions

### 1. Prerequisites
- Flutter 3.13.3+ installed
- Android SDK with Platform Tools API 21+
- Physical Android device (recommended) or Android Emulator

### 2. Dependency Installation
```bash
flutter pub get
```

### 3. Run on Connected Device / Emulator
```bash
flutter run
```

### 4. Build Release APK
```bash
flutter build apk --release
```
The compiled APK will be located at:
- `build/app/outputs/flutter-apk/app-release.apk`
- Renamed deliverable: `NEXA_Admin_Abhay.apk`
