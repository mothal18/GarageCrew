import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:garage_crew/l10n/app_localizations.dart';

import 'auth_gate.dart';
import 'config/env_config.dart';
import 'services/error_logger.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _minDisplayDuration = Duration(seconds: 2);
  final ValueNotifier<double> _progress = ValueNotifier<double>(0.0);
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeApp();
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  Future<void> _initializeApp() async {
    final startedAt = DateTime.now();
    try {
      _progress.value = 0.1;
      await _precacheAsset('assets/images/logo_logowanie.png');

      _progress.value = 0.3;
      await _initializeSupabase();

      _progress.value = 0.7;
      await _precacheAsset('assets/images/splash_screen.png');
      _progress.value = 1.0;
    } catch (error, stackTrace) {
      debugPrint('Splash init failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }

    if (!mounted) {
      return;
    }

    final elapsed = DateTime.now().difference(startedAt);
    final remainingMs =
        _minDisplayDuration.inMilliseconds - elapsed.inMilliseconds;
    if (remainingMs > 0) {
      await Future<void>.delayed(Duration(milliseconds: remainingMs));
    }

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthGate()));
  }

  Future<void> _initializeSupabase() async {
    if (_isSupabaseInitialized()) {
      return;
    }

    try {
      await Supabase.initialize(
        url: EnvConfig.supabaseUrl,
        anonKey: EnvConfig.supabaseAnonKey,
      );
    } catch (error, stackTrace) {
      if (_isSupabaseAlreadyInitializedError(error)) {
        return;
      }
      debugPrint('Supabase init failed: $error');
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
    }
  }

  bool _isSupabaseInitialized() {
    try {
      Supabase.instance.client;
      return true;
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'isSupabaseInitialized');
      return false;
    }
  }

  bool _isSupabaseAlreadyInitializedError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('already initialized') ||
        message.contains('already been initialized');
  }

  Future<void> _precacheAsset(String assetPath) async {
    try {
      await precacheImage(AssetImage(assetPath), context);
    } catch (error, stackTrace) {
      debugPrint('Precache failed for $assetPath: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  void _retryInitialization() {
    setState(() {
      _progress.value = 0.0;
      _initFuture = _initializeApp();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/splash_screen.png', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.black.withValues(alpha: 0.35),
                  Colors.black.withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 16, 32, 36),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ValueListenableBuilder<double>(
                      valueListenable: _progress,
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value.clamp(0.0, 1.0),
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(999),
                          backgroundColor: Colors.white.withValues(alpha: 0.35),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Text(
                      AppLocalizations.of(context)?.splashLoading ??
                          'Loading...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 0.3,
                      ),
                    ),
                    FutureBuilder<void>(
                      future: _initFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              AppLocalizations.of(
                                    context,
                                  )?.splashLoadingError ??
                                  'Loading failed.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    FutureBuilder<void>(
                      future: _initFuture,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: TextButton(
                              onPressed: _retryInitialization,
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.white.withValues(
                                  alpha: 0.15,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: Text(
                                AppLocalizations.of(context)?.splashRetry ??
                                    'Try again',
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
