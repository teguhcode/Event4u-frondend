import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_model.dart';
import '../providers/repository_providers.dart';
import '../repositories/auth_repository.dart';

// User state notifier
class AuthStateNotifier extends StateNotifier<UserModel?> {
  final AuthRepository _authRepository;

  AuthStateNotifier(this._authRepository) : super(null);

  Future<void> login(LoginRequest request) async {
    try {
      final response = await _authRepository.login(request);
      state = response.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> register(RegisterRequest request) async {
    try {
      final response = await _authRepository.register(request);
      state = response.user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadProfile() async {
    try {
      final user = await _authRepository.getProfile();
      state = user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      state = null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> checkAutoLogin() async {
    try {
      final token = await _authRepository.getStoredToken();
      if (token != null) {
        await loadProfile();
      }
    } catch (e) {
      state = null;
    }
  }

  Future<bool> hasToken() async {
    final token = await _authRepository.getStoredToken();
    return token != null;
  }
}

// Auth State Providers
final authStateProvider =
    StateNotifierProvider<AuthStateNotifier, UserModel?>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthStateNotifier(authRepository);
});

// Check if user is authenticated
final isAuthenticatedProvider = FutureProvider<bool>((ref) async {
  final authRepository = ref.watch(authRepositoryProvider);
  final token = await authRepository.getStoredToken();
  return token != null;
});
