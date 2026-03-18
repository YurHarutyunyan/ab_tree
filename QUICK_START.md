# AB Tree Flutter - Quick Start Guide

## One Command to Run Everything! 🚀

```bash
./start_app.sh
```

This single command will:
1. ✅ Check Docker and Flutter are installed
2. ✅ Install backend dependencies (npm packages)
3. ✅ Create `.env` file if missing (from template)
4. ✅ Start MongoDB in Docker
5. ✅ Start Backend API in Docker
6. ✅ Wait for services to be healthy
7. ✅ Install Flutter dependencies
8. ✅ Launch the Flutter app

## What You Get

After running `./start_app.sh`:

```
✅ MongoDB Database      → http://localhost:27017
✅ Backend API          → http://localhost:3000
✅ API Documentation    → http://localhost:3000/
✅ Health Check         → http://localhost:3000/health
✅ Flutter App Running  → On your device/emulator
```

## First Time Setup

### Prerequisites

Install these before running:
1. **Docker** - https://docs.docker.com/get-docker/
2. **Flutter** - https://docs.flutter.dev/get-started/install
3. **Node.js 18+** - https://nodejs.org/ (optional, only for local development)

### Initial Configuration

The script will create `backend/.env` from template. To use real payments:

1. Get Stripe API keys from https://dashboard.stripe.com/test/apikeys
2. Edit `backend/.env`:
   ```env
   STRIPE_SECRET_KEY=sk_test_YOUR_REAL_KEY_HERE
   STRIPE_PUBLISHABLE_KEY=pk_test_YOUR_REAL_KEY_HERE
   ```
3. Edit `lib/utils/constants.dart`:
   ```dart
   static const String stripePublishableKey = 'pk_test_YOUR_REAL_KEY_HERE';
   ```

## Other Useful Commands

### Stop Everything
```bash
./stop_app.sh
```
Stops MongoDB and Backend API (but keeps data).

### View Database
```bash
./view_db.sh
```
Shows all users and payments in the database.

### Test Backend API
```bash
./test_complete_flow.sh
```
Runs automated tests for all API endpoints.

### Restart Services
```bash
./stop_app.sh && ./start_app.sh
```

### View Backend Logs
```bash
cd backend && docker compose logs -f
```

### Clear Database (Fresh Start)
```bash
docker exec ab_tree_mongodb mongosh ab_tree_db --eval "db.dropDatabase()"
```

## Troubleshooting

### "Docker is not running"
Start Docker Desktop or Docker daemon first.

### "MongoDB container not found"
```bash
cd backend
docker compose up -d
```

### "Backend API not responding"
```bash
# Check logs
cd backend && docker compose logs backend

# Restart backend
docker compose restart backend
```

### "Flutter build fails"
```bash
flutter clean
flutter pub get
flutter run --dart-define=DEVELOPMENT=true
```

### "Network error" in app
Backend is not accessible. Check:
```bash
curl http://localhost:3000/health
```

## Development Workflow

```bash
# Day 1: Setup
./start_app.sh                    # First time setup (installs everything)

# Daily Development
./start_app.sh                    # Starts backend + app
# Make code changes
# Press 'r' for hot reload
# Press 'R' for hot restart
# Press 'q' to quit
./stop_app.sh                     # When done for the day

# Testing
./view_db.sh                      # Check database
./test_complete_flow.sh           # Test API
```

## Build for Production

```bash
# Android
flutter build appbundle --release --dart-define=DEVELOPMENT=false

# iOS (macOS only)
flutter build ios --release --dart-define=DEVELOPMENT=false
```

See `DEPLOYMENT.md` for complete production deployment guide.

---

## Summary

**One command does it all:**
```bash
./start_app.sh
```

That's it! Everything else is automatic. 🎉
