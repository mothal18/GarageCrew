import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/notification_repository.dart';
import 'error_logger.dart';

class RealtimeNotificationService {
  RealtimeNotificationService._();
  static final instance = RealtimeNotificationService._();

  final _notificationRepository = NotificationRepository();
  RealtimeChannel? _channel;
  String? _currentUserId;

  StreamController<int>? _unreadCountController;
  Stream<int> get unreadCountStream =>
      (_unreadCountController ??= StreamController<int>.broadcast()).stream;

  StreamController<NotificationItem>? _newNotificationController;
  Stream<NotificationItem> get newNotificationStream =>
      (_newNotificationController ??= StreamController<NotificationItem>.broadcast()).stream;

  GlobalKey<NavigatorState>? _navigatorKey;

  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  Future<void> initialize(String userId) async {
    if (_currentUserId == userId && _channel != null) {
      return; // Already subscribed for this user
    }

    await dispose();
    _currentUserId = userId;

    // Load initial unread count
    final count = await _notificationRepository.getUnreadCount(userId);
    _unreadCountController?.add(count);

    // Subscribe to realtime changes
    _channel = Supabase.instance.client
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: _onNewNotification,
        )
        .subscribe();
  }

  void _onNewNotification(PostgresChangePayload payload) {
    final newRecord = payload.newRecord;
    if (newRecord.isEmpty) return;

    try {
      final notification = NotificationItem.fromMap(newRecord);
      _newNotificationController?.add(notification);

      // Update unread count
      _refreshUnreadCount();

      // Show in-app banner
      _showNotificationBanner(notification);
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'handleRealtimeNotification');
      // Ignore parsing errors (don't show to user)
    }
  }

  Future<void> _refreshUnreadCount() async {
    if (_currentUserId == null) return;

    try {
      final count = await _notificationRepository.getUnreadCount(_currentUserId!);
      _unreadCountController?.add(count);
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'refreshUnreadCount');
      // Ignore errors (don't show to user)
    }
  }

  void _showNotificationBanner(NotificationItem notification) {
    final context = _navigatorKey?.currentContext;
    if (context == null) return;

    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;

    IconData icon;
    Color backgroundColor;

    switch (notification.type) {
      case 'new_follower':
        icon = Icons.person_add;
        backgroundColor = Colors.blue;
        break;
      case 'new_like':
        icon = Icons.favorite;
        backgroundColor = Colors.red;
        break;
      default:
        icon = Icons.notifications;
        backgroundColor = Colors.grey;
    }

    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                notification.title,
                style: const TextStyle(color: Colors.white),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // Navigate to notifications screen if possible
            _navigatorKey?.currentState?.pushNamed('/notifications');
          },
        ),
      ),
    );
  }

  void notifyUnreadCountChanged() {
    _refreshUnreadCount();
  }

  Future<void> dispose() async {
    await _channel?.unsubscribe();
    _channel = null;
    _currentUserId = null;

    // Close stream controllers to prevent memory leaks
    await _unreadCountController?.close();
    _unreadCountController = null;
    await _newNotificationController?.close();
    _newNotificationController = null;
  }
}
