import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'auth_screen.dart';
import 'car_list_screen.dart';
import 'services/realtime_notification_service.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _lastInitializedUserId;

  @override
  Widget build(BuildContext context) {
    final auth = Supabase.instance.client.auth;

    return StreamBuilder<AuthState>(
      stream: auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen();
        }

        final session = snapshot.data?.session ?? auth.currentSession;

        if (session == null) {
          // User logged out - dispose realtime notifications
          if (_lastInitializedUserId != null) {
            RealtimeNotificationService.instance.dispose();
            _lastInitializedUserId = null;
          }
          return const AuthScreen();
        } else {
          // User logged in - initialize realtime notifications
          final userId = session.user.id;
          if (_lastInitializedUserId != userId) {
            _lastInitializedUserId = userId;
            RealtimeNotificationService.instance.initialize(userId);
          }
          return const CarListScreen();
        }
      },
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth.clamp(200.0, 420.0);
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/splash_screen.png',
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 24),
                      const CircularProgressIndicator(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
