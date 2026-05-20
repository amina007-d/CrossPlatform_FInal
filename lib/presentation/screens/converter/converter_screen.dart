import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/formatters.dart';
import '../../providers/providers.dart';

class ConverterScreen extends ConsumerStatefulWidget {
  const ConverterScreen({super.key});

  @override
  ConsumerState<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends ConsumerState<ConverterScreen> {
  final _amountCtrl = TextEditingController(text: '1');

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  void _swapCurrencies() {
    final from = ref.read(selectedFromCurrencyProvider);
    final to = ref.read(selectedToCurrencyProvider);
    ref.read(selectedFromCurrencyProvider.notifier).state = to;
    ref.read(selectedToCurrencyProvider.notifier).state = from;
    _refresh();
  }

  void _refresh() {
    final from = ref.read(selectedFromCurrencyProvider);
    ref.invalidate(currencyRatesProvider(from));
    ref.invalidate(conversionResultProvider);
  }

  @override
  Widget build(BuildContext context) {
    final from = ref.watch(selectedFromCurrencyProvider);
    final to = ref.watch(selectedToCurrencyProvider);
    final amount = ref.watch(conversionAmountProvider);
    final resultAsync = ref.watch(conversionResultProvider);
    final ratesAsync = ref.watch(currencyRatesProvider(from));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
            tooltip: 'Refresh rates',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Amount Input
                    TextField(
                      controller: _amountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: Theme.of(context).textTheme.headlineMedium,
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        final parsed = double.tryParse(v);
                        if (parsed != null && parsed > 0) {
                          ref.read(conversionAmountProvider.notifier).state = parsed;
                          ref.invalidate(conversionResultProvider);
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    // From
                    DropdownButtonFormField<String>(
                      value: from,
                      decoration: const InputDecoration(
                        labelText: 'From',
                        border: OutlineInputBorder(),
                      ),
                      items: AppConstants.currencies
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) {
                        ref.read(selectedFromCurrencyProvider.notifier).state = v!;
                        _refresh();
                      },
                    ),
                    const SizedBox(height: 12),

                    IconButton.filled(
                      onPressed: _swapCurrencies,
                      icon: const Icon(Icons.swap_vert),
                    ),
                    const SizedBox(height: 12),

                    // To
                    DropdownButtonFormField<String>(
                      value: to,
                      decoration: const InputDecoration(
                        labelText: 'To',
                        border: OutlineInputBorder(),
                      ),
                      items: AppConstants.currencies
                          .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                          .toList(),
                      onChanged: (v) {
                        ref.read(selectedToCurrencyProvider.notifier).state = v!;
                        ref.invalidate(conversionResultProvider);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Result
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: resultAsync.when(
                        data: (result) => Column(
                          children: [
                            Text('$amount $from =',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 8),
                            Text(
                              CurrencyFormatter.format(result, to),
                              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  ),
                            ),
                          ],
                        ),
                        loading: () => const Center(child: CircularProgressIndicator()),
                        error: (e, _) => Column(
                          children: [
                            const Icon(Icons.wifi_off, size: 32, color: Colors.red),
                            const SizedBox(height: 8),
                            Text(
                              'Error: $e',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _refresh,
                              icon: const Icon(Icons.refresh, size: 16),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // All rates
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Rates vs $from',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ratesAsync.when(
                      data: (rates) => GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: rates.length,
                        itemBuilder: (context, index) {
                          final entry = rates.entries.elementAt(index);
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(entry.key,
                                    style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(entry.value.toStringAsFixed(4),
                                    style: Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          );
                        },
                      ),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, _) => Column(
                        children: [
                          Text('Error: $e', style: const TextStyle(fontSize: 12)),
                          ElevatedButton.icon(
                            onPressed: _refresh,
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}