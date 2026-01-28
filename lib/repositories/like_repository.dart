import 'package:supabase_flutter/supabase_flutter.dart';

import 'notification_repository.dart';

class LikeRepository {
  static const _table = 'likes';
  final _notificationRepository = NotificationRepository();

  SupabaseClient get _client => Supabase.instance.client;

  Future<bool> isLiked(String carId, String userId) async {
    final response = await _client
        .from(_table)
        .select('id')
        .eq('car_id', carId)
        .eq('user_id', userId)
        .maybeSingle();

    return response != null;
  }

  Future<void> like(String carId, String userId) async {
    await _client.from(_table).insert({
      'car_id': carId,
      'user_id': userId,
    });

    // Get car info and owner
    final carData = await _client
        .from('garage_cars')
        .select('title, user_id')
        .eq('id', carId)
        .maybeSingle();

    if (carData == null) return;

    final carOwnerId = carData['user_id'] as String?;
    final carTitle = carData['title'] as String? ?? 'car';

    // Don't notify if user likes their own car
    if (carOwnerId == null || carOwnerId == userId) return;

    // Get liker's login
    final likerData = await _client
        .from('profiles')
        .select('login')
        .eq('id', userId)
        .maybeSingle();

    final likerLogin = likerData?['login'] as String? ?? 'Someone';

    // Send notification to car owner
    await _notificationRepository.createNotification(
      userId: carOwnerId,
      type: 'new_like',
      title: '@$likerLogin liked your $carTitle',
      data: {
        'liker_id': userId,
        'liker_login': likerLogin,
        'car_id': carId,
        'car_title': carTitle,
      },
    );
  }

  Future<void> unlike(String carId, String userId) async {
    await _client
        .from(_table)
        .delete()
        .eq('car_id', carId)
        .eq('user_id', userId);
  }

  Future<int> getLikesCount(String carId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('car_id', carId)
        .count(CountOption.exact);

    return response.count;
  }

  Future<Map<String, int>> getLikesCountForCars(List<String> carIds) async {
    if (carIds.isEmpty) {
      return {};
    }

    final response = await _client
        .from(_table)
        .select('car_id')
        .inFilter('car_id', carIds);

    final counts = <String, int>{};
    for (final carId in carIds) {
      counts[carId] = 0;
    }

    for (final row in response as List<dynamic>) {
      final carId = row['car_id'] as String;
      counts[carId] = (counts[carId] ?? 0) + 1;
    }

    return counts;
  }

  Future<Set<String>> getLikedCarIds(String userId, List<String> carIds) async {
    if (carIds.isEmpty) {
      return {};
    }

    final response = await _client
        .from(_table)
        .select('car_id')
        .eq('user_id', userId)
        .inFilter('car_id', carIds);

    return (response as List<dynamic>)
        .map((row) => row['car_id'] as String)
        .toSet();
  }
}
