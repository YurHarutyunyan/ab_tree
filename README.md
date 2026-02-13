# AB Tree Flutter Application

A complete Flutter mobile application with Login, Registration, Payment System, and Apps listing functionality. Built with MongoDB Atlas for backend storage and Stripe for payment processing.

## Features

✅ User Registration & Authentication
✅ Secure Login System
✅ Payment Processing with Stripe
✅ Apps Listing with Card Grid
✅ App Detail Pages
✅ MongoDB Integration
✅ Session Management
✅ Form Validation
✅ Beautiful Orange Gradient Theme

## Screenshots

- Login Screen with authentication
- Registration form with validation
- Payment screen with card input
- Apps grid with 6 applications
- Detailed app pages with reviews

## Tech Stack

- **Frontend**: Flutter (Dart)
- **Database**: MongoDB Atlas with mongo_dart
- **Payment**: Stripe Flutter SDK
- **State Management**: Provider
- **Local Storage**: SharedPreferences

## Project Structure

```
lib/
├── main.dart                 # App entry point with routing
├── models/                   # Data models
│   ├── user_model.dart      # User data structure
│   ├── app_model.dart       # App data structure
│   └── payment_model.dart   # Payment data structure
├── services/                 # Business logic
│   ├── mongodb_service.dart # Database operations
│   ├── auth_service.dart    # Authentication logic
│   └── payment_service.dart # Payment processing
├── screens/                  # UI screens
│   ├── login_screen.dart    # Login page
│   ├── register_screen.dart # Registration page
│   ├── payment_screen.dart  # Payment form
│   ├── apps_screen.dart     # Apps listing
│   └── app_detail_screen.dart # App details
├── widgets/                  # Reusable components
│   ├── custom_button.dart   # Gradient buttons
│   ├── custom_text_field.dart # Styled input fields
│   └── app_card.dart        # App card component
└── utils/                    # Utilities
    ├── constants.dart        # App constants & config
    └── theme.dart           # App theme configuration
```

## Prerequisites

- Flutter SDK (3.10.0 or higher)
- Dart SDK (3.10.8 or higher)
- Android Studio or VS Code with Flutter extensions
- MongoDB Atlas account (optional - works with in-memory storage)
- Stripe account (optional - works in demo mode)

## Installation

### 1. Clone and Navigate

```bash
cd ab_tree_flutter
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Configure MongoDB (Optional)

If you want to use real MongoDB storage:

1. Create a free account at [MongoDB Atlas](https://cloud.mongodb.com)
2. Create a new cluster (free tier M0)
3. Get your connection string
4. Open `lib/utils/constants.dart`
5. Replace `YOUR_MONGODB_CONNECTION_STRING` with your actual connection string

Example:
```dart
static const String mongoDbConnectionString = 
  'mongodb+srv://username:password@cluster.mongodb.net/ab_tree_db?retryWrites=true&w=majority';
```

**Note**: If you skip this step, the app will use in-memory storage (data won't persist after app restart).

### 4. Configure Stripe (Optional)

If you want real payment processing:

1. Create an account at [Stripe](https://stripe.com)
2. Get your test API keys from the Dashboard
3. Open `lib/utils/constants.dart`
4. Replace the placeholder keys:

```dart
static const String stripePublishableKey = 'pk_test_your_key_here';
static const String stripeSecretKey = 'sk_test_your_key_here';
```

**Note**: If you skip this step, the app will simulate payments (still works for testing).

### 5. Update Recipient Card (Optional)

In `lib/utils/constants.dart`, update the recipient card details:

```dart
static const String recipientCardNumber = '**** **** **** YOUR_LAST_4_DIGITS';
static const String recipientName = 'Your Business Name';
```

## Running the App

### Check Connected Devices

```bash
flutter devices
```

### Run on Connected Device

```bash
flutter run
```

### Run on Specific Device

```bash
flutter run -d <device_id>
```

### Build for Release

**Android:**
```bash
flutter build apk
```

**iOS:**
```bash
flutter build ios
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
