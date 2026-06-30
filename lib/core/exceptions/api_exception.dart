/// API Exception
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalException;

  ApiException({
    required this.message,
    this.statusCode,
    this.originalException,
  });

  @override
  String toString() {
    if (statusCode != null) {
      return 'ApiException ($statusCode): $message';
    }
    return 'ApiException: $message';
  }
}

/// Specific exception types
class UnauthorizedException extends ApiException {
  UnauthorizedException({String? message})
      : super(
          message: message ?? 'Unauthorized',
          statusCode: 401,
        );
}

class NotFoundException extends ApiException {
  NotFoundException({String? message})
      : super(
          message: message ?? 'Resource not found',
          statusCode: 404,
        );
}

class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException({
    String? message,
    this.errors,
  }) : super(
          message: message ?? 'Validation failed',
          statusCode: 422,
        );
}

class ServerException extends ApiException {
  ServerException({String? message})
      : super(
          message: message ?? 'Server error',
          statusCode: 500,
        );
}

class NetworkException extends ApiException {
  NetworkException({String? message})
      : super(
          message: message ?? 'Network error',
        );
}
