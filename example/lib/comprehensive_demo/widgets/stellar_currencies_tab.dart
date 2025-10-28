import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/sdk_provider.dart';
import '../providers/stellar_currencies_provider.dart';

class StellarCurrenciesTab extends ConsumerWidget {
  const StellarCurrenciesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currenciesState = ref.watch(stellarCurrenciesProvider);
    final config = ref.watch(sdkConfigProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Stellar Currencies',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: currenciesState.isLoading
                        ? null
                        : () => ref.read(stellarCurrenciesProvider.notifier)
                            .refresh(config.stellarAccountId),
                    icon: currenciesState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (currenciesState.error != null)
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Error: ${currenciesState.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (currenciesState.isLoading)
                const Center(child: CircularProgressIndicator())
              else if (currenciesState.currencies.isEmpty)
                const Text('No currencies loaded')
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: currenciesState.currencies.length,
                  itemBuilder: (context, index) {
                    final currency = currenciesState.currencies[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Text(
                            currency.code.substring(0, 1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(currency.name),
                        subtitle: Text('Code: ${currency.code}'),
                        trailing: Text(
                          currency.id,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
