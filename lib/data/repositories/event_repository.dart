import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../datasources/event_remote_datasource.dart';
import '../models/event_model.dart';

final eventRepositoryProvider = Provider<EventRepository>((ref) {
  return EventRepository(EventRemoteDatasource(ref.read(dioProvider)));
});

class EventRepository {
  final EventRemoteDatasource _ds;
  EventRepository(this._ds);

  Future<List<EventModel>> getEvents({String? search}) =>
      _ds.getEvents(search: search);

  Future<EventModel> getEventDetail(int id) => _ds.getEventDetail(id);
}
