import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dube/features/transactions/data/models/transaction.dart';
import 'package:dube/features/transactions/data/repositories/transaction_repository.dart';

class TransactionNotifier
    extends StateNotifier<AsyncValue<List<CreditTransaction>>> {
  final TransactionRepository _repo;
  final String uid;
  final String customerId;

  TransactionNotifier(this._repo, this.uid, this.customerId)
      : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final txns = await _repo.getCustomerTransactions(uid, customerId);
      state = AsyncValue.data(txns);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addTransaction(CreditTransaction txn) async {
    try {
      await _repo.addTransaction(uid, txn);
      await _load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() => _load();
}
