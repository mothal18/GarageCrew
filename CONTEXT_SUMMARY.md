# GarageCrew (MyGarage) - Context Summary

## Overview
**Project Name:** MyGarage / GarageCrew
**Platform:** Flutter mobile application
**Database:** Supabase
**GitHub Repository:** https://github.com/mothal18/MyGarage
**Session Duration:** January 18-21, 2026
**Total Messages:** 312 (extracted from 3366 log lines)

---

## What is GarageCrew?

GarageCrew is a **Hot Wheels collector app** built with Flutter. It allows users to:
- Create and manage their personal garage of Hot Wheels cars
- Make garages public for others to browse
- Follow other collectors
- Like cars and receive notifications
- Search for Hot Wheels models via external API integration
- Upload photos of their cars from camera or gallery
- View multi-photo galleries for each car model

Think of it as **Instagram for Hot Wheels collectors**.

---

## Project Architecture

### Tech Stack
- **Frontend:** Flutter (Dart)
- **Backend:** Supabase (PostgreSQL + Auth + Storage)
- **External API:** Hot Wheels API (https://hotwheels.collectors-society.com/)
- **Localization:** Polish (pl) and English (en)
- **Image Handling:** image_picker, cached_network_image

### Key Dependencies
```yaml
supabase_flutter: ^2.6.0
google_fonts: ^6.3.1
http: ^1.2.2
intl: ^0.20.2
flutter_dotenv: ^5.2.1
image_picker: ^1.1.2
cached_network_image: ^3.4.1
```

### Directory Structure
```
lib/
├── main.dart                          # Entry point
├── auth_gate.dart                     # Authentication routing
├── auth_screen.dart                   # Login screen
├── register_screen.dart               # Registration screen
├── auth_background.dart               # Auth screens background
├── splash_screen.dart                 # Splash screen with Supabase init
├── car_list_screen.dart              # User's garage (main screen)
├── car_detail_screen.dart            # Single car details with gallery
├── add_car_screen.dart               # Add new car with Hot Wheels API search
├── settings_screen.dart              # User settings and profile
├── public_garage_search_screen.dart  # Browse public garages (Instagram-style)
├── models/
│   └── car_item.dart                 # Car model
├── repositories/
│   ├── car_repository.dart           # Car CRUD operations
│   └── profile_repository.dart       # Profile CRUD operations
├── services/
│   ├── hot_wheels_api.dart           # External API integration
│   ├── image_picker_service.dart     # Camera/gallery photo picker
│   └── error_logger.dart             # Centralized error logging
├── widgets/
│   └── car_thumbnail.dart            # Car grid thumbnail widget
└── l10n/                             # Localization files
    ├── app_localizations.dart
    ├── app_localizations_en.dart
    └── app_localizations_pl.dart
```

---

## Major Work Completed

### Phase 1: Critical Security Fixes (Jan 18, 2026)
**Problem:** Hardcoded Supabase credentials in source code

**Solution Implemented:**
1. Created `.env` file with environment variables
2. Created `lib/config/env_config.dart` to load `.env`
3. Updated `main.dart` to load environment on startup
4. Updated `splash_screen.dart` to use `EnvConfig` instead of hardcoded values
5. Added `.env` to `.gitignore`

**Files Created:**
- `C:\Users\motha\Desktop\Programowanie\GarageCrew\.env` (on Linux: `/home/mothal/Pulpit/Programowanie/Projekty/MyGarage/MyGarage/my_garage/.env`)
- `lib/config/env_config.dart`

### Phase 2: Architecture Improvements (Jan 18, 2026)
**Problem:** Direct Supabase calls scattered throughout UI code, poor error handling

**Solution Implemented:**
1. **Repository Pattern:**
   - Created `lib/repositories/car_repository.dart` - All car CRUD operations
   - Created `lib/repositories/profile_repository.dart` - All profile operations
   - Refactored `car_list_screen.dart` to use `CarRepository`
   - Refactored `settings_screen.dart` to use `ProfileRepository`

2. **Error Handling:**
   - Created `lib/services/error_logger.dart` - Centralized error logging
   - Replaced all `catch (_) {}` with proper error logging
   - Added user-friendly error messages with context

### Phase 3: Instagram-Style Public Garage (Jan 19, 2026)
**Problem:** Basic UI, needed social features

**Solution Implemented:**
1. **Profile Enhancements:**
   - Added `avatarUrl` field to profiles
   - Added `bio` field (150 char limit)
   - Created profile editing UI in settings

2. **Public Garage Redesign:**
   - Instagram-style profile header with avatar, username, bio
   - Stats row: car count, followers, following
   - Follow/Unfollow button
   - Grid view of cars with photos
   - Car detail modal with like button and owner info

3. **Database Schema Updates:**
   - Added `follows` table (user_id, followed_user_id)
   - Added `likes` table (user_id, car_id)
   - Added `notifications` table

### Phase 4: Photo Upload & Gallery (Jan 19, 2026)
**Problem:** Images only from URL, no multiple photos per car

**Solution Implemented:**
1. **Image Picker Service:**
   - Created `lib/services/image_picker_service.dart`
   - Support for camera capture
   - Support for gallery selection
   - Automatic upload to Supabase Storage

2. **Multi-Photo Gallery:**
   - Created `car_images` table in Supabase
   - Updated `add_car_screen.dart` to support multiple photos
   - Updated `car_detail_screen.dart` to show photo gallery
   - Added photo captions/labels

3. **Supabase Storage Buckets:**
   - `car-images` bucket for car photos
   - `profile-avatars` bucket for profile pictures
   - RLS policies for secure access

### Phase 5: Auth Background Redesign (Jan 19, 2026)
**Change:** New motorsport/collector-themed background for login/register screens

**Files Updated:**
- `lib/auth_background.dart` - Gallery/shelf style background with automotive theme

### Phase 6: UX Improvements (Jan 21, 2026)
1. **Settings Screen Reorder:**
   - Profile (avatar, username, bio) - moved to top
   - Garage name
   - Public garage toggle
   - Notifications toggle
   - Dark mode (appearance)

2. **Add Car Screen:**
   - Auto-scroll to top when Hot Wheels model selected
   - Better form flow

3. **Bug Fixes:**
   - Fixed image cache crash when `width.isFinite` check missing
   - Commit: `c0f1314` - Fix image cache size crash when width is infinite

### Phase 7: Security Audit (Jan 21, 2026)
**Reviewed:** Supabase configuration security

**Findings:**
- ✅ Application security: **SAFE**
  - Credentials in `.env`, not hardcoded
  - `.env` in `.gitignore`
  - Only using `anon_key` (not `service_role` key)

- ⚠️ Database performance: **46 warnings**
  - RLS policies using `auth.uid()` instead of `(select auth.uid())`
  - Affects performance, not security
  - SQL optimization script prepared (not yet applied)

---

## Database Schema

### Core Tables

#### `profiles`
```sql
- id (uuid, FK to auth.users)
- username (text, unique)
- created_at (timestamp)
- garage_name (text)
- is_public (boolean)
- notifications_enabled (boolean)
- avatarUrl (text, nullable)
- bio (text, nullable, max 150 chars)
```

#### `cars`
```sql
- id (uuid, PK)
- user_id (uuid, FK to profiles)
- make (text)
- model (text)
- year (integer)
- image_url (text) -- Main photo
- series (text, nullable)
- toy_number (text, nullable)
- created_at (timestamp)
```

#### `car_images`
```sql
- id (uuid, PK)
- car_id (uuid, FK to cars)
- image_url (text)
- caption (text, nullable)
- is_primary (boolean)
- uploaded_at (timestamp)
```

#### `follows`
```sql
- id (uuid, PK)
- user_id (uuid, FK to profiles) -- follower
- followed_user_id (uuid, FK to profiles)
- created_at (timestamp)
```

#### `likes`
```sql
- id (uuid, PK)
- user_id (uuid, FK to profiles)
- car_id (uuid, FK to cars)
- created_at (timestamp)
```

#### `notifications`
```sql
- id (uuid, PK)
- user_id (uuid, FK to profiles) -- recipient
- type (text) -- 'follow', 'like', etc.
- from_user_id (uuid, FK to profiles)
- car_id (uuid, FK to cars, nullable)
- is_read (boolean)
- created_at (timestamp)
```

---

## Environment Configuration

### Required `.env` File
Location: `[project_root]/.env`

```env
SUPABASE_URL=https://qpmzjfjvanlgohhpsfmn.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**IMPORTANT:** This file is NOT in git. You must copy it manually when moving between computers.

---

## Current State & Next Steps

### Completed Features
- ✅ User authentication (register, login, logout)
- ✅ Personal garage management (CRUD operations)
- ✅ Public garage browsing with Instagram-style UI
- ✅ Multi-photo support for cars
- ✅ Photo upload from camera/gallery
- ✅ Hot Wheels API integration for model search
- ✅ Social features (follow, like, notifications)
- ✅ Profile customization (avatar, bio)
- ✅ Dark mode support
- ✅ Polish and English localization
- ✅ Repository pattern for clean architecture
- ✅ Centralized error handling
- ✅ Environment-based configuration

### Known Issues
1. **Hot Wheels API limitation:** Need to verify if API has unique model numbers to prevent duplicate entries
   - User requested validation to ensure users can only add real Hot Wheels models
   - This was the last question asked before session ended

2. **Supabase RLS Performance:** 46 warnings about suboptimal RLS policies
   - SQL fix script prepared but not yet executed
   - Performance impact, not security risk

### Pending Tasks
- [ ] Investigate Hot Wheels API for unique model identifiers
- [ ] Implement model validation on car creation
- [ ] Apply Supabase RLS optimization SQL script
- [ ] Test app on new Windows machine after migration

---

## Git Information

**Repository:** https://github.com/mothal18/MyGarage
**Branch:** main
**Last Commit:** `c0f1314` - Fix image cache size crash when width is infinite

### Latest Commits
- `f1274a3` - Improve UX: reorder settings and add auto-scroll
- `c0f1314` - Fix image cache size crash when width is infinite

---

## Setup Instructions for New Machine (Windows)

### 1. Clone Repository
```bash
git clone https://github.com/mothal18/MyGarage.git
cd MyGarage
```

### 2. Copy `.env` File
**From Linux machine:**
```bash
# Source path:
/home/mothal/Pulpit/Programowanie/Projekty/MyGarage/MyGarage/my_garage/.env
```

**To Windows machine:**
```
C:\Users\motha\Desktop\Programowanie\[project_folder]\.env
```

### 3. Install Dependencies
```bash
flutter pub get
```

### 4. Run App
```bash
flutter run
```

---

## Technical Decisions & Patterns

### Why Repository Pattern?
- **Separation of concerns:** UI doesn't know about Supabase
- **Testability:** Easy to mock repositories for unit tests
- **Maintainability:** Database changes don't affect UI
- **Reusability:** Same repository used by multiple screens

### Why .env for Credentials?
- **Security:** Credentials never in source control
- **Flexibility:** Different env files for dev/staging/prod
- **Standard practice:** Industry best practice for sensitive data

### Why Supabase?
- **BaaS:** Backend-as-a-Service reduces development time
- **Real-time:** Built-in real-time subscriptions (future feature)
- **Auth:** Built-in authentication system
- **Storage:** Integrated file storage for images
- **PostgreSQL:** Full SQL database with RLS security

### Why Instagram-Style UI?
- **Familiarity:** Users already know Instagram's interaction patterns
- **Visual focus:** Car collecting is visual, photos are central
- **Social:** Follow/like patterns match user expectations
- **Modern:** Contemporary, polished aesthetic

---

## Important File Paths

### Linux (Original Machine)
```
Project: /home/mothal/Pulpit/Programowanie/Projekty/MyGarage/MyGarage/my_garage/
.env: /home/mothal/Pulpit/Programowanie/Projekty/MyGarage/MyGarage/my_garage/.env
Session: /home/mothal/.claude/projects/-home-mothal-Pulpit-Programowanie-Projekty-MyGarage-MyGarage-my-garage/be13f295-d8a5-4e27-a5aa-369ae751ce28.jsonl
```

### Windows (New Machine)
```
Project: C:\Users\motha\Desktop\Programowanie\GarageCrew\
Session file: C:\Users\motha\AppData\Roaming\.claude\projects\-home-mothal-Pulpit-Programowanie-Projekty-MyGarage-MyGarage-my-garage\be13f295-d8a5-4e27-a5aa-369ae751ce28.jsonl
```

---

## Session Metadata

- **Session ID:** be13f295-d8a5-4e27-a5aa-369ae751ce28
- **Original CWD:** /home/mothal/Pulpit/Programowanie/Projekty/MyGarage/MyGarage/my_garage
- **Git Branch:** main
- **Flutter SDK:** ^3.10.3
- **Claude Version:** 2.1.11
- **Model:** claude-sonnet-4-5-20250929

---

## How to Continue Work

You have several options:

### Option 1: Fresh Start (Recommended)
1. Clone repo on Windows machine
2. Copy `.env` file
3. Run `flutter pub get`
4. Start new Claude Code session
5. Reference this summary document for context

### Option 2: Continue Old Session
1. Copy `.claude` folder from Linux to Windows
2. Maintain exact project path structure
3. Resume session with ID: `be13f295-d8a5-4e27-a5aa-369ae751ce28`

### Option 3: Hybrid Approach
1. Use Option 1 for setup
2. Keep this summary document as reference
3. Ask Claude Code to "read CONTEXT_SUMMARY.md" when starting new session

---

## Quick Reference Commands

```bash
# Install dependencies
flutter pub get

# Run app (debug)
flutter run

# Build APK (Android)
flutter build apk

# Check for issues
flutter analyze

# Format code
dart format lib/

# Git commands
git status
git add .
git commit -m "message"
git push origin main
```

---

## Contact & Resources

- **GitHub:** https://github.com/mothal18/MyGarage
- **Supabase Project:** https://qpmzjfjvanlgohhpsfmn.supabase.co
- **Hot Wheels API:** https://hotwheels.collectors-society.com/

---

**Generated:** 2026-01-21
**For:** Context transfer from Linux to Windows machine
**By:** Claude Code (Sonnet 4.5)
