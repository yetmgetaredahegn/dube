import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dube/features/auth/data/repositories/auth_repository.dart';
import 'package:dube/features/customers/data/models/customer.dart';
import 'package:dube/features/customers/data/repositories/customer_repository.dart';
import 'package:dube/features/customers/providers/customer_notifier.dart';
import 'package:dube/features/transactions/data/models/transaction.dart';
import 'package:dube/features/transactions/data/repositories/transaction_repository.dart';
import 'package:dube/features/transactions/providers/transaction_notifier.dart';
import 'package:dube/features/transactions/services/ledger_service.dart';

// ── Auth ──────────────────────────────────────────────────────────────────────

final authRepositoryProvider =
    Provider<AuthRepository>((_) => AuthRepository());

// Stream of Firebase auth state changes — used by router for redirect
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// Current user uid (null if not logged in)
final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.uid;
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
  final uid = ref.watch(currentUidProvider) ?? '';
  return CustomerNotifier(ref.read(customerRepositoryProvider), uid);
});

// Stream of customers with derived balances attached
final customersWithBalancesProvider =
    StreamProvider<List<Customer>>((ref) async* {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) {
    yield [];
    return;
  }
  final customerRepo = ref.read(customerRepositoryProvider);
  final txnRepo = ref.read(transactionRepositoryProvider);
  final ledger = ref.read(ledgerServiceProvider);

  yield* customerRepo.watchCustomers(uid).asyncMap((customers) async {
    final updated = await Future.wait(customers.map((c) async {
      final txns = await txnRepo.getCustomerTransactions(uid, c.id);
      final bal = ledger.calculateBalance(txns);
      return c.withBalance(bal);
    }));
    return List<Customer>.from(updated);
  });
});

// ── Transactions ──────────────────────────────────────────────────────────────

// Family provider keyed by customerId
final transactionNotifierProvider = StateNotifierProvider.family<
    TransactionNotifier,
    AsyncValue<List<CreditTransaction>>,
    ({String uid, String customerId})>((ref, params) {
  return TransactionNotifier(
    ref.read(transactionRepositoryProvider),
    params.uid,
    params.customerId,
  );
});
