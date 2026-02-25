# AB Tree Flutter - Deployment Guide

This guide will walk you through deploying your AB Tree Flutter app with a secure client-server architecture.

## Architecture Overview

- **Client**: Flutter mobile app (iOS/Android) - communicates with backend via REST API
- **Backend**: Node.js/Express server - handles authentication, business logic, and Stripe payments
- **Database**: MongoDB (in Docker container on the same server as backend)

## Prerequisites

- A cloud server (AWS EC2, DigitalOcean Droplet, Google Cloud VM, etc.)
- Domain name (optional but recommended for SSL)
- Stripe account with API keys
- Basic knowledge of Linux command line

---

## Part 1: Backend Deployment

### Step 1: Set Up Cloud Server

#### Option A: DigitalOcean Droplet (Recommended for beginners)

1. Create a DigitalOcean account at https://www.digitalocean.com
2. Create a new Droplet:
   - **Image**: Ubuntu 22.04 LTS
   - **Plan**: Basic ($6/month is sufficient to start)
   - **Datacenter**: Choose closest to your users
   - **Authentication**: SSH key (recommended) or password
3. Note your droplet's IP address

#### Option B: AWS EC2

1. Launch an EC2 instance:
   - **AMI**: Ubuntu Server 22.04 LTS
   - **Instance Type**: t2.micro (free tier) or t2.small
   - **Security Group**: Allow ports 22 (SSH), 80 (HTTP), 443 (HTTPS), 3000 (API)
2. Note your instance's public IP address

### Step 2: Connect to Your Server

```bash
ssh root@YOUR_SERVER_IP
```

### Step 3: Install Dependencies

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Install Docker Compose
sudo apt install docker-compose -y

# Install Node.js (for local testing)
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Verify installations
docker --version
docker-compose --version
node --version
npm --version
```

### Step 4: Transfer Backend Code to Server

On your **local machine**, navigate to your project directory and transfer the backend:

```bash
# Create a tarball of the backend directory
cd /path/to/ab_tree_flutter
tar -czf backend.tar.gz backend/

# Transfer to server (replace YOUR_SERVER_IP)
scp backend.tar.gz root@YOUR_SERVER_IP:/root/

# SSH into server and extract
ssh root@YOUR_SERVER_IP
cd /root
tar -xzf backend.tar.gz
cd backend
```

### Step 5: Configure Environment Variables

```bash
# Copy the example env file
cp .env.example .env

# Edit the .env file with your actual values
nano .env
```

Update these values in `.env`:

```env
# Stripe Configuration (Get from https://dashboard.stripe.com/test/apikeys)
STRIPE_SECRET_KEY=sk_test_YOUR_ACTUAL_STRIPE_SECRET_KEY
STRIPE_PUBLISHABLE_KEY=pk_test_YOUR_ACTUAL_STRIPE_PUBLISHABLE_KEY

# JWT Secret (generate a new one)
JWT_SECRET=YOUR_GENERATED_JWT_SECRET_HERE

# MongoDB Configuration (keep as is for Docker)
MONGODB_URI=mongodb://mongodb:27017/ab_tree_db

# Server Configuration
PORT=3000
NODE_ENV=production

# CORS Configuration (replace with your domain or keep * for development)
ALLOWED_ORIGINS=*
```

To generate a secure JWT secret:
```bash
openssl rand -hex 32
```

### Step 6: Start the Backend

```bash
# Install dependencies
npm install

# Start Docker containers (MongoDB + Backend)
docker-compose up -d

# Check if containers are running
docker ps

# Check logs
docker-compose logs -f
```

Your backend should now be running at `http://YOUR_SERVER_IP:3000`

Test it:
```bash
curl http://YOUR_SERVER_IP:3000/health
```

### Step 7: Set Up Domain and SSL (Recommended)

#### A. Configure DNS

1. Go to your domain registrar (GoDaddy, Namecheap, etc.)
2. Add an A record pointing to your server's IP:
   - Type: A
   - Name: @ (or api for subdomain)
   - Value: YOUR_SERVER_IP
   - TTL: 3600

Wait 5-60 minutes for DNS propagation.

#### B. Install Nginx as Reverse Proxy

```bash
# Install Nginx
sudo apt install nginx -y

# Create Nginx configuration
sudo nano /etc/nginx/sites-available/ab_tree_backend
```

Add this configuration (replace `your-domain.com`):

```nginx
server {
    listen 80;
    server_name your-domain.com;  # or api.your-domain.com

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

Enable the configuration:

```bash
sudo ln -s /etc/nginx/sites-available/ab_tree_backend /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
```

#### C. Install SSL Certificate (Let's Encrypt)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get SSL certificate (replace with your domain)
sudo certbot --nginx -d your-domain.com

# Follow the prompts and choose to redirect HTTP to HTTPS
```

Your backend is now accessible at `https://your-domain.com`

---

## Part 2: Flutter App Configuration

### Step 1: Update API Base URL

Edit `lib/config/environment.dart`:

```dart
class Environment {
  static const bool isDevelopment = bool.fromEnvironment(
    'DEVELOPMENT',
    defaultValue: true,
  );

  static String get apiBaseUrl {
    if (isDevelopment) {
      return 'http://localhost:3000';
    } else {
      return 'https://your-domain.com';  // Replace with your actual domain
    }
  }

  static String get environmentName => isDevelopment ? 'Development' : 'Production';
}
```

