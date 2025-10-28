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
  String? _lastAttemptedConfig;

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

    // Check for configuration validation errors
    final validationError = _validateConfiguration(config);

    // Auto-load data only when configuration changes and becomes valid
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentConfig =
          '${config.apiKey}|${config.stellarAccountId}|${config.customBaseUrl}|${config.useCustomSdk}';

      if (config.isConfigured &&
          validationError == null &&
          !currenciesState.isLoading &&
          !accountsState.isLoading &&
          _lastAttemptedConfig != currentConfig) {
        // Clear errors before attempting to load new data
        ref.read(stellarCurrenciesProvider.notifier).clearError();
        ref.read(companyAccountsProvider.notifier).clearError();
        _loadDataIfNeeded(ref, config);
        _lastAttemptedConfig = currentConfig;
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
              if (validationError != null)
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            validationError,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (currenciesState.error != null ||
                  accountsState.error != null)
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (currenciesState.error != null)
                                    Text(
                                      'Failed to load currencies: ${currenciesState.error}',
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  if (accountsState.error != null)
                                    Text(
                                      'Failed to load accounts: ${accountsState.error}',
                                      style: TextStyle(
                                        color: Colors.red.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              final currentConfig =
                                  '${config.apiKey}|${config.stellarAccountId}|${config.customBaseUrl}|${config.useCustomSdk}';
                              _loadDataIfNeeded(ref, config);
                              _lastAttemptedConfig = currentConfig;
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade100,
                              foregroundColor: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  void _loadDataIfNeeded(WidgetRef ref, SdkConfigState config) {
    final currenciesState = ref.read(stellarCurrenciesProvider);
    final accountsState = ref.read(companyAccountsProvider);

    // Always attempt to load if configuration is valid and not currently loading
    if (config.isConfigured &&
        !currenciesState.isLoading &&
        !accountsState.isLoading) {
      ref
          .read(stellarCurrenciesProvider.notifier)
          .loadCurrencies(config.stellarAccountId);
      ref.read(companyAccountsProvider.notifier).loadAccounts();
    }
  }

  /// Validates the SDK configuration and returns an error message if invalid
  String? _validateConfiguration(SdkConfigState config) {
    // Check if custom SDK is enabled but URL is empty
    if (config.useCustomSdk && config.customBaseUrl.isEmpty) {
      return 'Custom Base URL is required when using custom SDK';
    }

    // Check if custom SDK is enabled and URL is invalid
    if (config.useCustomSdk && config.customBaseUrl.isNotEmpty) {
      try {
        final uri = Uri.parse(config.customBaseUrl);
        if (!uri.hasScheme || (!uri.scheme.startsWith('http'))) {
          return 'Custom Base URL must be a valid HTTP/HTTPS URL';
        }
        if (!uri.hasAuthority) {
          return 'Custom Base URL must include a valid domain';
        }
      } catch (e) {
        return 'Custom Base URL format is invalid';
      }
    }

    // Check if API key is empty
    if (config.apiKey.isEmpty) {
      return 'API Key is required';
    }

    // Check if API key format is valid (basic validation for Beans format)
    if (config.apiKey.isNotEmpty) {
      // Basic validation: should be in format AAAA-BBBB-CCCC-DDDD
      final apiKeyPattern =
          RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$');
      if (!apiKeyPattern.hasMatch(config.apiKey)) {
        return 'API Key must be in format AAAA-BBBB-CCCC-DDDD';
      }
    }

    // Check if Stellar Account ID is empty
    if (config.stellarAccountId.isEmpty) {
      return 'Stellar Account ID is required';
    }

    // Check if Stellar Account ID format is valid (basic validation)
    if (config.stellarAccountId.isNotEmpty &&
        config.stellarAccountId.length != 56) {
      return 'Stellar Account ID must be exactly 56 characters long';
    }

    return null; // Configuration is valid
  }
}
