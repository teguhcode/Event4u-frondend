import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../models/events_model.dart';
import '../providers/repository_providers.dart';

// Events list state provider
final eventsListProvider =
    FutureProvider.family<EventsListResponse, Map<String, dynamic>>(
        (ref, params) async {
  final eventsRepository = ref.watch(eventsRepositoryProvider);

  return eventsRepository.getEvents(
    page: params['page'] ?? 1,
    perPage: params['perPage'] ?? AppConfig.defaultPageSize,
    search: params['search'],
    status: params['status'] ?? 'Published',
  );
});

// Single event detail provider
final eventDetailProvider =
    FutureProvider.family<EventModel, int>((ref, eventId) async {
  final eventsRepository = ref.watch(eventsRepositoryProvider);
  return eventsRepository.getEventDetail(eventId);
});

// Cached events provider
final cachedEventsProvider = StateProvider<List<EventModel>>((ref) {
  return [];
});

// Search query provider
final eventSearchQueryProvider = StateProvider<String>((ref) {
  return '';
});

// Current event filter provider
final eventStatusFilterProvider = StateProvider<String>((ref) {
  return 'Published';
});

// Current page provider
final eventCurrentPageProvider = StateProvider<int>((ref) {
  return 1;
});
