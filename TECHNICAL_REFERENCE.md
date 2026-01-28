# GarageCrew - Technical Reference

This document contains technical specifications, code snippets, and implementation details for quick reference when continuing development.

---

## Environment Configuration

### .env File Format
```env
SUPABASE_URL=https://qpmzjfjvanlgohhpsfmn.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### EnvConfig Class
**Location:** `lib/config/env_config.dart`

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY'] ?? '';
}
```

### Loading Environment in main.dart
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Load environment variables
  runApp(const MyApp());
}
```

---

## Repository Pattern Implementation

### CarRepository
**Location:** `lib/repositories/car_repository.dart`

**Key Methods:**
```dart
class CarRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Fetch user's cars
  Future<List<Map<String, dynamic>>> fetchUserCars(String userId);

  // Add new car
  Future<Map<String, dynamic>> addCar(Map<String, dynamic> carData);

  // Update car
  Future<void> updateCar(String carId, Map<String, dynamic> updates);

  // Delete car
  Future<void> deleteCar(String carId);

  // Fetch public garages
  Future<List<Map<String, dynamic>>> fetchPublicGarages();

  // Fetch specific user's cars
  Future<List<Map<String, dynamic>>> fetchUserCarsById(String userId);
}
```

### ProfileRepository
**Location:** `lib/repositories/profile_repository.dart`

**Key Methods:**
```dart
class ProfileRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Load current user profile
  Future<Map<String, dynamic>?> loadProfile();

  // Update garage name
  Future<void> updateGarageName(String garageName);

  // Update public garage status
  Future<void> updatePublicGarageStatus(bool isPublic);

  // Update avatar URL
  Future<void> updateAvatarUrl(String avatarUrl);

  // Update bio
  Future<void> updateBio(String bio);

  // Load public profile (for viewing others)
  Future<Map<String, dynamic>?> loadPublicProfile(String userId);
}
```

---

## Image Handling

### ImagePickerService
**Location:** `lib/services/image_picker_service.dart`

```dart
class ImagePickerService {
  final ImagePicker _picker = ImagePicker();
  final SupabaseClient _supabase = Supabase.instance.client;

  // Pick from camera
  Future<String?> pickFromCamera() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (photo != null) {
      return await _uploadToSupabase(photo);
    }
    return null;
  }

  // Pick from gallery
  Future<String?> pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1080,
      imageQuality: 85,
    );

    if (image != null) {
      return await _uploadToSupabase(image);
    }
    return null;
  }

  // Upload to Supabase Storage
  Future<String> _uploadToSupabase(XFile file) async {
    final bytes = await file.readAsBytes();
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${file.name}';
    final filePath = 'car-images/$fileName';

    await _supabase.storage
        .from('car-images')
        .uploadBinary(filePath, bytes);

    return _supabase.storage
        .from('car-images')
        .getPublicUrl(filePath);
  }
}
```

### Image Display with Caching
```dart
CachedNetworkImage(
  imageUrl: car['image_url'],
  fit: BoxFit.cover,
  placeholder: (context, url) => const Center(
    child: CircularProgressIndicator(),
  ),
  errorWidget: (context, url, error) => const Icon(Icons.error),
  memCacheWidth: width.isFinite ? (width * 2).toInt() : null, // Fixed crash
)
```

---

## Database Schema Reference

### Complete Supabase Tables

#### profiles
```sql
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  garage_name TEXT,
  is_public BOOLEAN DEFAULT false,
  notifications_enabled BOOLEAN DEFAULT true,
  avatar_url TEXT,
  bio TEXT CHECK (char_length(bio) <= 150)
);

-- RLS Policies
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own profile"
  ON profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Public profiles are readable"
  ON profiles FOR SELECT
  USING (is_public = true);
```

#### cars
```sql
CREATE TABLE cars (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  make TEXT NOT NULL,
  model TEXT NOT NULL,
  year INTEGER,
  image_url TEXT NOT NULL,
  series TEXT,
  toy_number TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_cars_user_id ON cars(user_id);
CREATE INDEX idx_cars_created_at ON cars(created_at DESC);

-- RLS Policies
ALTER TABLE cars ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can CRUD own cars"
  ON cars FOR ALL
  USING (auth.uid() = user_id);

CREATE POLICY "Public cars are readable"
  ON cars FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE profiles.id = cars.user_id
      AND profiles.is_public = true
    )
  );
