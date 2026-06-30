// Plain Dart classes — no Freezed, no code generation needed

enum TransactionStatus { pending, active, completed, failed }

class CheckoutRequest {
  final int eventId;
  final int ticketTypeId;
  final int quantity;
  final String? promoCode;

  const CheckoutRequest({
    required this.eventId,
    required this.ticketTypeId,
    required this.quantity,
    this.promoCode,
  });

  Map<String, dynamic> toJson() => {
        'event_id': eventId,
        'ticket_type_id': ticketTypeId,
        'quantity': quantity,
        if (promoCode != null) 'promo_code': promoCode,
      };
}

class PromoValidationRequest {
  final String promoCode;
  final int eventId;
  final int subtotal;

  const PromoValidationRequest({
    required this.promoCode,
    required this.eventId,
    required this.subtotal,
  });

  Map<String, dynamic> toJson() => {
        'promo_code': promoCode,
        'event_id': eventId,
        'subtotal': subtotal,
      };
}

class PromoValidationResponse {
  final bool valid;
  final int discount;
  final int finalPrice;
  final String? message;

  const PromoValidationResponse({
    required this.valid,
    required this.discount,
    required this.finalPrice,
    this.message,
  });

  factory PromoValidationResponse.fromJson(Map<String, dynamic> json) =>
      PromoValidationResponse(
        valid: json['valid'] as bool,
        discount: json['discount'] as int,
        finalPrice: json['final_price'] as int,
        message: json['message'] as String?,
      );
}

class TransactionModel {
  final String id;
  final String orderId;
  final String eventName;
  final String eventDate;
  final String eventTime;
  final String eventVenue;
  final String ticketCategory;
  final int quantity;
  final int totalPrice;
  final TransactionStatus status;
  final String createdAt;
  final MidtransPaymentModel? payment;
  final ETicketModel? eTicket;

  const TransactionModel({
    required this.id,
    required this.orderId,
    required this.eventName,
    required this.eventDate,
    required this.eventTime,
    required this.eventVenue,
    required this.ticketCategory,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
    this.payment,
    this.eTicket,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'].toString(),
        orderId: json['order_id'] as String,
        eventName: json['event_name'] as String,
        eventDate: json['event_date'] as String,
        eventTime: json['event_time'] as String,
        eventVenue: json['event_venue'] as String,
        ticketCategory: json['ticket_category'] as String,
        quantity: json['quantity'] as int,
        totalPrice: json['total_price'] as int,
        status: TransactionStatus.values.firstWhere(
          (e) => e.name == json['status'],
          orElse: () => TransactionStatus.pending,
        ),
        createdAt: json['created_at'] as String,
        payment: json['payment'] != null
            ? MidtransPaymentModel.fromJson(
                json['payment'] as Map<String, dynamic>)
            : null,
        eTicket: json['e_ticket'] != null
            ? ETicketModel.fromJson(
                json['e_ticket'] as Map<String, dynamic>)
            : null,
      );
}

class MidtransPaymentModel {
  final String snapToken;
  final String paymentUrl;
  final String paymentMethod;
  final String expiryTime;
  final String? vaNumber;
  final String? qrisImageUrl;

  const MidtransPaymentModel({
    required this.snapToken,
    required this.paymentUrl,
    required this.paymentMethod,
    required this.expiryTime,
    this.vaNumber,
    this.qrisImageUrl,
  });

  factory MidtransPaymentModel.fromJson(Map<String, dynamic> json) =>
      MidtransPaymentModel(
        snapToken: json['snap_token'] as String,
        paymentUrl: json['payment_url'] as String,
        paymentMethod: json['payment_method'] as String,
        expiryTime: json['expiry_time'] as String,
        vaNumber: json['va_number'] as String?,
        qrisImageUrl: json['qris_image_url'] as String?,
      );
}

class ETicketModel {
  final String bookingId;
  final String holderName;
  final String eventName;
  final String eventDate;
  final String eventTime;
  final String venue;
  final String ticketCategory;
  final String seatNumber;
  final int quantity;
  final String qrCodeData;

  const ETicketModel({
    required this.bookingId,
    required this.holderName,
    required this.eventName,
    required this.eventDate,
    required this.eventTime,
    required this.venue,
    required this.ticketCategory,
    required this.seatNumber,
    required this.quantity,
    required this.qrCodeData,
  });

  factory ETicketModel.fromJson(Map<String, dynamic> json) => ETicketModel(
        bookingId: json['booking_id'] as String,
        holderName: json['holder_name'] as String,
        eventName: json['event_name'] as String,
        eventDate: json['event_date'] as String,
        eventTime: json['event_time'] as String,
        venue: json['venue'] as String,
        ticketCategory: json['ticket_category'] as String,
        seatNumber: json['seat_number'] as String,
        quantity: json['quantity'] as int,
        qrCodeData: json['qr_code_data'] as String,
      );
}
