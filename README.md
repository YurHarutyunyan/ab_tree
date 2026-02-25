# AB Tree Flutter Application

A complete Flutter mobile application with secure client-server architecture, featuring user authentication, app credits system, and Stripe payment integration. Ready for App Store deployment.

## Features

✅ User Registration & Authentication with JWT
✅ Secure REST API Backend
✅ App Credits System (2 credits per app, 5 after payment)
✅ Payment Processing with Stripe
✅ User Profile Management
✅ Apps Listing with Detail Pages
✅ Session Management
✅ Form Validation
✅ Beautiful Orange Gradient Theme
✅ Production-Ready Architecture

## Architecture

```
┌─────────────────┐
│  Flutter Client │  ←  Mobile app (iOS/Android)
│  (UI Layer)     │     Communicates via HTTPS
└────────┬────────┘
         │
         ↓ REST API
┌─────────────────┐
│  Node.js/Express│  ←  Backend API
│  Backend Server │     JWT Authentication
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│    MongoDB      │  ←  Database (in Docker)
│  (in Docker)    │
└─────────────────┘
```

## Tech Stack

**Frontend (Client):**
- Flutter (Dart)
- HTTP package for API calls
- Stripe Flutter SDK (client-side)
- SharedPreferences for local storage
- Provider for state management

**Backend (Server):**
- Node.js with Express
- MongoDB with Mongoose
- JWT for authentication
- Stripe API (server-side)
- Docker & Docker Compose

**Security:**
- JWT token-based authentication
- Bcrypt password hashing
- HTTPS/SSL in production
- Server-side payment processing
- No database credentials in client

## Project Structure

```
ab_tree_flutter/
├── lib/                          # Flutter app
│   ├── main.dart                 # App entry point
│   ├── config/
│   │   └── environment.dart      # Environment configuration
│   ├── models/                   # Data models
│   │   ├── user_model.dart
│   │   ├── app_model.dart
│   │   └── payment_model.dart
│   ├── services/                 # API & business logic
│   │   ├── api_client.dart       # HTTP client with JWT
│   │   ├── auth_service.dart     # Authentication
│   │   └── api_data_service.dart # Data operations
│   ├── screens/                  # UI screens
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── apps_screen.dart
│   │   ├── app_detail_screen.dart
│   │   ├── my_account_screen.dart
│   │   ├── support_screen.dart
│   │   └── payment_screen.dart
│   ├── widgets/                  # Reusable components
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   └── app_card.dart
│   └── utils/                    # Utilities
│       └── constants.dart        # App constants
│
├── backend/                      # Node.js backend
│   ├── config/
│   │   └── database.js          # MongoDB connection
│   ├── models/
│   │   ├── User.js              # User schema
│   │   └── Payment.js           # Payment schema
│   ├── routes/
│   │   ├── auth.js              # Auth endpoints
│   │   ├── user.js              # User endpoints
│   │   └── payment.js           # Payment endpoints
│   ├── middleware/
│   │   └── auth.js              # JWT middleware
│   ├── server.js                # Express server
│   ├── package.json
│   ├── Dockerfile
│   ├── docker-compose.yml
│   └── .env                     # Environment vars
│
├── start_app.sh                 # Start all services
├── stop_app.sh                  # Stop all services
├── view_db.sh                   # View database
├── DEPLOYMENT.md                # Production deployment guide
└── README.md                    # This file
```

## Prerequisites

- Flutter SDK (3.10.0 or higher)
- Dart SDK (3.10.8 or higher)
- Docker and Docker Compose
- Node.js 18+ and npm (for backend)
- Android Studio or VS Code with Flutter extensions
- Stripe account (for payment processing)

## Quick Start (Development)

### 1. Clone and Navigate

```bash
cd ab_tree_flutter
```

### 2. Install Flutter Dependencies

```bash
flutter pub get
```

### 3. Configure Stripe Keys

