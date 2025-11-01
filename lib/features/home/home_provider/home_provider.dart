import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rms_tenant_app/features/auth/providers/auth_provider.dart';
import 'package:rms_tenant_app/shared/models/tenancy_model.dart';

final homeTenancyProvider = FutureProvider<Tenancy>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  try {
    final response = await apiClient.get('/tenancy');

    // --- THIS IS THE FIX ---
    // The API returns an object under 'data', not a list.
    if (response.statusCode == 200 && response.data['data'] != null) {
      
      final Map<String, dynamic> tenancyData = response.data['data'];
      
      if (tenancyData.isNotEmpty) {
        // Convert the JSON object to our Tenancy model
        return Tenancy.fromJson(tenancyData);
      } else {
        throw 'No active tenancy found for this user.';
      }
    } else {
      throw 'Failed to load tenancy data';
    }
  } catch (e) {
    throw 'Error fetching tenancy: $e';
  }
});