// Sesuai migration: transactions table + Midtrans fields

enum TransactionStatus { pending, paid, cancelled }

class TransactionModel {
  final int id;
  final int userId;
  final int eventId;
  final int? promoId;
  final int quantity;
  final double subtotal;
  final double discount;
  final double total;
  final TransactionStatus status;
  final String paymentMethod;
  final String? paidAt;
  final String? paymentProof;
  final String createdAt;
  final EventSummary? event;

  // ── Midtrans fields ────────────────────────────────────────────────────
  final String? midtransOrderId;
  final String? snapToken;
  final String? redirectUrl;

  const TransactionModel({
    required this.id,
    required this.userId,
    required this.eventId,
    this.promoId,
    required this.quantity,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.status,
    required this.paymentMethod,
    this.paidAt,
    this.paymentProof,
    required this.createdAt,
    this.event,
    this.midtransOrderId,
    this.snapToken,
    this.redirectUrl,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'pending';
    final status = TransactionStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => TransactionStatus.pending,
    );
    return TransactionModel(
      id:              json['id'] as int,
      userId:          json['user_id'] as int,
      eventId:         json['event_id'] as int,
      promoId:         json['promo_id'] as int?,
      quantity:        json['quantity'] as int,
      subtotal:        double.tryParse(json['subtotal'].toString()) ?? 0,
      discount:        double.tryParse(json['discount'].toString()) ?? 0,
      total:           double.tryParse(json['total'].toString()) ?? 0,
      status:          status,
      paymentMethod:   json['payment_method'] as String? ?? '',
      paidAt:          json['paid_at'] as String?,
      paymentProof:    json['payment_proof'] as String?,
      createdAt:       json['created_at'] as String? ?? '',
      midtransOrderId: json['midtrans_order_id'] as String?,
      snapToken:       json['snap_token'] as String?,
      redirectUrl:     json['redirect_url'] as String?,
      event: json['event'] != null
          ? EventSummary.fromJson(json['event'] as Map<String, dynamic>)
          : null,
    );
  }

  String get formattedTotal {
    final s = total.toInt().toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
    return 'Rp$s';
  }

  String get statusLabel {
    switch (status) {
      case TransactionStatus.paid:      return 'Aktif';
      case TransactionStatus.pending:   return 'Menunggu Pembayaran';
      case TransactionStatus.cancelled: return 'Dibatalkan';
    }
  }

  /// Order ID untuk ditampilkan ke user (pakai midtrans_order_id jika ada)
  String get displayOrderId =>
      midtransOrderId ?? 'TKT-${id.toString().padLeft(6, '0')}';
}

class EventSummary {
  final int id;
  final String title;
  final String eventDate;
  final String location;

  const EventSummary({
    required this.id,
    required this.title,
    required this.eventDate,
    required this.location,
  });

  factory EventSummary.fromJson(Map<String, dynamic> json) => EventSummary(
        id:        json['id'] as int,
        title:     json['title'] as String,
        eventDate: json['event_date'] as String,
        location:  json['location'] as String,
      );
}

// ── Request models ─────────────────────────────────────────────────────────

class CheckoutRequest {
  final int eventId;
  final int quantity;
  final String? paymentMethod;
  final String? promoCode;

  const CheckoutRequest({
    required this.eventId,
    required this.quantity,
    this.paymentMethod,
    this.promoCode,
  });

  Map<String, dynamic> toJson() => {
        'event_id': eventId,
        'quantity': quantity,
        if (paymentMethod != null) 'payment_method': paymentMethod,
        if (promoCode != null && promoCode!.isNotEmpty)
          'promo_code': promoCode,
      };
}

class PromoValidationResponse {
  final bool valid;
  final double discount;
  final double finalPrice;
  final String? message;

  const PromoValidationResponse({
    required this.valid,
    required this.discount,
    required this.finalPrice,
    this.message,
  });
}

// ── Auth models ──────────────────────────────────────────────────────────────

class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String status;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.role = 'user',
    this.status = 'Active',
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id:     json['id'] as int,
        name:   json['name'] as String,
        email:  json['email'] as String,
        role:   json['role'] as String? ?? 'user',
        status: json['status'] as String? ?? 'Active',
      );

  String get firstName => name.split(' ').first;
  String get initial   => name.isNotEmpty ? name[0].toUpperCase() : 'U';
}

class AuthResponse {
  final String token;
  final UserModel user;

  const AuthResponse({required this.token, required this.user});

  factory AuthResponse.fromJson(Map<String, dynamic> json) => AuthResponse(
        token: json['token'] as String,
        user:  UserModel.fromJson(json['user'] as Map<String, dynamic>),
      );
}

// ── E-Ticket model ───────────────────────────────────────────────────────────

class ETicketModel {
  final String bookingId;
  final String transactionId;
  final String holderName;
  final String eventName;
  final String eventDate;
  final String eventTime;
  final String venue;
  final String ticketCategory;
  final int ticketNumber;
  final int totalTickets;

  const ETicketModel({
    required this.bookingId,
    required this.transactionId,
    required this.holderName,
    required this.eventName,
    required this.eventDate,
    required this.eventTime,
    required this.venue,
    required this.ticketCategory,
    required this.ticketNumber,
    required this.totalTickets,
  });

  static List<ETicketModel> fromTransaction(
    TransactionModel tx,
    UserModel user,
  ) {
    final event   = tx.event;
    final txIdStr = tx.id.toString().padLeft(6, '0');

    return List.generate(tx.quantity, (i) {
      final ticketNo = i + 1;
      return ETicketModel(
        bookingId:      'TKT-$txIdStr-$ticketNo',
        transactionId:  'TKT-$txIdStr',
        holderName:     user.name,
        eventName:      event?.title ?? '-',
        eventDate:      event?.eventDate ?? '-',
        eventTime:      '-',
        venue:          event?.location ?? '-',
        ticketCategory: 'Festival A',
        ticketNumber:   ticketNo,
        totalTickets:   tx.quantity,
      );
    });
  }

  static ETicketModel single(TransactionModel tx, UserModel user) {
    return fromTransaction(tx, user).first;
  }
}
