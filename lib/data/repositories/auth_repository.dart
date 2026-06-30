import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/transaction_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(AuthRemoteDatasource(ref.read(dioProvider)));
});

class AuthRepository {
  final AuthRemoteDatasource _ds;
  AuthRepository(this._ds);

  Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
  }) => _ds.register(name: name, email: email, password: password);

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) => _ds.login(email: email, password: password);

  Future<void> logout() => _ds.logout();

  Future<UserModel> profile() => _ds.profile();
}
