

# Backend API – Police Authentication Module

## New Features

- **Police Station Master Data Seeding**
	- Seeder script (`seeder.js`) to populate station data.
- **Email-based OTP Verification**
	- Sends OTP to OIC's official email using nodemailer.
- **Secure Police Registration & Login**
	- JWT authentication for police officers.

## Database Models

- **Station**
	- Stores station name, district, and official OIC email.
- **Verification**
	- Stores temporary OTP codes for registration.
- **Police**
	- Stores officer details: Name, BadgeID, NIC, Phone, Password.

## API Endpoints

- `POST /api/auth/request-verification`
	- Sends OTP to OIC email for officer registration.
- `POST /api/auth/verify-otp`
	- Validates the OTP code.
- `POST /api/auth/register-police`
	- Creates police account after OTP validation.
- `POST /api/auth/login`
	- Authenticates officer and returns JWT token.
- `GET /api/stations`
	- Fetches list of police stations.

### Example Request: Send OTP
```http
POST /api/auth/request-verification
Content-Type: application/json

{
	"badgeNumber": "123456",
	"stationCode": "GAL-HQ"
}
```

### Example Request: Register Police
```http
POST /api/auth/register-police
Content-Type: application/json

{
	"name": "John Doe",
	"badgeNumber": "123456",
	"email": "john@police.lk",
	"nic": "199912345678",
	"phone": "0712345678",
	"password": "securePass123",
	"station": "GAL-HQ",
	"otp": "654321"
}
```

## Environment Variables

- `MONGO_URI` – MongoDB connection string
- `EMAIL_USER` – Gmail address for nodemailer
- `EMAIL_PASS` – Gmail app password

## Quick Start

1. Install dependencies:
	 ```bash
	 npm install
	 ```
2. Create a `.env` file in `backend_api/` with required variables.
3. Seed station data:
	 ```bash
	 node seeder.js
	 ```
4. Start the server:
	 ```bash
	 node server.js
	 ```


## Recent Changes & Next Steps

### Recent Changes
- Improved police registration flow and OTP verification.
- Enhanced email template for OIC notifications.
- Added police station master data seeding.
- JWT-based login for police officers.

### Next Steps
- Add 'Forgot Password' functionality for police login.
- Implement Police Home Page with dashboard and actions.
- Develop Driver Home Page for driver-specific features.
- Expand API endpoints for password reset and user management.

## Notes

- Ensure Gmail account allows app password for nodemailer.
- MongoDB must be running and accessible via provided URI.
