# Backend API – E-Fine SL System

## Quick Start

1. Install dependencies:

   ```bash
   cd backend_api
   npm install
   ```

2. Create `.env` file with `MONGO_URI`, `JWT_SECRET`, and E-mail credentials.
3. Run the server:

   ```bash
   npm run dev
   ```

## Recent API Enhancements

### 🚦 Fine Management

**`GET /api/fines/pending`**

- **Description:** Fetches all 'Unpaid' or 'Pending' fines for a specific driver.
- **Query Param:** `licenseNumber` (required).
- **Usage:** Used by the Driver App to show real-time fine alerts.

**`GET /api/fines/history`**

- **Description:** Fetches the fine issuance history.
- **Query Param:** `policeOfficerId` (optional, to filter by officer).

### 🔐 Authentication & Profile

**`POST /api/auth/login` (Updated)**

- Now returns additional driver details: `isVerified`, `licenseNumber`, and `nic` to facilitate frontend logic.

**`PUT /api/auth/profile-image` (Optimized)**

- Refactored to use `findByIdAndUpdate` for smoother updates without triggering strict schema validation on legacy data.

### 👮 Police Module

- **OTP Verification:** Email-based OTP for secure officer registration.
- **Station Management:** Seeding scripts for police station data.

## API Endpoints Summary

### Auth

- `POST /api/auth/register-driver` - Register new driver.
- `POST /api/auth/login` - Login (Driver/Police).
- `GET /api/auth/me` - Get current user profile.
- `PUT /api/auth/verify-driver` - Update driver verification data (OCR).

### Fines

- `POST /api/fines/issue` - Issue a new fine (Police).
- `POST /api/fines/pay` - **(Coming Soon)** Process fine payment.

## Future Plans & Roadmap

- **💳 Payment Gateway:** Integrate **PayHere** for online fine settlements.
- **📉 Demerit System:** Logic to automatically deduct points upon fine issuance/payment.
- **📱 SMS Notifications:** Send SMS to drivers when a fine is issued.

## Database Models

- **Driver:** Stores registered driver info, license details, and demerit points.
- **Police:** Officer details, station assignment, and badge number.
- **IssuedFine:** Records of all traffic violations, linked to `licenseNumber` and `offenseId`.
- **Offense:** Master data of traffic rules and fine amounts.
