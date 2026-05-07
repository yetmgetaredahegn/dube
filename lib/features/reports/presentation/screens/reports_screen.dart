import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dube/core/theme/app_theme.dart';
import 'package:dube/core/utils/currency_formatter.dart';
import 'package:dube/shared/providers/app_providers.dart';
import 'package:dube/features/transactions/services/ledger_service.dart';

/// Provider for the aging report — fetches once and caches.
final agingReportProvider =
    FutureProvider.autoDispose<List<AgingBucket>>((ref) async {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return [];
  final ledger = ref.read(ledgerServiceProvider);
  return ledger.getAgingReport(uid);
});

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final agingAsync = ref.watch(agingReportProvider);
    final customersAsync = ref.watch(customersWithBalancesProvider);

    // Compute grand totals from customers
    double totalOutstanding = 0;
    int customerCount = 0;

    final customers = customersAsync.valueOrNull ?? [];
    for (final c in customers) {
      final bal = c.balance ?? 0;
      if (bal > 0) {
        totalOutstanding += bal;
        customerCount++;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(agingReportProvider);
          ref.invalidate(customersWithBalancesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            // ── Summary card ────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [DubeTheme.primaryDark, DubeTheme.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Outstanding',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyFormatter.format(totalOutstanding),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$customerCount customers with outstanding balance',
                    style: const TextStyle(
                      color: Colors.white60,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Aging Analysis header ───────────────────────────
            const Text(
              'Aging Analysis',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Customers grouped by how long their debt has been outstanding',
              style: DubeText.bodyMuted,
            ),
            const SizedBox(height: 16),

            // ── Aging buckets ───────────────────────────────────
            agingAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => Text('Error: $err'),
              data: (buckets) {
                if (buckets.every((b) => b.customers.isEmpty)) {
                  return Container(
                    padding: const EdgeInsets.all(32),
                    child: const Center(
                      child: Text(
                        'No outstanding debts — great!',
                        style: TextStyle(color: Color(0xFF6B7280)),
                      ),
                    ),
                  );
                }

                return Column(
                  children: buckets.map((bucket) {
                    return _AgingBucketCard(bucket: bucket);
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Aging bucket card (expandable) ───────────────────────────────────────────

class _AgingBucketCard extends StatefulWidget {
  final AgingBucket bucket;
  const _AgingBucketCard({required this.bucket});

  @override
  State<_AgingBucketCard> createState() => _AgingBucketCardState();
}

class _AgingBucketCardState extends State<_AgingBucketCard> {
  bool _expanded = false;

  Color get _bucketColor {
    final label = widget.bucket.label;
    if (label.contains('90+')) return DubeTheme.danger;
    if (label.contains('61')) return const Color(0xFFE57A00);
    if (label.contains('31')) return DubeTheme.warning;
    return DubeTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    final bucket = widget.bucket;
    final color = _bucketColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8E8), width: 0.5),
      ),
      child: Column(
        children: [
          // ── Header (tappable to expand) ────────────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        '${bucket.customers.length}',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bucket.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${bucket.customers.length} customer${bucket.customers.length != 1 ? 's' : ''}',
                          style: DubeText.bodyMuted,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    CurrencyFormatter.format(bucket.totalOwed,
                        showDecimal: false),
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.expand_more,
                      color: Color(0xFFADB5BD),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Expanded customer list ────────────────────────
          if (_expanded && bucket.customers.isNotEmpty)
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFF0F0F0)),
                ),
              ),
              child: Column(
                children: bucket.customers.map((c) {
                  return ListTile(
                    dense: true,
                    onTap: () => context.go('/customers/${c.id}'),
                    leading: CircleAvatar(
                      radius: 16,
                      backgroundColor: color.withValues(alpha: 0.12),
                      child: Text(
                        c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    title: Text(
                      c.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    trailing: Text(
                      CurrencyFormatter.format(c.balance ?? 0),
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
