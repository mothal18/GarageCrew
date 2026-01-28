import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/error_logger.dart';

class CarImage {
  const CarImage({
    required this.id,
    required this.carId,
    required this.userId,
    required this.imageUrl,
    this.displayOrder = 0,
    this.createdAt,
  });

  final String id;
  final String carId;
  final String userId;
  final String imageUrl;
  final int displayOrder;
  final DateTime? createdAt;

  factory CarImage.fromMap(Map<String, dynamic> map) {
    return CarImage(
      id: map['id']?.toString() ?? '',
      carId: map['car_id']?.toString() ?? '',
      userId: map['user_id']?.toString() ?? '',
      imageUrl: map['image_url'] as String? ?? '',
      displayOrder: map['display_order'] as int? ?? 0,
      createdAt: DateTime.tryParse(map['created_at']?.toString() ?? ''),
    );
  }
}

class CarImageRepository {
  static const _tableName = 'car_images';

  SupabaseClient get _client => Supabase.instance.client;

  Future<List<CarImage>> getImagesForCar(String carId) async {
    try {
      final data = await _client
          .from(_tableName)
          .select()
          .eq('car_id', carId)
          .order('display_order', ascending: true);

      return (data as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(CarImage.fromMap)
          .toList();
    } catch (error, stackTrace) {
      ErrorLogger.log(
        error,
        stackTrace: stackTrace,
        context: 'CarImageRepository.getImagesForCar',
      );
      return [];
    }
  }

  Future<List<String>> getImageUrlsForCar(String carId) async {
    final images = await getImagesForCar(carId);
    return images.map((img) => img.imageUrl).toList();
  }

  Future<CarImage?> addImage(
    String carId,
    String userId,
    String imageUrl, {
    int? displayOrder,
  }) async {
    try {
      final order = displayOrder ?? await _getNextDisplayOrder(carId);

      final data = await _client.from(_tableName).insert({
        'car_id': carId,
        'user_id': userId,
        'image_url': imageUrl,
        'display_order': order,
      }).select().single();

      return CarImage.fromMap(data);
    } catch (error, stackTrace) {
      ErrorLogger.log(
        error,
        stackTrace: stackTrace,
        context: 'CarImageRepository.addImage',
      );
      return null;
    }
  }

  Future<int> _getNextDisplayOrder(String carId) async {
    try {
      final data = await _client
          .from(_tableName)
          .select('display_order')
          .eq('car_id', carId)
          .order('display_order', ascending: false)
          .limit(1);

      if ((data as List).isEmpty) return 0;
      return (data.first['display_order'] as int? ?? 0) + 1;
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'getNextDisplayOrder');
      return 0;
    }
  }

  Future<bool> deleteImage(String imageId) async {
    try {
      await _client.from(_tableName).delete().eq('id', imageId);
      return true;
    } catch (error, stackTrace) {
      ErrorLogger.log(
        error,
        stackTrace: stackTrace,
        context: 'CarImageRepository.deleteImage',
      );
      return false;
    }
  }

  Future<bool> deleteAllImagesForCar(String carId) async {
    try {
      await _client.from(_tableName).delete().eq('car_id', carId);
      return true;
    } catch (error, stackTrace) {
      ErrorLogger.log(
        error,
        stackTrace: stackTrace,
        context: 'CarImageRepository.deleteAllImagesForCar',
      );
      return false;
    }
  }

  Future<bool> reorderImages(String carId, List<String> imageIds) async {
    try {
      for (int i = 0; i < imageIds.length; i++) {
        await _client
            .from(_tableName)
            .update({'display_order': i})
            .eq('id', imageIds[i]);
      }
      return true;
    } catch (error, stackTrace) {
      ErrorLogger.log(
        error,
        stackTrace: stackTrace,
        context: 'CarImageRepository.reorderImages',
      );
      return false;
    }
  }
}
