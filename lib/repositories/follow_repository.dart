import 'package:supabase_flutter/supabase_flutter.dart';

import 'notification_repository.dart';

class FollowRepository {
  static const _table = 'follows';
  final _notificationRepository = NotificationRepository();

  SupabaseClient get _client => Supabase.instance.client;

  Future<bool> isFollowing(String followerId, String followedId) async {
    final response = await _client
        .from(_table)
        .select('id')
        .eq('follower_id', followerId)
        .eq('followed_id', followedId)
        .maybeSingle();

    return response != null;
  }

  Future<void> follow(String followerId, String followedId) async {
    await _client.from(_table).insert({
      'follower_id': followerId,
      'followed_id': followedId,
    });

    // Get follower's login for notification
    final followerData = await _client
        .from('profiles')
        .select('login')
        .eq('id', followerId)
        .maybeSingle();

    final followerLogin = followerData?['login'] as String? ?? 'Someone';

    // Send notification to followed user
    await _notificationRepository.createNotification(
      userId: followedId,
      type: 'new_follower',
      title: '@$followerLogin started following you',
      data: {
        'follower_id': followerId,
        'follower_login': followerLogin,
      },
    );
  }

  Future<void> unfollow(String followerId, String followedId) async {
    await _client
        .from(_table)
        .delete()
        .eq('follower_id', followerId)
        .eq('followed_id', followedId);
  }

  Future<int> getFollowersCount(String userId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('followed_id', userId)
        .count(CountOption.exact);

    return response.count;
  }

  Future<int> getFollowingCount(String userId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('follower_id', userId)
        .count(CountOption.exact);

    return response.count;
  }

  Future<List<String>> getFollowedIds(String userId) async {
    final response = await _client
        .from(_table)
        .select('followed_id')
        .eq('follower_id', userId);

    return (response as List<dynamic>)
        .map((row) => row['followed_id'] as String)
        .toList();
  }
}
