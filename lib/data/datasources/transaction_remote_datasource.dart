import 'package:dio/dio.dart';
import '../../core/constants/api_constants.dart';
import '../../core/errors/api_exception.dart';
import '../models/transaction_model.dart';

class TransactionRemoteDatasource {
  final Dio _dio;
  TransactionRemoteDatasource(this._dio);

  /// POST /api/transactions/checkout
  /// Body: { event_id, quantity, payment_method, promo_code? }
  Future<TransactionModel> checkout(CheckoutRequest req) async {
    try {
      final res = await _dio.post(
        ApiConstants.checkout,
        data: req.toJson(),
      );
      final raw = res.data;
      final json = raw is Map && raw['data'] is Map
          ? raw['data'] as Map<String, dynamic>
          : raw as Map<String, dynamic>;
      return TransactionModel.fromJson(json);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /api/transactions
  Future<List<TransactionModel>> getHistory() async {
    try {
      final res = await _dio.get(ApiConstants.transactions);
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
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /api/transactions/{id}
  Future<TransactionModel> getDetail(int id) async {
    try {
      final res = await _dio.get(ApiConstants.transactionDetail(id));
      final raw = res.data;
      final json = raw is Map && raw['data'] is Map
          ? raw['data'] as Map<String, dynamic>
          : raw as Map<String, dynamic>;
      return TransactionModel.fromJson(json);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// POST /api/transactions/{id}/pay
  /// Body: { payment_method } — untuk update status ke paid
  Future<TransactionModel> pay(int id, String paymentMethod) async {
    try {
      final res = await _dio.post(
        ApiConstants.transactionPay(id),
        data: {'payment_method': paymentMethod},
      );
      final raw = res.data;
      final json = raw is Map && raw['data'] is Map
          ? raw['data'] as Map<String, dynamic>
          : raw as Map<String, dynamic>;
      return TransactionModel.fromJson(json);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// GET /api/transactions/{id}/check-status
  /// Polling silent untuk cek status pembayaran Midtrans
  Future<TransactionModel> checkStatus(int id) async {
    try {
      final res = await _dio.get(ApiConstants.transactionStatus(id));
      final raw = res.data;
      final json = raw is Map && raw['data'] is Map
          ? raw['data'] as Map<String, dynamic>
          : raw as Map<String, dynamic>;
      return TransactionModel.fromJson(json);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
