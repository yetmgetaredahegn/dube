import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dube/features/customers/data/models/customer.dart';
import 'package:dube/features/transactions/data/models/transaction.dart';
import 'package:dube/features/transactions/services/ledger_service.dart';
import 'package:dube/shared/providers/app_providers.dart';

class TransactionActionState {
  final bool         isLoading;
  final String?      error;
  final bool         success;
  final Transaction? lastTransaction;

  const TransactionActionState({
    this.isLoading = false,
    this.error,
    this.success = false,
    this.lastTransaction,
  });

  TransactionActionState copyWith({
    bool? isLoading, String? error,
    bool? success,  Transaction? lastTransaction,
  }) =>
      TransactionActionState(
        isLoading:       isLoading       ?? this.isLoading,
        error:           error,
        success:         success         ?? this.success,
        lastTransaction: lastTransaction ?? this.lastTransaction,
      );
}

class TransactionNotifier extends StateNotifier<TransactionActionState> {
  final LedgerService _ledger;
  final String        _uid;

  TransactionNotifier(this._ledger, this._uid)
      : super(const TransactionActionState());

  Future<bool> addCredit({
    required Customer customer,
    required double   amount,
    String note = '',
  }) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      final tx = await _ledger.addCredit(
          uid: _uid, customer: customer, amount: amount, note: note);
      state = state.copyWith(isLoading: false, success: true, lastTransaction: tx);
      return true;
    } on CreditLimitException catch (e) {
      state = state.copyWith(isLoading: false, error: e.userMessage);
      return false;
    } catch (_) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to record credit. Try again.');
      return false;
    }
  }

  Future<bool> addPayment({
    required String customerId,
    required double amount,
    String note = '',
  }) async {
    state = state.copyWith(isLoading: true, error: null, success: false);
    try {
      final tx = await _ledger.addPayment(
          uid: _uid, customerId: customerId, amount: amount, note: note);
      state = state.copyWith(isLoading: false, success: true, lastTransaction: tx);
      return true;
    } catch (_) {
      state = state.copyWith(
          isLoading: false, error: 'Failed to record payment. Try again.');
      return false;
    }
  }

  void reset() => state = const TransactionActionState();
}

final transactionNotifierProvider =
    StateNotifierProvider<TransactionNotifier, TransactionActionState>((ref) {
  final uid = ref.watch(currentUidProvider);
  return TransactionNotifier(ref.watch(ledgerServiceProvider), uid);
});
