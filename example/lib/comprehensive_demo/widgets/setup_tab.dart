import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/company_accounts_provider.dart';
import '../providers/sdk_provider.dart';
import '../providers/stellar_currencies_provider.dart';

class SetupTab extends ConsumerStatefulWidget {
  const SetupTab({super.key});

  @override
  ConsumerState<SetupTab> createState() => _SetupTabState();
}

class _SetupTabState extends ConsumerState<SetupTab> {
  late final TextEditingController _apiKeyController;
  late final TextEditingController _stellarAccountIdController;
  late final TextEditingController _customBaseUrlController;

  @override
  void initState() {
    super.initState();
    _apiKeyController = TextEditingController();
    _stellarAccountIdController = TextEditingController();
    _customBaseUrlController = TextEditingController();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _stellarAccountIdController.dispose();
    _customBaseUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = ref.watch(sdkConfigProvider);
    final currenciesState = ref.watch(stellarCurrenciesProvider);
    final accountsState = ref.watch(companyAccountsProvider);

    // Update controllers when state changes
    if (_apiKeyController.text != config.apiKey) {
      _apiKeyController.text = config.apiKey;
    }
    if (_stellarAccountIdController.text != config.stellarAccountId) {
      _stellarAccountIdController.text = config.stellarAccountId;
    }
    if (_customBaseUrlController.text != config.customBaseUrl) {
      _customBaseUrlController.text = config.customBaseUrl;
    }

    // Auto-load data when configuration is complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (config.isConfigured &&
          !currenciesState.isLoading &&
          !accountsState.isLoading) {
        _loadDataIfNeeded(ref, config);
      }
    });

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SDK Configuration',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Use Custom SDK'),
                subtitle: const Text(
                    'Configure custom base URL instead of predefined environments'),
                value: config.useCustomSdk,
                onChanged: (value) {
                  ref.read(sdkConfigProvider.notifier).toggleCustomSdk(value);
                },
              ),
              const SizedBox(height: 16),
              if (config.useCustomSdk) ...[
                TextField(
                  controller: _customBaseUrlController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Base URL',
                    hintText: 'https://api.example.com',
                  ),
                  onChanged: (value) {
                    ref
                        .read(sdkConfigProvider.notifier)
                        .updateCustomBaseUrl(value);
                  },
                ),
                const SizedBox(height: 16),
              ] else ...[
                DropdownButtonFormField<String>(
                  initialValue: config.environment,
                  decoration: const InputDecoration(labelText: 'Environment'),
                  items: const [
                    DropdownMenuItem(value: 'staging', child: Text('Staging')),
                    DropdownMenuItem(
                        value: 'production', child: Text('Production')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref
                          .read(sdkConfigProvider.notifier)
                          .updateEnvironment(value);
                    }
                  },
                ),
                const SizedBox(height: 16),
              ],
              TextField(
                controller: _apiKeyController,
                decoration: const InputDecoration(labelText: 'API Key'),
                onChanged: (value) {
                  ref.read(sdkConfigProvider.notifier).updateApiKey(value);
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _stellarAccountIdController,
                decoration:
                    const InputDecoration(labelText: 'Stellar Account ID'),
                onChanged: (value) {
                  ref
                      .read(sdkConfigProvider.notifier)
                      .updateStellarAccountId(value);
                },
              ),
              const SizedBox(height: 16),
              // Status indicator
              if (currenciesState.isLoading || accountsState.isLoading)
                Card(
                  color: Colors.blue.shade50,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Loading currencies and accounts...',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (!config.isConfigured)
                Card(
                  color: Colors.orange.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.info, color: Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Please configure API Key and Stellar Account ID to load data.',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _loadDataIfNeeded(WidgetRef ref, SdkConfigState config) {
    final currenciesState = ref.read(stellarCurrenciesProvider);
    final accountsState = ref.read(companyAccountsProvider);

    // Only load if we have data and it's not already loading
    if (config.isConfigured &&
        !currenciesState.isLoading &&
        !accountsState.isLoading &&
        currenciesState.currencies.isEmpty &&
        accountsState.accounts.isEmpty) {
      ref
          .read(stellarCurrenciesProvider.notifier)
          .loadCurrencies(config.stellarAccountId);
      ref.read(companyAccountsProvider.notifier).loadAccounts();
    }
  }
}
