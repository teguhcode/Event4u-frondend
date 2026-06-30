// Sesuai migration: events table
// Fields: id, title, description, event_date, location,
//         ticket_price, quota, image, status, timestamps

class EventModel {
  final int id;
  final String title;
  final String description;
  final String eventDate;
  final String location;
  final double ticketPrice;
  final int quota;
  final String? image;
  final String status;
  final String? createdAt;

  const EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.location,
    required this.ticketPrice,
    required this.quota,
    this.image,
    this.status = 'Published',
    this.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => EventModel(
        id:          json['id'] as int,
        title:       json['title'] as String,
        description: json['description'] as String,
        eventDate:   json['event_date'] as String,
        location:    json['location'] as String,
        ticketPrice: double.tryParse(json['ticket_price'].toString()) ?? 0,
        quota:       int.tryParse(json['quota'].toString()) ?? 0,
        image:       json['image'] as String?,
        status:      json['status'] as String? ?? 'Published',
        createdAt:   json['created_at'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id':           id,
        'title':        title,
        'description':  description,
        'event_date':   eventDate,
        'location':     location,
        'ticket_price': ticketPrice,
        'quota':        quota,
        'image':        image,
        'status':       status,
      };

  /// Build full image URL dari baseUrl Laravel
  /// image field dari DB: "events/xxxxx.jpg"
  /// URL final: "https://xxx.ngrok.app/storage/events/xxxxx.jpg"
  String? fullImageUrl(String baseUrl) {
    if (image == null || image!.isEmpty) return null;
    // Jika image sudah berisi full URL, langsung return
    if (image!.startsWith('http')) return image;
    // Strip leading slash jika ada
    final cleanImage = image!.startsWith('/') ? image!.substring(1) : image!;
    // Strip "storage/" prefix jika sudah ada di path
    final cleanPath = cleanImage.startsWith('storage/')
        ? cleanImage.substring(8)
        : cleanImage;
    return '$baseUrl/storage/$cleanPath';
  }

  String get formattedPrice {
    if (ticketPrice == 0) return 'Gratis';
    final s = ticketPrice.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp$s';
  }

  String get formattedDate {
    try {
      final dt = DateTime.parse(eventDate);
      const months = [
        'Jan','Feb','Mar','Apr','Mei','Jun',
        'Jul','Agt','Sep','Okt','Nov','Des'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return eventDate;
    }
  }

  String get formattedTime {
    try {
      final dt = DateTime.parse(eventDate);
      return '${dt.hour.toString().padLeft(2,'0')}:'
             '${dt.minute.toString().padLeft(2,'0')} WIB';
    } catch (_) {
      return '';
    }
  }
}
