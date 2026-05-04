import 'package:dube/core/constants/firestore_paths.dart';
import 'package:dube/features/customers/data/models/customer.dart';
import 'package:dube/features/transactions/data/models/transaction.dart';
import 'package:dube/features/transactions/data/repositories/transaction_repository.dart';

/// CORE PRINCIPLE: balance = SUM(CREDIT) - SUM(PAYMENT)
/// It is NEVER stored in Firestore. Always derived from the ledger.
class LedgerService {
  final TransactionRepository _txRepo;

  LedgerService({TransactionRepository? txRepo})
      : _txRepo = txRepo ?? TransactionRepository();

  // ── Balance calculation ────────────────────────────────────────────────────

  Future<double> calculateBalance(String uid, String customerId) async {
    final txns = await _txRepo.fetchCustomerTransactions(uid, customerId);
    return _compute(txns);
  }

  double calculateBalanceFromList(List<Transaction> txns) => _compute(txns);

  double _compute(List<Transaction> txns) {
    double credits = 0, payments = 0;
    for (final tx in txns) {
      if (tx.isCredit)  credits  += tx.amount;
      else              payments += tx.amount;
    }
    return credits - payments;
  }

  // ── Add credit (enforces limit) ────────────────────────────────────────────

  Future<Transaction> addCredit({
    required String uid,
    required Customer customer,
    required double amount,
    String note = '',
  }) async {
    if (amount <= 0) throw ArgumentError('Amount must be positive');

    final balance    = await calculateBalance(uid, customer.id);
    final newBalance = balance + amount;

    if (newBalance > customer.creditLimit) {
      throw CreditLimitException(
        requested:      amount,
        currentBalance: balance,
        limit:          customer.creditLimit,
        available:      customer.creditLimit - balance,
      );
    }

    return _txRepo.addTransaction(
      uid:        uid,
      customerId: customer.id,
      type:       TransactionType.credit,
      amount:     amount,
      note:       note,
    );
  }

  // ── Record payment ─────────────────────────────────────────────────────────

  Future<Transaction> addPayment({
    required String uid,
    required String customerId,
    required double amount,
    String note = '',
  }) async {
    if (amount <= 0) throw ArgumentError('Amount must be positive');
    return _txRepo.addTransaction(
      uid:        uid,
      customerId: customerId,
      type:       TransactionType.payment,
      amount:     amount,
      note:       note,
    );
  }

  // ── Attach balances to a list of customers ─────────────────────────────────
  // One batched Firestore read instead of N reads.

  Future<List<Customer>> attachBalances(
      String uid, List<Customer> customers) async {
    if (customers.isEmpty) return customers;

    final allTxns = await _txRepo.fetchAllTransactions(uid);

    final Map<String, List<Transaction>> byCustomer = {};
    for (final tx in allTxns) {
      byCustomer.putIfAbsent(tx.customerId, () => []).add(tx);
    }

    return customers.map((c) {
      final balance = _compute(byCustomer[c.id] ?? []);
      return c.withBalance(balance);
    }).toList();
  }

  // ── Aging report ───────────────────────────────────────────────────────────

  Future<AgingReport> getAgingReport(
      String uid, List<Customer> customers) async {
    final allTxns = await _txRepo.fetchAllTransactions(uid);
    final now     = DateTime.now();

    final Map<String, List<Transaction>> byCustomer = {};
    for (final tx in allTxns) {
      byCustomer.putIfAbsent(tx.customerId, () => []).add(tx);
    }

    double current = 0, days30 = 0, days60 = 0, days90plus = 0;
    final entries = <CustomerAgingEntry>[];

    for (final customer in customers) {
      final txns   = byCustomer[customer.id] ?? [];
      final balance = _compute(txns);
      if (balance <= 0) continue;

      final credits = txns.where((t) => t.isCredit).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      final ageDays = credits.isEmpty
          ? 0
          : now.difference(credits.first.createdAt).inDays;

      if      (ageDays <= 30) current   += balance;
      else if (ageDays <= 60) days30    += balance;
      else if (ageDays <= 90) days60    += balance;
      else                    days90plus += balance;

      entries.add(CustomerAgingEntry(
        customer: customer.withBalance(balance),
        ageDays:  ageDays,
        balance:  balance,
      ));
    }

    entries.sort((a, b) => b.ageDays.compareTo(a.ageDays));

    return AgingReport(
      current:   current,
      days30:    days30,
      days60:    days60,
      days90plus: days90plus,
      entries:   entries,
    );
  }
}

// ── Exception ──────────────────────────────────────────────────────────────

class CreditLimitException implements Exception {
  final double requested;
  final double currentBalance;
  final double limit;
  final double available;

  const CreditLimitException({
    required this.requested,
    required this.currentBalance,
    required this.limit,
    required this.available,
  });

  String get userMessage =>
      'Cannot add ETB ${requested.toStringAsFixed(0)}. '
      'Only ETB ${available.toStringAsFixed(0)} available '
      '(limit: ETB ${limit.toStringAsFixed(0)}).';
}

// ── Report models ──────────────────────────────────────────────────────────

class AgingReport {
  final double current;
  final double days30;
  final double days60;
  final double days90plus;
  final List<CustomerAgingEntry> entries;

  const AgingReport({
    required this.current,
    required this.days30,
    required this.days60,
    required this.days90plus,
    required this.entries,
  });

  double get totalOutstanding => current + days30 + days60 + days90plus;
}

class CustomerAgingEntry {
  final Customer customer;
  final int      ageDays;
  final double   balance;

  const CustomerAgingEntry({
    required this.customer,
    required this.ageDays,
    required this.balance,
  });

  AgingBucket get bucket {
    if (ageDays <= 30) return AgingBucket.current;
    if (ageDays <= 60) return AgingBucket.days30;
    if (ageDays <= 90) return AgingBucket.days60;
    return AgingBucket.days90plus;
  }
}

enum AgingBucket { current, days30, days60, days90plus }

extension AgingBucketLabel on AgingBucket {
  String get label {
    switch (this) {
      case AgingBucket.current:    return '0–30 days';
      case AgingBucket.days30:     return '31–60 days';
      case AgingBucket.days60:     return '61–90 days';
      case AgingBucket.days90plus: return '90+ days';
    }
  }
}
