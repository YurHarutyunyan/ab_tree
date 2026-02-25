# Git Setup and File Exclusions

This document explains what files are ignored from version control and why.

## What's Ignored (Not Pushed to Remote)

### Backend Files (Node.js)
```
backend/node_modules/          # 40MB of dependencies (install with npm install)
backend/.env                   # Contains secrets (JWT, Stripe keys, etc.)
backend/.env.local
backend/*.log                  # Runtime logs
backend/package-lock.json      # Auto-generated dependency lock
backend/dist/                  # Build output
```

### Flutter Build Files
```
build/                         # Compiled Flutter output (~100MB+)
.dart_tool/                    # Dart tooling cache
.flutter-plugins              # Auto-generated plugin list
.flutter-plugins-dependencies # Auto-generated dependencies
android/app/debug             # Debug builds
android/app/release           # Release builds
ios/Flutter/.last_build_id    # Build artifacts
```

### IDE and Editor Files
```
.idea/                        # IntelliJ/Android Studio
.vscode/                      # VS Code settings
.cursor/                      # Cursor IDE data
*.iml                         # IntelliJ module files
*.swp, *.swo                  # Vim swap files
```

### Logs and Temporary Files
```
*.log                         # All log files
backend.log                   # Backend server logs
logs/                         # Log directories
*.tmp, *.temp                 # Temporary files
.cache/                       # Cache directories
```

### Database Files
```
mongodb_data/                 # Docker volume data (managed by Docker)
*.db, *.sqlite                # Local database files
```

### OS Files
```
.DS_Store                     # macOS metadata
Thumbs.db                     # Windows thumbnails
```

## What's Included (Safe to Commit)

### Source Code
```
lib/                          # Flutter source code
backend/*.js                  # Backend JavaScript files
backend/models/               # Database schemas
backend/routes/               # API routes
backend/middleware/           # Express middleware
backend/config/               # Configuration files
```

### Configuration Templates
```
backend/.env.example          # Template for environment variables (no secrets)
pubspec.yaml                  # Flutter dependencies
backend/package.json          # Node.js dependencies
```

### Docker Configuration
```
backend/Dockerfile            # Backend container config
backend/docker-compose.yml    # Service orchestration
backend/.dockerignore         # Docker build exclusions
```

### Documentation
```
README.md                     # Project overview
DEPLOYMENT.md                 # Production deployment guide
TESTING_GUIDE.md              # Testing instructions
PROJECT_SUMMARY.md            # Project documentation
```

### Scripts
```
start_app.sh                  # Start services
stop_app.sh                   # Stop services
view_db.sh                    # View database
test_complete_flow.sh         # API testing
```

## Security Check Before Committing

**NEVER commit these files** (they contain secrets):
- ❌ `backend/.env` - Contains JWT secret, Stripe secret keys
- ❌ `backend/node_modules/` - Huge and unnecessary
- ❌ Any `*.log` files - May contain sensitive data
- ❌ `.cursor/` - Local IDE data

**Safe to commit**:
- ✅ `backend/.env.example` - Template without real secrets
- ✅ All `.js`, `.dart` files - Source code
- ✅ `package.json`, `pubspec.yaml` - Dependency lists
- ✅ Documentation files (`.md`)
- ✅ Shell scripts (`.sh`)

## First Time Git Setup

If you haven't initialized git yet:

```bash
cd /home/ubuntu/samurai/ab_tree_flutter

# Initialize git
git init

# Add all files (respects .gitignore)
git add .

# Check what will be committed
git status

# Create first commit
git commit -m "Initial commit: Flutter app with Node.js backend"

# Add remote repository
git remote add origin https://github.com/yourusername/ab-tree-flutter.git

# Push to remote
git push -u origin main
```

## Verify Exclusions

Check if files are properly ignored:

```bash
# Should show ignored files
git check-ignore backend/node_modules backend/.env *.log

# Should NOT show node_modules or .env
git status

# List all tracked files (should not include node_modules or .env)
git ls-files | grep -E "node_modules|\.env$"
```

## Cleaning Up Already Committed Files

If you accidentally committed files that should be ignored:

```bash
# Remove from git but keep local file
git rm --cached backend/.env
git rm --cached -r backend/node_modules
git rm --cached backend.log

# Commit the removal
git commit -m "Remove sensitive and build files from tracking"

# Push
git push
```

## Repository Size

With proper exclusions, your repository should be:
- **Source code**: ~5-10 MB
- **Without node_modules**: Saves ~40 MB
- **Without build files**: Saves ~100+ MB
- **Total**: Small, fast to clone

## Quick Reference

**Add new files to gitignore:**
1. Edit `.gitignore` or `backend/.gitignore`
2. Add the pattern (e.g., `*.secret`)
3. If already tracked: `git rm --cached filename`
4. Commit: `git commit -m "Update gitignore"`

**Check what's ignored:**
```bash
git status --ignored
```

**Force add an ignored file** (if really needed):
```bash
git add -f path/to/file
```

---

**Current Status:**
- ✅ `.gitignore` updated with comprehensive exclusions
- ✅ `backend/.gitignore` created
- ✅ `backend/node_modules/` removed from tracking
- ✅ `backend/.env` removed from tracking
- ✅ `backend.log` removed from tracking

Your repository is now secure and clean! 🔒
