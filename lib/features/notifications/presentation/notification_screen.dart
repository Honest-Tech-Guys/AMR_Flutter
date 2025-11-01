import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rms_tenant_app/features/notifications/notification_provider.dart';
import 'package:rms_tenant_app/shared/models/notification_model.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // <-- Use this context
    final notificationAsyncValue = ref.watch(notificationProvider);
    const Color primaryColor = Color(0xFF076633);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body: notificationAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (response) {
          if (response.notifications.isEmpty) {
            return const Center(
              child: Text(
                'You have no notifications.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: response.notifications.length,
            itemBuilder: (ctx, index) { // <-- Use this context
              final notif = response.notifications[index];
              return _buildNotificationTile(ctx, notif, primaryColor);
            },
          );
        },
      ),
    );
  }

  // Helper widget for a single notification
  Widget _buildNotificationTile(BuildContext context, NotificationItem notif, Color primaryColor) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ListTile(
        leading: Icon(
          notif.isRead ? Icons.mark_email_read_outlined : Icons.mark_email_unread,
          color: notif.isRead ? Colors.grey : primaryColor,
          size: 30,
        ),
        title: Text(
          notif.message,
          style: TextStyle(
            fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
          ),
        ),
        subtitle: Text(_formatDateTime(context, notif.createdAt)), // <-- Pass context
        onTap: () {
          // TODO: Mark notification as read
        },
      ),
    );
  }

  // Helper to format the date
  String _formatDateTime(BuildContext context, String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      // Format to: 13/10/2025  10:38 PM
      final time = TimeOfDay.fromDateTime(date).format(context); // <-- Use context
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}  $time';
    } catch (e) {
      return dateStr;
    }
  }
}