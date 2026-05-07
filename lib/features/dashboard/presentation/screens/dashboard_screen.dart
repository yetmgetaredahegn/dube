import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dube/core/theme/app_theme.dart';
import 'package:dube/core/utils/currency_formatter.dart';
import 'package:dube/shared/providers/app_providers.dart';
import 'package:dube/shared/widgets/stat_card.dart';


class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customersAsync = ref.watch(customersWithBalancesProvider);


    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: customersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (customers) {
          // Calculate totals
          double totalOutstanding = 0;
          int activeCustomers = 0;
          int overLimitCount = 0;

          for (final c in customers) {
            final bal = c.balance ?? 0;
            if (bal > 0) {
              totalOutstanding += bal;
              activeCustomers++;
            }
            if (c.isOverLimit) overLimitCount++;
          }

          // Sort by balance for top debtors
          final debtors = customers
              .where((c) => (c.balance ?? 0) > 0)
              .toList()
            ..sort((a, b) =>
                (b.balance ?? 0).compareTo(a.balance ?? 0));
          final topDebtors = debtors.take(5).toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(customersWithBalancesProvider);
            },
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: [
                // ── Stat cards ──────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Outstanding',
                        value: CurrencyFormatter.format(totalOutstanding,
                            showDecimal: false),
                        icon: Icons.account_balance_wallet_rounded,
                        color: DubeTheme.danger,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Total Customers',
                        value: '${customers.length}',
                        icon: Icons.people_rounded,
                        color: DubeTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Active Debtors',
                        value: '$activeCustomers',
                        icon: Icons.trending_up_rounded,
                        color: DubeTheme.warning,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Over Limit',
                        value: '$overLimitCount',
                        icon: Icons.warning_amber_rounded,
                        color: overLimitCount > 0
                            ? DubeTheme.danger
                            : DubeTheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // ── Top debtors ─────────────────────────────────
                if (topDebtors.isNotEmpty) ...[
                  const Text(
                    'Top Debtors',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...topDebtors.map((c) {
                    final bal = c.balance ?? 0;
                    final color = DubeTheme.balanceColor(c.utilizationRatio);
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFFE8E8E8), width: 0.5),
                      ),
                      child: ListTile(
                        onTap: () => context.go('/customers/${c.id}'),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        leading: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              c.name.isNotEmpty
                                  ? c.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        title: Text(
                          c.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(c.phone, style: DubeText.bodyMuted),
                        trailing: Text(
                          CurrencyFormatter.format(bal),
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 20),
                ],

                // ── Quick actions ───────────────────────────────
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.person_add_rounded,
                        label: 'Add Customer',
                        color: DubeTheme.primary,
                        onTap: () => context.go('/customers/add'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.bar_chart_rounded,
                        label: 'View Reports',
                        color: DubeTheme.info,
                        onTap: () => context.go('/reports'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
