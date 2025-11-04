// Create this file: lib/features/smart_home/smart_lock_api_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rms_tenant_app/features/auth/providers/auth_provider.dart';

class AddLockRequest {
  final int unitId;
  final String name;
  final String serialNumber;
  final String lockData;

  AddLockRequest({
    required this.unitId,
    required this.name,
    required this.serialNumber,
    required this.lockData,
  });

  Map<String, dynamic> toJson() {
    return {
      'unit_id': unitId,
      'name': name,
      'serial_number': serialNumber,
      'lock_data': lockData,
    };
  }
}

final addLockProvider = FutureProvider.autoDispose.family<void, AddLockRequest>(
  (ref, request) async {
    final apiClient = ref.watch(apiClientProvider);
    
    try {
      await apiClient.post(
        '/locks',
        data: request.toJson(),
      );
    } catch (e) {
      throw 'Failed to add smart lock: $e';
    }
  },
);

// Provider to get unit_id from current tenancy
// NOTE: If you already have a homeTenancyProvider elsewhere, remove this placeholder and import it instead.
final homeTenancyProvider = Provider<AsyncValue<dynamic>>((ref) {
  // Placeholder provider to satisfy references; replace with real provider that returns tenancy AsyncValue.
  return const AsyncValue.data(null);
});

final currentUnitIdProvider = Provider<int?>((ref) {
  final tenancyAsync = ref.watch(homeTenancyProvider);
  
  return tenancyAsync.when(
    data: (tenancy) {
      // Extract unit_id from tenancy
      // You'll need to add this field to your Tenancy model
      // For now, returning a placeholder
      return 6; // Replace with actual unit_id from tenancy
    },
    loading: () => null,
    error: (_, __) => null,
  );
});