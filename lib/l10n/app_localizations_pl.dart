// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class AppLocalizationsPl extends AppLocalizations {
  AppLocalizationsPl([String locale = 'pl']) : super(locale);

  @override
  String get authSignInFailed => 'Nie udało się zalogować.';

  @override
  String authSignInFailedWithCode(Object code) {
    return 'Nie udało się zalogować. Kod: $code';
  }

  @override
  String authSignInFailedWithDetails(Object details) {
    return 'Nie udało się zalogować. Szczegóły: $details';
  }

  @override
  String get authTitle => 'Zaloguj się';

  @override
  String get authSubtitle => 'Dostęp do Twojego garażu w jednym miejscu.';

  @override
  String get authLoginLabel => 'Login';

  @override
  String get authLoginEmpty => 'Podaj login.';

  @override
  String get authLoginInvalid => 'Login: 3-20 znaków, a-z, 0-9 lub _.';

  @override
  String get authPasswordLabel => 'Hasło';

  @override
  String get authPasswordEmpty => 'Podaj hasło.';

  @override
  String get authPasswordShort => 'Hasło musi mieć min. 6 znaków.';

  @override
  String get authSignInButton => 'Zaloguj';

  @override
  String get authCreateAccountButton => 'Utwórz konto';

  @override
  String get authFooter =>
      'Korzystając z aplikacji akceptujesz regulamin i politykę prywatności.';

  @override
  String get authBrandTagline =>
      'Zarządzaj kolekcją Hot Wheels jak profesjonalista.';

  @override
  String get registerTitle => 'Rejestracja';

  @override
  String get registerHeader => 'Utwórz konto';

  @override
  String get registerSubtitle => 'Dołącz do MyGarage i buduj swoją kolekcję.';

  @override
  String get registerEmailLabel => 'Email';

  @override
  String get registerEmailEmpty => 'Podaj email.';

  @override
  String get registerEmailInvalid => 'Podaj poprawny email.';

  @override
  String get registerPasswordLabel => 'Hasło';

  @override
  String get registerPasswordEmpty => 'Podaj hasło.';

  @override
  String get registerPasswordShort => 'Hasło musi mieć min. 6 znaków.';

  @override
  String get registerCreateAccountButton => 'Utwórz konto';

  @override
  String get registerHaveAccount => 'Masz już konto? Zaloguj się';

  @override
  String get registerSuccessTitle => 'Sukces!';

  @override
  String get registerCreatedCheckEmail =>
      'Konto utworzone. Sprawdź maila, aby potwierdzić konto.';

  @override
  String get registerLoginTaken => 'Ten login jest już zajęty.';

  @override
  String get registerCreateFailed =>
      'Nie udało się utworzyć konta. Spróbuj ponownie.';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsNoUser => 'Brak zalogowanego użytkownika.';

  @override
  String get settingsLoadFailed => 'Nie udało się pobrać ustawień.';

  @override
  String get settingsSaveGarageNameFailed =>
      'Nie udało się zapisać nazwy garażu.';

  @override
  String get settingsSaveFailed => 'Nie udało się zapisać ustawień.';

  @override
  String get garageNameSection => 'Nazwa garażu';

  @override
  String get garageNameLabel => 'Nazwa wyświetlana';

  @override
  String get garageNameHint => 'np. Garaż Mothal';

  @override
  String get garageNameSaveTooltip => 'Zapisz nazwę';

  @override
  String get garageNameHelper =>
      'Ta nazwa będzie widoczna dla innych po udostępnieniu garażu.';

  @override
  String get publicGarageSection => 'Publiczny garaż';

  @override
  String get publicGarageNoLogin => 'Twój garaż może być publiczny.';

  @override
  String publicGarageWithLogin(Object login) {
    return 'Twój login: $login';
  }

  @override
  String get publicGarageToggleTitle => 'Udostępnij mój garaż publicznie';

  @override
  String get publicGarageToggleSubtitle =>
      'Inni będą mogli znaleźć Twój garaż po loginie.';

  @override
  String get carListSignOutFailed =>
      'Nie udało się wylogować. Spróbuj ponownie.';

  @override
  String get carListLoadFailed => 'Nie udało się pobrać autek.';

  @override
  String get carListSaveCarFailed => 'Nie udało się zapisać autka.';

  @override
  String get carListSaveChangesFailed => 'Nie udało się zapisać zmian.';

  @override
  String get carListDeleteFailed => 'Nie udało się usunąć autka.';

  @override
  String carLimitReached(Object maxCars) {
    return 'Osiągnięto limit $maxCars autek w garażu.';
  }

  @override
  String imageLimitReached(Object maxImages) {
    return 'Maksymalnie $maxImages zdjęć na autko.';
  }

  @override
  String get networkError =>
      'Brak połączenia z internetem. Sprawdź połączenie i spróbuj ponownie.';

  @override
  String get unknownError => 'Wystąpił nieoczekiwany błąd. Spróbuj ponownie.';

  @override
  String get carDeleteTitle => 'Usunąć autko?';

  @override
  String get carDeleteContent => 'To autko zostanie usunięte z Twojego garażu.';

  @override
  String get cancel => 'Anuluj';

  @override
  String get delete => 'Usuń';

  @override
  String get settingsTooltip => 'Ustawienia';

  @override
  String get logoutTooltip => 'Wyloguj';

  @override
  String get publicGaragesTooltip => 'Publiczne garaże';

  @override
  String get garageEmpty => 'Twój garaż jest pusty.';

  @override
  String get addCar => 'Dodaj autko';

  @override
  String get searchNoResults => 'Brak wyników dla tego wyszukiwania.';

  @override
  String get editCarTooltip => 'Edytuj autko';

  @override
  String get deleteCarTooltip => 'Usuń autko';

  @override
  String get searchGarageLabel => 'Szukaj w garażu';

  @override
  String get sortLabel => 'Sortowanie';

  @override
  String get sortNewest => 'Najnowsze';

  @override
  String get sortOldest => 'Najstarsze';

  @override
  String get sortAz => 'A-Z';

  @override
  String get sortZa => 'Z-A';

  @override
  String get addCarTitle => 'Dodaj autko';

  @override
  String get editCarTitle => 'Edytuj autko';

  @override
  String get save => 'Zapisz';

  @override
  String get carDataSection => 'Dane autka';

  @override
  String get carNameLabel => 'Nazwa / model';

  @override
  String get carNameEmpty => 'Podaj nazwę autka.';

  @override
  String get toyNumberLabel => 'Numer Toy';

  @override
  String get toyNumberHint => 'np. JJJ02';

  @override
  String get toyNumberHelper => 'Format: 3 wielkie litery + 2 cyfry (ABC12)';

  @override
  String get toyNumberEmpty => 'Podaj numer Toy.';

  @override
  String get toyNumberInvalidFormat =>
      'Nieprawidłowy format. Użyj: 3 litery + 2 cyfry (np. JJJ02)';

  @override
  String get toyNumberAlreadyExists =>
      'Ten numer Toy już istnieje w Twoim garażu.';

  @override
  String get toyNumberReminderAfterSearch => 'Nie zapomnij wpisać numeru Toy!';

  @override
  String get carDescriptionLabel => 'Opis (opcjonalnie)';

  @override
  String get carImageUrlLabel => 'URL zdjęcia (opcjonalnie)';

  @override
  String get hotWheelsSearchSection => 'Wyszukaj w bazie Hot Wheels';

  @override
  String get hotWheelsSearchLabel => 'Szukaj po nazwie';

  @override
  String get hotWheelsSearchFailed => 'Nie udało się pobrać wyników.';

  @override
  String get hotWheelsSearchHint =>
      'Wpisz przynajmniej 2 znaki, aby wyszukać autko.';

  @override
  String get noResults => 'Brak wyników.';

  @override
  String get saveChanges => 'Zapisz zmiany';

  @override
  String get addToGarage => 'Dodaj do garażu';

  @override
  String get useDataTooltip => 'Użyj danych';

  @override
  String get carDetailsTitle => 'Szczegóły autka';

  @override
  String get noDescription => 'Brak opisu.';

  @override
  String get imageUrlLabel => 'URL zdjęcia';

  @override
  String get addedAtLabel => 'Dodano';

  @override
  String get publicGaragesTitle => 'Publiczne garaże';

  @override
  String get publicSearchLabel => 'Szukaj po loginie lub nazwie garażu';

  @override
  String get publicSearchTooltip => 'Szukaj';

  @override
  String get publicSearchHint =>
      'Wpisz co najmniej 2 znaki, aby wyszukać garaż.';

  @override
  String get publicSearchNoResults => 'Brak wyników.';

  @override
  String get discoverRecentModels => 'Odkryj Nowe Modele';

  @override
  String get discoverLoadFailed => 'Nie udało się załadować ostatnich modeli.';

  @override
  String get publicGarageSubtitle => 'Publiczny garaż';

  @override
  String get publicGaragesLoadFailed =>
      'Nie udało się pobrać publicznych garaży.';

  @override
  String get publicGarageCarsLoadFailed => 'Nie udało się pobrać autek.';

  @override
  String publicGarageTitle(Object login) {
    return 'Garaż: $login';
  }

  @override
  String get publicGarageEmpty => 'Ten garaż jest pusty.';

  @override
  String get splashLoading => 'Ładowanie...';

  @override
  String get splashLoadingError => 'Błąd ładowania. Spróbuj ponownie.';

  @override
  String get splashRetry => 'Spróbuj ponownie';

  @override
  String get appearanceSection => 'Wygląd';

  @override
  String get darkModeToggleTitle => 'Tryb ciemny';

  @override
  String get darkModeToggleSubtitle => 'Zmień motyw aplikacji na ciemny.';

  @override
  String get racingThemeToggleTitle => 'Motyw wyścigowy';

  @override
  String get racingThemeToggleSubtitle =>
      'Kolorystyka inspirowana stroną GarageCrew.';

  @override
  String get themeTooltip => 'Zmień motyw';

  @override
  String get profileSection => 'Profil garażu';

  @override
  String get avatarUrlLabel => 'URL zdjęcia profilowego';

  @override
  String get avatarUrlHint => 'https://example.com/zdjecie.jpg';

  @override
  String get avatarUrlSaveTooltip => 'Zapisz zdjęcie';

  @override
  String get avatarUrlHelper => 'Zdjęcie profilowe widoczne przy Twoim garażu.';

  @override
  String get avatarSaveFailed => 'Nie udało się zapisać zdjęcia profilowego.';

  @override
  String get bioLabel => 'Opis profilu';

  @override
  String get bioHint => 'Napisz coś o sobie lub swojej kolekcji...';

  @override
  String get bioSaveTooltip => 'Zapisz opis';

  @override
  String get bioHelper => 'Krótki opis widoczny na Twoim profilu.';

  @override
  String get bioSaveFailed => 'Nie udało się zapisać opisu.';

  @override
  String carsCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'autek',
      few: 'autka',
      one: 'autko',
    );
    return '$count $_temp0';
  }

  @override
  String get noBio => 'Brak opisu.';

  @override
  String get pickImageTitle => 'Wybierz zdjęcie';

  @override
  String get pickFromCamera => 'Zrób zdjęcie';

  @override
  String get pickFromGallery => 'Wybierz z galerii';

  @override
  String get pickFromUrl => 'Wpisz URL';

  @override
  String get imageUploadFailed => 'Nie udało się przesłać zdjęcia';

  @override
  String get imageDeleteConfirm => 'Usunąć to zdjęcie?';

  @override
  String get galleryEmpty => 'Brak zdjęć';

  @override
  String get tapToAddImage => 'Dotknij, aby dodać zdjęcie';

  @override
  String maxImagesReached(Object count) {
    return 'Maksymalnie $count zdjęć';
  }

  @override
  String imageUploadPartialFailure(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count zdjęć nie zostało przesłanych.',
      one: '1 zdjęcie nie zostało przesłane.',
    );
    return '$_temp0';
  }

  @override
  String get imageUploading => 'Przesyłanie...';

  @override
  String get reorderImages => 'Przeciągnij, aby zmienić kolejność';

  @override
  String get carImagesSection => 'Zdjęcia autka';

  @override
  String get addImageButton => 'Dodaj zdjęcie';

  @override
  String get exploreGarages => 'Szukaj';

  @override
  String get notificationsTitle => 'Powiadomienia';

  @override
  String get notificationsEmpty => 'Brak powiadomień';

  @override
  String get notificationsMarkAllRead => 'Oznacz wszystkie';

  @override
  String get notificationsClearAll => 'Wyczyść wszystkie';

  @override
  String get notificationsClearConfirmTitle =>
      'Wyczyścić wszystkie powiadomienia?';

  @override
  String get notificationsClearConfirmContent =>
      'Ta operacja usunie wszystkie powiadomienia.';

  @override
  String get follow => 'Obserwuj';

  @override
  String get following => 'Obserwujesz';

  @override
  String get unfollowConfirmTitle => 'Przestać obserwować?';

  @override
  String get unfollowConfirmContent =>
      'Nie będziesz otrzymywać powiadomień o nowych autkach z tego garażu.';

  @override
  String followersCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'obserwujących',
      one: 'obserwujący',
    );
    return '$count $_temp0';
  }

  @override
  String get notificationBellTooltip => 'Powiadomienia';

  @override
  String get justNow => 'przed chwilą';

  @override
  String minutesAgo(Object count) {
    return '$count min temu';
  }

  @override
  String hoursAgo(Object count) {
    return '$count godz. temu';
  }

  @override
  String daysAgo(Object count) {
    return '$count dni temu';
  }

  @override
  String get notificationsSection => 'Powiadomienia';

  @override
  String get notificationsToggleTitle => 'Włącz powiadomienia';

  @override
  String get notificationsToggleSubtitle =>
      'Otrzymuj powiadomienia o nowych autkach i polubieniach.';

  @override
  String get notificationsSaveFailed =>
      'Nie udało się zapisać ustawień powiadomień.';

  @override
  String likesCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'polubień',
      few: 'polubienia',
      one: 'polubienie',
    );
    return '$count $_temp0';
  }

  @override
  String get likeTooltip => 'Polub';

  @override
  String get unlikeTooltip => 'Cofnij polubienie';

  @override
  String get likedNotificationTitle => 'Ktoś polubił Twoje autko';

  @override
  String likedNotificationBody(Object login, Object carTitle) {
    return '$login polubił(a): $carTitle';
  }

  @override
  String get quantityLabel => 'Ilość';

  @override
  String get quantityHelper => 'Ile kopii tego wariantu posiadasz';

  @override
  String get quantityEmpty => 'Podaj ilość.';

  @override
  String get quantityInvalid => 'Ilość musi wynosić co najmniej 1.';

  @override
  String get variantLabel => 'Wariant (opcjonalnie)';

  @override
  String get variantHint => 'np. Mint, Otwarty, TH';

  @override
  String get variantHelper => 'Opisz stan lub specjalną edycję';

  @override
  String get advancedFilters => 'Filtry zaawansowane';

  @override
  String get toyNumberPrefixFilter => 'Serie Toy #';

  @override
  String get toyNumberPrefixAll => 'Wszystkie serie';

  @override
  String get hasImagesFilter => 'Ma zdjęcia';

  @override
  String get hasImagesAll => 'Wszystkie';

  @override
  String get hasImagesYes => 'Tak';

  @override
  String get hasImagesNo => 'Nie';

  @override
  String get likesRangeFilter => 'Zakres polubień';

  @override
  String get dateRangeFilter => 'Dodane';

  @override
  String get dateRangeLast7Days => 'Ostatnie 7 dni';

  @override
  String get dateRangeLast30Days => 'Ostatnie 30 dni';

  @override
  String get dateRangeLast90Days => 'Ostatnie 90 dni';

  @override
  String get dateRangeAllTime => 'Cały czas';

  @override
  String get clearFilters => 'Wyczyść filtry';

  @override
  String showingXofYCars(Object x, Object y) {
    return 'Wyświetlanie $x z $y autek';
  }

  @override
  String get statisticsTitle => 'Statystyki';

  @override
  String get statisticsTooltip => 'Zobacz statystyki';

  @override
  String get statisticsLoadFailed => 'Nie udało się pobrać statystyk.';

  @override
  String get overviewSection => 'Przegląd';

  @override
  String get popularitySection => 'Popularność';

  @override
  String get collectionSection => 'Kolekcja';

  @override
  String get activitySection => 'Aktywność';

  @override
  String get totalCars => 'Łącznie aut';

  @override
  String get totalLikes => 'Łącznie polubień';

  @override
  String get mostLikedCar => 'Najbardziej lajkowane';

  @override
  String get averageLikes => 'Średnia polubień';

  @override
  String get carsByToyNumber => 'Według serii Toy #';

  @override
  String get carsWithImages => 'Ze zdjęciami';

  @override
  String get carsAddedThisWeek => 'Dodane w tym tygodniu';

  @override
  String get carsAddedThisMonth => 'Dodane w tym miesiącu';

  @override
  String get collectionAge => 'Wiek kolekcji';

  @override
  String collectionAgeDays(num days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'dni',
      few: 'dni',
      one: 'dzień',
    );
    return '$days $_temp0';
  }

  @override
  String get followers => 'Obserwujący';

  @override
  String get followingCount => 'Obserwowanych';
}
