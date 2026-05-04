import 'package:dube/features/customers/data/models/customer.dart';
import 'package:dube/features/customers/data/repositories/customer_repository.dart';
import 'package:dube/features/transactions/data/models/transaction.dart';
import 'package:dube/features/transactions/data/repositories/transaction_repository.dart';

class AgingBucket {
  final String label;
  final List<Customer> customers;
  final double totalOwed;

  AgingBucket(
      {required this.label,
      required this.customers,
      required this.totalOwed});
}

class LedgerService {
  final TransactionRepository _txnRepo;
  final CustomerRepository _customerRepo;

  LedgerService(this._txnRepo, this._customerRepo);

  /// Derives balance from transactions — never stored directly
  double calculateBalance(List<CreditTransaction> transactions) {
    double balance = 0;
    for (final txn in transactions) {
      if (txn.isCredit) {
        balance += txn.amount;
      } else {
        balance -= txn.amount;
      }
    }
    return balance;
  }

  /// Add a credit, enforcing the credit limit
  Future<void> addCredit({
    required String shopOwnerId,
    required String customerId,
    required double amount,
    String? note,
  }) async {
    final customer =
        await _customerRepo.getCustomer(shopOwnerId, customerId);
    if (customer == null) throw Exception('Customer not found');

    final txns = await _txnRepo.getCustomerTransactions(
        shopOwnerId, customerId);
    final currentBalance = calculateBalance(txns);

    if (currentBalance + amount > customer.creditLimit) {
      throw Exception(
          'Credit limit exceeded. Current balance: $currentBalance, Limit: ${customer.creditLimit}');
    }

    final txn = CreditTransaction(
      id: '',
      customerId: customerId,
      shopOwnerId: shopOwnerId,
      type: TransactionType.credit,
      amount: amount,
      note: note,
      createdAt: DateTime.now(),
    );

    await _txnRepo.addTransaction(shopOwnerId, txn);
  }

  /// Add a payment
  Future<void> addPayment({
    required String shopOwnerId,
    required String customerId,
    required double amount,
    String? note,
  }) async {
    final txn = CreditTransaction(
      id: '',
      customerId: customerId,
      shopOwnerId: shopOwnerId,
      type: TransactionType.payment,
      amount: amount,
      note: note,
      createdAt: DateTime.now(),
    );

    await _txnRepo.addTransaction(shopOwnerId, txn);
  }

  /// Aging report: buckets customers by how old their debt is
  Future<List<AgingBucket>> getAgingReport(String shopOwnerId) async {
    final customers = await _customerRepo.getCustomers(shopOwnerId);
    final now = DateTime.now();

    final bucket0to30 = <Customer>[];
    final bucket31to60 = <Customer>[];
    final bucket61to90 = <Customer>[];
    final bucket90plus = <Customer>[];

    for (final customer in customers) {
      final txns = await _txnRepo.getCustomerTransactions(
          shopOwnerId, customer.id);
      final balance = calculateBalance(txns);
      if (balance <= 0) continue;

      // Find the oldest unpaid credit
      final credits =
          txns.where((t) => t.isCredit).toList()
            ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

      if (credits.isEmpty) continue;
      final oldestCredit = credits.first;
      final daysDiff = now.difference(oldestCredit.createdAt).inDays;

      if (daysDiff <= 30) {
        bucket0to30.add(customer);
      } else if (daysDiff <= 60) {
        bucket31to60.add(customer);
      } else if (daysDiff <= 90) {
        bucket61to90.add(customer);
      } else {
        bucket90plus.add(customer);
      }
    }

    double totalFor(List<Customer> list) =>
        list.fold(0, (sum, c) => sum + (c.currentBalance ?? 0));

    return [
      AgingBucket(
          label: '0–30 days',
          customers: bucket0to30,
          totalOwed: totalFor(bucket0to30)),
      AgingBucket(
          label: '31–60 days',
          customers: bucket31to60,
          totalOwed: totalFor(bucket31to60)),
      AgingBucket(
          label: '61–90 days',
          customers: bucket61to90,
          totalOwed: totalFor(bucket61to90)),
      AgingBucket(
          label: '90+ days',
          customers: bucket90plus,
          totalOwed: totalFor(bucket90plus)),
    ];
  }
}
