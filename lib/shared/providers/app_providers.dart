import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dube/features/auth/data/repositories/auth_repository.dart';
import 'package:dube/features/auth/providers/auth_notifier.dart';
import 'package:dube/features/customers/data/models/customer.dart';
import 'package:dube/features/customers/data/repositories/customer_repository.dart';
import 'package:dube/features/customers/providers/customer_notifier.dart';
import 'package:dube/features/transactions/data/models/transaction.dart';
import 'package:dube/features/transactions/data/repositories/transaction_repository.dart';
import 'package:dube/features/transactions/providers/transaction_notifier.dart';
import 'package:dube/core/services/ledger_service.dart';

// ── Auth ──────────────────────────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((_) => AuthRepository());

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authNotifierProvider).value;
});

// ── Repositories ──────────────────────────────────────────────────────────────

final customerRepositoryProvider =
    Provider<CustomerRepository>((_) => CustomerRepository());

final transactionRepositoryProvider =
    Provider<TransactionRepository>((_) => TransactionRepository());

// ── Ledger Service ────────────────────────────────────────────────────────────

final ledgerServiceProvider = Provider<LedgerService>((ref) {
  return LedgerService(
    ref.read(transactionRepositoryProvider),
    ref.read(customerRepositoryProvider),
  );
});

// ── Customers ─────────────────────────────────────────────────────────────────

final customerNotifierProvider =
    StateNotifierProvider<CustomerNotifier, AsyncValue<List<Customer>>>((ref) {
  final user = ref.watch(currentUserProvider);
  return CustomerNotifier(
    ref.read(customerRepositoryProvider),
    user?.uid ?? '',
  );
});

// Stream of customers with derived balances attached
final customersWithBalancesProvider =
    StreamProvider<List<Customer>>((ref) async* {
  final user = ref.watch(currentUserProvider);
  if (user == null) {
    yield [];
    return;
  }
  final customerRepo = ref.read(customerRepositoryProvider);
  final txnRepo = ref.read(transactionRepositoryProvider);
  final ledger = ref.read(ledgerServiceProvider);

  yield* customerRepo.watchCustomers(user.uid).asyncMap((customers) async {
    final updated = await Future.wait(customers.map((c) async {
      final txns =
          await txnRepo.getCustomerTransactions(user.uid, c.id);
      final balance = ledger.calculateBalance(txns);
      return c.copyWith(currentBalance: balance);
    }));
    return updated;
  });
});

// ── Transactions ──────────────────────────────────────────────────────────────

// Family provider: pass (shopOwnerId, customerId) as a record
final transactionNotifierProvider = StateNotifierProvider.family<
    TransactionNotifier,
    AsyncValue<List<CreditTransaction>>,
    ({String shopOwnerId, String customerId})>((ref, params) {
  return TransactionNotifier(
    ref.read(transactionRepositoryProvider),
    params.shopOwnerId,
    params.customerId,
  );
});
