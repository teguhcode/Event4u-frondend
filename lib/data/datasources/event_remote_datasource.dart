import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/api_exception.dart';
import '../models/event_model.dart';

class EventRemoteDatasource {
  final Dio _dio;
  EventRemoteDatasource(this._dio);

  /// GET /api/events?search=xxx
  Future<List<EventModel>> getEvents({String? search}) async {
    try {
      final res = await _dio.get(
        ApiConstants.events,
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );
      // Laravel resource collection: { data: [...] } atau langsung [...]
      final raw = res.data;
      List<dynamic> list;
      if (raw is Map && raw['data'] is List) {
        list = raw['data'] as List;
      } else if (raw is List) {
        list = raw;
      } else {
        list = [];
      }
      return list
          .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /api/events/{id}
  Future<EventModel> getEventDetail(int id) async {
    try {
      final res = await _dio.get(ApiConstants.eventDetail(id));
      final raw = res.data;
      // Bisa dalam { data: {...} } atau langsung {...}
      final json = raw is Map && raw['data'] is Map
          ? raw['data'] as Map<String, dynamic>
          : raw as Map<String, dynamic>;
      return EventModel.fromJson(json);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
