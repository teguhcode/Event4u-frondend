import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/errors/api_exception.dart';
import '../../data/models/transaction_model.dart';
import '../../data/repositories/transaction_repository.dart';

// ── Checkout State ─────────────────────────────────────────────────────────
class CheckoutState {
  final bool isLoading;
  final TransactionModel? transaction;
  final String? error;

  const CheckoutState({
    this.isLoading   = false,
    this.transaction,
    this.error,
  });

  CheckoutState copyWith({
    bool?             isLoading,
    TransactionModel? transaction,
    String?           error,
    bool              clearError = false,
  }) => CheckoutState(
    isLoading:   isLoading   ?? this.isLoading,
    transaction: transaction ?? this.transaction,
    error:       clearError ? null : (error ?? this.error),
  );
}

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final TransactionRepository _repo;
  CheckoutNotifier(this._repo) : super(const CheckoutState());

  Future<TransactionModel?> checkout(CheckoutRequest req) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tx = await _repo.checkout(req);
      state = state.copyWith(isLoading: false, transaction: tx);
      return tx;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Checkout gagal: ${e.toString()}');
      return null;
    }
  }

  Future<TransactionModel?> pay(int txId, String method) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tx = await _repo.pay(txId, method);
      state = state.copyWith(isLoading: false, transaction: tx);
      return tx;
    } on ApiException catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return null;
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: 'Pembayaran gagal: ${e.toString()}');
      return null;
    }
  }

  /// Cek status pembayaran tanpa update UI loading (untuk polling silent)
  Future<TransactionModel?> checkStatus(int txId) async {
    try {
      final tx = await _repo.checkStatus(txId);
      if (tx.status == TransactionStatus.paid) {
        state = state.copyWith(transaction: tx);
      }
      return tx;
    } catch (_) {
      return null;
    }
  }

  void reset() => state = const CheckoutState();
}

final checkoutProvider =
    StateNotifierProvider<CheckoutNotifier, CheckoutState>((ref) {
  return CheckoutNotifier(ref.read(transactionRepositoryProvider));
});

// ── Transaction History ────────────────────────────────────────────────────
final transactionHistoryProvider =
    FutureProvider<List<TransactionModel>>((ref) async {
  return ref.read(transactionRepositoryProvider).getHistory();
});

// ── Single Transaction Detail ──────────────────────────────────────────────
final transactionDetailProvider =
    FutureProvider.family<TransactionModel, int>((ref, id) async {
  return ref.read(transactionRepositoryProvider).getDetail(id);
});