Get your Stripe test API keys from [Stripe Dashboard](https://dashboard.stripe.com/test/apikeys).

**Backend Configuration:**

Edit `backend/.env`:
```env
STRIPE_SECRET_KEY=sk_test_YOUR_ACTUAL_STRIPE_SECRET_KEY
STRIPE_PUBLISHABLE_KEY=pk_test_YOUR_ACTUAL_STRIPE_PUBLISHABLE_KEY
```

**Flutter Configuration:**

Edit `lib/utils/constants.dart`:
```dart
static const String stripePublishableKey = 'pk_test_YOUR_ACTUAL_STRIPE_PUBLISHABLE_KEY';
```

### 4. Start All Services

The easiest way to get started:

```bash
./start_app.sh
```

This will:
- Start MongoDB in Docker
- Start the backend API server in Docker
- Launch the Flutter app in development mode

**Services will be running at:**
- MongoDB: `mongodb://localhost:27017/ab_tree_db`
- Backend API: `http://localhost:3000`
- Backend Health Check: `http://localhost:3000/health`

### 5. Stop Services

```bash
./stop_app.sh
```

## Manual Backend Testing

You can test the backend API independently:

```bash
# Check health
curl http://localhost:3000/health

# Register a user
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "email": "test@example.com",
    "firstName": "Test",
    "lastName": "User",
    "password": "password123"
  }'

# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "password": "password123"
  }'

# Use the token from login response for protected endpoints
curl http://localhost:3000/api/user/profile \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## Running the Flutter App

### Development Mode (uses localhost:3000)

```bash
flutter run --dart-define=DEVELOPMENT=true
```

### Build for Production (uses your production API)

**Android:**
```bash
flutter build apk --release --dart-define=DEVELOPMENT=false
flutter build appbundle --release --dart-define=DEVELOPMENT=false
```

**iOS:**
```bash
flutter build ios --release --dart-define=DEVELOPMENT=false
```

## Testing Flow

1. **Register a new user**
   - Open the app
   - Navigate to Register screen
   - Fill in all fields
   - Submit registration

2. **Login**
   - Use your credentials
   - Should redirect to Apps screen

3. **View App Details**
   - Tap any app card
   - Should see 2 credits initially

4. **Use Credits**
   - Tap BUY button
   - Credits should decrement
   - Persist after logout/login

5. **Make Payment**
   - Navigate to payment screen
   - Use Stripe test card: `4242 4242 4242 4242`
   - Expiry: Any future date
   - CVC: Any 3 digits
   - After payment, all app credits should be 5

6. **Update Profile**
   - Go to My Account
   - Update email/phone
   - Changes should persist

## Database Management

View database contents:
```bash
./view_db.sh
```

Access MongoDB shell:
```bash
docker exec -it ab_tree_mongodb mongosh ab_tree_db
```

Clear all data:
```bash
docker exec ab_tree_mongodb mongosh ab_tree_db --eval "db.users.deleteMany({}); db.payments.deleteMany({})"
```

## Usage Guide

### 1. Registration Flow

1. Launch the app (opens Login screen)
2. Tap "Create Account"
3. Fill in the registration form:
   - First Name & Last Name
   - Email address
   - Username (at least 3 characters)
   - Password (at least 6 characters)
   - Confirm Password
4. Tap "Create Account"
5. You'll be redirected to Login screen

### 2. Login Flow

1. Enter your username/email
2. Enter your password
3. Tap "Log In"
4. Upon success, navigate to Payment screen

### 3. Payment Flow

1. Enter payment amount (default $100)
2. Fill in card details:
   - Card Number: Use `4242 4242 4242 4242` for testing
   - Cardholder Name
   - Expiry Date: Any future date (e.g., 12/25)
   - CVV: Any 3-4 digits (e.g., 123)
3. Fill in billing address
4. Tap "Process Payment"
5. Wait for processing (2-3 seconds)
6. Success modal appears with transaction ID
7. Tap "Done" to navigate to Apps screen

### 4. Apps Listing

1. View grid of 6 applications
2. Each card shows:
   - Badge (FREE, NEW, PREMIUM)
   - App icon
   - Name and tagline
   - Description
   - Features list
3. Tap any card to view details

### 5. App Details

1. View detailed app information
2. See ratings and reviews
3. Browse screenshots (placeholders)
4. Read user reviews
5. Tap "Open App" (shows notification)
6. Tap back button to return to Apps screen

## Testing

### Test Cards (Stripe)

- **Success**: 4242 4242 4242 4242
- **Declined**: 4000 0000 0000 0002
- **Authentication Required**: 4000 0025 0000 3155

Use any future expiry date and any CVV.

### Test User Data

You can create any user during registration. The app stores:
- Username
- Email
- Password (hashed with SHA-256)
- First & Last Name

## Troubleshooting

### Build Errors

If you get build errors, try:

```bash
flutter clean
flutter pub get
flutter run
```

### MongoDB Connection Issues

If MongoDB connection fails:
- Check your connection string
- Verify network connectivity
- The app will automatically fall back to in-memory storage

### Stripe Initialization Issues

If Stripe fails to initialize:
- Verify your publishable key is correct
- Check that you're using test keys (starts with `pk_test_`)
- The app will automatically fall back to simulated payments

### Hot Reload Not Working

```bash
# Stop the app and run with hot reload enabled
flutter run --hot
```

## Configuration Files

### constants.dart

Main configuration file containing:
- MongoDB connection string
- Stripe API keys
- Recipient card details
- App colors and gradients
- Countries list
- Validation regex patterns

### theme.dart

Theme configuration with:
- Color scheme
- Text styles
- Button styles
- Input field styles
- Card styles

## Database Schema

### Users Collection

```json
{
  "_id": "ObjectId",
  "username": "string",
  "email": "string",
  "firstName": "string",
  "lastName": "string",
  "passwordHash": "string",
  "createdAt": "ISODate"
}
```

### Payments Collection

```json
{
  "_id": "ObjectId",
  "userId": "string",
  "amount": "number",
  "cardLast4": "string",
  "cardHolder": "string",
  "transactionId": "string",
  "timestamp": "ISODate",
  "status": "string",
  "recipientCard": "string"
}
```

## Security Notes

⚠️ **Important Security Considerations:**

1. **Never commit API keys** to version control
2. Use environment variables for production
3. Implement proper password hashing (currently uses SHA-256)
4. Add rate limiting for authentication endpoints
5. Implement HTTPS for all API calls
6. Store sensitive keys in secure storage
7. Add input sanitization for all user inputs
8. Implement proper session timeout
9. Use refresh tokens for long-lived sessions
10. Add CAPTCHA for registration/login

## Production Checklist

Before deploying to production:

- [ ] Replace all placeholder API keys
- [ ] Set up proper MongoDB database
- [ ] Configure Stripe webhooks
- [ ] Implement proper error logging
- [ ] Add analytics tracking
- [ ] Set up crash reporting
- [ ] Test on multiple devices
- [ ] Implement proper backup strategy
- [ ] Add terms of service and privacy policy
- [ ] Configure app signing for release
- [ ] Set up CI/CD pipeline

## App Demo Data

The app includes 6 demo applications:

1. **Art Lunch** - Meal planning app
2. **Smart Portal** - Digital life management
3. **Business Hub** - Business management suite
4. **Learn Plus** - Education platform
5. **Creative Studio** - Design tools
6. **Finance Tracker** - Money management

## Support

For issues or questions:
1. Check the troubleshooting section
2. Review Flutter documentation
3. Check MongoDB Atlas documentation
4. Review Stripe documentation

## License

This project is created for educational purposes.

## Version History

### v1.0.0 (Current)
- Initial release
- Login & Registration
- Payment processing
- Apps listing
- App details
- MongoDB integration
- Stripe integration

## Contributing

This is a demo project. Feel free to fork and modify for your needs.

---

**Built with ❤️ using Flutter**
