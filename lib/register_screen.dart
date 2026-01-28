import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:garage_crew/l10n/app_localizations.dart';

import 'auth_background.dart';
import 'theme/app_colors.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static final RegExp _loginRegex = RegExp(r'^[a-z0-9_]{3,20}$');
  final _formKey = GlobalKey<FormState>();
  final loginController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  String? errorMessage;

  @override
  void dispose() {
    loginController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final login = loginController.text.trim().toLowerCase();
      final response = await Supabase.instance.client.auth.signUp(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        data: {'login': login},
      );

      final userId = response.user?.id;
      if (userId != null) {
        await Supabase.instance.client.from('profiles').upsert(
          {
            'id': userId,
            'login': login,
          },
          onConflict: 'id',
        );
      }

      if (response.session == null) {
        setState(() {
          errorMessage =
              AppLocalizations.of(context)!.registerCreatedCheckEmail;
        });
      } else if (mounted) {
        Navigator.of(context).pop();
      }
    } on AuthException catch (e) {
      setState(() {
        if (e.message.contains('duplicate key') ||
            e.message.contains('profiles_login_key')) {
          errorMessage = AppLocalizations.of(context)!.registerLoginTaken;
        } else {
          errorMessage = e.message;
        }
      });
    } catch (e) {
      setState(() {
        errorMessage = AppLocalizations.of(context)!.registerCreateFailed;
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
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
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF6A00), // Hot Wheels Orange
                Color(0xFFFF8533), // Lighter Orange
              ],
            ),
          ),
        ),
        title: Text(l10n.registerTitle),
      ),
      body: Stack(
        children: [
          const AnimatedAuthBackground(),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 700;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isWide ? 120 : 24,
                    vertical: 32,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 520,
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isDark
                              ? colorScheme.surface.withValues(alpha: 0.96)
                              : Colors.white.withValues(alpha: 0.96),
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
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  l10n.registerHeader,
                                  style: GoogleFonts.manrope(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  l10n.registerSubtitle,
                                  style: GoogleFonts.manrope(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                TextFormField(
                                  controller: loginController,
                                  decoration: InputDecoration(
                                    labelText: l10n.authLoginLabel,
                                    prefixIcon: const Icon(
                                      Icons.person_outline,
                                    ),
                                  ),
                                  textInputAction: TextInputAction.next,
                                  autofillHints: const [
                                    AutofillHints.username
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
                                  controller: emailController,
                                  decoration: InputDecoration(
                                    labelText: l10n.registerEmailLabel,
                                    prefixIcon: const Icon(Icons.mail_outline),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  autofillHints: const [AutofillHints.email],
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    final trimmed = value?.trim() ?? '';
                                    if (trimmed.isEmpty) {
                                      return l10n.registerEmailEmpty;
                                    }
                                    if (!trimmed.contains('@')) {
                                      return l10n.registerEmailInvalid;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: passwordController,
                                  decoration: InputDecoration(
                                    labelText: l10n.registerPasswordLabel,
                                    prefixIcon: const Icon(Icons.lock_outline),
                                  ),
                                  obscureText: true,
                                  autofillHints: const [
                                    AutofillHints.newPassword
                                  ],
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _signUp(),
                                  validator: (value) {
                                    final trimmed = value?.trim() ?? '';
                                    if (trimmed.isEmpty) {
                                      return l10n.registerPasswordEmpty;
                                    }
                                    if (trimmed.length < 6) {
                                      return l10n.registerPasswordShort;
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                if (errorMessage != null) ...[
                                  Text(
                                    errorMessage!,
                                    style: TextStyle(
                                      color: colorScheme.error,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],
                                if (isLoading)
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                else
                                  ElevatedButton(
                                    onPressed: _signUp,
                                    child: Text(
                                      l10n.registerCreateAccountButton,
                                    ),
                                  ),
                                const SizedBox(height: 12),
                                TextButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme.colorScheme.primary,
                                  ),
                                  child: Text(l10n.registerHaveAccount),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
