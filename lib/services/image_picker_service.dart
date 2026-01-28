import 'dart:io';

import 'package:image_picker/image_picker.dart';

import 'error_logger.dart';

class ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  static const int defaultMaxWidth = 1200;
  static const int defaultImageQuality = 85;

  Future<File?> pickFromCamera({
    int maxWidth = defaultMaxWidth,
    int imageQuality = defaultImageQuality,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: maxWidth.toDouble(),
        imageQuality: imageQuality,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (error, stackTrace) {
      ErrorLogger.log(
        error,
        stackTrace: stackTrace,
        context: 'ImagePickerService.pickFromCamera',
      );
      return null;
    }
  }

  Future<File?> pickFromGallery({
    int maxWidth = defaultMaxWidth,
    int imageQuality = defaultImageQuality,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        imageQuality: imageQuality,
      );

      if (image == null) return null;
      return File(image.path);
    } catch (error, stackTrace) {
      ErrorLogger.log(
        error,
        stackTrace: stackTrace,
        context: 'ImagePickerService.pickFromGallery',
      );
      return null;
    }
  }

  Future<List<File>> pickMultipleFromGallery({
    int limit = 5,
    int maxWidth = defaultMaxWidth,
    int imageQuality = defaultImageQuality,
  }) async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: maxWidth.toDouble(),
        imageQuality: imageQuality,
        limit: limit,
      );

      return images.map((xFile) => File(xFile.path)).toList();
    } catch (error, stackTrace) {
      ErrorLogger.log(
        error,
        stackTrace: stackTrace,
        context: 'ImagePickerService.pickMultipleFromGallery',
      );
      return [];
    }
  }
}
