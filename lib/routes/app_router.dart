import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dube/shared/providers/app_providers.dart';

// ── Screens ────────────────────────────────────────────────────────────────
import 'package:dube/features/auth/presentation/screens/login_screen.dart';
import 'package:dube/features/auth/presentation/screens/register_screen.dart';
import 'package:dube/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:dube/features/customers/presentation/screens/customers_list_screen.dart';
import 'package:dube/features/customers/presentation/screens/add_customer_screen.dart';
import 'package:dube/features/customers/presentation/screens/customer_detail_screen.dart';
import 'package:dube/features/transactions/presentation/screens/add_transaction_screen.dart';
import 'package:dube/features/reports/presentation/screens/reports_screen.dart';
import 'package:dube/features/settings/presentation/screens/settings_screen.dart';
import 'package:dube/shared/widgets/bottom_nav_shell.dart';

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
  static const String settings       = '/settings';

  static String customerDetailPath(String id) => '/customers/$id';
  static String addTransactionPath(String id) => '/customers/$id/transaction';
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
      // ── Auth routes (no bottom nav) ────────────────────────
      GoRoute(
        path: AppRoutes.login,
        builder: (ctx, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (ctx, state) => const RegisterScreen(),
      ),

      // ── Main shell with bottom navigation ──────────────────
      StatefulShellRoute.indexedStack(
        builder: (ctx, state, navigationShell) {
          return BottomNavShell(
            currentIndex: navigationShell.currentIndex,
            child: navigationShell,
            onTabChanged: (index) {
              navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              );
            },
          );
        },
        branches: [
          // Tab 0 — Dashboard
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.dashboard,
                builder: (ctx, state) => const DashboardScreen(),
              ),
            ],
          ),

          // Tab 1 — Customers
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.customers,
                builder: (ctx, state) => const CustomersListScreen(),
                routes: [
                  GoRoute(
                    path: 'add',
                    builder: (ctx, state) => const AddCustomerScreen(),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (ctx, state) {
                      final id = state.pathParameters['id']!;
                      return CustomerDetailScreen(customerId: id);
                    },
                    routes: [
                      GoRoute(
                        path: 'transaction',
                        builder: (ctx, state) {
                          final id = state.pathParameters['id']!;
                          return AddTransactionScreen(customerId: id);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),

          // Tab 2 — Reports
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.reports,
                builder: (ctx, state) => const ReportsScreen(),
              ),
            ],
          ),

          // Tab 3 — Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.settings,
                builder: (ctx, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
