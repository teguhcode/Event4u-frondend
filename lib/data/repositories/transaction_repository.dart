import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/dio_client.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../models/transaction_model.dart';

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepository(
      TransactionRemoteDatasource(ref.read(dioProvider)));
});

class TransactionRepository {
  final TransactionRemoteDatasource _ds;
  TransactionRepository(this._ds);

  Future<TransactionModel> checkout(CheckoutRequest req) => _ds.checkout(req);
  Future<List<TransactionModel>> getHistory() => _ds.getHistory();
  Future<TransactionModel> getDetail(int id) => _ds.getDetail(id);
  Future<TransactionModel> pay(int id, String method) => _ds.pay(id, method);
  Future<TransactionModel> checkStatus(int id) => _ds.checkStatus(id);
}
