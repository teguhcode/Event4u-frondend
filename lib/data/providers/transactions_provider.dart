import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/config/app_config.dart';
import '../models/transactions_model.dart';
import '../providers/repository_providers.dart';

// Transaction history provider
final transactionHistoryProvider =
    FutureProvider.family<TransactionHistoryResponse, Map<String, dynamic>>(
        (ref, params) async {
  final transactionsRepository = ref.watch(transactionsRepositoryProvider);

  return transactionsRepository.getTransactionHistory(
    page: params['page'] ?? 1,
    perPage: params['perPage'] ?? AppConfig.defaultPageSize,
    status: params['status'],
  );
});

// Single transaction detail provider
final transactionDetailProvider =
    FutureProvider.family<TransactionModel, int>((ref, transactionId) async {
  final transactionsRepository = ref.watch(transactionsRepositoryProvider);
  return transactionsRepository.getTransactionDetail(transactionId);
});

// Checkout provider
final checkoutProvider =
    FutureProvider.family<CheckoutResponse, CheckoutRequest>(
        (ref, request) async {
  final transactionsRepository = ref.watch(transactionsRepositoryProvider);
  return transactionsRepository.checkout(request);
});

// Pay transaction provider
final payTransactionProvider =
    FutureProvider.family<TransactionModel, int>((ref, transactionId) async {
  final transactionsRepository = ref.watch(transactionsRepositoryProvider);
  return transactionsRepository.payTransaction(transactionId);
});

// Cached transactions provider
final cachedTransactionsProvider = StateProvider<List<TransactionModel>>((ref) {
  return [];
});

// Current transaction page provider
final transactionCurrentPageProvider = StateProvider<int>((ref) {
  return 1;
});
