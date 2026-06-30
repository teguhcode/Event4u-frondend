import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  factory ApiException.fromDio(DioException e) {
    final data     = e.response?.data;
    final code     = e.response?.statusCode;
    String msg     = 'Terjadi kesalahan. Coba lagi.';

    // Parse Laravel error response
    if (data is Map) {
      if (data['errors'] is Map) {
        // Validation errors: {"errors": {"email": ["..."]}}
        final errs = data['errors'] as Map;
        msg = errs.values
            .expand((v) => v is List ? v : [v.toString()])
            .join('\n');
      } else if (data['message'] is String && (data['message'] as String).isNotEmpty) {
        msg = data['message'];
      }
    } else if (data is String && data.isNotEmpty) {
      msg = data;
    }

    // Specific status codes
    switch (code) {
      case 401:
        msg = 'Email atau password salah.';
        break;
      case 404:
        // Tampilkan URL yang tidak ditemukan untuk debugging
        msg = 'Endpoint tidak ditemukan: ${e.requestOptions.path}\n'
            'Pastikan routes/api.php sesuai dengan ApiConstants.';
        break;
      case 422:
        // Validation error sudah di-parse di atas
        break;
      case 500:
        msg = 'Server error. Periksa log Laravel.';
        break;
    }

    // Network errors
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        msg = 'Koneksi timeout. Periksa internet atau ngrok.';
        break;
      case DioExceptionType.connectionError:
        msg = 'Tidak dapat terhubung ke server.\n'
            'Pastikan:\n'
            '• Laravel sudah berjalan (php artisan serve)\n'
            '• URL di api_constants.dart sudah benar\n'
            '• Emulator: gunakan http://10.0.2.2:8000';
        break;
      default:
        break;
    }

    return ApiException(msg, statusCode: code);
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
