import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:garage_crew/l10n/app_localizations.dart';

import 'auth_background.dart';
import 'register_screen.dart';
import 'theme/app_colors.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static final RegExp _loginRegex = RegExp(r'^[a-z0-9_]{3,20}$');
  final _formKey = GlobalKey<FormState>();
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final login = _loginController.text.trim().toLowerCase();
      final response = await Supabase.instance.client.functions.invoke(
        'login-with-login',
        body: {'login': login, 'password': _passwordController.text.trim()},
      );
      final data = response.data;
      final decoded = data is String ? jsonDecode(data) as Object? : data;
      final refreshToken = decoded is Map
          ? decoded['refresh_token'] as String?
          : null;
      if (refreshToken == null || refreshToken.isEmpty) {
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.authSignInFailed;
        });
        return;
      }
      await Supabase.instance.client.auth.setSession(refreshToken);
      // Dalej już zajmie się tym AuthGate (nasłuchuje onAuthStateChange)
    } on FunctionException catch (e) {
      final details = e.details;
      String message;
      if (details is Map && details['error'] is String) {
        message = details['error'] as String;
      } else if (details is String && details.isNotEmpty) {
        message = details;
      } else {
        message = AppLocalizations.of(
          context,
        )!.authSignInFailedWithCode(e.status.toString());
      }
      setState(() {
        _errorMessage = message;
      });
    } on AuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = AppLocalizations.of(
          context,
        )!.authSignInFailedWithDetails(e.toString());
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 700;

          return Stack(
            children: [
              const AnimatedAuthBackground(),
              SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 120 : 24,
                    vertical: 32,
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 64,
                    ),
                    child: Center(
                      child: SizedBox(
                        width: 520,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _BrandHeader(theme: theme, isDark: isDark),
                            const SizedBox(height: 24),
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? colorScheme.surface.withValues(alpha: 0.95)
                                    : Colors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(AppRadius.xxl),
                                boxShadow: [
                                  BoxShadow(
                                    color: isDark
                                        ? Colors.black.withValues(alpha: 0.3)
                                        : Colors.black.withValues(alpha: 0.08),
                                    blurRadius: 24,
                                    offset: const Offset(0, 16),
                                  ),
                                ],
                                border: Border.all(
                                  color: isDark
                                      ? colorScheme.outline.withValues(alpha: 0.2)
                                      : Colors.white.withValues(alpha: 0.7),
                                ),
                              ),
                              child: Form(
                                key: _formKey,
                                child: AutofillGroup(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        l10n.authTitle,
                                        style: GoogleFonts.manrope(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        l10n.authSubtitle,
                                        style: GoogleFonts.manrope(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      TextFormField(
                                        controller: _loginController,
                                        decoration: InputDecoration(
                                          labelText: l10n.authLoginLabel,
                                          prefixIcon: const Icon(
                                            Icons.person_outline,
                                          ),
                                        ),
                                        textInputAction: TextInputAction.next,
                                        autofillHints: const [
                                          AutofillHints.username,
                                        ],
                                        validator: (value) {
                                          final trimmed =
                                              value?.trim().toLowerCase() ?? '';
                                          if (trimmed.isEmpty) {
                                            return l10n.authLoginEmpty;
                                          }
                                          if (!_loginRegex.hasMatch(trimmed)) {
                                            return l10n.authLoginInvalid;
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _passwordController,
                                        decoration: InputDecoration(
                                          labelText: l10n.authPasswordLabel,
                                          prefixIcon: const Icon(
                                            Icons.lock_outline,
                                          ),
                                        ),
                                        obscureText: true,
                                        autofillHints: const [
                                          AutofillHints.password,
                                        ],
                                        textInputAction: TextInputAction.done,
                                        onFieldSubmitted: (_) => _signIn(),
                                        validator: (value) {
                                          final trimmed = value?.trim() ?? '';
                                          if (trimmed.isEmpty) {
                                            return l10n.authPasswordEmpty;
                                          }
                                          if (trimmed.length < 6) {
                                            return l10n.authPasswordShort;
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      if (_errorMessage != null) ...[
                                        Text(
                                          _errorMessage!,
                                          style: TextStyle(
                                            color: colorScheme.error,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                      if (_isLoading)
                                        const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                      else ...[
                                        ElevatedButton(
                                          onPressed: _signIn,
                                          child: Text(l10n.authSignInButton),
                                        ),
                                        const SizedBox(height: 12),
                                        OutlinedButton(
                                          onPressed: () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    const RegisterScreen(),
                                              ),
                                            );
                                          },
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                theme.colorScheme.primary,
                                            side: BorderSide(
                                              color: theme.colorScheme.primary,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 14,
                                            ),
                                            textStyle: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            l10n.authCreateAccountButton,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              l10n.authFooter,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                color: isDark
                                    ? AppColors.textTertiaryDark
                                    : AppColors.textTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BrandHeader extends StatelessWidget {
  const _BrandHeader({required this.theme, required this.isDark});

  final ThemeData theme;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final colorScheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: isDark
                ? colorScheme.surface.withValues(alpha: 0.95)
                : Colors.white.withValues(alpha: 0.95),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Image.asset(
              'assets/images/logo_logowanie.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'MyGarage',
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          AppLocalizations.of(context)!.authBrandTagline,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
