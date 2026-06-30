import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/api_exception.dart';
import '../../data/models/event_model.dart';
import '../../data/repositories/event_repository.dart';

// ── State ──────────────────────────────────────────────────────────────────
class EventListState {
  final List<EventModel> events;
  final bool isLoading;
  final String? error;

  const EventListState({
    this.events    = const [],
    this.isLoading = false,
    this.error,
  });

  EventListState copyWith({
    List<EventModel>? events,
    bool?             isLoading,
    String?           error,
    bool              clearError = false,
  }) => EventListState(
    events:    events    ?? this.events,
    isLoading: isLoading ?? this.isLoading,
    error:     clearError ? null : (error ?? this.error),
  );
}

// ── Event List Notifier ────────────────────────────────────────────────────
class EventListNotifier extends StateNotifier<EventListState> {
  final EventRepository _repo;
  EventListNotifier(this._repo) : super(const EventListState()) {
    fetchEvents();
  }

  Future<void> fetchEvents({String? search}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final list = await _repo.getEvents(search: search);
      state = state.copyWith(events: list, isLoading: false);
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Gagal memuat event: ${e.toString()}');
    }
  }

  Future<void> refresh() => fetchEvents();
}

final eventListProvider =
    StateNotifierProvider<EventListNotifier, EventListState>((ref) {
  return EventListNotifier(ref.read(eventRepositoryProvider));
});

// ── Single Event Detail ────────────────────────────────────────────────────
final eventDetailProvider =
    FutureProvider.family<EventModel, int>((ref, id) async {
  return ref.read(eventRepositoryProvider).getEventDetail(id);
});
