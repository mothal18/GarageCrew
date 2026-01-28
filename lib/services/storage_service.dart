import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'error_logger.dart';

class StorageService {
  static const _carImagesBucket = 'car-images';
  static const _avatarsBucket = 'avatars';
  static const _uuid = Uuid();

  SupabaseClient get _client => Supabase.instance.client;

  String _getFileExtension(String path) {
    final parts = path.split('.');
    if (parts.length > 1) {
      return parts.last.toLowerCase();
    }
    return 'jpg';
  }

  Future<String?> uploadCarImage(File file, String userId, String carId) async {
    try {
      final extension = _getFileExtension(file.path);
      final fileName = '${_uuid.v4()}.$extension';
      final storagePath = '$userId/$carId/$fileName';

      await _client.storage.from(_carImagesBucket).upload(
        storagePath,
        file,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: false,
        ),
      );

      final publicUrl = _client.storage
          .from(_carImagesBucket)
          .getPublicUrl(storagePath);

      return publicUrl;
    } catch (error, stackTrace) {
      ErrorLogger.log(
        error,
        stackTrace: stackTrace,
        context: 'StorageService.uploadCarImage',
      );
      return null;
    }
  }

  Future<String?> uploadAvatar(File file, String userId) async {
    try {
      final extension = _getFileExtension(file.path);
      final fileName = 'avatar.$extension';
      final storagePath = '$userId/$fileName';

      await _client.storage.from(_avatarsBucket).upload(
        storagePath,
        file,
        fileOptions: const FileOptions(
          cacheControl: '3600',
          upsert: true,
        ),
      );

      final publicUrl = _client.storage
          .from(_avatarsBucket)
          .getPublicUrl(storagePath);

      return publicUrl;
    } catch (error, stackTrace) {
      ErrorLogger.log(
        error,
        stackTrace: stackTrace,
        context: 'StorageService.uploadAvatar',
      );
      return null;
    }
  }

  Future<bool> deleteCarImage(String userId, String carId, String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      if (pathSegments.length < 3) return false;

      final fileName = pathSegments.last;
      final storagePath = '$userId/$carId/$fileName';

      await _client.storage.from(_carImagesBucket).remove([storagePath]);
      return true;
    } catch (error, stackTrace) {
      ErrorLogger.log(
        error,
        stackTrace: stackTrace,
        context: 'StorageService.deleteCarImage',
      );
      return false;
    }
  }

  Future<bool> deleteAvatar(String userId) async {
    try {
      final files = await _client.storage.from(_avatarsBucket).list(path: userId);

      if (files.isEmpty) return true;

      final paths = files.map((f) => '$userId/${f.name}').toList();
      await _client.storage.from(_avatarsBucket).remove(paths);
      return true;
    } catch (error, stackTrace) {
      ErrorLogger.log(
        error,
        stackTrace: stackTrace,
        context: 'StorageService.deleteAvatar',
      );
      return false;
    }
  }
}
