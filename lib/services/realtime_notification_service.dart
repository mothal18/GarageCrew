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

  // Stream controllers are kept alive for the singleton's lifetime to avoid
  // breaking listeners on user switch. Only the channel is unsubscribed.
  final _unreadCountController = StreamController<int>.broadcast();
  Stream<int> get unreadCountStream => _unreadCountController.stream;

  final _newNotificationController = StreamController<NotificationItem>.broadcast();
  Stream<NotificationItem> get newNotificationStream => _newNotificationController.stream;

  GlobalKey<NavigatorState>? _navigatorKey;

  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  Future<void> initialize(String userId) async {
    if (_currentUserId == userId && _channel != null) {
      return; // Already subscribed for this user
    }

    // Unsubscribe previous channel without closing stream controllers
    await _unsubscribeChannel();
    _currentUserId = userId;

    // Load initial unread count
    final count = await _notificationRepository.getUnreadCount(userId);
    _unreadCountController.add(count);

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
      _newNotificationController.add(notification);

      // Update unread count
      _refreshUnreadCount();

      // Show in-app banner
      _showNotificationBanner(notification);
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'handleRealtimeNotification');
    }
  }

  Future<void> _refreshUnreadCount() async {
    if (_currentUserId == null) return;

    try {
      final count = await _notificationRepository.getUnreadCount(_currentUserId!);
      _unreadCountController.add(count);
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'refreshUnreadCount');
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

  /// Unsubscribes the realtime channel without closing stream controllers.
  Future<void> _unsubscribeChannel() async {
    await _channel?.unsubscribe();
    _channel = null;
    _currentUserId = null;
  }

  /// Disposes the realtime channel subscription.
  ///
  /// Stream controllers are kept alive since this is a singleton - they will
  /// be re-used on the next [initialize] call.
  Future<void> dispose() async {
    await _unsubscribeChannel();
  }
}
