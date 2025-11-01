import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rms_tenant_app/core/api/api_client.dart';

// Enum to represent our auth state
enum AuthStatus { signedIn, signedOut, loading }

// --- 1. CORE PROVIDERS ---

// Provider for the secure storage with Android options
final _storageProvider = Provider((ref) => const FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ),
));

// Provider for the Dio instance
final _dioProvider = Provider((ref) => Dio());

// Provider for our ApiClient
final apiClientProvider = Provider(
  (ref) => ApiClient(
    ref.watch(_dioProvider),
    ref.watch(_storageProvider),
    ref,
  ),
);

// Provider for the AuthRepository
final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(_storageProvider),
  ),
);

// --- 2. AUTH REPOSITORY ---
// This class talks to the API and Storage

class AuthRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;
  final String _tokenKey = 'auth_token';

  AuthRepository(this._apiClient, this._storage);

  // Read token from storage with error handling
  Future<String?> _getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      // If there's a decryption error, delete the corrupted token
      print('Error reading token (corrupted data): $e');
      await _deleteToken();
      return null;
    }
  }

  // Save token to storage with error handling
  Future<void> _saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
      // If write fails, try to delete and write again
      print('Error saving token: $e');
      try {
        await _storage.delete(key: _tokenKey);
        await _storage.write(key: _tokenKey, value: token);
      } catch (retryError) {
        print('Retry save token failed: $retryError');
        rethrow;
      }
    }
  }

  // Delete token from storage
  Future<void> _deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      // If delete fails, try deleteAll
      print('Error deleting token: $e');
      try {
        await _storage.deleteAll();
      } catch (deleteAllError) {
        print('Delete all failed: $deleteAllError');
      }
    }
  }

  // Login function
  Future<void> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        final token = response.data['token'] as String;
        await _saveToken(token);
        
        // Reset 401 counter after successful login
        _apiClient.reset401Counter();
      } else {
        // This is a successful request but bad data
        throw 'Login successful, but no token was found.';
      }
    } on DioException catch (e) {
      // Handle API errors (like 401, 404, 500)
      if (e.response != null) {
        // Server responded with an error
        final errorMsg = e.response?.data['message'] ?? 'Server error';
        throw 'Error: $errorMsg';
      
      } else {
        // Handle network errors (no connection, timeout, etc.)
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
            throw 'Network Error: Connection timed out.';
          case DioExceptionType.sendTimeout:
            throw 'Network Error: Request timed out.';
          case DioExceptionType.receiveTimeout:
            throw 'Network Error: Response timed out.';
          case DioExceptionType.connectionError:
            throw 'Network Error: Connection failed. Check internet or permissions.';
          case DioExceptionType.unknown:
            throw 'Network Error: Unknown issue. Check internet or http permissions.';
          default:
            throw 'Login failed: ${e.message}';
        }
      }
    } catch (e) {
      // Catch any other errors
      rethrow;
    }
  }

  // Logout function
  Future<void> logout() async {
    // Delete the token locally
    await _deleteToken();
    
    // Reset 401 counter
    _apiClient.reset401Counter();
    
    // You could also call a '/logout' endpoint if your API has one
    // try {
    //   await _apiClient.post('/logout');
    // } catch (e) {
    //   // Ignore errors during logout
    // }
  }
}

// --- 3. AUTH CONTROLLER ---
// This is the StateNotifier that our UI will listen to.
// It manages the *current state* of authentication.

final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthStatus>(
  () => AuthController(),
);

// --- 4. REGISTRATION CONTROLLER ---
final registrationControllerProvider =
    AsyncNotifierProvider<RegistrationController, bool>(
  () => RegistrationController(),
);

class AuthController extends AsyncNotifier<AuthStatus> {
  late AuthRepository _authRepository;

  @override
  Future<AuthStatus> build() async {
    _authRepository = ref.watch(authRepositoryProvider);

    // Check if a token exists when the app starts
    final token = await _authRepository._getToken();
    
    if (token != null) {
      return AuthStatus.signedIn;
    }
    return AuthStatus.signedOut;
  }

  // Login method
  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authRepository.login(email, password);
      state = const AsyncValue.data(AuthStatus.signedIn);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  // Logout method
  Future<void> logout() async {
    state = const AsyncValue.loading();
    await _authRepository.logout();
    state = const AsyncValue.data(AuthStatus.signedOut);
  }
}

class RegistrationController extends AsyncNotifier<bool> {
  @override
  Future<bool> build() async {
    return false;
  }

  Future<void> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String role,
  }) async {
    state = const AsyncValue.loading();
    try {
      final apiClient = ref.watch(apiClientProvider);

      // This matches your Next.js 'useRegister' hook
      await apiClient.post(
        '/register',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'role': role,
        },
      );
      state = const AsyncValue.data(true);
      
    } on DioException catch (e) {
      // Try to return a helpful error message
      final errorMsg = e.response?.data?['message'] ?? 'Registration failed';
      state = AsyncValue.error(errorMsg, e.stackTrace ?? StackTrace.current);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}