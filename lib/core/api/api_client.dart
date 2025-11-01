import 'package:dio/dio.dart'; // <-- FIX 1
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rms_tenant_app/features/auth/providers/auth_provider.dart'; 

const String _apiBaseUrl = 'http://43.217.80.136:8015/api';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage _storage;
  final Ref _ref; // <-- FIX 2

  ApiClient(this.dio, this._storage, this._ref) {
    dio.options.baseUrl = _apiBaseUrl;
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // If we get 401 (Unauthenticated), log the user out.
            _ref.read(authControllerProvider.notifier).logout();
          }
          
          return handler.next(e);
        },
      ),
    );
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
}