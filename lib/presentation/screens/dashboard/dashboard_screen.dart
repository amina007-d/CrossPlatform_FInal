import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final budgetAsync = ref.watch(budgetSettingsProvider);
    final monthlyTotalAsync = ref.watch(monthlyTotalProvider);
    final categoryTotalsAsync = ref.watch(categoryTotalsProvider);
    final recentExpenses = ref.watch(monthlyExpensesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Finance Tracker'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => context.pushNamed('add-expense'),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Budget Card
                budgetAsync.when(
                  data: (settings) => monthlyTotalAsync.when(
                    data: (total) => _BudgetCard(
                      spent: total,
                      limit: settings.monthlyLimit,
                      currency: settings.currency,
                    ),
                    loading: () => const _LoadingCard(),
                    error: (e, _) => _ErrorCard(message: e.toString()),
                  ),
                  loading: () => const _LoadingCard(),
                  error: (e, _) => _ErrorCard(message: e.toString()),
                ),
                const SizedBox(height: 16),

                // Category Chart
                categoryTotalsAsync.when(
                  data: (totals) => totals.isEmpty
                      ? const _EmptyChart()
                      : _CategoryChart(totals: totals),
                  loading: () => const _LoadingCard(height: 220),
                  error: (e, _) => _ErrorCard(message: e.toString()),
                ),
                const SizedBox(height: 16),

                // Recent Expenses Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Expenses',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/expenses'),
                      child: const Text('See all'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Recent Expenses List
                recentExpenses.when(
                  data: (expenses) {
                    final recent = expenses.take(5).toList();
                    if (recent.isEmpty) return const _EmptyExpenses();
                    return Column(
                      children: recent
                          .map((e) => _ExpenseTile(expense: e))
                          .toList(),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => _ErrorCard(message: e.toString()),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  final double spent;
  final double limit;
  final String currency;

  const _BudgetCard({
    required this.spent,
    required this.limit,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    final progress = limit > 0 ? (spent / limit).clamp(0.0, 1.0) : 0.0;
    final remaining = limit - spent;
    final isOverBudget = spent > limit;
    final color = isOverBudget
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Budget',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      CurrencyFormatter.format(spent, currency),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                    ),
                  ],
                ),
                CircleAvatar(
                  backgroundColor: color.withValues(alpha: 0.1),
                  radius: 28,
                  child: Icon(
                    isOverBudget
                        ? Icons.warning_rounded
                        : Icons.account_balance_wallet,
                    color: color,
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isOverBudget
                      ? 'Over by ${CurrencyFormatter.format(spent - limit, currency)}'
                      : '${CurrencyFormatter.format(remaining, currency)} remaining',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isOverBudget
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                      ),
                ),
                Text(
                  'of ${CurrencyFormatter.format(limit, currency)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoryChart extends StatelessWidget {
  final Map<String, double> totals;
  const _CategoryChart({required this.totals});

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFF03DAC6),
      const Color(0xFFFF6584),
      const Color(0xFFFFBE0B),
      const Color(0xFF3A86FF),
      const Color(0xFF8338EC),
      const Color(0xFFFF006E),
    ];

    final entries = totals.entries.toList();
    final total = totals.values.fold(0.0, (a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Spending by Category',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sections: entries.asMap().entries.map((entry) {
                          final i = entry.key;
                          final e = entry.value;
                          return PieChartSectionData(
                            value: e.value,
                            color: colors[i % colors.length],
                            title:
                                '${(e.value / total * 100).toStringAsFixed(0)}%',
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: entries.asMap().entries.map((entry) {
                      final i = entry.key;
                      final e = entry.value;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: colors[i % colors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${AppConstants.categoryEmojis[e.key] ?? ''} ${e.key.split(' ').first}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  final dynamic expense;
  const _ExpenseTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Text(
            AppConstants.categoryEmojis[expense.category] ?? '💰',
            style: const TextStyle(fontSize: 20),
          ),
        ),
        title: Text(
          expense.title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          '${expense.category} • ${DateFormatter.formatDate(expense.date)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Text(
          CurrencyFormatter.format(expense.amount, expense.currency),
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.error,
              ),
        ),
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  final double height;
  const _LoadingCard({this.height = 120});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: const Card(
          child: Center(child: CircularProgressIndicator()),
        ),
      );
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) => Card(
        color: Theme.of(context).colorScheme.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.error_outline,
                  color: Theme.of(context).colorScheme.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Error: $message',
                  style: TextStyle(
                      color:
                          Theme.of(context).colorScheme.onErrorContainer),
                ),
              ),
            ],
          ),
        ),
      );
}

class _EmptyChart extends StatelessWidget {
  const _EmptyChart();

  @override
  Widget build(BuildContext context) => const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Column(
              children: [
                Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text('No expenses this month',
                    style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ),
      );
}

class _EmptyExpenses extends StatelessWidget {
  const _EmptyExpenses();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text('No expenses yet. Add your first one!',
                  style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
}