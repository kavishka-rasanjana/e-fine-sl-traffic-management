# How to Run the Mobile App

To run the E-Fine SL Driver Mobile Application:

1. Make sure you have Flutter installed. If not, follow the official guide: https://docs.flutter.dev/get-started/install
2. Connect your Android device (or use an emulator) and enable USB debugging.
3. Open a terminal in the `mobile_app` directory.
4. Install dependencies:
  ```bash
  flutter pub get
  ```
5. Run the app:
  ```bash
  flutter run
  ```
6. For multi-language support, ensure the `assets/translations/en.json` and `assets/translations/si.json` files are present.

**Note:**
- If connecting to a backend API, update the base URL in `lib/services/auth_service.dart` as needed.
- For iOS, additional setup may be required (see Flutter docs).

# E-Fine SL Driver Mobile Application

## Recent Updates & Features Implemented

### Smart License Scanning (OCR)
- Integrated Google ML Kit for scanning driving licenses.
- Automatically detects Issue/Expiry dates and Vehicle Classes using advanced geometric row matching logic.
- Includes a validation step to ensure the scanned license matches the registered user's license number.

### Dynamic Driver Dashboard
- Implemented a comprehensive 'Driver Home Screen' featuring:
  - Real-time 'Demerit Point Meter' (using percent_indicator).
  - Dynamic greeting system based on the time of day.
  - 'Unpaid Fines Alert' system for immediate notifications.

### Digital Profile System
- Developed a detailed Profile Screen displaying:
  - Personal information.
  - License status (Active/Suspended).
  - Vehicle classes in a digital card format.
- Data is securely fetched from the backend API (`/me`).

### Localization (Multi-language)
- Full support for English and Sinhala languages using easy_localization.
- Dynamic translation for API data fields, including status messages.

### Secure Authentication
- Driver Registration with rigorous validation (NIC, Phone, Strong Password).
- Role-Based Login system for enhanced security.

## Updated Folder Structure

```
📦 lib/
 ├── main.dart                # App entry point
 ├── config/                  # App-wide configuration (themes, constants)
 ├── models/                  # Data models (Driver, Police, Offense, etc.)
 ├── providers/               # State management (Provider classes)
 ├── screens/
 │    ├── auth/               # Authentication screens
 │    │    ├── driver_signup_screen.dart
 │    │    ├── forgot_password_screen.dart
 │    │    ├── login_screen.dart
 │    │    ├── police_signup_screen.dart
 │    │    └── user_selection_screen.dart
 │    ├── driver/             # Driver features
 │    │    ├── driver_home_screen.dart
 │    │    ├── profile_screen.dart
 │    │    └── license_verification_screen.dart
 │    ├── police/             # Police features
 │    │    └── police_home_screen.dart
 │    └── splash/             # Splash and onboarding
 │         └── splash_screen.dart
 ├── services/                # API and business logic
 │    └── auth_service.dart
 └── widgets/                 # Reusable UI components
      ├── custom_button.dart
      └── custom_textfield.dart

🎨 assets/
 ├── icons/
 │    └── app_icon/           # App icons
 └── translations/            # Localization files
      ├── en.json
      └── si.json
```
> This creative structure highlights the modular design and separation of concerns, making the codebase easy to navigate and maintain.