### Step 2: Configure Stripe Publishable Key

Edit `lib/utils/constants.dart`:

```dart
// Replace with your actual Stripe publishable key
static const String stripePublishableKey = 'pk_test_YOUR_ACTUAL_PUBLISHABLE_KEY';
```

### Step 3: Test Backend Connection Locally

```bash
# Run in development mode (will use localhost:3000)
flutter run

# Test registration and login
# Make sure your backend is accessible
```

### Step 4: Build for Production

#### For Android:

```bash
# Build release APK
flutter build apk --release --dart-define=DEVELOPMENT=false

# Or build App Bundle for Google Play Store
flutter build appbundle --release --dart-define=DEVELOPMENT=false
```

The APK will be at: `build/app/outputs/flutter-apk/app-release.apk`
The App Bundle will be at: `build/app/outputs/bundle/release/app-release.aab`

#### For iOS:

```bash
# Build iOS release
flutter build ios --release --dart-define=DEVELOPMENT=false

# Then open in Xcode to archive and submit
open ios/Runner.xcworkspace
```

In Xcode:
1. Select "Any iOS Device" as target
2. Product → Archive
3. Distribute App → App Store Connect
4. Follow the prompts to upload

---

## Part 3: App Store Submission

### iOS App Store

1. **Prepare Assets**:
   - App icon (1024x1024px)
   - Screenshots for all device sizes
   - App description and keywords

2. **Create App in App Store Connect**:
   - Go to https://appstoreconnect.apple.com
   - Create new app
   - Fill in app information
   - Upload build from Xcode

3. **Submit for Review**:
   - Answer questionnaires
   - Submit for review
   - Usually takes 1-3 days

### Google Play Store

1. **Create Developer Account**:
   - Go to https://play.google.com/console
   - Pay $25 one-time fee

2. **Create New App**:
   - Fill in app details
   - Upload App Bundle (`.aab` file)
   - Add screenshots and description

3. **Submit for Review**:
   - Complete content rating questionnaire
   - Submit for review
   - Usually approved in a few hours

---

## Part 4: Maintenance & Monitoring

### Backend Monitoring

```bash
# Check backend logs
ssh root@YOUR_SERVER_IP
cd /root/backend
docker-compose logs -f backend

# Check MongoDB logs
docker-compose logs -f mongodb

# Restart services if needed
docker-compose restart

# Update backend code
# On local machine: make changes, then
scp backend.tar.gz root@YOUR_SERVER_IP:/root/
# On server:
cd /root/backend
docker-compose down
cd ..
tar -xzf backend.tar.gz
cd backend
docker-compose up -d
```

### Database Backup

```bash
# Create backup script
cat > /root/backup-mongo.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
docker exec ab_tree_mongodb mongodump --out=/backup_$DATE
docker cp ab_tree_mongodb:/backup_$DATE /root/backups/
echo "Backup created: backup_$DATE"
EOF

chmod +x /root/backup-mongo.sh

# Run backup
./backup-mongo.sh

# Set up daily backup cron job
crontab -e
# Add line: 0 2 * * * /root/backup-mongo.sh
```

### Updating Flutter App

1. Make changes to Flutter code
2. Increment version in `pubspec.yaml`
3. Build new release
4. Submit update to stores

---

## Troubleshooting

### Backend Issues

**Problem**: Can't connect to backend
```bash
# Check if containers are running
docker ps

# Check logs
docker-compose logs

# Restart services
docker-compose restart
```

**Problem**: MongoDB connection error
```bash
# Check MongoDB is running
docker exec -it ab_tree_mongodb mongosh

# Check MongoDB logs
docker-compose logs mongodb
```

### Flutter App Issues

**Problem**: "Network error" in app
- Verify backend URL in `environment.dart`
- Check backend is accessible: `curl https://your-domain.com/health`
- Check phone/emulator can reach the server

**Problem**: "Authentication failed"
- Verify JWT_SECRET is set in backend `.env`
- Check token is being sent in API requests
- Clear app data and try fresh login

---

## Security Checklist

- [ ] JWT_SECRET is a strong, random 64-character string
- [ ] Stripe secret key is only on backend, never in app
- [ ] HTTPS/SSL is enabled for production
- [ ] MongoDB is not exposed to public (only accessible via Docker network)
- [ ] Server firewall only allows necessary ports
- [ ] Regular database backups are configured
- [ ] .env file is in .gitignore
- [ ] CORS is configured to only allow your app's domain (in production)

---

## Support

For issues or questions:
- Check logs first: `docker-compose logs`
- Review API endpoints: `https://your-domain.com/`
- Test with curl or Postman
- Check MongoDB data: `docker exec -it ab_tree_mongodb mongosh ab_tree_db`

---

## Cost Estimate

**Monthly Costs**:
- Server (DigitalOcean/AWS): $6-12/month
- Domain name: $10-15/year (~$1/month)
- SSL certificate: Free (Let's Encrypt)
- **Total**: ~$7-13/month

**One-time Costs**:
- iOS Developer account: $99/year
- Google Play Developer account: $25 one-time
