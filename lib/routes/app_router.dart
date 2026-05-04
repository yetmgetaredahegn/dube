import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dube/shared/providers/app_providers.dart';

// ── Route paths ────────────────────────────────────────────────────────────

class AppRoutes {
  AppRoutes._();

  static const String login          = '/login';
  static const String register       = '/register';
  static const String dashboard      = '/dashboard';
  static const String customers      = '/customers';
  static const String addCustomer    = '/customers/add';
  static const String customerDetail = '/customers/:id';
  static const String addTransaction = '/customers/:id/transaction';
  static const String reports        = '/reports';

  static String customerDetailPath(String id) => '/customers/$id';
  static String addTransactionPath(String id)  => '/customers/$id/transaction';
}

// ── Router provider ────────────────────────────────────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) {
      final isLoggedIn = authState.valueOrNull != null;
      final isAuthRoute =
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      if (!isLoggedIn && !isAuthRoute) return AppRoutes.login;
      if (isLoggedIn  &&  isAuthRoute) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      GoRoute(
        path:    AppRoutes.login,
        builder: (ctx, state) => const _Placeholder('Login'),
      ),
      GoRoute(
        path:    AppRoutes.register,
        builder: (ctx, state) => const _Placeholder('Register'),
      ),
      GoRoute(
        path:    AppRoutes.dashboard,
        builder: (ctx, state) => const _Placeholder('Dashboard'),
      ),
      GoRoute(
        path:    AppRoutes.customers,
        builder: (ctx, state) => const _Placeholder('Customers'),
      ),
      GoRoute(
        path:    AppRoutes.addCustomer,
        builder: (ctx, state) => const _Placeholder('Add Customer'),
      ),
      GoRoute(
        path:    AppRoutes.customerDetail,
        builder: (ctx, state) {
          final id = state.pathParameters['id']!;
          return _Placeholder('Customer $id');
        },
      ),
      GoRoute(
        path:    AppRoutes.addTransaction,
        builder: (ctx, state) {
          final id = state.pathParameters['id']!;
          return _Placeholder('Transaction for $id');
        },
      ),
      GoRoute(
        path:    AppRoutes.reports,
        builder: (ctx, state) => const _Placeholder('Reports'),
      ),
    ],
  );
});

// Placeholder screen — replace each one as you build the real screen
class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder(this.title);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text('$title — coming soon')),
      );
}
