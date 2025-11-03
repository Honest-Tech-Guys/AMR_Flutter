import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rms_tenant_app/features/auth/providers/auth_provider.dart';
import 'package:rms_tenant_app/shared/models/tenancy_model.dart';

final homeTenancyProvider = FutureProvider.autoDispose<Tenancy>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  
  // This line is from your old file and is a good optimization.
  final authState = ref.watch(authControllerProvider);
  if (authState.asData?.value == AuthStatus.signedOut) {
    throw 'User is not authenticated.';
  }

  try {
    final response = await apiClient.get('/tenancy');

    // --- THIS IS THE FIX ---
    // Check if the 'data' key is null (our fake 401 response)
    if (response.data['data'] == null) {
      // The user is being logged out. We stay in a "pending"
      // state to let the router redirect without a crash.
      return Completer<Tenancy>().future;
    }
    // ----------------------

    // If data is not null, proceed as normal
    final Map<String, dynamic> tenancyData = response.data['data'];
    if (tenancyData.isNotEmpty) {
      return Tenancy.fromJson(tenancyData);
    } else {
      throw 'No active tenancy found for this user.';
    }

  } on DioException catch (e) {
    if (e.response?.statusCode == 401) {
      throw 'Authentication failed. Redirecting...';
    }
    throw 'Error fetching tenancy: ${e.message}';
  } catch (e) {
    throw e.toString();
  }
});