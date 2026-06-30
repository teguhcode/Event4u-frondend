import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/app_config.dart';
import '../exceptions/api_exception.dart'; // Jalur import disesuaikan dengan folder Anda
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ApiClient {
  late Dio _dio;
  final FlutterSecureStorage _storage;

  ApiClient(this._storage) {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: Duration(seconds: int.parse(AppConfig.apiTimeout)),
        receiveTimeout: Duration(seconds: int.parse(AppConfig.apiTimeout)),
        responseType: ResponseType.json,
        contentType: 'application/json',
        headers: {
          // 💡 CRITICAL: Menghindari Ngrok Interstitial Page yang merusak format JSON
          'ngrok-skip-browser-warning': 'true',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.read(key: AppConfig.tokenKey);

    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  void _onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) {
    handler.next(response);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      // Token expired or invalid, clear storage
      await _storage.delete(key: AppConfig.tokenKey);
      await _storage.delete(key: AppConfig.userKey);
    }

    // 💡 MENGUBAH DIO ERROR MENJADI CUSTOM API EXCEPTION ANDA
    final exception = _handleDioError(err);
    
    // Kirimkan error yang sudah dipetakan agar ditangkap di blok try-catch service
    handler.next(DioException(
      requestOptions: err.requestOptions,
      response: err.response,
      type: err.type,
      error: exception,
    ));
  }

  /// Helper untuk memetakan DioException ke kelas ApiException kustom Anda
  ApiException _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.connectionError) {
      return NetworkException(message: 'Koneksi ke server terputus. Silakan coba lagi.');
    }

    final response = error.response;
    if (response != null) {
      final statusCode = response.statusCode;
      final data = response.data;
      String? serverMessage;

      // Mengekstrak pesan error standar dari Laravel jika ada
      if (data is Map && data.containsKey('message')) {
        serverMessage = data['message'];
      }

      switch (statusCode) {
        case 401:
          return UnauthorizedException(message: serverMessage ?? 'Sesi Anda telah berakhir. Silakan login kembali.');
        case 404:
          return NotFoundException(message: serverMessage ?? 'Data tidak ditemukan di server.');
        case 422:
          // Khusus Laravel Validation Error (mengembalikan objek list error form)
          Map<String, dynamic>? validationErrors;
          if (data is Map && data.containsKey('errors')) {
            validationErrors = Map<String, dynamic>.from(data['errors']);
          }
          return ValidationException(
            message: serverMessage ?? 'Data yang Anda masukkan tidak valid.',
            errors: validationErrors,
          );
        case 500:
          return ServerException(message: 'Terjadi gangguan internal pada server backend.');
        default:
          return ApiException(
            message: serverMessage ?? 'Terjadi kesalahan tidak dikenal.',
            statusCode: statusCode,
          );
      }
    }

    return ApiException(message: 'Terjadi kesalahan sistem: ${error.message}');
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  void dispose() {
    _dio.close();
  }
}

// Provider untuk Secure Storage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

// Provider untuk ApiClient
final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storage);
});