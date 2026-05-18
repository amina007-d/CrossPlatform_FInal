import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../presentation/screens/dashboard/dashboard_screen.dart';
import '../../presentation/screens/expenses/expenses_screen.dart';
import '../../presentation/screens/expenses/add_expense_screen.dart';
import '../../presentation/screens/converter/converter_screen.dart';
import '../../presentation/screens/settings/settings_screen.dart';
import '../../presentation/screens/household/household_screen.dart';
import '../../presentation/screens/main_shell.dart';

part 'app_router.g.dart';

// Theme mode provider backed by SharedPreferences
final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.light);

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: false,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/expenses',
            name: 'expenses',
            builder: (context, state) => const ExpensesScreen(),
            routes: [
              GoRoute(
                path: 'add',
                name: 'add-expense',
                builder: (context, state) {
                  final extra = state.extra as Map<String, dynamic>?;
                  return AddExpenseScreen(editExpense: extra);
                },
              ),
            ],
          ),
          GoRoute(
            path: '/converter',
            name: 'converter',
            builder: (context, state) => const ConverterScreen(),
          ),
          GoRoute(
            path: '/household',
            name: 'household',
            builder: (context, state) => const HouseholdScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
}
