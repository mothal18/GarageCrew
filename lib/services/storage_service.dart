import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'error_logger.dart';

/// Exception thrown when a storage operation fails.
class StorageException implements Exception {
  const StorageException(this.message, {this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'StorageException: $message';
}

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

  /// Uploads a car image and returns its public URL.
  ///
  /// Throws [StorageException] if the upload fails.
  Future<String> uploadCarImage(File file, String userId, String carId) async {
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
      throw StorageException('Failed to upload car image', cause: error);
    }
  }

  /// Uploads a user avatar and returns its public URL.
  ///
  /// Throws [StorageException] if the upload fails.
  Future<String> uploadAvatar(File file, String userId) async {
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
      throw StorageException('Failed to upload avatar', cause: error);
    }
  }

  /// Deletes a car image from storage.
  ///
  /// Throws [StorageException] if the deletion fails.
  Future<void> deleteCarImage(String userId, String carId, String imageUrl) async {
    try {
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      if (pathSegments.length < 3) {
        throw const StorageException('Invalid image URL: path too short');
      }

      final fileName = pathSegments.last;
      final storagePath = '$userId/$carId/$fileName';

      await _client.storage.from(_carImagesBucket).remove([storagePath]);
    } catch (error, stackTrace) {
      if (error is StorageException) rethrow;
      ErrorLogger.log(
        error,
        stackTrace: stackTrace,
        context: 'StorageService.deleteCarImage',
      );
      throw StorageException('Failed to delete car image', cause: error);
    }
  }

  /// Deletes a user's avatar from storage.
  ///
  /// Throws [StorageException] if the deletion fails.
  Future<void> deleteAvatar(String userId) async {
    try {
      final files = await _client.storage.from(_avatarsBucket).list(path: userId);

      if (files.isEmpty) return;

      final paths = files.map((f) => '$userId/${f.name}').toList();
      await _client.storage.from(_avatarsBucket).remove(paths);
    } catch (error, stackTrace) {
      ErrorLogger.log(
        error,
        stackTrace: stackTrace,
        context: 'StorageService.deleteAvatar',
      );
      throw StorageException('Failed to delete avatar', cause: error);
    }
  }
}
