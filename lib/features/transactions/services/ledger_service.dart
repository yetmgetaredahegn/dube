import 'package:dube/features/customers/data/models/customer.dart';
import 'package:dube/features/customers/data/repositories/customer_repository.dart';
import 'package:dube/features/transactions/data/models/transaction.dart';
import 'package:dube/features/transactions/data/repositories/transaction_repository.dart';

class AgingBucket {
  final String label;
  final List<Customer> customers;
  final double totalOwed;

  AgingBucket({
    required this.label,
    required this.customers,
    required this.totalOwed,
  });
}

class LedgerService {
  final TransactionRepository? _txnRepo;
  final CustomerRepository? _customerRepo;

  LedgerService([this._txnRepo, this._customerRepo]);

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
    required String uid,
    required String customerId,
    required double amount,
    String? note,
  }) async {
    final customer = await _customerRepo!.fetchCustomer(uid, customerId);

    final txns = await _txnRepo!.getCustomerTransactions(uid, customerId);
    final currentBalance = calculateBalance(txns);

    if (currentBalance + amount > customer.creditLimit) {
      throw Exception(
          'Credit limit exceeded. Balance: $currentBalance, Limit: ${customer.creditLimit}');
    }

    final txn = CreditTransaction(
      id: '',
      customerId: customerId,
      shopOwnerId: uid,
      type: TransactionType.credit,
      amount: amount,
      note: note,
      createdAt: DateTime.now(),
    );

    await _txnRepo!.addTransaction(uid, txn);
  }

  /// Add a payment
  Future<void> addPayment({
    required String uid,
    required String customerId,
    required double amount,
    String? note,
  }) async {
    final txn = CreditTransaction(
      id: '',
      customerId: customerId,
      shopOwnerId: uid,
      type: TransactionType.payment,
      amount: amount,
      note: note,
      createdAt: DateTime.now(),
    );

    await _txnRepo!.addTransaction(uid, txn);
  }

  /// Aging report — buckets customers by how long debt has been outstanding
  Future<List<AgingBucket>> getAgingReport(String uid) async {
    if (_customerRepo == null) return [];
    final customers = await _customerRepo!.fetchCustomers(uid);
    return getAgingReportFromCustomers(customers);
  }

  /// Pure logic for aging report — used by tests and internal methods
  List<AgingBucket> getAgingReportFromCustomers(List<Customer> customers) {
    final now = DateTime.now();

    final b0  = <Customer>[];
    final b31 = <Customer>[];
    final b61 = <Customer>[];
    final b90 = <Customer>[];

    for (final customer in customers) {
      if ((customer.balance ?? 0) <= 0) continue;

      // In a real app, we'd look at the oldest unpaid credit. 
      // For this simplified aging, we use the customer's creation date 
      // as a proxy if we don't have the transaction list here.
      final days = now.difference(customer.createdAt).inDays;

      if (days <= 30)      b0.add(customer);
      else if (days <= 60) b31.add(customer);
      else if (days <= 90) b61.add(customer);
      else                 b90.add(customer);
    }

    double total(List<Customer> list) =>
        list.fold(0, (sum, c) => sum + (c.balance ?? 0));

    return [
      AgingBucket(label: '0–30 days',  customers: b0,  totalOwed: total(b0)),
      AgingBucket(label: '31–60 days', customers: b31, totalOwed: total(b31)),
      AgingBucket(label: '61–90 days', customers: b61, totalOwed: total(b61)),
      AgingBucket(label: '90+ days',   customers: b90, totalOwed: total(b90)),
    ];
  }
}
