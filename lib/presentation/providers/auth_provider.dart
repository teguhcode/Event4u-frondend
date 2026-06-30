import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/auth_repository.dart';

// ── Auth State ─────────────────────────────────────────────────────────────
class AuthState {
  final bool isLoggedIn;
  final bool isLoading;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.isLoggedIn = false,
    this.isLoading  = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool?      isLoggedIn,
    bool?      isLoading,
    UserModel? user,
    String?    error,
    bool       clearError = false,
  }) => AuthState(
    isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    isLoading:  isLoading  ?? this.isLoading,
    user:       user       ?? this.user,
    error:      clearError ? null : (error ?? this.error),
  );
}

// ── Auth Notifier ──────────────────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  AuthNotifier(this._repo) : super(const AuthState()) {
    _restoreSession();
  }

  /// Cek token tersimpan — restore sesi tanpa login ulang
  Future<void> _restoreSession() async {
    final token = await TokenStorage.get();
    if (token == null) return;
    try {
      final user = await _repo.profile();
      state = state.copyWith(isLoggedIn: true, user: user);
    } catch (_) {
      await TokenStorage.clear();
    }
  }

  /// Login — email saja (sesuai users table: unique email)
  /// Jika input mengandung @  → kirim sebagai email
  /// Jika tidak → cari user by name (fallback, backend perlu support ini)
  Future<bool> login(String emailOrName, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Seeder pakai email, tapi kita terima input fleksibel
      // Jika tidak ada @, tambahkan domain default sebagai hint
      // Backend AuthController harus handle email saja
      final email = emailOrName.contains('@')
          ? emailOrName.trim()
          : emailOrName.trim(); // kirim apa adanya, backend validasi

      final auth = await _repo.login(email: email, password: password);
      state = state.copyWith(
        isLoggedIn: true,
        isLoading:  false,
        user:       auth.user,
        clearError: true,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Terjadi kesalahan: ${e.toString()}');
      return false;
    }
  }

  /// Register — name, email, password
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final auth = await _repo.register(
          name: name, email: email, password: password);
      state = state.copyWith(
        isLoggedIn: true,
        isLoading:  false,
        user:       auth.user,
        clearError: true,
      );
      return true;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Terjadi kesalahan: ${e.toString()}');
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _repo.logout();
    } catch (_) {}
    state = const AuthState();
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final authProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});
