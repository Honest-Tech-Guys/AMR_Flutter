import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rms_tenant_app/features/auth/providers/auth_provider.dart';
import 'package:rms_tenant_app/shared/models/tenancy_model.dart';

// --- 1. DEFINE YOUR CUSTOM EXCEPTION ---
// This is the custom exception class we created.
// The UI (HomeScreen) will look for this specific error type.
class NoActiveTenancyException implements Exception {
  final String message = "No active tenancy found.";

  @override
  String toString() => message;
}

// --- 2. UPDATED PROVIDER ---
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
    // Check if the 'data' key is null (your 401 response)
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
      // --- 3. THROW CUSTOM EXCEPTION ---
      // This handles the case where the API returns 200 OK
      // but the 'data' object is empty.
      throw NoActiveTenancyException();
    }
  } on DioException catch (e) {
    // Keep your original 401 check
    if (e.response?.statusCode == 401) {
      throw 'Authentication failed. Redirecting...';
    }

    // --- 4. ADDED: CATCH THE 404 NOT FOUND ---
    // This handles the exact error message you specified.
    if (e.response?.statusCode == 404 &&
        e.response?.data?['message'] == "No active tenancy found.") {
      throw NoActiveTenancyException();
    }
    // ----------------------------------------

    // For all other API errors, throw a cleaner message
    throw e.response?.data?['message'] ?? e.message ?? 'Error fetching tenancy';
  } catch (e) {
    // Handle any other exceptions (like our custom one)
    rethrow;
  }
});