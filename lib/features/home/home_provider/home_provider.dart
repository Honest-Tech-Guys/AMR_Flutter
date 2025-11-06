import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rms_tenant_app/features/auth/providers/auth_provider.dart';
import 'package:rms_tenant_app/shared/models/tenancy_model.dart';

// --- UPDATED PROVIDER: Returns null when no tenancy found ---
final homeTenancyProvider = FutureProvider.autoDispose<Tenancy?>((ref) async {
  final apiClient = ref.watch(apiClientProvider);

  // Check auth state
  final authState = ref.watch(authControllerProvider);
  if (authState.asData?.value == AuthStatus.signedOut) {
    throw 'User is not authenticated.';
  }

  try {
    final response = await apiClient.get('/tenancy');

    // Check if the 'data' key is null (no active tenancy)
    if (response.data['data'] == null) {
      // Return null instead of throwing an error
      return null;
    }

    // If data exists, parse and return the Tenancy
    final Map<String, dynamic> tenancyData = response.data['data'];
    if (tenancyData.isNotEmpty) {
      return Tenancy.fromJson(tenancyData);
    } else {
      // Empty data object, return null
      return null;
    }
  } on DioException catch (e) {
    // Handle 401 errors
    if (e.response?.statusCode == 401) {
      throw 'Authentication failed. Redirecting...';
    }

    // For all other API errors, throw a cleaner message
    throw e.response?.data?['message'] ?? e.message ?? 'Error fetching tenancy';
  } catch (e) {
    // Handle any other exceptions
    rethrow;
  }
});