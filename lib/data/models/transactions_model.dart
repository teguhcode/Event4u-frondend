// Transaction Models

enum TransactionStatus {
  pending('pending'),
  paid('paid'),
  cancelled('cancelled');

  final String value;
  const TransactionStatus(this.value);

  factory TransactionStatus.fromString(String value) {
    return TransactionStatus.values.firstWhere(
      (e) => e.value.toLowerCase() == value.toLowerCase(),
      orElse: () => TransactionStatus.pending,
    );
  }
}

class EventDataInTransaction {
  final int id;
  final String title;
  final String? image;

  const EventDataInTransaction({
    required this.id,
    required this.title,
    this.image,
  });

  factory EventDataInTransaction.fromJson(Map<String, dynamic> json) =>
      EventDataInTransaction(
        id: json['id'] as int,
        title: json['title'] as String,
        image: json['image'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image': image,
      };
}

class TransactionModel {
  final int id;
  final EventDataInTransaction event;
  final int quantity;
  final double subtotal;
  final double discount;
  final double total;
  final String paymentMethod;
  final TransactionStatus status;
  final String? snapToken;
  final String? snapRedirectUrl;
  final String? midtransOrderId;
  final String createdAt;
  final String? paidAt;

  const TransactionModel({
    required this.id,
    required this.event,
    required this.quantity,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.paymentMethod,
    required this.status,
    this.snapToken,
    this.snapRedirectUrl,
    this.midtransOrderId,
    required this.createdAt,
    this.paidAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      TransactionModel(
        id: json['id'] as int,
        event: EventDataInTransaction.fromJson(
            json['event'] as Map<String, dynamic>),
        quantity: json['quantity'] as int,
        subtotal: (json['subtotal'] as num? ?? 0).toDouble(),
        discount: (json['discount'] as num? ?? 0).toDouble(),
        total: (json['total'] as num).toDouble(),
        paymentMethod: json['payment_method'] as String? ?? 'Unknown',
        status: TransactionStatus.fromString(json['status'] as String? ?? 'pending'),
        snapToken: json['snap_token'] as String?,
        snapRedirectUrl: json['snap_redirect_url'] as String?,
        midtransOrderId: json['midtrans_order_id'] as String?,
        createdAt: json['created_at'] as String,
        paidAt: json['paid_at'] as String?,
      );
}

class TransactionListResponse {
  final List<TransactionModel> transactions;
  final TransactionMeta meta;

  const TransactionListResponse({
    required this.transactions,
    required this.meta,
  });

  factory TransactionListResponse.fromJson(Map<String, dynamic> json) =>
      TransactionListResponse(
        transactions: (json['data'] as List<dynamic>)
            .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
            .toList(),
        meta: TransactionMeta.fromJson(json['meta'] as Map<String, dynamic>),
      );
}

class TransactionMeta {
  final int currentPage;
  final int total;
  final int perPage;
  final int lastPage;

  const TransactionMeta({
    required this.currentPage,
    required this.total,
    required this.perPage,
    required this.lastPage,
  });

  factory TransactionMeta.fromJson(Map<String, dynamic> json) => TransactionMeta(
        currentPage: json['current_page'] as int,
        total: json['total'] as int,
        perPage: json['per_page'] as int,
        lastPage: json['last_page'] as int,
      );
}

class CheckoutRequest {
  final int eventId;
  final int quantity;
  final String? promoCode;
  final String paymentMethod;

  const CheckoutRequest({
    required this.eventId,
    required this.quantity,
    this.promoCode,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() => {
        'event_id': eventId,
        'quantity': quantity,
        'promo_code': promoCode,
        'payment_method': paymentMethod,
      };
}