// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get authSignInFailed => 'Sign in failed.';

  @override
  String authSignInFailedWithCode(Object code) {
    return 'Sign in failed. Code: $code';
  }

  @override
  String authSignInFailedWithDetails(Object details) {
    return 'Sign in failed. Details: $details';
  }

  @override
  String get authTitle => 'Sign in';

  @override
  String get authSubtitle => 'Access your garage in one place.';

  @override
  String get authLoginLabel => 'Login';

  @override
  String get authLoginEmpty => 'Enter a login.';

  @override
  String get authLoginInvalid => 'Login: 3-20 characters, a-z, 0-9 or _.';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authPasswordEmpty => 'Enter a password.';

  @override
  String get authPasswordShort => 'Password must be at least 6 characters.';

  @override
  String get authSignInButton => 'Sign in';

  @override
  String get authCreateAccountButton => 'Create account';

  @override
  String get authFooter =>
      'By using the app you accept the terms and privacy policy.';

  @override
  String get authBrandTagline =>
      'Manage your Hot Wheels collection like a pro.';

  @override
  String get registerTitle => 'Register';

  @override
  String get registerHeader => 'Create account';

  @override
  String get registerSubtitle => 'Join MyGarage and build your collection.';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerEmailEmpty => 'Enter an email.';

  @override
  String get registerEmailInvalid => 'Enter a valid email.';

  @override
  String get registerPasswordLabel => 'Password';

  @override
  String get registerPasswordEmpty => 'Enter a password.';

  @override
  String get registerPasswordShort => 'Password must be at least 6 characters.';

  @override
  String get registerCreateAccountButton => 'Create account';

  @override
  String get registerHaveAccount => 'Already have an account? Sign in';

  @override
  String get registerCreatedCheckEmail =>
      'Account created. Check your email to confirm.';

  @override
  String get registerLoginTaken => 'This login is already taken.';

  @override
  String get registerCreateFailed => 'Couldn\'t create account. Try again.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsNoUser => 'No signed-in user.';

  @override
  String get settingsLoadFailed => 'Couldn\'t load settings.';

  @override
  String get settingsSaveGarageNameFailed => 'Couldn\'t save garage name.';

  @override
  String get settingsSaveFailed => 'Couldn\'t save settings.';

  @override
  String get garageNameSection => 'Garage name';

  @override
  String get garageNameLabel => 'Display name';

  @override
  String get garageNameHint => 'e.g. Mothal\'s Garage';

  @override
  String get garageNameSaveTooltip => 'Save name';

  @override
  String get garageNameHelper =>
      'This name will be visible to others when the garage is public.';

  @override
  String get publicGarageSection => 'Public garage';

  @override
  String get publicGarageNoLogin => 'Your garage can be public.';

  @override
  String publicGarageWithLogin(Object login) {
    return 'Your login: $login';
  }

  @override
  String get publicGarageToggleTitle => 'Share my garage publicly';

  @override
  String get publicGarageToggleSubtitle =>
      'Others will be able to find your garage by login.';

  @override
  String get carListSignOutFailed => 'Couldn\'t sign out. Try again.';

  @override
  String get carListLoadFailed => 'Couldn\'t load cars.';

  @override
  String get carListSaveCarFailed => 'Couldn\'t save the car.';

  @override
  String get carListSaveChangesFailed => 'Couldn\'t save changes.';

  @override
  String get carListDeleteFailed => 'Couldn\'t delete the car.';

  @override
  String carLimitReached(Object maxCars) {
    return 'You\'ve reached the limit of $maxCars cars in your garage.';
  }

  @override
  String imageLimitReached(Object maxImages) {
    return 'Maximum $maxImages photos per car.';
  }

  @override
  String get networkError =>
      'No internet connection. Check your connection and try again.';

  @override
  String get unknownError => 'An unexpected error occurred. Please try again.';

  @override
  String get carDeleteTitle => 'Delete car?';

  @override
  String get carDeleteContent => 'This car will be removed from your garage.';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get settingsTooltip => 'Settings';

  @override
  String get logoutTooltip => 'Sign out';

  @override
  String get publicGaragesTooltip => 'Public garages';

  @override
  String get garageEmpty => 'Your garage is empty.';

  @override
  String get addCar => 'Add car';

  @override
  String get searchNoResults => 'No results for this search.';

  @override
  String get editCarTooltip => 'Edit car';

  @override
  String get deleteCarTooltip => 'Delete car';

  @override
  String get searchGarageLabel => 'Search in garage';

  @override
  String get sortLabel => 'Sorting';

  @override
  String get sortNewest => 'Newest';

  @override
  String get sortOldest => 'Oldest';

  @override
  String get sortAz => 'A-Z';

  @override
  String get sortZa => 'Z-A';

  @override
  String get addCarTitle => 'Add car';

  @override
  String get editCarTitle => 'Edit car';

  @override
  String get save => 'Save';

  @override
  String get carDataSection => 'Car details';

  @override
  String get carNameLabel => 'Name / model';

  @override
  String get carNameEmpty => 'Enter a car name.';

  @override
  String get toyNumberLabel => 'Toy #';

  @override
  String get toyNumberHint => 'e.g., JJJ02';

  @override
  String get toyNumberHelper =>
      'Format: 3 uppercase letters + 2 digits (ABC12)';

  @override
  String get toyNumberEmpty => 'Enter Toy Number.';

  @override
  String get toyNumberInvalidFormat =>
      'Invalid format. Use: 3 letters + 2 digits (e.g., JJJ02)';

  @override
  String get toyNumberAlreadyExists =>
      'This Toy # already exists in your garage.';

  @override
  String get toyNumberReminderAfterSearch =>
      'Don\'t forget to enter the Toy Number!';

  @override
  String get carDescriptionLabel => 'Description (optional)';

  @override
  String get carImageUrlLabel => 'Image URL (optional)';

  @override
  String get hotWheelsSearchSection => 'Search Hot Wheels database';

  @override
  String get hotWheelsSearchLabel => 'Search by name';

  @override
  String get hotWheelsSearchFailed => 'Couldn\'t fetch results.';

  @override
  String get hotWheelsSearchHint => 'Type at least 2 characters to search.';

  @override
  String get noResults => 'No results.';

  @override
  String get saveChanges => 'Save changes';

  @override
  String get addToGarage => 'Add to garage';

  @override
  String get useDataTooltip => 'Use data';

  @override
  String get carDetailsTitle => 'Car details';

  @override
  String get noDescription => 'No description.';

  @override
  String get imageUrlLabel => 'Image URL';

  @override
  String get addedAtLabel => 'Added';

  @override
  String get publicGaragesTitle => 'Public garages';

  @override
  String get publicSearchLabel => 'Search by login or garage name';

  @override
  String get publicSearchTooltip => 'Search';

  @override
  String get publicSearchHint =>
      'Type at least 2 characters to search for a garage.';

  @override
  String get publicSearchNoResults => 'No results.';

  @override
  String get publicGarageSubtitle => 'Public garage';

  @override
  String get publicGaragesLoadFailed => 'Couldn\'t load public garages.';

  @override
  String get publicGarageCarsLoadFailed => 'Couldn\'t load cars.';

  @override
  String publicGarageTitle(Object login) {
    return 'Garage: $login';
  }

  @override
  String get publicGarageEmpty => 'This garage is empty.';

  @override
  String get splashLoading => 'Loading...';

  @override
  String get splashLoadingError => 'Loading failed. Please try again.';

  @override
  String get splashRetry => 'Try again';

  @override
  String get appearanceSection => 'Appearance';

  @override
  String get darkModeToggleTitle => 'Dark mode';

  @override
  String get darkModeToggleSubtitle => 'Switch to dark theme.';

  @override
  String get racingThemeToggleTitle => 'Racing theme';

  @override
  String get racingThemeToggleSubtitle =>
      'Colors inspired by the GarageCrew website.';

  @override
  String get themeTooltip => 'Change theme';

  @override
  String get profileSection => 'Garage profile';

  @override
  String get avatarUrlLabel => 'Profile image URL';

  @override
  String get avatarUrlHint => 'https://example.com/image.jpg';

  @override
  String get avatarUrlSaveTooltip => 'Save image';

  @override
  String get avatarUrlHelper => 'Profile image visible on your garage.';

  @override
  String get avatarSaveFailed => 'Couldn\'t save profile image.';

  @override
  String get bioLabel => 'Profile description';

  @override
  String get bioHint => 'Write something about yourself or your collection...';

  @override
  String get bioSaveTooltip => 'Save description';

  @override
  String get bioHelper => 'Short description visible on your profile.';

  @override
  String get bioSaveFailed => 'Couldn\'t save description.';

  @override
  String carsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'cars',
      one: 'car',
    );
    return '$count $_temp0';
  }

  @override
  String get noBio => 'No description.';

  @override
  String get pickImageTitle => 'Choose image';

  @override
  String get pickFromCamera => 'Take photo';

  @override
  String get pickFromGallery => 'Choose from gallery';

  @override
  String get pickFromUrl => 'Enter URL';

  @override
  String get imageUploadFailed => 'Failed to upload image';

  @override
  String get imageDeleteConfirm => 'Delete this image?';

  @override
  String get galleryEmpty => 'No images';

  @override
  String get tapToAddImage => 'Tap to add image';

  @override
  String maxImagesReached(Object count) {
    return 'Maximum $count images';
  }

  @override
  String get imageUploading => 'Uploading...';

  @override
  String get reorderImages => 'Drag to reorder';

  @override
  String get carImagesSection => 'Car images';

  @override
  String get addImageButton => 'Add image';

  @override
  String get exploreGarages => 'Explore';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsEmpty => 'No notifications';

  @override
  String get notificationsMarkAllRead => 'Mark all read';

  @override
  String get notificationsClearAll => 'Clear all';

  @override
  String get notificationsClearConfirmTitle => 'Clear all notifications?';

  @override
  String get notificationsClearConfirmContent =>
      'This will delete all notifications.';

  @override
  String get follow => 'Follow';

  @override
  String get following => 'Following';

  @override
  String get unfollowConfirmTitle => 'Unfollow?';

  @override
  String get unfollowConfirmContent =>
      'You won\'t receive notifications about new cars from this garage.';

  @override
  String followersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'followers',
      one: 'follower',
    );
    return '$count $_temp0';
  }

  @override
  String get notificationBellTooltip => 'Notifications';

  @override
  String get justNow => 'just now';

  @override
  String minutesAgo(Object count) {
    return '$count min ago';
  }

  @override
  String hoursAgo(Object count) {
    return '$count h ago';
  }

  @override
  String daysAgo(Object count) {
    return '$count d ago';
  }

  @override
  String get notificationsSection => 'Notifications';

  @override
  String get notificationsToggleTitle => 'Enable notifications';

  @override
  String get notificationsToggleSubtitle =>
      'Receive notifications about new cars and likes.';

  @override
  String get notificationsSaveFailed => 'Couldn\'t save notification settings.';

  @override
  String likesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'likes',
      one: 'like',
    );
    return '$count $_temp0';
  }

  @override
  String get likeTooltip => 'Like';

  @override
  String get unlikeTooltip => 'Unlike';

  @override
  String get likedNotificationTitle => 'Someone liked your car';

  @override
  String likedNotificationBody(Object login, Object carTitle) {
    return '$login liked: $carTitle';
  }

  @override
  String get quantityLabel => 'Quantity';

  @override
  String get quantityHelper => 'How many copies of this variant';

  @override
  String get quantityEmpty => 'Enter quantity.';

  @override
  String get quantityInvalid => 'Quantity must be at least 1.';

  @override
  String get variantLabel => 'Variant (optional)';

  @override
  String get variantHint => 'e.g., Mint, Opened, TH';

  @override
  String get variantHelper => 'Describe the condition or special edition';

  @override
  String get advancedFilters => 'Advanced filters';

  @override
  String get toyNumberPrefixFilter => 'Toy # series';

  @override
  String get toyNumberPrefixAll => 'All series';

  @override
  String get hasImagesFilter => 'Has images';

  @override
  String get hasImagesAll => 'All';

  @override
  String get hasImagesYes => 'Yes';

  @override
  String get hasImagesNo => 'No';

  @override
  String get likesRangeFilter => 'Likes range';

  @override
  String get dateRangeFilter => 'Added';

  @override
  String get dateRangeLast7Days => 'Last 7 days';

  @override
  String get dateRangeLast30Days => 'Last 30 days';

  @override
  String get dateRangeLast90Days => 'Last 90 days';

  @override
  String get dateRangeAllTime => 'All time';

  @override
  String get clearFilters => 'Clear filters';

  @override
  String showingXofYCars(Object x, Object y) {
    return 'Showing $x of $y cars';
  }

  @override
  String get statisticsTitle => 'Statistics';

  @override
  String get statisticsTooltip => 'View statistics';

  @override
  String get statisticsLoadFailed => 'Couldn\'t load statistics.';

  @override
  String get overviewSection => 'Overview';

  @override
  String get popularitySection => 'Popularity';

  @override
  String get collectionSection => 'Collection';

  @override
  String get activitySection => 'Activity';

  @override
  String get totalCars => 'Total cars';

  @override
  String get totalLikes => 'Total likes';

  @override
  String get mostLikedCar => 'Most liked car';

  @override
  String get averageLikes => 'Average likes';

  @override
  String get carsByToyNumber => 'By Toy # series';

  @override
  String get carsWithImages => 'With images';

  @override
  String get carsAddedThisWeek => 'Added this week';

  @override
  String get carsAddedThisMonth => 'Added this month';

  @override
  String get collectionAge => 'Collection age';

  @override
  String collectionAgeDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'days',
      one: 'day',
    );
    return '$days $_temp0';
  }

  @override
  String get followers => 'Followers';

  @override
  String get followingCount => 'Following';
}
