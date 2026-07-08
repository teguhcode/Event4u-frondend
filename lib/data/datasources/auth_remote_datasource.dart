import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../models/transaction_model.dart';

class AuthRemoteDatasource {
  final Dio _dio;
  AuthRemoteDatasource(this._dio);

  /// POST /api/auth/register
  /// Body: { name, email, password, password_confirmation }
  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        ApiConstants.register,
        data: {
          'name':                  name,
          'email':                 email,
          'password':              password,
          'password_confirmation': password,
        },
      );
      final auth = AuthResponse.fromJson(res.data as Map<String, dynamic>);
      await TokenStorage.save(auth.token);
      return auth;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /api/auth/login
  /// Body: { email, password }
  /// Note: login by email only — sesuai users table (unique: email)
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        ApiConstants.login,
        data: {'email': email, 'password': password},
      );
      final auth = AuthResponse.fromJson(res.data as Map<String, dynamic>);
      // Simpan token ke secure storage
      await TokenStorage.save(auth.token);
      return auth;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /api/auth/logout  (requires Bearer token)
  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } finally {
      await TokenStorage.clear();
    }
  }

  /// GET /api/auth/profile  (requires Bearer token)
  Future<UserModel> profile() async {
    try {
      final res = await _dio.get(ApiConstants.profile);
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
