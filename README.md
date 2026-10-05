# NEXA Admin Lite - Enterprise Mobile Application

Compact enterprise administration Flutter mobile application built for Admin users, backed by Firebase (Authentication, Cloud Firestore, Firebase Storage, and Firebase Cloud Messaging).

---

## 🛠️ Tech Stack & Services

- **Framework:** Flutter (Dart SDK ^3.13.3)
- **Backend:** Firebase
  - **Authentication:** Firebase Auth (Email & Password, Session Persistence)
  - **Database:** Cloud Firestore
  - **Storage:** Firebase Cloud Storage (Profile photos, ID Proofs, Receipts)
  - **Push Notifications:** Firebase Cloud Messaging (FCM)
- **Device Capabilities:** Geolocator (GPS Geofencing), Image Picker, Google Maps Flutter
- **Architecture:** Layered Architecture (`core`, `models`, `services`, `screens`, `widgets`, `state`)

---

## 📁 Firestore Collection Structure

| Collection | Description | Document Fields |
| :--- | :--- | :--- |
| `users` | Admin user profiles | `uid`, `email`, `role`, `displayName`, `createdAt` |
| `employees` | Staff directory | `name`, `mobile`, `email`, `designation`, `branchId`, `status`, `photoUrl`, `createdAt` |
| `branches` | Branch locations & geofences | `name`, `latitude`, `longitude`, `radius`, `createdAt` |
| `attendance` | Geofence attendance records | `employeeId`, `branchId`, `timestamp`, `latitude`, `longitude`, `distanceMeters`, `status` |
| `customers` | Leads & customers | `name`, `mobile`, `email`, `status`, `notes`, `createdAt`, `updatedAt` |
| `documents` | Uploaded verification proofs | `customerId`, `type`, `fileUrl`, `fileName`, `uploadedAt`, `uploadedBy` |
| `expenses` | Approval requests | `employeeId`, `amount`, `category`, `description`, `receiptUrl`, `status`, `rejectionReason`, `approvedAt` |
| `audit_logs` | Immutable audit trail | `action`, `entityType`, `entityId`, `adminId`, `adminEmail`, `timestamp`, `metadata` |
| `notifications` | In-app notification queue | `title`, `body`, `targetRoute`, `payload`, `timestamp`, `read` |

---

## 🛡️ Security Rules

### Firestore Security (`firestore.rules`)
- **Authentication Required:** Protected collections (`employees`, `branches`, `attendance`, `customers`, `documents`, `expenses`, `audit_logs`) reject unauthenticated read and write requests.
- **Data Validation:** Strict type and enum validation for statuses (`Active`/`Inactive`, `Present`/`Absent`, `Pending`/`Approved`/`Rejected`).
- **Approval Constraints:** Rejection requires a non-empty `rejectionReason`.
- **Immutable Audit Logs:** `audit_logs` documents are append-only; update and delete operations are strictly prohibited.

### Firebase Storage Security (`storage.rules`)
- Read and write operations require valid user authentication.
- File uploads are validated by content type (`image/*`, `application/pdf`) and capped at a maximum of 10MB to prevent storage abuse.

---

## 🚀 Getting Started & Run Instructions

### 1. Prerequisites
- Flutter SDK 3.13.3+
- Android SDK (API 21+) / Physical Android device

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run Locally
```bash
flutter run
```

### 4. Build Release APK
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk` (renamed to `NEXA_Admin_<CandidateName>.apk`).
