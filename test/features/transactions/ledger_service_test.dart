import 'package:flutter_test/flutter_test.dart';
import 'package:dube/features/transactions/services/ledger_service.dart';
import 'package:dube/features/transactions/data/models/transaction.dart';
import 'package:dube/features/customers/data/models/customer.dart';

void main() {
  late LedgerService ledgerService;

  setUp(() {
    ledgerService = LedgerService();
  });

  group('LedgerService - Balance Calculation', () {
    test('calculateBalance returns 0 for empty list', () {
      expect(ledgerService.calculateBalance([]), 0.0);
    });

    test('calculateBalance correctly sums credits and subtracts payments', () {
      final transactions = [
        CreditTransaction(
          id: '1',
          customerId: 'c1',
          amount: 1000.0,
          isCredit: true,
          createdAt: DateTime.now(),
        ),
        CreditTransaction(
          id: '2',
          customerId: 'c1',
          amount: 400.0,
          isCredit: false,
          createdAt: DateTime.now(),
        ),
        CreditTransaction(
          id: '3',
          customerId: 'c1',
          amount: 200.0,
          isCredit: true,
          createdAt: DateTime.now(),
        ),
      ];

      expect(ledgerService.calculateBalance(transactions), 800.0);
    });
  });

  group('LedgerService - Aging Report', () {
    test('getAgingReport categorizes customers correctly', () {
      final now = DateTime.now();
      final customers = [
        Customer(
          id: 'c1',
          name: 'Old Debt',
          phone: '123',
          creditLimit: 1000,
          createdAt: now.subtract(const Duration(days: 100)),
          balance: 500,
        ),
        Customer(
          id: 'c2',
          name: 'Recent Debt',
          phone: '456',
          creditLimit: 1000,
          createdAt: now,
          balance: 200,
        ),
      ];

      final report = ledgerService.getAgingReportFromCustomers(customers);

      // 90+ days bucket should have c1
      final over90 = report.firstWhere((b) => b.label.contains('90+'));
      expect(over90.customers.any((c) => c.id == 'c1'), true);
      expect(over90.totalOwed, 500.0);

      // 0-30 days bucket should have c2
      final current = report.firstWhere((b) => b.label.contains('0-30'));
      expect(current.customers.any((c) => c.id == 'c2'), true);
      expect(current.totalOwed, 200.0);
    });
  });
}
