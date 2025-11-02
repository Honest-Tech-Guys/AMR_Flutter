import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rms_tenant_app/features/auth/providers/auth_provider.dart';
import 'package:rms_tenant_app/shared/models/smart_devices_model.dart';

final smartDevicesProvider = FutureProvider<SmartDeviceResponse>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  try {
    final response = await apiClient.get('/devices');

    // The entire response is what we parse
    if (response.statusCode == 200 && response.data != null) {
      return SmartDeviceResponse.fromJson(response.data);
    } else {
      throw 'Failed to load smart devices';
    }
  } catch (e) {
    throw 'Error fetching smart devices: $e';
  }
});