```

#### car_images
```sql
CREATE TABLE car_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  car_id UUID NOT NULL REFERENCES cars(id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  caption TEXT,
  is_primary BOOLEAN DEFAULT false,
  uploaded_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_car_images_car_id ON car_images(car_id);

-- RLS Policies
ALTER TABLE car_images ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage images for own cars"
  ON car_images FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM cars
      WHERE cars.id = car_images.car_id
      AND cars.user_id = auth.uid()
    )
  );

CREATE POLICY "Public car images are readable"
  ON car_images FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM cars
      JOIN profiles ON profiles.id = cars.user_id
      WHERE cars.id = car_images.car_id
      AND profiles.is_public = true
    )
  );
```

#### follows
```sql
CREATE TABLE follows (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  followed_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, followed_user_id),
  CHECK (user_id != followed_user_id)
);

CREATE INDEX idx_follows_user_id ON follows(user_id);
CREATE INDEX idx_follows_followed_user_id ON follows(followed_user_id);

-- RLS Policies
ALTER TABLE follows ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own follows"
  ON follows FOR ALL
  USING (auth.uid() = user_id);

CREATE POLICY "Follow relationships are readable"
  ON follows FOR SELECT
  USING (true);
```

#### likes
```sql
CREATE TABLE likes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  car_id UUID NOT NULL REFERENCES cars(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, car_id)
);

CREATE INDEX idx_likes_user_id ON likes(user_id);
CREATE INDEX idx_likes_car_id ON likes(car_id);

-- RLS Policies
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own likes"
  ON likes FOR ALL
  USING (auth.uid() = user_id);

CREATE POLICY "Likes are readable"
  ON likes FOR SELECT
  USING (true);
```

#### notifications
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('follow', 'like', 'comment')),
  from_user_id UUID NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
  car_id UUID REFERENCES cars(id) ON DELETE CASCADE,
  is_read BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);

-- RLS Policies
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own notifications"
  ON notifications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can update own notifications"
  ON notifications FOR UPDATE
  USING (auth.uid() = user_id);
```

### Supabase Storage Buckets

#### car-images
```sql
-- Public bucket for car images
-- RLS: Users can upload to their own folders, everyone can read public images
```

#### profile-avatars
```sql
-- Public bucket for profile pictures
-- RLS: Users can upload their own avatar, everyone can read
```

---

## Hot Wheels API Integration

### API Service
**Location:** `lib/services/hot_wheels_api.dart`

**Base URL:** `https://hotwheels.collectors-society.com/`

**Example Usage:**
```dart
class HotWheelsAPI {
  static const String baseUrl = 'https://hotwheels.collectors-society.com/api';

  Future<List<dynamic>> searchCars(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/search?q=$query'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to search Hot Wheels');
    }
  }
}
```

**Note:** Need to investigate if API provides unique model identifiers (toy_number or similar) to prevent fake/duplicate entries.

---

## Error Handling Pattern

### ErrorLogger
**Location:** `lib/services/error_logger.dart`

```dart
class ErrorLogger {
  static void log(String context, dynamic error, [StackTrace? stackTrace]) {
    debugPrint('ERROR in $context: $error');
    if (stackTrace != null) {
      debugPrint('Stack trace: $stackTrace');
    }
  }

  static void logWithMessage(String context, String message) {
    debugPrint('INFO in $context: $message');
  }
}
```

**Usage Example:**
```dart
try {
  await _repository.addCar(carData);
} catch (e, stackTrace) {
  ErrorLogger.log('CarListScreen.addCar', e, stackTrace);
  if (mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to add car: ${e.toString()}'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
```

---

## UI Components

### Profile Header (Instagram-style)
```dart
Widget _buildProfileHeader(Map<String, dynamic> profile, int carCount) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        // Avatar
        CircleAvatar(
          radius: 40,
          backgroundImage: profile['avatar_url'] != null
              ? NetworkImage(profile['avatar_url'])
              : null,
          child: profile['avatar_url'] == null
              ? const Icon(Icons.person, size: 40)
              : null,
        ),
        const SizedBox(height: 12),

        // Username
        Text(
          '@${profile['username']}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        // Bio
        if (profile['bio'] != null) ...[
          const SizedBox(height: 8),
          Text(
            profile['bio'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Stats Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildStatItem(carCount, 'cars'),
            _buildStatItem(followers, 'followers'),
            _buildStatItem(following, 'following'),
          ],
        ),

        const SizedBox(height: 16),

        // Follow Button
        ElevatedButton(
          onPressed: () => _toggleFollow(),
          style: ElevatedButton.styleFrom(
            backgroundColor: isFollowing ? Colors.grey : Colors.blue,
          ),
          child: Text(isFollowing ? 'Following' : 'Follow'),
        ),
      ],
    ),
  );
}

Widget _buildStatItem(int count, String label) {
  return Column(
    children: [
      Text(
        count.toString(),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
    ],
  );
}
```

