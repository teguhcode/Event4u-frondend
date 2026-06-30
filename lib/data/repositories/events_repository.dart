import 'package:dio/dio.dart';
import '../../core/exceptions/api_exception.dart';
import '../../core/services/api_client.dart';
import '../models/events_model.dart';

class EventsRepository {
  final ApiClient _apiClient;

  EventsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  Future<EventsListResponse> getEvents({
    int page = 1,
    int perPage = 10,
    String? search,
    String status = 'Published',
  }) async {
    try {
      final response = await _apiClient.get(
        '/events',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (search != null) 'search': search,
          'status': status,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] != true) {
          throw ApiException(
            message: data['message'] ?? 'Failed to fetch events',
            statusCode: response.statusCode,
          );
        }

        return EventsListResponse.fromJson(data);
      }

      throw ApiException(
        message: 'Failed to fetch events',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<EventModel> getEventDetail(int eventId) async {
    try {
      final response = await _apiClient.get('/events/$eventId');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] != true) {
          throw ApiException(
            message: data['message'] ?? 'Failed to fetch event detail',
            statusCode: response.statusCode,
          );
        }

        return EventModel.fromJson(data['data'] as Map<String, dynamic>);
      }

      throw ApiException(
        message: 'Failed to fetch event detail',
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  ApiException _handleDioException(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return NetworkException(message: 'Connection timeout');
    }

    if (e.response?.statusCode == 401) {
      return UnauthorizedException(
        message: e.response?.data['message'] ?? 'Unauthorized',
      );
    }

    if (e.response?.statusCode == 404) {
      return NotFoundException(
        message: e.response?.data['message'] ?? 'Event not found',
      );
    }

    if (e.response?.statusCode == 500) {
      return ServerException(
        message: e.response?.data['message'] ?? 'Server error',
      );
    }

    return NetworkException(
      message: e.message ?? 'Unknown error occurred',
    );
  }
}
