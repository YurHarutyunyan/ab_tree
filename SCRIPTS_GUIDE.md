# 🚀 Quick Start Scripts Guide

This project includes convenient scripts to manage the app and MongoDB Docker container.

## Available Scripts

### 1. `start_app.sh` - Start Everything
Starts MongoDB container and launches the Flutter app.

```bash
./start_app.sh
```

**What it does:**
- ✅ Checks if Docker is running
- ✅ Creates/starts MongoDB container on port 27017
- ✅ Waits for MongoDB to be ready
- ✅ Launches Flutter app
- ✅ Auto-reconnects if container already exists

### 2. `stop_app.sh` - Stop MongoDB
Stops the MongoDB container gracefully.

```bash
./stop_app.sh
```

**What it does:**
- ✅ Stops MongoDB Docker container
- ✅ Data is preserved (container still exists)
- ✅ Shows helpful next-step commands

### 3. `view_db.sh` - View Database Contents
Shows all data stored in MongoDB.

```bash
./view_db.sh
```

**What it shows:**
- 📊 All registered users
- 💳 All payment records
- 📈 Database statistics (counts)

---

## Usage Examples

### First Time Setup
```bash
# Make scripts executable (only needed once)
chmod +x *.sh

# Start the app
./start_app.sh
```

### Daily Development
```bash
# Morning - Start working
./start_app.sh

# During development - View database
./view_db.sh

# End of day - Stop MongoDB
./stop_app.sh
```

### Testing the Database Persistence
```bash
# 1. Start the app
./start_app.sh

# 2. Register a user in the app

# 3. Close the Flutter app (Ctrl+C or press 'q')

# 4. View the data persisted in MongoDB
./view_db.sh

# 5. Start the app again
./start_app.sh

# 6. Login with the same user - it works! ✅
```

---

## Manual Docker Commands

If you prefer manual control:

### Start MongoDB manually
```bash
docker start mongodb
```

### Stop MongoDB manually
```bash
docker stop mongodb
```

### Remove MongoDB container (deletes all data!)
```bash
docker stop mongodb
docker rm mongodb
```

### Access MongoDB shell directly
```bash
docker exec -it mongodb mongosh ab_tree_db
```

### View container logs
```bash
docker logs mongodb
```

### Check container status
```bash
docker ps -a | grep mongodb
```

---

## Troubleshooting

### "Docker is not running"
Start Docker Desktop or Docker service:
```bash
sudo systemctl start docker
```

### "Container already exists with different config"
Remove and recreate:
```bash
docker rm -f mongodb
./start_app.sh
```

### "Port 27017 already in use"
Check what's using the port:
```bash
sudo lsof -i :27017
# or
sudo netstat -tulpn | grep 27017
```

### "Cannot connect to MongoDB"
Check if container is running:
```bash
docker ps | grep mongodb
docker logs mongodb
```

### Reset everything (fresh start)
```bash
# Stop and remove container (deletes all data!)
docker stop mongodb
docker rm mongodb

# Start fresh
./start_app.sh
```

---

## MongoDB Container Details

- **Container Name**: `mongodb`
- **Port**: `27017` (localhost:27017)
- **Database**: `ab_tree_db`
- **Collections**: `users`, `payments`
- **Image**: `mongo:latest`
- **Data Persistence**: Data is stored inside the container

### To persist data permanently (across container deletion):
Modify `start_app.sh` to add a volume:
```bash
docker run -d \
  --name mongodb \
  -p 27017:27017 \
  -v mongodb_data:/data/db \
  -e MONGO_INITDB_DATABASE=ab_tree_db \
  mongo:latest
```

---

## Quick Reference

| Action | Command |
|--------|---------|
| Start app + MongoDB | `./start_app.sh` |
| Stop MongoDB | `./stop_app.sh` |
| View database | `./view_db.sh` |
| MongoDB shell | `docker exec -it mongodb mongosh ab_tree_db` |
| Container status | `docker ps` |
| Container logs | `docker logs mongodb` |
| Delete all data | `docker rm -f mongodb` |

---

## Development Workflow

```
┌─────────────────────────────────────────────┐
│  ./start_app.sh                             │
│  ↓                                           │
│  MongoDB starts → Flutter runs              │
│  ↓                                           │
│  Develop & test app                         │
│  ↓                                           │
│  ./view_db.sh (check data anytime)          │
│  ↓                                           │
│  Close Flutter app (q or Ctrl+C)            │
│  ↓                                           │
│  ./stop_app.sh (optional, saves resources)  │
└─────────────────────────────────────────────┘
```

---

## Tips

💡 **MongoDB keeps running** even after Flutter app closes - this is intentional!  
💡 **Data persists** between app restarts  
💡 **Use `view_db.sh`** to verify data is being saved  
💡 **Container auto-starts** if it already exists  
💡 **No MongoDB installation needed** - runs in Docker!

---

Happy coding! 🎉
