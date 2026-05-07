import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dube/core/theme/app_theme.dart';
import 'package:dube/core/utils/currency_formatter.dart';
import 'package:dube/shared/providers/app_providers.dart';
import 'package:dube/shared/widgets/loading_button.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  final String customerId;

  const AddTransactionScreen({super.key, required this.customerId});

  @override
  ConsumerState<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  bool _isCredit = true; // true = credit, false = payment
  bool _isLoading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = ref.read(currentUidProvider);
    if (uid == null) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountCtrl.text.trim());
      final note =
          _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();
      final ledger = ref.read(ledgerServiceProvider);

      if (_isCredit) {
        await ledger.addCredit(
          uid: uid,
          customerId: widget.customerId,
          amount: amount,
          note: note,
        );
      } else {
        await ledger.addPayment(
          uid: uid,
          customerId: widget.customerId,
          amount: amount,
          note: note,
        );
      }

      // Refresh the transaction list
      ref
          .read(transactionNotifierProvider(
            (uid: uid, customerId: widget.customerId),
          ).notifier)
          .refresh();

      // Refresh the customer balances
      ref.invalidate(customersWithBalancesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isCredit ? 'Credit added' : 'Payment recorded'),
            backgroundColor: DubeTheme.primary,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        final msg = e.toString().contains('Credit limit exceeded')
            ? 'Credit limit exceeded! Cannot add more credit.'
            : 'Error: $e';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(msg),
            backgroundColor: DubeTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersWithBalancesProvider);

    // Get current customer balance for display
    final customerData = customersAsync.valueOrNull
        ?.where((c) => c.id == widget.customerId)
        .firstOrNull;
    final balance = customerData?.balance ?? 0;
    final limit = customerData?.creditLimit ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isCredit ? 'Add Credit' : 'Record Payment'),
      ),
      body: SingleChildScrollView(
        padding: DubeSpacing.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ── Type toggle ───────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isCredit = true),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color:
                                _isCredit ? DubeTheme.danger : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Credit',
                              style: TextStyle(
                                color:
                                    _isCredit ? Colors.white : const Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isCredit = false),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: !_isCredit
                                ? DubeTheme.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Payment',
                              style: TextStyle(
                                color: !_isCredit
                                    ? Colors.white
                                    : const Color(0xFF6B7280),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Current balance info ──────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isCredit ? DubeTheme.dangerLight : DubeTheme.primaryLight,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Balance',
                          style: DubeText.label
                              .copyWith(color: const Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.format(balance),
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Credit Limit',
                          style: DubeText.label
                              .copyWith(color: const Color(0xFF6B7280)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          CurrencyFormatter.format(limit),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Amount ────────────────────────────────────────
              TextFormField(
                controller: _amountCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w700),
                decoration: const InputDecoration(
                  labelText: 'Amount (ETB)',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Required';
                  final parsed = double.tryParse(v.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              // ── Note ──────────────────────────────────────────
              TextFormField(
                controller: _noteCtrl,
                textInputAction: TextInputAction.done,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  prefixIcon: Icon(Icons.note_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 28),

              // ── Submit ────────────────────────────────────────
              LoadingButton(
                label: _isCredit ? 'Add Credit' : 'Record Payment',
                isLoading: _isLoading,
                onPressed: _submit,
                icon: _isCredit
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
