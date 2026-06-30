// Plain Dart classes — no Freezed needed

class EventModel {
  final int id;
  final String name;
  final String description;
  final String category;
  final String date;
  final String time;
  final String posterUrl;
  final List<TicketTypeModel> ticketTypes;
  final bool isFavorited;
  final int viewCount;

  const EventModel({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.date,
    required this.time,
    required this.posterUrl,
    required this.ticketTypes,
    this.isFavorited = false,
    this.viewCount = 0,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id: json['id'] as int,
        name: json['name'] as String,
        description: json['description'] as String,
        category: json['category'] as String,
        date: json['date'] as String,
        time: json['time'] as String,
        posterUrl: json['poster_url'] as String,
        ticketTypes: (json['ticket_types'] as List<dynamic>? ?? [])
            .map((e) => TicketTypeModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        isFavorited: json['is_favorited'] as bool? ?? false,
        viewCount: json['view_count'] as int? ?? 0,
      );

  EventModel copyWith({bool? isFavorited}) => EventModel(
        id: id,
        name: name,
        description: description,
        category: category,
        date: date,
        time: time,
        posterUrl: posterUrl,
        ticketTypes: ticketTypes,
        isFavorited: isFavorited ?? this.isFavorited,
        viewCount: viewCount,
      );
}

class TicketTypeModel {
  final int id;
  final String name;
  final int price;
  final int availableStock;

  const TicketTypeModel({
    required this.id,
    required this.name,
    required this.price,
    required this.availableStock,
  });

  factory TicketTypeModel.fromJson(Map<String, dynamic> json) =>
      TicketTypeModel(
        id: json['id'] as int,
        name: json['name'] as String,
        price: json['price'] as int,
        availableStock: json['available_stock'] as int,
      );
}

class BannerModel {
  final int id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String ctaText;
  final String? eventId;

  const BannerModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    required this.ctaText,
    this.eventId,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
        id: json['id'] as int,
        title: json['title'] as String,
        subtitle: json['subtitle'] as String,
        imageUrl: json['image_url'] as String,
        ctaText: json['cta_text'] as String,
        eventId: json['event_id']?.toString(),
      );
}
