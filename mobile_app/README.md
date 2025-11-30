
samples, guidance on mobile development, and a full API reference.

# Mobile App (Flutter)

This directory contains the Flutter mobile application for the e-Fine SL Traffic Management System.


## File/Folder Architecture
```
lib/
├── config/
│   ├── constants.dart
│   └── theme.dart
├── main.dart
├── models/                # (currently empty)
├── providers/             # (currently empty)
├── screens/
│   ├── auth/
│   │   ├── driver_signup_screen.dart
│   │   ├── forgot_password_screen.dart
│   │   ├── login_screen.dart
│   │   ├── police_signup_screen.dart
│   │   └── user_selection_screen.dart
│   ├── driver/
│   │   └── driver_home_screen.dart
│   ├── police/
│   │   └── police_home_screen.dart
│   └── splash/
│       └── splash_screen.dart
├── services/
│   └── auth_service.dart
├── widgets/
│   ├── custom_button.dart
│   └── custom_textfield.dart
```

## Current Stage
- Material 3 design implemented.
- Main screen and counter demo working.
- App successfully builds and runs on Android (V2419) and other platforms.
- Launcher icons configured.
- Project structure updated for better organization (see `lib/config/constants.dart`).
- Recent commits include configuration improvements and code cleanup.

## How to Run
1. Connect your Android device and enable USB debugging.
2. Run `flutter devices` to verify device connection.
3. Run `flutter run` to launch the app.

---

## Recent Updates – Police Officer Registration & Login Implementation

### New Screens

- **PoliceSignupScreen**
  - 3-step stepper form: handles OTP request, verification, and profile creation.
  - Input validation for NIC and phone number.
  - Searchable dropdown for station selection using `dropdown_search`.
- **LoginScreen**
  - Updated to support backend authentication.

### Services

- **AuthService**
  - Handles HTTP requests to backend for login, registration, and fetching stations.
- **Token Management**
  - Uses `flutter_secure_storage` to securely store JWT tokens locally.

### Key Packages Added

- `http`: For API communication.
- `flutter_secure_storage`: For secure local data storage.
- `dropdown_search`: For searchable station selection dropdown.

### Configuration

- Updated `AndroidManifest.xml` to allow cleartext traffic for local backend testing.

## How to Run
1. Install dependencies:
   ```bash
   flutter pub get
   ```
2. Run the app:
   ```bash
   flutter run
   ```


## Recent Changes & Next Steps

### Recent Changes
- Implemented PoliceSignupScreen with 3-step registration (OTP request, verification, profile creation).
- Added input validation for NIC and phone number in registration.
- Integrated backend authentication in LoginScreen with JWT token management.
- Added searchable dropdown for station selection using `dropdown_search`.
- AuthService now handles registration, login, and station fetching via HTTP.
- Secure token storage using `flutter_secure_storage`.
- Updated AndroidManifest.xml for local backend testing.
- Add 'Forgot Password' and password reset flow for police login and driver login.

### Next Steps
- Implement Police Home Page with dashboard, actions, and notifications.
- Develop Driver Home Page with driver-specific features and UI.
- Add user profile management and editing.
- Expand authentication, error handling, and user management features.
