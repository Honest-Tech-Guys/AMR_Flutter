import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rms_tenant_app/features/auth/providers/auth_provider.dart';
import 'package:rms_tenant_app/shared/models/invoice_model.dart';

final invoicesProvider = FutureProvider<List<Invoice>>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  try {
    final response = await apiClient.get('/invoices');

    // Your API response has the list nested under 'data'
    if (response.statusCode == 200 && response.data['data'] != null) {
      final List<dynamic> dataList = response.data['data'];
      
      // Map the JSON list to our Invoice model
      return dataList.map((json) => Invoice.fromJson(json)).toList();
    } else {
      throw 'Failed to load invoices';
    }
  } catch (e) {
    throw 'Error fetching invoices: $e';
  }
});