### Car Grid (3 columns)
```dart
Widget _buildCarGrid(List<Map<String, dynamic>> cars) {
  return GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 3,
      crossAxisSpacing: 2,
      mainAxisSpacing: 2,
      childAspectRatio: 1,
    ),
    itemCount: cars.length,
    itemBuilder: (context, index) {
      final car = cars[index];
      return GestureDetector(
        onTap: () => _showCarDetail(car),
        child: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: car['image_url'],
              fit: BoxFit.cover,
            ),

            // Car name overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Text(
                  car['model'],
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}
```

### Car Detail Modal
```dart
void _showCarDetail(Map<String, dynamic> car) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Car Image
              AspectRatio(
                aspectRatio: 16 / 9,
                child: CachedNetworkImage(
                  imageUrl: car['image_url'],
                  fit: BoxFit.cover,
                ),
              ),

              // Like Button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : null,
                      ),
                      onPressed: () => _toggleLike(car['id']),
                    ),
                    Text('$likeCount likes'),
                  ],
                ),
              ),

              // Car Details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      car['model'],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Make: ${car['make']}'),
                    Text('Year: ${car['year']}'),
                    if (car['series'] != null)
                      Text('Series: ${car['series']}'),
                    if (car['toy_number'] != null)
                      Text('Toy #: ${car['toy_number']}'),
                  ],
                ),
              ),

              // Owner Info
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: ownerProfile['avatar_url'] != null
                          ? NetworkImage(ownerProfile['avatar_url'])
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '@${ownerProfile['username']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
```

---

## Localization

### ARB Files
**Location:** `lib/l10n/`

**English (app_en.arb):**
```json
{
  "@@locale": "en",
  "appTitle": "GarageCrew",
  "login": "Login",
  "register": "Register",
  "email": "Email",
  "password": "Password",
  "username": "Username",
  "garageName": "Garage Name",
  "addCar": "Add Car",
  "searchHotWheels": "Search Hot Wheels",
  "publicGarages": "Public Garages",
  "settings": "Settings",
  "profile": "Profile",
  "bio": "Bio",
  "followers": "Followers",
  "following": "Following",
  "cars": "Cars"
}
```

**Polish (app_pl.arb):**
```json
{
  "@@locale": "pl",
  "appTitle": "GarageCrew",
  "login": "Zaloguj",
  "register": "Zarejestruj",
  "email": "Email",
  "password": "Hasło",
  "username": "Nazwa użytkownika",
  "garageName": "Nazwa garażu",
  "addCar": "Dodaj auto",
  "searchHotWheels": "Szukaj Hot Wheels",
  "publicGarages": "Publiczne garaże",
  "settings": "Ustawienia",
  "profile": "Profil",
  "bio": "Bio",
  "followers": "Obserwujący",
  "following": "Obserwowani",
  "cars": "Samochody"
}
```

### Usage in Code
```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// In build method
Text(AppLocalizations.of(context)!.appTitle)
```

---

## Git Workflow

### Recent Commits
```bash
c0f1314 - Fix image cache size crash when width is infinite
f1274a3 - Improve UX: reorder settings and add auto-scroll
```

### Standard Commit Message Format
```
<type>: <subject>

<body (optional)>

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

**Types:** feat, fix, docs, style, refactor, test, chore

**Examples:**
```
feat: Add multi-photo gallery support

- Created car_images table
- Implemented ImagePickerService
- Updated car detail screen with carousel

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
```

---

## Performance Optimization

### RLS Policy Optimization
**Issue:** Using `auth.uid()` directly causes function re-evaluation for each row.

**Solution:** Use subquery `(SELECT auth.uid())`

**Example:**
```sql
-- ❌ SLOW (re-evaluates auth.uid() for each row)
CREATE POLICY "Users can read own cars"
  ON cars FOR SELECT
  USING (auth.uid() = user_id);

