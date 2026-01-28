import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final String type;
  final String title;
  final String? body;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  factory NotificationItem.fromMap(Map<String, dynamic> map) {
    return NotificationItem(
      id: map['id'] as String,
      type: map['type'] as String,
      title: map['title'] as String,
      body: map['body'] as String?,
      data: (map['data'] as Map<String, dynamic>?) ?? {},
      isRead: map['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  NotificationItem copyWith({
    String? id,
    String? type,
    String? title,
    String? body,
    Map<String, dynamic>? data,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class NotificationRepository {
  static const _table = 'notifications';

  SupabaseClient get _client => Supabase.instance.client;

  Future<List<NotificationItem>> getNotifications(
    String userId, {
    int limit = 50,
  }) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

    return (response as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(NotificationItem.fromMap)
        .toList();
  }

  Future<int> getUnreadCount(String userId) async {
    final response = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .eq('is_read', false)
        .count(CountOption.exact);

    return response.count;
  }

  Future<void> markAsRead(String notificationId) async {
    await _client
        .from(_table)
        .update({'is_read': true})
        .eq('id', notificationId);
  }

  Future<void> markAllAsRead(String userId) async {
    await _client
        .from(_table)
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  Future<void> deleteNotification(String notificationId) async {
    await _client.from(_table).delete().eq('id', notificationId);
  }

  Future<void> deleteAllNotifications(String userId) async {
    await _client.from(_table).delete().eq('user_id', userId);
  }

  Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    String? body,
    Map<String, dynamic>? data,
  }) async {
    await _client.from(_table).insert({
      'user_id': userId,
      'type': type,
      'title': title,
      'body': body,
      'data': data ?? {},
      'is_read': false,
    });
  }
}
