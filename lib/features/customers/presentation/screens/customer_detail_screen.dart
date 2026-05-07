import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dube/core/theme/app_theme.dart';
import 'package:dube/core/utils/currency_formatter.dart';
import 'package:dube/shared/providers/app_providers.dart';
import 'package:dube/features/transactions/data/models/transaction.dart';

class CustomerDetailScreen extends ConsumerWidget {
  final String customerId;

  const CustomerDetailScreen({super.key, required this.customerId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(currentUidProvider) ?? '';
    final customersAsync = ref.watch(customersWithBalancesProvider);

    return customersAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $err')),
      ),
      data: (customers) {
        final customer = customers
            .where((c) => c.id == customerId)
            .firstOrNull;

        if (customer == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Customer not found')),
          );
        }

        final balance = customer.balance ?? 0;
        final ratio = customer.utilizationRatio;
        final color = DubeTheme.balanceColor(ratio);

        // Watch transaction stream for this customer
        final txnNotifier = ref.watch(
          transactionNotifierProvider(
            (uid: uid, customerId: customerId),
          ),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(customer.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () {
                  // Will navigate to edit screen (Phase B completion)
                },
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            children: [
              // ── Balance card ───────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: const Color(0xFFE8E8E8), width: 0.5),
                ),
                child: Column(
                  children: [
                    Text('Outstanding Balance',
                        style: DubeText.label.copyWith(
                            color: const Color(0xFF6B7280))),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.format(balance),
                      style: DubeText.displayAmount.copyWith(color: color),
                    ),
                    const SizedBox(height: 16),

                    // Credit limit bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Credit Limit',
                            style: DubeText.bodyMuted),
                        Text(
                          CurrencyFormatter.format(customer.creditLimit),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: ratio.clamp(0.0, 1.0),
                        minHeight: 10,
                        backgroundColor: const Color(0xFFF0F0F0),
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(ratio * 100).toStringAsFixed(0)}% used',
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Info row ──────────────────────────────────────
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border:
                      Border.all(color: const Color(0xFFE8E8E8), width: 0.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone_outlined,
                        size: 20, color: Color(0xFF6B7280)),
                    const SizedBox(width: 10),
                    Text(customer.phone,
                        style: const TextStyle(fontSize: 15)),
                    const Spacer(),
                    Text(
                      'Since ${DateFormatter.date(customer.createdAt)}',
                      style: DubeText.bodyMuted,
                    ),
                  ],
                ),
              ),
              if (customer.note != null && customer.note!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: DubeTheme.warningLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.note_outlined,
                          size: 18, color: DubeTheme.warning),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          customer.note!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // ── Transaction history header ────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transaction History',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  Text(
                    txnNotifier.when(
                      loading: () => '',
                      error: (_, __) => '',
                      data: (txns) => '${txns.length} records',
                    ),
                    style: DubeText.bodyMuted,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // ── Transaction list ──────────────────────────────
              txnNotifier.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator()),
                error: (err, _) => Text('Error: $err'),
                data: (txns) {
                  if (txns.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(32),
                      child: const Center(
                        child: Text(
                          'No transactions yet',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: txns.map((txn) => _TransactionTile(txn)).toList(),
                  );
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () =>
                context.go('/customers/$customerId/transaction'),
            backgroundColor: DubeTheme.primary,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Add Transaction'),
          ),
        );
      },
    );
  }
}

// ── Transaction tile ─────────────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  final CreditTransaction txn;
  const _TransactionTile(this.txn);

  @override
  Widget build(BuildContext context) {
    final isCredit = txn.isCredit;
    final color = isCredit ? DubeTheme.danger : DubeTheme.primary;
    final icon = isCredit
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;
    final sign = isCredit ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCredit ? 'Credit' : 'Payment',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  txn.note ?? DateFormatter.relative(txn.createdAt),
                  style: DubeText.bodyMuted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign ${CurrencyFormatter.short(txn.amount)}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                DateFormatter.relative(txn.createdAt),
                style: const TextStyle(
                  color: Color(0xFFADB5BD),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
