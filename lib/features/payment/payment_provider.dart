import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rms_tenant_app/features/auth/providers/auth_provider.dart';

// This provider will handle the payment API call
final paymentProvider =
    AsyncNotifierProvider<PaymentController, String?>(
  () => PaymentController(),
);

class PaymentController extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async {
    return null; // Initial state is null
  }

  // This is the function we'll call from our UI
  Future<String?> generatePaymentLink({
    required String payableType,
    required int payableId,
    double? amount,
  }) async {
    state = const AsyncValue.loading();
    try {
      final apiClient = ref.watch(apiClientProvider);
      
      // Build the request body
      final Map<String, dynamic> requestData = {
        'payable_type': payableType,
        'payable_id': payableId,
      };
      
      // Add amount only if it's provided (for meter top-up)
      if (amount != null) {
        requestData['amount'] = amount;
      }

      final response = await apiClient.post(
        '/payment-links/generate',
        data: requestData,
      );

      // Parse the 'payment_url' from the response
      if (response.statusCode == 200 && response.data['payment_url'] != null) {
        final String url = response.data['payment_url'];
        state = AsyncValue.data(url);
        return url;
      } else {
        throw 'Failed to get payment link from response';
      }
    } on DioException catch (e, s) {
      final errorMsg = e.response?.data?['message'] ?? 'Payment failed';
      state = AsyncValue.error(errorMsg, s);
      return null;
    } catch (e, s) {
      state = AsyncValue.error(e.toString(), s);
      return null;
    }
  }
}