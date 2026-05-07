import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dube/core/theme/app_theme.dart';
import 'package:dube/features/auth/providers/auth_notifier.dart';
import 'package:dube/routes/app_router.dart';
import 'package:dube/shared/widgets/loading_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    ref.read(authNotifierProvider.notifier).clearError();

    final success = await ref.read(authNotifierProvider.notifier).signUp(
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
          shopName: _shopNameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
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
                  // ── Header ────────────────────────────────────────
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: DubeTheme.primaryLight,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.storefront_rounded,
                      size: 36,
                      color: DubeTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Create your account',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Set up your shop in under a minute',
                    style: DubeText.bodyMuted,
                  ),
                  const SizedBox(height: 32),

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

                  // ── Shop name ─────────────────────────────────────
                  TextFormField(
                    controller: _shopNameCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Shop Name',
                      prefixIcon: Icon(Icons.store_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),

                  // ── Phone ─────────────────────────────────────────
                  TextFormField(
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),

                  // ── Email ─────────────────────────────────────────
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (!v.contains('@')) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // ── Password ──────────────────────────────────────
                  TextFormField(
                    controller: _passwordCtrl,
                    obscureText: _obscure,
                    textInputAction: TextInputAction.next,
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
                      if (v == null || v.isEmpty) return 'Required';
                      if (v.length < 6) return 'At least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // ── Confirm password ──────────────────────────────
                  TextFormField(
                    controller: _confirmCtrl,
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                    validator: (v) {
                      if (v != _passwordCtrl.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),

                  // ── Submit ────────────────────────────────────────
                  LoadingButton(
                    label: 'Create Account',
                    isLoading: authState.isLoading,
                    onPressed: _submit,
                  ),
                  const SizedBox(height: 16),

                  // ── Login link ────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Already have an account?'),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.login),
                        child: const Text('Sign In'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
