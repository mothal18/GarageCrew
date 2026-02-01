import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/car_item.dart';
import '../services/error_logger.dart';

class CarLimitExceededException implements Exception {
  final int maxCars;
  const CarLimitExceededException(this.maxCars);

  @override
  String toString() => 'Car limit exceeded. Maximum $maxCars cars allowed.';
}

class CarRepository {
  static const _tableName = 'garage_cars';
  static const maxCarsPerUser = 50;

  SupabaseClient get _client => Supabase.instance.client;

  Future<int> getCarCount(String userId) async {
    try {
      final response = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .count(CountOption.exact);

      return response.count;
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'CarRepository.getCarCount');
      rethrow;
    }
  }

  Future<bool> canAddCar(String userId) async {
    final count = await getCarCount(userId);
    return count < maxCarsPerUser;
  }

  Future<List<CarItem>> loadCars(String userId) async {
    try {
      final data = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (data as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(CarItem.fromMap)
          .toList();
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'CarRepository.loadCars');
      rethrow;
    }
  }

  /// Gets all cars with the same toy number for a user
  Future<List<CarItem>> getDuplicatesByToyNumber(
    String userId,
    String toyNumber,
  ) async {
    try {
      final data = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('toy_number', toyNumber)
          .order('created_at', ascending: false);

      return (data as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(CarItem.fromMap)
          .toList();
    } catch (error, stackTrace) {
      ErrorLogger.log(
        error,
        stackTrace: stackTrace,
        context: 'CarRepository.getDuplicatesByToyNumber',
      );
      rethrow;
    }
  }

  /// Gets cars added in the last N days
  Future<List<CarItem>> getRecentCars(String userId, {int days = 7}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));

      final data = await _client
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .gte('created_at', cutoffDate.toIso8601String())
          .order('created_at', ascending: false);

      return (data as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(CarItem.fromMap)
          .toList();
    } catch (error, stackTrace) {
      ErrorLogger.log(
        error,
        stackTrace: stackTrace,
        context: 'CarRepository.getRecentCars',
      );
      rethrow;
    }
  }

  /// Gets the date of the first car added by the user
  Future<DateTime?> getFirstCarDate(String userId) async {
    try {
      final data = await _client
          .from(_tableName)
          .select('created_at')
          .eq('user_id', userId)
          .order('created_at', ascending: true)
          .limit(1)
          .maybeSingle();

      return data != null ? DateTime.tryParse(data['created_at']) : null;
    } catch (error, stackTrace) {
      ErrorLogger.log(
        error,
        stackTrace: stackTrace,
        context: 'CarRepository.getFirstCarDate',
      );
      rethrow;
    }
  }

  Future<CarItem> addCar(CarItem car, String userId) async {
    try {
      // Check car limit
      final canAdd = await canAddCar(userId);
      if (!canAdd) {
        throw CarLimitExceededException(maxCarsPerUser);
      }

      final data = await _client
          .from(_tableName)
          .insert(car.toInsertMap(userId))
          .select()
          .single();

      return CarItem.fromMap(data);
    } catch (error, stackTrace) {
      if (error is CarLimitExceededException) rethrow;
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'CarRepository.addCar');
      rethrow;
    }
  }

  Future<CarItem> updateCar(CarItem car, String userId) async {
    if (car.id == null) {
      throw ArgumentError('Car ID cannot be null for update');
    }

    try {
      final data = await _client
          .from(_tableName)
          .update({
            'title': car.title,
            'description': car.description,
            'image_url': car.imageUrl,
            'toy_number': car.toyNumber,
            'quantity': car.quantity,
            'variant': car.variant,
          })
          .eq('id', car.id as Object)
          .eq('user_id', userId)
          .select()
          .single();

      return CarItem.fromMap(data);
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'CarRepository.updateCar');
      rethrow;
    }
  }

  Future<void> deleteCar(String carId, String userId) async {
    try {
      await _client
          .from(_tableName)
          .delete()
          .eq('id', carId)
          .eq('user_id', userId);
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'CarRepository.deleteCar');
      rethrow;
    }
  }

  /// Gets recently added cars from all users (global feed)
  /// Returns cars with owner login information for Discover feed
  Future<List<Map<String, dynamic>>> getRecentlyAddedCarsGlobal({
    int limit = 50,
  }) async {
    try {
      final data = await _client
          .from(_tableName)
          .select('''
            *,
            profiles!inner(login)
          ''')
          .order('created_at', ascending: false)
          .limit(limit);

      return (data as List<dynamic>).cast<Map<String, dynamic>>();
    } catch (error, stackTrace) {
      ErrorLogger.log(
        error,
        stackTrace: stackTrace,
        context: 'CarRepository.getRecentlyAddedCarsGlobal',
      );
      rethrow;
    }
  }
}
