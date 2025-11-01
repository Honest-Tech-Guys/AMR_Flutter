import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rms_tenant_app/features/auth/providers/auth_provider.dart';

const String _apiBaseUrl = 'http://43.217.80.136:8015/api';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage _storage;
  final Ref _ref;

  // Track consecutive 401 errors to prevent infinite loops
  int _consecutive401Count = 0;
  static const int _max401BeforeLogout = 1; // Changed from 3 to 1 for immediate logout
  
  // Track if we're currently logging out to prevent multiple logout calls
  bool _isLoggingOut = false;

  ApiClient(this.dio, this._storage, this._ref) {
    dio.options.baseUrl = _apiBaseUrl;
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);

    // Request interceptor - Add token to all requests
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        
        onResponse: (response, handler) {
          // Reset the 401 counter on successful response
          _consecutive401Count = 0;
          return handler.next(response);
        },
        
        onError: (DioException e, handler) async {
          // Handle 401 Unauthorized errors
          if (e.response?.statusCode == 401) {
            _consecutive401Count++;
            
            print('401 Error detected. Count: $_consecutive401Count');
            
            // Immediately logout on first 401 - no retries
            if (!_isLoggingOut) {
              _isLoggingOut = true;
              print('Token invalid/expired. Forcing immediate logout...');
              
              // Force logout immediately without retrying
              await _forceLogout();
            }
            
            // Reject the request immediately - don't allow retries
            return handler.reject(e);
          }
          
          return handler.next(e);
        },
      ),
    );
  }

  // Force logout without any API calls
  Future<void> _forceLogout() async {
    try {
      // Clear token directly
      await _storage.delete(key: 'auth_token');
      
      // Update auth state to trigger navigation
      await _ref.read(authControllerProvider.notifier).logout();
      
      print('Logout completed successfully');
    } catch (e) {
      print('Error in force logout: $e');
    } finally {
      _isLoggingOut = false;
      _consecutive401Count = 0;
    }
  }

  // Reset the 401 counter (useful after successful login)
  void reset401Counter() {
    _consecutive401Count = 0;
    _isLoggingOut = false;
  }

  // --- Helper Methods ---

  Future<Response> get(String path, {Map<String, dynamic>? queryParams}) async {
    try {
      return await dio.get(path, queryParameters: queryParams);
    } on DioException {
      rethrow;
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await dio.post(path, data: data);
    } on DioException {
      rethrow;
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await dio.put(path, data: data);
    } on DioException {
      rethrow;
    }
  }

  Future<Response> delete(String path, {dynamic data}) async {
    try {
      return await dio.delete(path, data: data);
    } on DioException {
      rethrow;
    }
  }
}