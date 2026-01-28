import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:garage_crew/l10n/app_localizations.dart';

import 'main.dart';
import 'repositories/profile_repository.dart';
import 'services/error_logger.dart';
import 'services/storage_service.dart';
import 'theme/app_colors.dart';
import 'widgets/car_thumbnail.dart';
import 'widgets/image_picker_sheet.dart';
import 'widgets/return_to_garage_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _repository = ProfileRepository();
  final _storageService = StorageService();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isUploadingAvatar = false;
  bool _isPublic = false;
  bool _notificationsEnabled = true;
  String _garageName = '';
  String _avatarUrl = '';
  String _bio = '';
  String? _login;
  String? _errorMessage;
  final _garageNameController = TextEditingController();
  final _avatarUrlController = TextEditingController();
  final _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _garageNameController.dispose();
    _avatarUrlController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context)!.settingsNoUser;
      });
      return;
    }

    try {
      final profile = await _repository.loadProfile(user.id);

      if (!mounted) {
        return;
      }
      setState(() {
        _login = profile.login;
        _isPublic = profile.isPublic;
        _notificationsEnabled = profile.notificationsEnabled;
        _garageName = profile.garageName;
        _avatarUrl = profile.avatarUrl ?? '';
        _bio = profile.bio;
        _garageNameController.text = _garageName;
        _avatarUrlController.text = _avatarUrl;
        _bioController.text = _bio;
        _isLoading = false;
      });
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'loadProfile');
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context)!.settingsLoadFailed;
      });
    }
  }

  Future<void> _saveGarageName() async {
    if (_isSaving) {
      return;
    }
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.settingsNoUser;
      });
      return;
    }

    final trimmed = _garageNameController.text.trim();
    if (trimmed == _garageName) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _garageName = trimmed;
    });

    try {
      await _repository.updateGarageName(user.id, trimmed);
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'updateGarageName');
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage =
            AppLocalizations.of(context)!.settingsSaveGarageNameFailed;
        _garageName = _garageNameController.text;
      });
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _togglePublic(bool value) async {
    if (_isSaving) {
      return;
    }
    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _isPublic = value;
    });

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _isSaving = false;
        _errorMessage = AppLocalizations.of(context)!.settingsNoUser;
      });
      return;
    }

    try {
      await _repository.updateIsPublic(user.id, value);
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'updateIsPublic');
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.settingsSaveFailed;
        _isPublic = !value;
      });
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (_isSaving) {
      return;
    }
    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _notificationsEnabled = value;
    });

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _isSaving = false;
        _errorMessage = AppLocalizations.of(context)!.settingsNoUser;
      });
      return;
    }

    try {
      await _repository.updateNotificationsEnabled(user.id, value);
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'updateNotificationsEnabled');
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.notificationsSaveFailed;
        _notificationsEnabled = !value;
      });
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _saveAvatarUrl() async {
    if (_isSaving) {
      return;
    }
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.settingsNoUser;
      });
      return;
    }

    final trimmed = _avatarUrlController.text.trim();
    if (trimmed == _avatarUrl) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _avatarUrl = trimmed;
    });

    try {
      await _repository.updateAvatarUrl(user.id, trimmed);
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'updateAvatarUrl');
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.avatarSaveFailed;
        _avatarUrl = _avatarUrlController.text;
      });
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _saveBio() async {
    if (_isSaving) {
      return;
    }
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.settingsNoUser;
      });
      return;
    }

    final trimmed = _bioController.text.trim();
    if (trimmed == _bio) {
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
      _bio = trimmed;
    });

    try {
      await _repository.updateBio(user.id, trimmed);
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'updateBio');
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.bioSaveFailed;
        _bio = _bioController.text;
      });
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isSaving = false;
      });
    }
  }

  Future<void> _pickAvatar() async {
    if (_isUploadingAvatar) return;

    final result = await ImagePickerSheet.show(context, showUrlOption: false);
    if (result == null || !mounted) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = AppLocalizations.of(context)!.settingsNoUser;
      });
      return;
    }

    if (result.file != null) {
      setState(() {
        _isUploadingAvatar = true;
        _errorMessage = null;
      });

      try {
        final uploadedUrl = await _storageService.uploadAvatar(
          result.file!,
          user.id,
        );

        if (uploadedUrl != null) {
          await _repository.updateAvatarUrl(user.id, uploadedUrl);
          if (!mounted) return;
          setState(() {
            _avatarUrl = uploadedUrl;
            _avatarUrlController.text = uploadedUrl;
          });
        } else {
          throw Exception('Upload failed');
        }
      } catch (error, stackTrace) {
        ErrorLogger.log(error, stackTrace: stackTrace, context: 'uploadAvatar');
        if (!mounted) return;
        setState(() {
          _errorMessage = AppLocalizations.of(context)!.avatarSaveFailed;
        });
      } finally {
        if (!mounted) return;
        setState(() {
          _isUploadingAvatar = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: Text(l10n.settingsTitle),
        actions: const [
          ReturnToGarageButton(),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: AppColors.errorLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                // Profile section - at the top
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.profileSection,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: _isUploadingAvatar ? null : _pickAvatar,
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(48),
                                    child: CarThumbnail(
                                      url: _avatarUrl.isNotEmpty ? _avatarUrl : null,
                                      size: 96,
                                    ),
                                  ),
                                  if (_isUploadingAvatar)
                                    Positioned.fill(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(alpha: 0.5),
                                          borderRadius: BorderRadius.circular(48),
                                        ),
                                        child: const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(6),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.camera_alt,
                                          size: 16,
                                          color: Theme.of(context).colorScheme.onPrimary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_login != null)
                                    Text(
                                      '@$_login',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                    ),
                                  if (_garageName.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      _garageName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          controller: _avatarUrlController,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _saveAvatarUrl(),
                          decoration: InputDecoration(
                            labelText: l10n.avatarUrlLabel,
                            hintText: l10n.avatarUrlHint,
                            suffixIcon: IconButton(
                              tooltip: l10n.avatarUrlSaveTooltip,
                              onPressed: _isSaving ? null : _saveAvatarUrl,
                              icon: const Icon(Icons.save_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          l10n.avatarUrlHelper,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        TextField(
                          controller: _bioController,
                          textInputAction: TextInputAction.done,
                          maxLines: 3,
                          maxLength: 150,
                          onSubmitted: (_) => _saveBio(),
                          decoration: InputDecoration(
                            labelText: l10n.bioLabel,
                            hintText: l10n.bioHint,
                            alignLabelWithHint: true,
                            suffixIcon: IconButton(
                              tooltip: l10n.bioSaveTooltip,
                              onPressed: _isSaving ? null : _saveBio,
                              icon: const Icon(Icons.save_outlined),
                            ),
                          ),
                        ),
                        Text(
                          l10n.bioHelper,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.garageNameSection,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        TextField(
                          controller: _garageNameController,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _saveGarageName(),
                          decoration: InputDecoration(
                            labelText: l10n.garageNameLabel,
                            hintText: l10n.garageNameHint,
                            suffixIcon: IconButton(
                              tooltip: l10n.garageNameSaveTooltip,
                              onPressed: _isSaving ? null : _saveGarageName,
                              icon: const Icon(Icons.save_outlined),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          l10n.garageNameHelper,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.publicGarageSection,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          _login == null
                              ? l10n.publicGarageNoLogin
                              : l10n.publicGarageWithLogin(_login!),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.publicGarageToggleTitle),
                          subtitle: Text(l10n.publicGarageToggleSubtitle),
                          value: _isPublic,
                          onChanged: _isSaving ? null : _togglePublic,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Notifications section
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.notificationsSection,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.notificationsToggleTitle),
                          subtitle: Text(l10n.notificationsToggleSubtitle),
                          value: _notificationsEnabled,
                          onChanged: _isSaving ? null : _toggleNotifications,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                // Appearance section
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.appearanceSection,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ValueListenableBuilder<ThemeMode>(
                          valueListenable: themeNotifier,
                          builder: (context, mode, _) {
                            return SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              title: Text(l10n.darkModeToggleTitle),
                              subtitle: Text(l10n.darkModeToggleSubtitle),
                              value: mode == ThemeMode.dark,
                              onChanged: (value) {
                                themeNotifier.value =
                                    value ? ThemeMode.dark : ThemeMode.light;
                              },
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        ValueListenableBuilder<bool>(
                          valueListenable: racingThemeNotifier,
                          builder: (context, isRacingTheme, _) {
                            return SwitchListTile.adaptive(
                              contentPadding: EdgeInsets.zero,
                              title: Text(l10n.racingThemeToggleTitle),
                              subtitle: Text(l10n.racingThemeToggleSubtitle),
                              value: isRacingTheme,
                              onChanged: (value) {
                                racingThemeNotifier.value = value;
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
