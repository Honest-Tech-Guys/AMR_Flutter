import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rms_tenant_app/features/auth/providers/auth_provider.dart';
import 'package:rms_tenant_app/shared/models/notification_model.dart';

final notificationProvider = FutureProvider<NotificationResponse>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  try {
    final response = await apiClient.get('/notifications');

    if (response.statusCode == 200 && response.data != null) {
      // Parse the full response using our new model
      return NotificationResponse.fromJson(response.data);
    } else {
      throw 'Failed to load notifications';
    }
  } catch (e) {
    throw 'Error fetching notifications: $e';
  }
});