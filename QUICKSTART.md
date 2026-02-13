# Quick Start Guide

Get the AB Tree Flutter app running in 5 minutes!

## Prerequisites Check

Before starting, make sure you have:

```bash
# Check Flutter installation
flutter --version

# Check if Flutter is set up correctly
flutter doctor
```

If any issues appear, follow the instructions to fix them.

## Installation (3 Steps)

### Step 1: Get Dependencies

```bash
cd ab_tree_flutter
flutter pub get
```

This installs all required packages.

### Step 2: Run the App

```bash
flutter run
```

Or choose a specific device:

```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

### Step 3: Start Testing!

The app will launch on your device/emulator.

## First Time Usage

### 1. Register a New User

1. App opens to **Login Screen**
2. Click **"Create Account"**
3. Fill in the form:
   - First Name: `John`
   - Last Name: `Doe`
   - Email: `john@example.com`
   - Username: `johndoe`
   - Password: `password123`
   - Confirm Password: `password123`
4. Click **"Create Account"**
5. You'll see "Registration successful" message
6. You're redirected back to Login

### 2. Login

1. Enter your credentials:
   - Username: `johndoe`
   - Password: `password123`
2. Click **"Log In"**
3. You're redirected to Payment Screen

### 3. Make a Test Payment

1. Amount is pre-filled with $100 (you can change it)
2. Enter card details:
   - **Card Number**: `4242 4242 4242 4242` (test card)
   - **Cardholder**: `John Doe`
   - **Expiry**: `12/25` (any future date)
   - **CVV**: `123` (any 3 digits)
3. Fill billing address:
   - Address: `123 Main St`
   - City: `New York`
   - ZIP: `10001`
   - Country: `United States`
4. Click **"Process Payment"**
5. Wait 2-3 seconds for processing
6. Success dialog appears with Transaction ID
7. Click **"Done"**
8. You're redirected to Apps Screen

### 4. Browse Apps

1. See grid of 6 applications
2. Each card shows:
   - App icon and name
   - Badge (FREE, NEW, PREMIUM)
   - Description
   - Features
3. Tap any card to see details

### 5. View App Details

1. See full app information
2. View ratings and reviews
3. Browse screenshots (placeholders)
4. Tap **"Open App"** (shows notification)
5. Tap back button to return to Apps

### 6. Logout

1. Click **"Logout"** button in top bar
2. You're redirected to Login Screen

## Development Tips

### Hot Reload

While app is running, make code changes and press:
- `r` - Hot reload
- `R` - Hot restart
- `q` - Quit

### View Logs

```bash
# Run with verbose logging
flutter run -v

# View logs only
flutter logs
```

### Clear Data

If you need to reset:

```bash
# Clear build cache
flutter clean

# Reinstall dependencies
flutter pub get

# Rebuild and run
flutter run
```

## Default Test Data

### Test Users

You can register any user, but here's an example:

| Field | Value |
|-------|-------|
| Username | testuser |
| Password | test123 |
| Email | test@example.com |
| First Name | Test |
| Last Name | User |

### Test Cards

**Success**: `4242 4242 4242 4242`
**Decline**: `4000 0000 0000 0002`
**Authentication**: `4000 0025 0000 3155`

All need:
- Expiry: Any future date
- CVV: Any 3 digits
- ZIP: Any 5 digits

### Included Apps

1. **Art Lunch** (🍽️) - Meal planning
2. **Smart Portal** (🌐) - Digital management
3. **Business Hub** (💼) - Business tools
4. **Learn Plus** (📚) - Education
5. **Creative Studio** (🎨) - Design tools
6. **Finance Tracker** (💰) - Money management

## Common Issues & Quick Fixes

### "No device found"

**Solution**:
```bash
# Start an emulator
flutter emulators --launch <emulator_id>

# Or connect physical device via USB
# Enable USB debugging in developer options
```

### "Build failed"

**Solution**:
```bash
flutter clean
flutter pub get
flutter run
```

### "Gradle build failed" (Android)

**Solution**:
```bash
cd android
./gradlew clean
cd ..
flutter run
```

### "Pod install failed" (iOS)

**Solution**:
```bash
cd ios
pod install
cd ..
flutter run
```

### App crashes on startup

**Solution**:
1. Check you ran `flutter pub get`
2. Try `flutter clean` then rebuild
3. Check Flutter doctor: `flutter doctor`
4. Restart device/emulator

## Project Structure Overview

```
lib/
├── main.dart              # App entry point
├── models/                # Data structures
├── services/              # Business logic
├── screens/               # UI pages
├── widgets/               # Reusable components
└── utils/                 # Configuration
```

## Key Files to Know

- **constants.dart** - Configuration (MongoDB, Stripe, colors)
- **theme.dart** - App styling
- **main.dart** - App routing
- **auth_service.dart** - Login/register logic
- **payment_service.dart** - Payment processing

## Configuration (Optional)

### MongoDB Setup

For persistent storage, see: [MONGODB_SETUP.md](MONGODB_SETUP.md)

**Without MongoDB**: Data stored in memory (resets on app restart)

### Stripe Setup

For real payments, see: [STRIPE_SETUP.md](STRIPE_SETUP.md)

**Without Stripe**: Payments are simulated (still works for testing)

## Next Steps

Now that your app is running:

1. ✅ Test the complete flow (register → login → payment → apps)
2. ✅ Explore the codebase
3. ✅ Modify colors/themes to match your brand
4. ✅ Add real app data
5. ✅ Set up MongoDB for persistence
6. ✅ Configure Stripe for payments
7. ✅ Customize for your use case

## Getting Help

If you encounter issues:

1. Check [README.md](README.md) for detailed info
2. Run `flutter doctor` to check setup
3. Review error messages in console
4. Check [Flutter documentation](https://docs.flutter.dev/)

## Building for Release

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### iOS

```bash
flutter build ios --release
```

Then open in Xcode to archive and upload to App Store.

## Performance Tips

- Use release mode for testing performance
- Profile with DevTools: `flutter run --profile`
- Check widget rebuilds
- Optimize images
- Use const constructors where possible

## Useful Commands

```bash
# Check for updates
flutter upgrade

# Analyze code
flutter analyze

# Format code
flutter format .

# Run tests
flutter test

# Generate icons
flutter pub run flutter_launcher_icons:main

# Build for web
flutter build web
```

---

**You're all set!** 🚀

Start coding and building your Flutter app!
