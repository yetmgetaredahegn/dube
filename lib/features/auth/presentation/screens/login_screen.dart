import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dube/core/theme/app_theme.dart';
import 'package:dube/features/auth/providers/auth_notifier.dart';
import 'package:dube/routes/app_router.dart';
import 'package:dube/shared/widgets/loading_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(authNotifierProvider.notifier).clearError();

    final success = await ref.read(authNotifierProvider.notifier).signIn(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        );

    if (success && mounted) {
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Logo / Title ──────────────────────────────────
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: DubeTheme.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      size: 36,
                      color: DubeTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Welcome back',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in to manage your shop credit',
                    style: DubeText.bodyMuted,
                  ),
                  const SizedBox(height: 36),

                  // ── Error banner ──────────────────────────────────
                  if (authState.error != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: DubeTheme.dangerLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: DubeTheme.danger, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              authState.error!,
                              style: const TextStyle(
                                  color: DubeTheme.danger, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // ── Email field ───────────────────────────────────
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Email is required';
                      }
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // ── Password field ────────────────────────────────
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                            _obscure ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Password is required';
                      if (v.length < 6) return 'At least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // ── Submit ────────────────────────────────────────
                  LoadingButton(
                    label: 'Sign In',
                    isLoading: authState.isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 16),

                  // ── Register link ─────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account?"),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.register),
                        child: const Text('Register'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
