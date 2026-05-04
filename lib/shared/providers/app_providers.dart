import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:dube/features/auth/data/models/app_user.dart';
import 'package:dube/features/auth/data/repositories/auth_repository.dart';
import 'package:dube/features/customers/data/models/customer.dart';
import 'package:dube/features/customers/data/repositories/customer_repository.dart';
import 'package:dube/features/transactions/data/models/transaction.dart';
import 'package:dube/features/transactions/data/repositories/transaction_repository.dart';
import 'package:dube/features/transactions/services/ledger_service.dart';

// ── Repository providers ───────────────────────────────────────────────────

final authRepositoryProvider =
    Provider<AuthRepository>((ref) => AuthRepository());

final customerRepositoryProvider =
    Provider<CustomerRepository>((ref) => CustomerRepository());

final transactionRepositoryProvider =
    Provider<TransactionRepository>((ref) => TransactionRepository());

final ledgerServiceProvider = Provider<LedgerService>(
  (ref) => LedgerService(txRepo: ref.watch(transactionRepositoryProvider)),
);

// ── Auth providers ─────────────────────────────────────────────────────────

final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(authRepositoryProvider).authStateChanges,
);

final currentUidProvider = Provider<String>((ref) {
  final user = ref.watch(authStateProvider).valueOrNull;
  if (user == null) throw Exception('Not authenticated');
  return user.uid;
});

final currentUserProfileProvider = FutureProvider<AppUser?>((ref) {
  return ref.watch(authRepositoryProvider).getCurrentUserProfile();
});

// ── Customer providers ─────────────────────────────────────────────────────

final customersStreamProvider = StreamProvider<List<Customer>>((ref) {
  final uid = ref.watch(currentUidProvider);
  return ref.watch(customerRepositoryProvider).watchCustomers(uid);
});

final customersWithBalancesProvider =
    FutureProvider<List<Customer>>((ref) async {
  final uid       = ref.watch(currentUidProvider);
  final customers = await ref.watch(customerRepositoryProvider).fetchCustomers(uid);
  return ref.watch(ledgerServiceProvider).attachBalances(uid, customers);
});

final customerProvider =
    FutureProvider.family<Customer, String>((ref, customerId) async {
  final uid      = ref.watch(currentUidProvider);
  final customer = await ref.watch(customerRepositoryProvider)
      .fetchCustomer(uid, customerId);
  final balance  = await ref.watch(ledgerServiceProvider)
      .calculateBalance(uid, customerId);
  return customer.withBalance(balance);
});

// ── Transaction providers ──────────────────────────────────────────────────

final customerTransactionsProvider =
    StreamProvider.family<List<Transaction>, String>((ref, customerId) {
  final uid = ref.watch(currentUidProvider);
  return ref.watch(transactionRepositoryProvider)
      .watchCustomerTransactions(uid, customerId);
});

// ── Dashboard summary ──────────────────────────────────────────────────────

final dashboardSummaryProvider =
    FutureProvider<DashboardSummary>((ref) async {
  final uid     = ref.watch(currentUidProvider);
  final ledger  = ref.watch(ledgerServiceProvider);
  final custRepo = ref.watch(customerRepositoryProvider);
  final txRepo  = ref.watch(transactionRepositoryProvider);

  final customers = await custRepo.fetchCustomers(uid);
  final allTxns   = await txRepo.fetchAllTransactions(uid);

  double totalCredit = 0, totalPayments = 0;
  for (final tx in allTxns) {
    if (tx.isCredit) totalCredit   += tx.amount;
    else             totalPayments += tx.amount;
  }

  final withBalances = await ledger.attachBalances(uid, customers);
  final withDebt     = withBalances.where((c) => (c.balance ?? 0) > 0).length;

  return DashboardSummary(
    totalCredit:         totalCredit,
    totalPayments:       totalPayments,
    totalOutstanding:    totalCredit - totalPayments,
    activeCustomers:     customers.length,
    customersWithBalance: withDebt,
  );
});

class DashboardSummary {
  final double totalCredit;
  final double totalPayments;
  final double totalOutstanding;
  final int    activeCustomers;
  final int    customersWithBalance;

  const DashboardSummary({
    required this.totalCredit,
    required this.totalPayments,
    required this.totalOutstanding,
    required this.activeCustomers,
    required this.customersWithBalance,
  });
}

// ── Aging report ───────────────────────────────────────────────────────────

final agingReportProvider = FutureProvider<AgingReport>((ref) async {
  final uid       = ref.watch(currentUidProvider);
  final customers = await ref.watch(customerRepositoryProvider).fetchCustomers(uid);
  return ref.watch(ledgerServiceProvider).getAgingReport(uid, customers);
});
