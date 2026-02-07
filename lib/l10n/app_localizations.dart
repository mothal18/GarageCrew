import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// No description provided for @authSignInFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed.'**
  String get authSignInFailed;

  /// No description provided for @authSignInFailedWithCode.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed. Code: {code}'**
  String authSignInFailedWithCode(Object code);

  /// No description provided for @authSignInFailedWithDetails.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed. Details: {details}'**
  String authSignInFailedWithDetails(Object details);

  /// No description provided for @authTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authTitle;

  /// No description provided for @authSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Access your garage in one place.'**
  String get authSubtitle;

  /// No description provided for @authLoginLabel.
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get authLoginLabel;

  /// No description provided for @authLoginEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a login.'**
  String get authLoginEmpty;

  /// No description provided for @authLoginInvalid.
  ///
  /// In en, this message translates to:
  /// **'Login: 3-20 characters, a-z, 0-9 or _.'**
  String get authLoginInvalid;

  /// No description provided for @authPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get authPasswordLabel;

  /// No description provided for @authPasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a password.'**
  String get authPasswordEmpty;

  /// No description provided for @authPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get authPasswordShort;

  /// No description provided for @authSignInButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get authSignInButton;

  /// No description provided for @authCreateAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get authCreateAccountButton;

  /// No description provided for @authFooter.
  ///
  /// In en, this message translates to:
  /// **'By using the app you accept the terms and privacy policy.'**
  String get authFooter;

  /// No description provided for @authBrandTagline.
  ///
  /// In en, this message translates to:
  /// **'Manage your Hot Wheels collection like a pro.'**
  String get authBrandTagline;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerTitle;

  /// No description provided for @registerHeader.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerHeader;

  /// No description provided for @registerSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join MyGarage and build your collection.'**
  String get registerSubtitle;

  /// No description provided for @registerEmailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get registerEmailLabel;

  /// No description provided for @registerEmailEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter an email.'**
  String get registerEmailEmpty;

  /// No description provided for @registerEmailInvalid.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email.'**
  String get registerEmailInvalid;

  /// No description provided for @registerPasswordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get registerPasswordLabel;

  /// No description provided for @registerPasswordEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a password.'**
  String get registerPasswordEmpty;

  /// No description provided for @registerPasswordShort.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get registerPasswordShort;

  /// No description provided for @registerCreateAccountButton.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerCreateAccountButton;

  /// No description provided for @registerHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get registerHaveAccount;

  /// No description provided for @registerSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get registerSuccessTitle;

  /// No description provided for @registerCreatedCheckEmail.
  ///
  /// In en, this message translates to:
  /// **'Account created. Check your email to confirm.'**
  String get registerCreatedCheckEmail;

  /// No description provided for @registerLoginTaken.
  ///
  /// In en, this message translates to:
  /// **'This login is already taken.'**
  String get registerLoginTaken;

  /// No description provided for @registerCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t create account. Try again.'**
  String get registerCreateFailed;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsNoUser.
  ///
  /// In en, this message translates to:
  /// **'No signed-in user.'**
  String get settingsNoUser;

  /// No description provided for @settingsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load settings.'**
  String get settingsLoadFailed;

  /// No description provided for @settingsSaveGarageNameFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save garage name.'**
  String get settingsSaveGarageNameFailed;

  /// No description provided for @settingsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save settings.'**
  String get settingsSaveFailed;

  /// No description provided for @garageNameSection.
  ///
  /// In en, this message translates to:
  /// **'Garage name'**
  String get garageNameSection;

  /// No description provided for @garageNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Display name'**
  String get garageNameLabel;

  /// No description provided for @garageNameHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Mothal\'s Garage'**
  String get garageNameHint;

  /// No description provided for @garageNameSaveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save name'**
  String get garageNameSaveTooltip;

  /// No description provided for @garageNameHelper.
  ///
  /// In en, this message translates to:
  /// **'This name will be visible to others when the garage is public.'**
  String get garageNameHelper;

  /// No description provided for @publicGarageSection.
  ///
  /// In en, this message translates to:
  /// **'Public garage'**
  String get publicGarageSection;

  /// No description provided for @publicGarageNoLogin.
  ///
  /// In en, this message translates to:
  /// **'Your garage can be public.'**
  String get publicGarageNoLogin;

  /// No description provided for @publicGarageWithLogin.
  ///
  /// In en, this message translates to:
  /// **'Your login: {login}'**
  String publicGarageWithLogin(Object login);

  /// No description provided for @publicGarageToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Share my garage publicly'**
  String get publicGarageToggleTitle;

  /// No description provided for @publicGarageToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Others will be able to find your garage by login.'**
  String get publicGarageToggleSubtitle;

  /// No description provided for @carListSignOutFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t sign out. Try again.'**
  String get carListSignOutFailed;

  /// No description provided for @carListLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load cars.'**
  String get carListLoadFailed;

  /// No description provided for @carListSaveCarFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the car.'**
  String get carListSaveCarFailed;

  /// No description provided for @carListSaveChangesFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save changes.'**
  String get carListSaveChangesFailed;

  /// No description provided for @carListDeleteFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t delete the car.'**
  String get carListDeleteFailed;

  /// No description provided for @carLimitReached.
  ///
  /// In en, this message translates to:
  /// **'You\'ve reached the limit of {maxCars} cars in your garage.'**
  String carLimitReached(Object maxCars);

  /// No description provided for @imageLimitReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum {maxImages} photos per car.'**
  String imageLimitReached(Object maxImages);

  /// No description provided for @networkError.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Check your connection and try again.'**
  String get networkError;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'An unexpected error occurred. Please try again.'**
  String get unknownError;

  /// No description provided for @carDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete car?'**
  String get carDeleteTitle;

  /// No description provided for @carDeleteContent.
  ///
  /// In en, this message translates to:
  /// **'This car will be removed from your garage.'**
  String get carDeleteContent;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @settingsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTooltip;

  /// No description provided for @logoutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get logoutTooltip;

  /// No description provided for @publicGaragesTooltip.
  ///
  /// In en, this message translates to:
  /// **'Public garages'**
  String get publicGaragesTooltip;

  /// No description provided for @garageEmpty.
  ///
  /// In en, this message translates to:
  /// **'Your garage is empty.'**
  String get garageEmpty;

  /// No description provided for @addCar.
  ///
  /// In en, this message translates to:
  /// **'Add car'**
  String get addCar;

  /// No description provided for @searchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results for this search.'**
  String get searchNoResults;

  /// No description provided for @editCarTooltip.
  ///
  /// In en, this message translates to:
  /// **'Edit car'**
  String get editCarTooltip;

  /// No description provided for @deleteCarTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete car'**
  String get deleteCarTooltip;

  /// No description provided for @searchGarageLabel.
  ///
  /// In en, this message translates to:
  /// **'Search in garage'**
  String get searchGarageLabel;

  /// No description provided for @sortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sorting'**
  String get sortLabel;

  /// No description provided for @sortNewest.
  ///
  /// In en, this message translates to:
  /// **'Newest'**
  String get sortNewest;

  /// No description provided for @sortOldest.
  ///
  /// In en, this message translates to:
  /// **'Oldest'**
  String get sortOldest;

  /// No description provided for @sortAz.
  ///
  /// In en, this message translates to:
  /// **'A-Z'**
  String get sortAz;

  /// No description provided for @sortZa.
  ///
  /// In en, this message translates to:
  /// **'Z-A'**
  String get sortZa;

  /// No description provided for @addCarTitle.
  ///
  /// In en, this message translates to:
  /// **'Add car'**
  String get addCarTitle;

  /// No description provided for @editCarTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit car'**
  String get editCarTitle;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @carDataSection.
  ///
  /// In en, this message translates to:
  /// **'Car details'**
  String get carDataSection;

  /// No description provided for @carNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Name / model'**
  String get carNameLabel;

  /// No description provided for @carNameEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter a car name.'**
  String get carNameEmpty;

  /// No description provided for @toyNumberLabel.
  ///
  /// In en, this message translates to:
  /// **'Toy #'**
  String get toyNumberLabel;

  /// No description provided for @toyNumberHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., JJJ02'**
  String get toyNumberHint;

  /// No description provided for @toyNumberHelper.
  ///
  /// In en, this message translates to:
  /// **'Format: 3 uppercase letters + 2 digits (ABC12)'**
  String get toyNumberHelper;

  /// No description provided for @toyNumberEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter Toy Number.'**
  String get toyNumberEmpty;

  /// No description provided for @toyNumberInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid format. Use: 3 letters + 2 digits (e.g., JJJ02)'**
  String get toyNumberInvalidFormat;

  /// No description provided for @toyNumberAlreadyExists.
  ///
  /// In en, this message translates to:
  /// **'This Toy # already exists in your garage.'**
  String get toyNumberAlreadyExists;

  /// No description provided for @toyNumberReminderAfterSearch.
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget to enter the Toy Number!'**
  String get toyNumberReminderAfterSearch;

  /// No description provided for @carDescriptionLabel.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get carDescriptionLabel;

  /// No description provided for @carImageUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Image URL (optional)'**
  String get carImageUrlLabel;

  /// No description provided for @hotWheelsSearchSection.
  ///
  /// In en, this message translates to:
  /// **'Search Hot Wheels database'**
  String get hotWheelsSearchSection;

  /// No description provided for @hotWheelsSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by name'**
  String get hotWheelsSearchLabel;

  /// No description provided for @hotWheelsSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t fetch results.'**
  String get hotWheelsSearchFailed;

  /// No description provided for @hotWheelsSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters to search.'**
  String get hotWheelsSearchHint;

  /// No description provided for @noResults.
  ///
  /// In en, this message translates to:
  /// **'No results.'**
  String get noResults;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save changes'**
  String get saveChanges;

  /// No description provided for @addToGarage.
  ///
  /// In en, this message translates to:
  /// **'Add to garage'**
  String get addToGarage;

  /// No description provided for @useDataTooltip.
  ///
  /// In en, this message translates to:
  /// **'Use data'**
  String get useDataTooltip;

  /// No description provided for @carDetailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Car details'**
  String get carDetailsTitle;

  /// No description provided for @noDescription.
  ///
  /// In en, this message translates to:
  /// **'No description.'**
  String get noDescription;

  /// No description provided for @imageUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Image URL'**
  String get imageUrlLabel;

  /// No description provided for @addedAtLabel.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get addedAtLabel;

  /// No description provided for @publicGaragesTitle.
  ///
  /// In en, this message translates to:
  /// **'Public garages'**
  String get publicGaragesTitle;

  /// No description provided for @publicSearchLabel.
  ///
  /// In en, this message translates to:
  /// **'Search by login or garage name'**
  String get publicSearchLabel;

  /// No description provided for @publicSearchTooltip.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get publicSearchTooltip;

  /// No description provided for @publicSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Type at least 2 characters to search for a garage.'**
  String get publicSearchHint;

  /// No description provided for @publicSearchNoResults.
  ///
  /// In en, this message translates to:
  /// **'No results.'**
  String get publicSearchNoResults;

  /// No description provided for @discoverRecentModels.
  ///
  /// In en, this message translates to:
  /// **'Discover New Models'**
  String get discoverRecentModels;

  /// No description provided for @discoverLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to load recent models.'**
  String get discoverLoadFailed;

  /// No description provided for @publicGarageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Public garage'**
  String get publicGarageSubtitle;

  /// No description provided for @publicGaragesLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load public garages.'**
  String get publicGaragesLoadFailed;

  /// No description provided for @publicGarageCarsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load cars.'**
  String get publicGarageCarsLoadFailed;

  /// No description provided for @publicGarageTitle.
  ///
  /// In en, this message translates to:
  /// **'Garage: {login}'**
  String publicGarageTitle(Object login);

  /// No description provided for @publicGarageEmpty.
  ///
  /// In en, this message translates to:
  /// **'This garage is empty.'**
  String get publicGarageEmpty;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get splashLoading;

  /// No description provided for @splashLoadingError.
  ///
  /// In en, this message translates to:
  /// **'Loading failed. Please try again.'**
  String get splashLoadingError;

  /// No description provided for @splashRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get splashRetry;

  /// No description provided for @appearanceSection.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSection;

  /// No description provided for @darkModeToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkModeToggleTitle;

  /// No description provided for @darkModeToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Switch to dark theme.'**
  String get darkModeToggleSubtitle;

  /// No description provided for @racingThemeToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Racing theme'**
  String get racingThemeToggleTitle;

  /// No description provided for @racingThemeToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Colors inspired by the GarageCrew website.'**
  String get racingThemeToggleSubtitle;

  /// No description provided for @themeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Change theme'**
  String get themeTooltip;

  /// No description provided for @profileSection.
  ///
  /// In en, this message translates to:
  /// **'Garage profile'**
  String get profileSection;

  /// No description provided for @avatarUrlLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile image URL'**
  String get avatarUrlLabel;

  /// No description provided for @avatarUrlHint.
  ///
  /// In en, this message translates to:
  /// **'https://example.com/image.jpg'**
  String get avatarUrlHint;

  /// No description provided for @avatarUrlSaveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save image'**
  String get avatarUrlSaveTooltip;

  /// No description provided for @avatarUrlHelper.
  ///
  /// In en, this message translates to:
  /// **'Profile image visible on your garage.'**
  String get avatarUrlHelper;

  /// No description provided for @avatarSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save profile image.'**
  String get avatarSaveFailed;

  /// No description provided for @bioLabel.
  ///
  /// In en, this message translates to:
  /// **'Profile description'**
  String get bioLabel;

  /// No description provided for @bioHint.
  ///
  /// In en, this message translates to:
  /// **'Write something about yourself or your collection...'**
  String get bioHint;

  /// No description provided for @bioSaveTooltip.
  ///
  /// In en, this message translates to:
  /// **'Save description'**
  String get bioSaveTooltip;

  /// No description provided for @bioHelper.
  ///
  /// In en, this message translates to:
  /// **'Short description visible on your profile.'**
  String get bioHelper;

  /// No description provided for @bioSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save description.'**
  String get bioSaveFailed;

  /// No description provided for @carsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{car} other{cars}}'**
  String carsCount(num count);

  /// No description provided for @noBio.
  ///
  /// In en, this message translates to:
  /// **'No description.'**
  String get noBio;

  /// No description provided for @pickImageTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose image'**
  String get pickImageTitle;

  /// No description provided for @pickFromCamera.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get pickFromCamera;

  /// No description provided for @pickFromGallery.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get pickFromGallery;

  /// No description provided for @pickFromUrl.
  ///
  /// In en, this message translates to:
  /// **'Enter URL'**
  String get pickFromUrl;

  /// No description provided for @imageUploadFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to upload image'**
  String get imageUploadFailed;

  /// No description provided for @imageDeleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Delete this image?'**
  String get imageDeleteConfirm;

  /// No description provided for @galleryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No images'**
  String get galleryEmpty;

  /// No description provided for @tapToAddImage.
  ///
  /// In en, this message translates to:
  /// **'Tap to add image'**
  String get tapToAddImage;

  /// No description provided for @maxImagesReached.
  ///
  /// In en, this message translates to:
  /// **'Maximum {count} images'**
  String maxImagesReached(Object count);

  /// No description provided for @imageUploadPartialFailure.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{image} other{images}} failed to upload.'**
  String imageUploadPartialFailure(num count);

  /// No description provided for @imageUploading.
  ///
  /// In en, this message translates to:
  /// **'Uploading...'**
  String get imageUploading;

  /// No description provided for @reorderImages.
  ///
  /// In en, this message translates to:
  /// **'Drag to reorder'**
  String get reorderImages;

  /// No description provided for @carImagesSection.
  ///
  /// In en, this message translates to:
  /// **'Car images'**
  String get carImagesSection;

  /// No description provided for @addImageButton.
  ///
  /// In en, this message translates to:
  /// **'Add image'**
  String get addImageButton;

  /// No description provided for @exploreGarages.
  ///
  /// In en, this message translates to:
  /// **'Explore'**
  String get exploreGarages;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notificationsEmpty;

  /// No description provided for @notificationsMarkAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get notificationsMarkAllRead;

  /// No description provided for @notificationsClearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get notificationsClearAll;

  /// No description provided for @notificationsClearConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all notifications?'**
  String get notificationsClearConfirmTitle;

  /// No description provided for @notificationsClearConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'This will delete all notifications.'**
  String get notificationsClearConfirmContent;

  /// No description provided for @follow.
  ///
  /// In en, this message translates to:
  /// **'Follow'**
  String get follow;

  /// No description provided for @following.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get following;

  /// No description provided for @unfollowConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Unfollow?'**
  String get unfollowConfirmTitle;

  /// No description provided for @unfollowConfirmContent.
  ///
  /// In en, this message translates to:
  /// **'You won\'t receive notifications about new cars from this garage.'**
  String get unfollowConfirmContent;

  /// No description provided for @followersCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{follower} other{followers}}'**
  String followersCount(num count);

  /// No description provided for @notificationBellTooltip.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationBellTooltip;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'just now'**
  String get justNow;

  /// No description provided for @minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String minutesAgo(Object count);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} h ago'**
  String hoursAgo(Object count);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} d ago'**
  String daysAgo(Object count);

  /// No description provided for @notificationsSection.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsSection;

  /// No description provided for @notificationsToggleTitle.
  ///
  /// In en, this message translates to:
  /// **'Enable notifications'**
  String get notificationsToggleTitle;

  /// No description provided for @notificationsToggleSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Receive notifications about new cars and likes.'**
  String get notificationsToggleSubtitle;

  /// No description provided for @notificationsSaveFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save notification settings.'**
  String get notificationsSaveFailed;

  /// No description provided for @likesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} {count, plural, =1{like} other{likes}}'**
  String likesCount(num count);

  /// No description provided for @likeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Like'**
  String get likeTooltip;

  /// No description provided for @unlikeTooltip.
  ///
  /// In en, this message translates to:
  /// **'Unlike'**
  String get unlikeTooltip;

  /// No description provided for @likedNotificationTitle.
  ///
  /// In en, this message translates to:
  /// **'Someone liked your car'**
  String get likedNotificationTitle;

  /// No description provided for @likedNotificationBody.
  ///
  /// In en, this message translates to:
  /// **'{login} liked: {carTitle}'**
  String likedNotificationBody(Object login, Object carTitle);

  /// No description provided for @quantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantityLabel;

  /// No description provided for @quantityHelper.
  ///
  /// In en, this message translates to:
  /// **'How many copies of this variant'**
  String get quantityHelper;

  /// No description provided for @quantityEmpty.
  ///
  /// In en, this message translates to:
  /// **'Enter quantity.'**
  String get quantityEmpty;

  /// No description provided for @quantityInvalid.
  ///
  /// In en, this message translates to:
  /// **'Quantity must be at least 1.'**
  String get quantityInvalid;

  /// No description provided for @variantLabel.
  ///
  /// In en, this message translates to:
  /// **'Variant (optional)'**
  String get variantLabel;

  /// No description provided for @variantHint.
  ///
  /// In en, this message translates to:
  /// **'e.g., Mint, Opened, TH'**
  String get variantHint;

  /// No description provided for @variantHelper.
  ///
  /// In en, this message translates to:
  /// **'Describe the condition or special edition'**
  String get variantHelper;

  /// No description provided for @advancedFilters.
  ///
  /// In en, this message translates to:
  /// **'Advanced filters'**
  String get advancedFilters;

  /// No description provided for @toyNumberPrefixFilter.
  ///
  /// In en, this message translates to:
  /// **'Toy # series'**
  String get toyNumberPrefixFilter;

  /// No description provided for @toyNumberPrefixAll.
  ///
  /// In en, this message translates to:
  /// **'All series'**
  String get toyNumberPrefixAll;

  /// No description provided for @hasImagesFilter.
  ///
  /// In en, this message translates to:
  /// **'Has images'**
  String get hasImagesFilter;

  /// No description provided for @hasImagesAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get hasImagesAll;

  /// No description provided for @hasImagesYes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get hasImagesYes;

  /// No description provided for @hasImagesNo.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get hasImagesNo;

  /// No description provided for @likesRangeFilter.
  ///
  /// In en, this message translates to:
  /// **'Likes range'**
  String get likesRangeFilter;

  /// No description provided for @dateRangeFilter.
  ///
  /// In en, this message translates to:
  /// **'Added'**
  String get dateRangeFilter;

  /// No description provided for @dateRangeLast7Days.
  ///
  /// In en, this message translates to:
  /// **'Last 7 days'**
  String get dateRangeLast7Days;

  /// No description provided for @dateRangeLast30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get dateRangeLast30Days;

  /// No description provided for @dateRangeLast90Days.
  ///
  /// In en, this message translates to:
  /// **'Last 90 days'**
  String get dateRangeLast90Days;

  /// No description provided for @dateRangeAllTime.
  ///
  /// In en, this message translates to:
  /// **'All time'**
  String get dateRangeAllTime;

  /// No description provided for @clearFilters.
  ///
  /// In en, this message translates to:
  /// **'Clear filters'**
  String get clearFilters;

  /// No description provided for @showingXofYCars.
  ///
  /// In en, this message translates to:
  /// **'Showing {x} of {y} cars'**
  String showingXofYCars(Object x, Object y);

  /// No description provided for @statisticsTitle.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statisticsTitle;

  /// No description provided for @statisticsTooltip.
  ///
  /// In en, this message translates to:
  /// **'View statistics'**
  String get statisticsTooltip;

  /// No description provided for @statisticsLoadFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load statistics.'**
  String get statisticsLoadFailed;

  /// No description provided for @overviewSection.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overviewSection;

  /// No description provided for @popularitySection.
  ///
  /// In en, this message translates to:
  /// **'Popularity'**
  String get popularitySection;

  /// No description provided for @collectionSection.
  ///
  /// In en, this message translates to:
  /// **'Collection'**
  String get collectionSection;

  /// No description provided for @activitySection.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activitySection;

  /// No description provided for @totalCars.
  ///
  /// In en, this message translates to:
  /// **'Total cars'**
  String get totalCars;

  /// No description provided for @totalLikes.
  ///
  /// In en, this message translates to:
  /// **'Total likes'**
  String get totalLikes;

  /// No description provided for @mostLikedCar.
  ///
  /// In en, this message translates to:
  /// **'Most liked car'**
  String get mostLikedCar;

  /// No description provided for @averageLikes.
  ///
  /// In en, this message translates to:
  /// **'Average likes'**
  String get averageLikes;

  /// No description provided for @carsByToyNumber.
  ///
  /// In en, this message translates to:
  /// **'By Toy # series'**
  String get carsByToyNumber;

  /// No description provided for @carsWithImages.
  ///
  /// In en, this message translates to:
  /// **'With images'**
  String get carsWithImages;

  /// No description provided for @carsAddedThisWeek.
  ///
  /// In en, this message translates to:
  /// **'Added this week'**
  String get carsAddedThisWeek;

  /// No description provided for @carsAddedThisMonth.
  ///
  /// In en, this message translates to:
  /// **'Added this month'**
  String get carsAddedThisMonth;

  /// No description provided for @collectionAge.
  ///
  /// In en, this message translates to:
  /// **'Collection age'**
  String get collectionAge;

  /// No description provided for @collectionAgeDays.
  ///
  /// In en, this message translates to:
  /// **'{days} {days, plural, =1{day} other{days}}'**
  String collectionAgeDays(num days);

  /// No description provided for @followers.
  ///
  /// In en, this message translates to:
  /// **'Followers'**
  String get followers;

  /// No description provided for @followingCount.
  ///
  /// In en, this message translates to:
  /// **'Following'**
  String get followingCount;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pl':
      return AppLocalizationsPl();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
