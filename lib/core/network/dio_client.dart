import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.apiUrl,
      connectTimeout: ApiConstants.connectTimeout,
      receiveTimeout: ApiConstants.receiveTimeout,
      sendTimeout:    ApiConstants.sendTimeout,
      headers: {
        'Accept':                    'application/json',
        'Content-Type':              'application/json',
        'ngrok-skip-browser-warning': 'true',
      },
    ),
  );

  dio.interceptors.addAll([
    _AuthInterceptor(),
    _DebugInterceptor(),
  ]);

  // Print base URL saat init — membantu debug
  // ignore: avoid_print
  print('🌐 API baseUrl: ${ApiConstants.apiUrl}');

  return dio;
});

class _AuthInterceptor extends Interceptor {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'sanctum_token';

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      _storage.delete(key: _tokenKey);
    }
    handler.next(err);
  }

  static Future<void> saveToken(String token) =>
      _storage.write(key: _tokenKey, value: token);
  static Future<void> clearToken() =>
      _storage.delete(key: _tokenKey);
  static Future<String?> getToken() =>
      _storage.read(key: _tokenKey);
}

class _DebugInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ignore: avoid_print
    print('→ ${options.method} ${options.uri}');
    if (options.data != null) {
      // ignore: avoid_print
      print('  body: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // ignore: avoid_print
    print('← ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // ignore: avoid_print
    print('✗ [${err.response?.statusCode}] ${err.requestOptions.uri}');
    // ignore: avoid_print
    print('  response: ${err.response?.data}');
    handler.next(err);
  }
}

class TokenStorage {
  static Future<void> save(String token)  => _AuthInterceptor.saveToken(token);
  static Future<void> clear()             => _AuthInterceptor.clearToken();
  static Future<String?> get()            => _AuthInterceptor.getToken();
}
