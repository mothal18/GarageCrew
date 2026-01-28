# GarageCrew - Quick Start Guide

This is a condensed guide to get you up and running on your new Windows machine as quickly as possible.

---

## What You Need to Copy from Linux Machine

### Critical File
**`.env`** - Contains Supabase credentials (NOT in git repo)

**Linux path:**
```
/home/mothal/Pulpit/Programowanie/Projekty/MyGarage/MyGarage/my_garage/.env
```

**Copy to USB drive or use this command:**
```bash
# On Linux machine
cat ~/.../my_garage/.env

# Then copy the output to clipboard
```

---

## Setup on Windows Machine (5 minutes)

### Step 1: Clone Repository
```bash
cd C:\Users\motha\Desktop\Programowanie\
git clone https://github.com/mothal18/MyGarage.git GarageCrew
cd GarageCrew
```

### Step 2: Create .env File
Create file: `C:\Users\motha\Desktop\Programowanie\GarageCrew\.env`

Paste this content (with your actual keys):
```env
SUPABASE_URL=https://qpmzjfjvanlgohhpsfmn.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### Step 3: Install Dependencies
```bash
flutter pub get
```

### Step 4: Run App
```bash
flutter run
```

That's it! The app should launch on your connected device or emulator.

---

## Verify Everything Works

### Quick Test Checklist
1. **Launch app** - Splash screen appears
2. **Login** - Use existing account
3. **View garage** - Your cars load
4. **Add car** - Search Hot Wheels API
5. **Upload photo** - Test camera/gallery
6. **Browse public garages** - Instagram-style view works

If all 6 work, you're good to go!

---

## Common Setup Issues

### Issue: "flutter: command not found"
**Solution:** Install Flutter SDK or add to PATH
```bash
# Verify Flutter is installed
flutter --version
```

### Issue: ".env file not found"
**Solution:** Make sure `.env` is in project root (same level as `pubspec.yaml`)
```
GarageCrew/
├── .env          ← HERE
├── pubspec.yaml
├── lib/
└── ...
```

### Issue: "Supabase error: Invalid API key"
**Solution:** Check that `.env` has correct keys from Linux machine

### Issue: "No devices found"
**Solution:**
```bash
# For Android emulator
flutter emulators --launch <emulator_id>

# Check connected devices
flutter devices
```

---

## Project Structure (Where Things Are)

```
GarageCrew/
├── .env                          # Your Supabase keys (create this!)
├── lib/
│   ├── main.dart                # App entry point
│   ├── config/
│   │   └── env_config.dart      # Loads .env
│   ├── repositories/            # Database operations
│   ├── services/                # External APIs, image upload
│   ├── models/                  # Data models
│   └── *.dart                   # Screen files
├── assets/
│   └── images/                  # App assets
└── pubspec.yaml                 # Dependencies
```

---

## Most Important Files

| File | Purpose |
|------|---------|
| `.env` | Supabase credentials |
| `lib/main.dart` | Entry point, loads .env |
| `lib/car_list_screen.dart` | Main garage screen |
| `lib/public_garage_search_screen.dart` | Browse public garages |
| `lib/add_car_screen.dart` | Add car with Hot Wheels search |
| `lib/repositories/car_repository.dart` | All car database operations |
| `lib/services/image_picker_service.dart` | Photo upload |

---

## Key Commands

```bash
# Install dependencies
flutter pub get

# Run app (debug)
flutter run

# Run app (release)
flutter run --release

# Check for issues
flutter analyze

# Format code
dart format lib/

# Clean build
flutter clean
flutter pub get

# Git commands
git status
git pull origin main
git add .
git commit -m "Your message"
git push origin main
```

---

## Context Documents

If you need more details, check these files:

1. **CONTEXT_SUMMARY.md** - Complete overview of project and what was built
2. **CONVERSATION_TIMELINE.md** - Day-by-day development timeline
3. **TECHNICAL_REFERENCE.md** - Code snippets, database schema, implementation details

---

## Where You Left Off

### Last Thing Done
Fixed image loading crash - commit `c0f1314`

### Next Thing To Do
Investigate Hot Wheels API for unique model identifiers to prevent fake/duplicate car entries.

**The Question:**
> "Check if the Hot Wheels database has a column with a specific unique number for each model so users can only add real models and we can prevent duplicates."

**Why This Matters:**
Right now users can type anything in the add car form. You want to validate against real Hot Wheels models using a unique identifier from the API.

**Where to Start:**
1. Check Hot Wheels API documentation
2. Test API responses for unique fields (toy_number, model_id, etc.)
3. Update `add_car_screen.dart` to require/validate this field
4. Update database schema if needed

---

## Supabase Dashboard

**URL:** https://app.supabase.com/project/qpmzjfjvanlgohhpsfmn

**Quick Links:**
- Table Editor: View/edit database tables
- SQL Editor: Run SQL queries
- Storage: Manage car-images and profile-avatars buckets
- Auth: View registered users

---

## Need Help?

### If You Get Stuck
1. Check error message carefully
2. Run `flutter doctor` to check environment
3. Run `flutter clean && flutter pub get` to reset
4. Check Supabase dashboard logs
5. Verify `.env` file exists and has correct keys

### For Database Issues
- Check Supabase Table Editor
- Look at RLS policies (might be blocking queries)
- Check SQL logs in Supabase dashboard

### For Build Issues
```bash
# Nuclear option - reset everything
flutter clean
rm -rf ios/Pods
rm -rf ios/Podfile.lock
flutter pub get
cd ios && pod install
cd ..
flutter run
```

---

## Your Git Workflow

```bash
# Pull latest changes
git pull origin main

# Make changes to code...

# Check what changed
git status
git diff

# Stage changes
git add .

# Commit
git commit -m "feat: Add validation for Hot Wheels model numbers"

# Push to GitHub
git push origin main
```

---

## Pro Tips

1. **Keep `.env` safe** - Never commit it to git (it's already in .gitignore)
2. **Test on real device** - Emulators sometimes have issues with camera/gallery
3. **Use hot reload** - Press `r` in terminal while app is running to reload
4. **Check Supabase logs** - If queries fail, Supabase dashboard shows why
5. **Use Flutter DevTools** - Run `flutter pub global activate devtools` for advanced debugging

---

## Quick Reference: Supabase Tables

| Table | Purpose |
|-------|---------|
| `profiles` | User profiles (username, avatar, bio, garage name) |
| `cars` | Car collection (make, model, year, main image) |
| `car_images` | Additional photos for each car |
| `follows` | User follow relationships |
| `likes` | Car likes |
| `notifications` | Follow/like notifications |

---

## Status: Ready to Continue! ✅

You're all set. The project is:
- ✅ Secure (credentials in .env)
- ✅ Clean architecture (repository pattern)
- ✅ Well organized (clear file structure)
- ✅ Documented (these markdown files)
- ✅ In git (backed up on GitHub)

**Just clone, add .env, and go!**

---

**Last Updated:** January 21, 2026
**Your GitHub:** https://github.com/mothal18/MyGarage
