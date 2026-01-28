import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:garage_crew/l10n/app_localizations.dart';

import 'public_garage_search_screen.dart';
import 'repositories/notification_repository.dart';
import 'services/error_logger.dart';
import 'widgets/return_to_garage_button.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _repository = NotificationRepository();
  final List<NotificationItem> _notifications = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'No user';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await _repository.getNotifications(user.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _notifications
          ..clear()
          ..addAll(items);
      });
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'loadNotifications');
      if (!mounted) {
        return;
      }
      setState(() {
        _errorMessage = 'Failed to load notifications';
      });
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _markAllAsRead() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return;
    }

    try {
      await _repository.markAllAsRead(user.id);
      if (!mounted) {
        return;
      }
      setState(() {
        for (var i = 0; i < _notifications.length; i++) {
          _notifications[i] = _notifications[i].copyWith(isRead: true);
        }
      });
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'markAllAsRead');
      // Silently ignore (don't show to user)
    }
  }

  Future<void> _markAsRead(NotificationItem notification) async {
    if (notification.isRead) {
      return;
    }

    try {
      await _repository.markAsRead(notification.id);
      if (!mounted) {
        return;
      }
      setState(() {
        final index = _notifications.indexWhere((n) => n.id == notification.id);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
        }
      });
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'markAsRead');
      // Silently ignore (don't show to user)
    }
  }

  Future<void> _deleteNotification(NotificationItem notification) async {
    try {
      await _repository.deleteNotification(notification.id);
      if (!mounted) {
        return;
      }
      setState(() {
        _notifications.removeWhere((n) => n.id == notification.id);
      });
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'deleteNotification');
      // Silently ignore (don't show to user)
    }
  }

  Future<void> _clearAllNotifications() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.notificationsClearConfirmTitle),
        content: Text(l10n.notificationsClearConfirmContent),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await _repository.deleteAllNotifications(user.id);
      if (!mounted) return;
      setState(() {
        _notifications.clear();
      });
    } catch (error, stackTrace) {
      ErrorLogger.log(error, stackTrace: stackTrace, context: 'clearAllNotifications');
      // Silently ignore (don't show to user)
    }
  }

  void _openGarage(NotificationItem notification) {
    final garageUserId = notification.data['garage_user_id'] as String?;
    final garageLogin = notification.data['garage_login'] as String?;

    if (garageUserId == null || garageLogin == null) {
      return;
    }

    _markAsRead(notification);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PublicGarageDetailScreen(
          userId: garageUserId,
          login: garageLogin,
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime, AppLocalizations l10n) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return l10n.justNow;
    } else if (difference.inHours < 1) {
      return l10n.minutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return l10n.hoursAgo(difference.inHours);
    } else {
      return l10n.daysAgo(difference.inDays);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    final hasUnread = _notifications.any((n) => !n.isRead);

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFF6A00), // Hot Wheels Orange
                Color(0xFFFF8533), // Lighter Orange
              ],
            ),
          ),
        ),
        title: Text(l10n.notificationsTitle),
        actions: [
          const ReturnToGarageButton(),
          if (hasUnread)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(l10n.notificationsMarkAllRead),
            ),
          if (_notifications.isNotEmpty)
            IconButton(
              tooltip: l10n.notificationsClearAll,
              onPressed: _clearAllNotifications,
              icon: const Icon(Icons.delete_sweep),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: colorScheme.error),
                  ),
                )
              : _notifications.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.notifications_none,
                            size: 64,
                            color: colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.notificationsEmpty,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadNotifications,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemCount: _notifications.length,
                        itemBuilder: (context, index) {
                          final notification = _notifications[index];
                          return _NotificationTile(
                            notification: notification,
                            timeAgo: _formatTimeAgo(notification.createdAt, l10n),
                            onTap: () => _openGarage(notification),
                            onDismissed: () => _deleteNotification(notification),
                          );
                        },
                      ),
                    ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.timeAgo,
    required this.onTap,
    required this.onDismissed,
  });

  final NotificationItem notification;
  final String timeAgo;
  final VoidCallback onTap;
  final VoidCallback onDismissed;

  IconData _getIcon() {
    switch (notification.type) {
      case 'new_car':
        return Icons.directions_car;
      case 'new_follower':
        return Icons.person_add;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismissed(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: colorScheme.error,
        child: Icon(
          Icons.delete,
          color: colorScheme.onError,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        color: notification.isRead
            ? null
            : colorScheme.primaryContainer.withValues(alpha: 0.3),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: notification.isRead
                ? colorScheme.surfaceContainerHighest
                : colorScheme.primary,
            child: Icon(
              _getIcon(),
              color: notification.isRead
                  ? colorScheme.onSurfaceVariant
                  : colorScheme.onPrimary,
              size: 20,
            ),
          ),
          title: Text(
            notification.title,
            style: TextStyle(
              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.w600,
            ),
          ),
          subtitle: notification.body != null
              ? Text(
                  notification.body!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                )
              : null,
          trailing: Text(
            timeAgo,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          onTap: onTap,
        ),
      ),
    );
  }
}