-- ✅ FAST (evaluates auth.uid() once)
CREATE POLICY "Users can read own cars"
  ON cars FOR SELECT
  USING ((SELECT auth.uid()) = user_id);
```

**Status:** SQL script prepared but not yet executed in Supabase.

---

## Testing Checklist

### Core Features
- [ ] User registration
- [ ] User login
- [ ] User logout
- [ ] Add car manually
- [ ] Add car from Hot Wheels API
- [ ] Upload car photo (camera)
- [ ] Upload car photo (gallery)
- [ ] Add multiple photos to car
- [ ] View car gallery
- [ ] Edit car
- [ ] Delete car
- [ ] Toggle garage public/private
- [ ] Browse public garages
- [ ] View other user's garage
- [ ] Follow user
- [ ] Unfollow user
- [ ] Like car
- [ ] Unlike car
- [ ] Update profile avatar
- [ ] Update bio
- [ ] Toggle dark mode
- [ ] Toggle notifications
- [ ] Change garage name

### UI/UX
- [ ] Splash screen displays correctly
- [ ] Auth background looks good
- [ ] Instagram-style grid renders properly
- [ ] Car detail modal opens smoothly
- [ ] Images load and cache correctly
- [ ] No "Infinity" errors
- [ ] Settings sections in correct order
- [ ] Auto-scroll works in add car screen
- [ ] Localization switches correctly (EN/PL)

### Edge Cases
- [ ] Offline handling
- [ ] Large image upload
- [ ] Empty garage display
- [ ] No followers/following display
- [ ] Invalid Hot Wheels search
- [ ] Duplicate username registration
- [ ] Invalid email format
- [ ] Weak password rejection

---

## Common Issues & Solutions

### Issue: "Unsupported operation: Infinity"
**Location:** Image caching in car grid
**Fix:** Check `width.isFinite` before calculating cache size
```dart
memCacheWidth: width.isFinite ? (width * 2).toInt() : null,
```

### Issue: ".env file not found"
**Solution:** Ensure `.env` exists in project root and is loaded in `main.dart`
```dart
await dotenv.load(fileName: ".env");
```

### Issue: "Supabase not initialized"
**Solution:** Ensure initialization happens in splash screen before any Supabase calls
```dart
await Supabase.initialize(
  url: EnvConfig.supabaseUrl,
  anonKey: EnvConfig.supabaseAnonKey,
);
```

### Issue: "RLS policy blocks my query"
**Solution:** Check that user is authenticated and policy matches query pattern. Use Supabase logs to debug.

---

## Development Environment

### Required Tools
- Flutter SDK ^3.10.3
- Dart SDK (included with Flutter)
- Android Studio / Xcode (for mobile development)
- VS Code with Flutter extension (recommended)
- Git

### VS Code Extensions (Recommended)
- Flutter
- Dart
- Flutter Widget Snippets
- GitLens
- Error Lens

### Supabase Dashboard
https://app.supabase.com/project/qpmzjfjvanlgohhpsfmn

**Sections:**
- **Table Editor:** Manage database tables
- **SQL Editor:** Run SQL queries
- **Storage:** Manage file buckets
- **Auth:** View users and auth settings
- **Logs:** Debug RLS policies and queries

---

## Next Steps & TODOs

### Immediate Tasks
1. **Hot Wheels API validation:**
   - Investigate API for unique model identifiers
   - Implement validation in `add_car_screen.dart`
   - Prevent fake/duplicate entries

2. **RLS optimization:**
   - Execute prepared SQL script in Supabase
   - Test query performance
   - Verify no functionality breaks

3. **Windows machine setup:**
   - Clone repository
   - Copy `.env` file
   - Test all features
   - Verify photo upload works

### Future Enhancements
- [ ] In-app notifications UI
- [ ] Real-time updates (Supabase subscriptions)
- [ ] Car value/rarity database integration
- [ ] Trade/marketplace features
- [ ] Advanced search and filters
- [ ] User collections/wishlists
- [ ] Barcode scanner for toy numbers
- [ ] Share garage to social media
- [ ] Export garage as PDF/CSV

---

**Document Version:** 1.0
**Last Updated:** January 21, 2026
**Maintainer:** mothal18 (GitHub)
