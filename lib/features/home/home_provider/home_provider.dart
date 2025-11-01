import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rms_tenant_app/features/auth/providers/auth_provider.dart';
import 'package:rms_tenant_app/shared/models/tenancy_model.dart';

// Use autoDispose to prevent caching stale data
final homeTenancyProvider = FutureProvider.autoDispose<Tenancy>((ref) async {
  final apiClient = ref.watch(apiClientProvider);
  
  // Listen to auth state changes - if signed out, throw immediately
  final authState = ref.watch(authControllerProvider);
  
  // If user is not signed in, throw an error immediately
  if (authState.value == AuthStatus.signedOut) {
    throw 'User is not authenticated. Please login again.';
  }

  try {
    final response = await apiClient.get('/tenancy');

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
  } on DioException catch (e) {
    // Handle 401 specifically - don't retry, throw immediately
    if (e.response?.statusCode == 401) {
      // The ApiClient interceptor will handle logout automatically
      throw 'Authentication failed. Redirecting to login...';
    }
    
    // Handle other errors
    final errorMsg = e.response?.data?['message'] ?? e.message ?? 'Unknown error';
    throw 'Error fetching tenancy: $errorMsg';
  } catch (e) {
    throw 'Error fetching tenancy: $e';
  }
});