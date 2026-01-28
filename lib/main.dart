import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:garage_crew/l10n/app_localizations.dart';

import 'notifications_screen.dart';
import 'services/realtime_notification_service.dart';
import 'splash_screen.dart';
import 'theme/app_theme.dart';
import 'theme/racing_theme.dart';

final themeNotifier = ValueNotifier<ThemeMode>(ThemeMode.system);
final racingThemeNotifier = ValueNotifier<bool>(true); // Racing theme as default
final navigatorKey = GlobalKey<NavigatorState>();
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // Set navigator key for realtime notifications
  RealtimeNotificationService.instance.setNavigatorKey(navigatorKey);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: racingThemeNotifier,
      builder: (context, isRacingTheme, _) {
        return ValueListenableBuilder<ThemeMode>(
          valueListenable: themeNotifier,
          builder: (context, themeMode, _) {
            return MaterialApp(
              title: 'GarageCrew',
              debugShowCheckedModeBanner: false,
              navigatorKey: navigatorKey,
              scaffoldMessengerKey: scaffoldMessengerKey,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: AppLocalizations.supportedLocales,
              theme: isRacingTheme ? RacingTheme.dark : AppTheme.light,
              darkTheme: isRacingTheme ? RacingTheme.dark : AppTheme.dark,
              themeMode: themeMode,
              home: const SplashScreen(),
              routes: {
                '/notifications': (_) => const NotificationsScreen(),
              },
            );
          },
        );
      },
    );
  }
}
