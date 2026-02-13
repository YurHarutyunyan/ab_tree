# MongoDB Atlas Setup Guide

Complete guide to setting up MongoDB Atlas for the AB Tree Flutter application.

## Quick Start

The app works WITHOUT MongoDB configuration (uses in-memory storage). Follow this guide only if you want persistent cloud storage.

## Step-by-Step Setup

### 1. Create MongoDB Atlas Account

1. Go to [MongoDB Atlas](https://cloud.mongodb.com)
2. Click "Try Free"
3. Sign up with email or Google account
4. Verify your email address

### 2. Create a Cluster

1. After login, click "Create"
2. Choose "Shared" (Free tier)
3. Select your cloud provider:
   - AWS, Google Cloud, or Azure
   - Choose a region close to your users
4. Cluster Tier: M0 Sandbox (Free Forever)
5. Cluster Name: `ab-tree-cluster` (or any name)
6. Click "Create Cluster"
7. Wait 3-5 minutes for cluster creation

### 3. Create Database User

1. Click "Database Access" in left sidebar
2. Click "Add New Database User"
3. Authentication Method: Password
4. Username: `ab_tree_user` (or your choice)
5. Password: Click "Autogenerate Secure Password" or create your own
6. **IMPORTANT**: Copy and save the password securely
7. Database User Privileges: "Read and write to any database"
8. Click "Add User"

### 4. Configure Network Access

1. Click "Network Access" in left sidebar
2. Click "Add IP Address"
3. For development, click "Allow Access from Anywhere" (0.0.0.0/0)
   - **Note**: For production, restrict to specific IPs
4. Click "Confirm"

### 5. Get Connection String

1. Click "Database" in left sidebar
2. Click "Connect" on your cluster
3. Choose "Connect your application"
4. Driver: Select "Node.js" and Version "4.1 or later"
5. Copy the connection string, it looks like:
   ```
   mongodb+srv://ab_tree_user:<password>@ab-tree-cluster.xxxxx.mongodb.net/?retryWrites=true&w=majority
   ```
6. Replace `<password>` with your actual password
7. Add the database name before the `?`:
   ```
   mongodb+srv://ab_tree_user:YOUR_PASSWORD@ab-tree-cluster.xxxxx.mongodb.net/ab_tree_db?retryWrites=true&w=majority
   ```

### 6. Create Database and Collections

1. Click "Browse Collections"
2. Click "Add My Own Data"
3. Database Name: `ab_tree_db`
4. Collection Name: `users`
5. Click "Create"
6. Add another collection:
   - Click "+ Create Collection"
   - Collection Name: `payments`
   - Click "Create"

### 7. Configure Flutter App

1. Open `lib/utils/constants.dart`
2. Find this line:
   ```dart
   static const String mongoDbConnectionString = 'YOUR_MONGODB_CONNECTION_STRING';
   ```
3. Replace with your actual connection string:
   ```dart
   static const String mongoDbConnectionString = 
     'mongodb+srv://ab_tree_user:YOUR_PASSWORD@ab-tree-cluster.xxxxx.mongodb.net/ab_tree_db?retryWrites=true&w=majority';
   ```
4. Save the file

### 8. Test Connection

1. Run your Flutter app:
   ```bash
   flutter run
   ```
2. Check the console output
3. Look for: `✅ Connected to MongoDB`
4. If you see connection errors, verify:
   - Password is correct
   - IP address is whitelisted
   - Connection string format is correct

## Database Schema

### Users Collection

The app automatically creates documents with this structure:

```json
{
  "_id": ObjectId("..."),
  "username": "johndoe",
  "email": "john@example.com",
  "firstName": "John",
  "lastName": "Doe",
  "passwordHash": "sha256_hash_here",
  "createdAt": "2024-01-01T12:00:00.000Z"
}
```

### Payments Collection

```json
{
  "_id": ObjectId("..."),
  "userId": "user_id_here",
  "amount": 100.00,
  "cardLast4": "4242",
  "cardHolder": "John Doe",
  "transactionId": "TXN1234567890",
  "timestamp": "2024-01-01T12:00:00.000Z",
  "status": "completed",
  "recipientCard": "**** **** **** 5678"
}
```

## Indexes (Optional - for better performance)

After creating collections, add these indexes:

### Users Collection Indexes

1. Click on `users` collection
2. Click "Indexes" tab
3. Click "Create Index"
4. Field: `username`, Type: Ascending
5. Options: Check "Unique"
6. Click "Create"

Repeat for:
- Field: `email`, Unique: Yes

### Payments Collection Indexes

1. Click on `payments` collection
2. Click "Indexes" tab
3. Create index:
   - Field: `userId`, Type: Ascending
4. Create index:
   - Field: `transactionId`, Type: Ascending, Unique: Yes

## Security Best Practices

### For Development

✅ Current setup is fine:
- Allow access from anywhere (0.0.0.0/0)
- Simple username/password authentication

### For Production

🔒 Implement these security measures:

1. **IP Whitelist**
   - Remove 0.0.0.0/0
   - Add only your app server IPs
   - Add your team's IPs for management

2. **Strong Passwords**
   - Use complex, randomly generated passwords
   - Store in environment variables
   - Never commit to version control

3. **Database Roles**
   - Create role-specific users
   - Limit permissions to necessary operations
   - Use separate users for different apps

4. **Connection Security**
   - Always use SSL/TLS (mongodb+srv://)
   - Enable authentication
   - Use VPC peering for AWS/GCP

5. **Monitoring**
   - Enable MongoDB Atlas monitoring
   - Set up alerts for unusual activity
   - Review access logs regularly

## Troubleshooting

### Connection Timeout

**Problem**: "Connection timeout" error

**Solutions**:
1. Check internet connection
2. Verify IP address is whitelisted
3. Try "Allow Access from Anywhere" temporarily
4. Check if cluster is active (not paused)

### Authentication Failed

**Problem**: "Authentication failed" error

**Solutions**:
1. Verify username is correct
2. Check password (case-sensitive)
3. Ensure password doesn't contain special characters that need encoding
4. URL-encode password if it contains special chars:
   ```
   @ → %40
   : → %3A
   / → %2F
   ? → %3F
   # → %23
   ```

### Database Not Found

**Problem**: "Database does not exist" error

**Solutions**:
1. Check database name in connection string
2. Create database manually in Atlas
3. Verify database name matches in constants.dart

### Network Issues

**Problem**: "Network unreachable" error

**Solutions**:
1. Check firewall settings
2. Try different network (mobile hotspot)
3. Verify VPN is not blocking connection
4. Check if corporate proxy is interfering

## Alternative: Local MongoDB

If you prefer local development:

1. Install MongoDB locally
2. Use connection string:
   ```dart
   static const String mongoDbConnectionString = 
     'mongodb://localhost:27017/ab_tree_db';
   ```
3. Start MongoDB service
4. No cloud setup needed

## MongoDB Compass (Optional)

For easier database management:

1. Download [MongoDB Compass](https://www.mongodb.com/products/compass)
2. Install and open
3. Use your connection string to connect
4. View/edit collections visually
5. Run queries with GUI
6. Export/import data

## Backup Strategy

### Automatic Backups (Atlas)

- Free tier M0: No automatic backups
- Paid tiers: Automatic continuous backups
- Consider upgrading for production

### Manual Backup

1. Go to your cluster
2. Click "Collections"
3. Select collection
4. Click "Export Collection"
5. Choose format (JSON/CSV)
6. Save locally

### Programmatic Backup

Use MongoDB tools:
```bash
mongodump --uri="your_connection_string"
```

## Cost Information

### Free Tier (M0)

- 512 MB storage
- Shared RAM
- Perfect for development
- Forever free
- No credit card required

### Paid Tiers

Starting at $9/month for:
- 2 GB storage
- Backups
- More IOPS
- Better performance

## Migration Path

When ready to scale:

1. Create new cluster (higher tier)
2. Export data from M0
3. Import to new cluster
4. Update connection string
5. Test thoroughly
6. Switch over
7. Delete old cluster

## Monitoring

Set up in Atlas:

1. Click "Monitoring" in left sidebar
2. View metrics:
   - Connections
   - Operations per second
   - Network traffic
   - Disk usage
3. Set up alerts:
   - High CPU usage
   - Many failed operations
   - Storage threshold

## Support Resources

- [MongoDB Atlas Documentation](https://docs.atlas.mongodb.com/)
- [MongoDB University (Free Courses)](https://university.mongodb.com/)
- [Community Forums](https://www.mongodb.com/community/forums/)
- [Stack Overflow #mongodb](https://stackoverflow.com/questions/tagged/mongodb)

---

**You're all set!** 🎉

Your Flutter app can now store user data and payment records in MongoDB Atlas.
