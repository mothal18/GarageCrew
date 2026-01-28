import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/error_logger.dart';

class ProfileData {
  const ProfileData({
    this.login,
    this.isPublic = false,
    this.garageName = '',
    this.avatarUrl,
    this.bio = '',
    this.notificationsEnabled = true,
  });

  final String? login;
  final bool isPublic;
  final String garageName;
  final String? avatarUrl;
  final String bio;
  final bool notificationsEnabled;

  factory ProfileData.fromMap(Map<String, dynamic> map) {
    return ProfileData(
      login: map['login'] as String?,
      isPublic: map['is_public'] as bool? ?? false,
      garageName: map['garage_name'] as String? ?? '',
      avatarUrl: map['avatar_url'] as String?,
      bio: map['bio'] as String? ?? '',
      notificationsEnabled: map['notifications_enabled'] as bool? ?? true,
    );
  }
}

class ProfileRepository {
  static const _tableName = 'profiles';

  SupabaseClient get _client => Supabase.instance.client;

  Future<ProfileData> loadProfile(String userId) async {
    try {
      final data = await _client
          .from(_tableName)
          .select('login, is_public, garage_name, avatar_url, bio, notifications_enabled')
          .eq('id', userId)
          .single();

      return ProfileData.fromMap(data);
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'ProfileRepository.loadProfile');
      rethrow;
    }
  }

  Future<void> updateGarageName(String userId, String garageName) async {
    try {
      await _client
          .from(_tableName)
          .update({'garage_name': garageName})
          .eq('id', userId);
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'ProfileRepository.updateGarageName');
      rethrow;
    }
  }

  Future<void> updateIsPublic(String userId, bool isPublic) async {
    try {
      await _client
          .from(_tableName)
          .update({'is_public': isPublic})
          .eq('id', userId);
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'ProfileRepository.updateIsPublic');
      rethrow;
    }
  }

  Future<void> updateAvatarUrl(String userId, String avatarUrl) async {
    try {
      await _client
          .from(_tableName)
          .update({'avatar_url': avatarUrl})
          .eq('id', userId);
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'ProfileRepository.updateAvatarUrl');
      rethrow;
    }
  }

  Future<void> updateBio(String userId, String bio) async {
    try {
      await _client
          .from(_tableName)
          .update({'bio': bio})
          .eq('id', userId);
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'ProfileRepository.updateBio');
      rethrow;
    }
  }

  Future<void> updateNotificationsEnabled(String userId, bool enabled) async {
    try {
      await _client
          .from(_tableName)
          .update({'notifications_enabled': enabled})
          .eq('id', userId);
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'ProfileRepository.updateNotificationsEnabled');
      rethrow;
    }
  }

  Future<ProfileData?> loadPublicProfile(String userId) async {
    try {
      final data = await _client
          .from(_tableName)
          .select('login, garage_name, avatar_url, bio')
          .eq('id', userId)
          .eq('is_public', true)
          .maybeSingle();

      if (data == null) return null;
      return ProfileData.fromMap(data);
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'ProfileRepository.loadPublicProfile');
      rethrow;
    }
  }
}
