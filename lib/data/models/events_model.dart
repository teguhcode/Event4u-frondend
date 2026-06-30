// Event Models

class EventModel {
  final int id;
  final String title;
  final String description;
  final String? image;
  final String eventDate;
  final String location;
  final double ticketPrice;
  final int quota;
  final String status;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    required this.eventDate,
    required this.location,
    required this.ticketPrice,
    required this.quota,
    required this.status,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json['id'] as int,
        title: json['title'] as String,
        description: json['description'] as String,
        image: json['image'] as String?,
        eventDate: json['event_date'] as String,
        location: json['location'] as String,
        ticketPrice: (json['ticket_price'] as num).toDouble(),
        quota: json['quota'] as int,
        status: json['status'] as String? ?? 'Published',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'image': image,
        'event_date': eventDate,
        'location': location,
        'ticket_price': ticketPrice,
        'quota': quota,
        'status': status,
      };
}

class EventsListResponse {
  final List<EventModel> events;
  final EventMeta meta;

  const EventsListResponse({
    required this.events,
    required this.meta,
  });

  factory EventsListResponse.fromJson(Map<String, dynamic> json) =>
      EventsListResponse(
        events: (json['data'] as List<dynamic>)
            .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        meta: EventMeta.fromJson(json['meta'] as Map<String, dynamic>),
      );
}

class EventMeta {
  final int currentPage;
  final int total;
  final int perPage;
  final int lastPage;

  const EventMeta({
    required this.currentPage,
    required this.total,
    required this.perPage,
    required this.lastPage,
  });

  factory EventMeta.fromJson(Map<String, dynamic> json) => EventMeta(
        currentPage: json['current_page'] as int,
        total: json['total'] as int,
        perPage: json['per_page'] as int,
        lastPage: json['last_page'] as int,
      );
}