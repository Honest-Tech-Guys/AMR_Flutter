import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rms_tenant_app/core/api/api_client.dart';

// 1. ADD NEW STATE
enum AuthStatus { signedIn, signedOut, loading, needsVerification }

// --- 1. CORE PROVIDERS ---

// Provider for the secure storage with your Android options
final _storageProvider = Provider((ref) => const FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ),
));

final _dioProvider = Provider((ref) => Dio());

final apiClientProvider = Provider(
  (ref) => ApiClient(
    ref.watch(_dioProvider),
    ref.watch(_storageProvider),
    ref,
  ),
);

final authRepositoryProvider = Provider(
  (ref) => AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(_storageProvider),
  ),
);

// --- 2. AUTH REPOSITORY (with verification logic) ---
class AuthRepository {
  final ApiClient _apiClient;
  final FlutterSecureStorage _storage;
  final String _tokenKey = 'auth_token';
  final String _verifiedKey = 'is_verified';
  final String _emailKey = 'unverified_email';

  AuthRepository(this._apiClient, this._storage);

  // --- Token helpers from your file ---
  Future<String?> _getToken() async {
    try {
      return await _storage.read(key: _tokenKey);
    } catch (e) {
      print('Error reading token (corrupted data): $e');
      await _deleteToken();
      return null;
    }
  }
  Future<void> _saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
    } catch (e) {
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
  Future<void> _deleteToken() async {
    try {
      await _storage.delete(key: _tokenKey);
    } catch (e) {
      print('Error deleting token: $e');
    }
  }

  // --- New email/verification helpers ---
  Future<void> saveUnverifiedEmail(String email) async {
    await _storage.write(key: _emailKey, value: email);
  }
  Future<String?> getUnverifiedEmail() async {
    return await _storage.read(key: _emailKey);
  }
  Future<void> _deleteUnverifiedEmail() async {
    await _storage.delete(key: _emailKey);
  }
  Future<void> _saveVerificationStatus(bool isVerified) async {
    await _storage.write(key: _verifiedKey, value: isVerified.toString());
  }
  Future<bool> isVerified() async {
    final status = await _storage.read(key: _verifiedKey);
    return status == 'true';
  }
  
  // --- Updated Login function ---
  Future<bool> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data['token'] != null) {
        final token = response.data['token'] as String;
        await _saveToken(token);
        
        final isVerified = response.data['user']?['email_verified_at'] != null;
        await _saveVerificationStatus(isVerified); 
        
        if (!isVerified) {
          await saveUnverifiedEmail(email); 
        } else {
          await _deleteUnverifiedEmail();
        }
        return isVerified;
      } else {
        throw 'Invalid response from server';
      }
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Login failed';
    } catch (e) {
      rethrow;
    }
  }

  // --- Updated Logout function ---
  Future<void> logout() async {
    await _deleteToken();
    await _deleteUnverifiedEmail();
    await _storage.delete(key: _verifiedKey);
  }
}

// --- 3. AUTH CONTROLLER (FIXED) ---
final authControllerProvider =
    AsyncNotifierProvider<AuthController, AuthStatus>(
  () => AuthController(),
);

// --- THIS IS THE COMPILER FIX ---
class AuthController extends AsyncNotifier<AuthStatus> {
  late AuthRepository _authRepository;

  @override
  Future<AuthStatus> build() async {
    _authRepository = ref.watch(authRepositoryProvider); 

    final token = await _authRepository._getToken();
    if (token == null) {
      return AuthStatus.signedOut;
    }

    final isVerified = await _authRepository.isVerified();
    if (isVerified) {
      return AuthStatus.signedIn;
    } else {
      return AuthStatus.needsVerification;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      final isVerified = await _authRepository.login(email, password);
      
      if (isVerified) {
        state = const AsyncValue.data(AuthStatus.signedIn);
      } else {
        state = const AsyncValue.data(AuthStatus.needsVerification);
      }
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  Future<void> logout() async {
    state = const AsyncValue.loading();
    await _authRepository.logout();
    state = const AsyncValue.data(AuthStatus.signedOut);
  }
}

// --- 4. RESEND EMAIL CONTROLLER ---
final resendEmailProvider = AsyncNotifierProvider<ResendEmailController, void>(
  () => ResendEmailController(),
);

class ResendEmailController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> resend() async {
    state = const AsyncValue.loading();
    try {
      final apiClient = ref.watch(apiClientProvider);
      await apiClient.post('/resend-verification-email'); 
      state = const AsyncValue.data(null);
    } on DioException catch (e, s) {
      state = AsyncValue.error(e.response?.data['message'] ?? 'Failed to resend', s);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}

// --- 5. REGISTRATION CONTROLLER ---
final registrationControllerProvider =
    AsyncNotifierProvider<RegistrationController, bool>(
  () => RegistrationController(),
);

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
    } on DioException catch (e, s) {
      final errorMsg = e.response?.data?['message'] ?? 'Registration failed';
      state = AsyncValue.error(errorMsg, s);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }
}