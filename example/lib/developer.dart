import 'dart:async';

import 'package:beans_merchant_sdk/beans_merchant_sdk.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'constants.dart';

class DeveloperScreen extends StatelessWidget {
  const DeveloperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Developer (advanced)'),
      ),
      body: const DeveloperPage(),
    );
  }
}

class DeveloperPage extends StatefulWidget {
  const DeveloperPage({super.key});

  @override
  State<DeveloperPage> createState() => _DeveloperPageState();
}

class _DeveloperPageState extends State<DeveloperPage> {
  late BeansMerchantSdk sdk;

  final apiKeyController = TextEditingController(
    text: Constants.beansApiKey,
  );
  final stellarAccountIdController = TextEditingController(
    text: Constants.beansStellarAccountId,
  );
  final amountController = TextEditingController();
  final memoController = TextEditingController();
  final maxAllowedPaymentsController = TextEditingController();
  final webhookUrlController = TextEditingController();
  final customEnvironmentController = TextEditingController();

  String selectedEnvironment = 'production';
  List<String> environments = [
    'staging',
    'production',
  ];

  List<DropdownMenuItem<String>>? stellarCurrenciesDropdownItems;
  String? selectedCurrency;

  String? successMessage;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _initSdk();
  }

  void _initSdk() {
    switch (selectedEnvironment) {
      case 'production':
        sdk = BeansMerchantSdk.production(
          apiKey: apiKeyController.text,
        );
        break;
      default:
        sdk = BeansMerchantSdk.staging(
          apiKey: apiKeyController.text,
        );
    }
    unawaited(
      _loadInitialData(),
    );
  }

  Future<void> _loadInitialData() async {
    if (apiKeyController.text.isEmpty ||
        stellarAccountIdController.text.isEmpty) {
      return;
    }
    errorMessage = '';
    setState(() {});

    try {
      final data = await sdk.fetchStellarCurrencies(
        stellarAccountIdController.text,
      );
      stellarCurrenciesDropdownItems = [
        for (final currency in data.stellarCurrencies)
          DropdownMenuItem<String>(
            value: currency.id,
            child: Text('${currency.name} (${currency.code})'),
          ),
      ];
      selectedCurrency = stellarCurrenciesDropdownItems?.first.value;
      setState(() {});
    } catch (e) {
      errorMessage = 'Error fetching stellar currencies: $e';
      setState(() {});
    }
  }

  Future<void> generateQrCode() async {
    final theme = Theme.of(context);

    errorMessage = '';
    setState(() {});

    try {
      final data = await sdk.generateSvgQrCode(
        stellarAccountIdController.text,
        selectedCurrency!,
        double.parse(amountController.text),
        memoController.text,
        maxAllowedPayments: maxAllowedPaymentsController.text.isEmpty
            ? null
            : int.parse(maxAllowedPaymentsController.text),
        webhookUrl: webhookUrlController.text.isEmpty
            ? null
            : webhookUrlController.text,
      );
      final svgString = data.svgQrCode
          .replaceAll('#FFFFFF', theme.colorScheme.surface.toString())
          .replaceAll('#000000', '#FFFFFF');
      showDialog(
        // ignore: use_build_context_synchronously
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('QR Code generated successfully'),
                SvgPicture.string(svgString),
              ],
            ),
          );
        },
      );
    } catch (error) {
      errorMessage = 'Error generating QR Code: $error';
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: 600,
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: ListView(
            children: [
              DropdownButtonFormField2(
                decoration: InputDecoration(
                  labelText: 'Select Environment',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                value: selectedEnvironment,
                items: [
                  for (final env in environments)
                    DropdownMenuItem<String>(
                      value: env,
                      child: Text(env),
                    ),
                ],
                onChanged: (_) {
                  apiKeyController.clear();
                  stellarAccountIdController.clear();
                  _loadInitialData();
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: apiKeyController,
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) {
                  stellarAccountIdController.clear();
                  _loadInitialData();
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: stellarAccountIdController,
                decoration: const InputDecoration(
                  labelText: 'Destination Stellar Account ID',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) {
                  _loadInitialData();
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField2<String>(
                decoration: InputDecoration(
                  labelText: 'Select Currency',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                value: selectedCurrency,
                items: stellarCurrenciesDropdownItems,
                onChanged: (value) {
                  selectedCurrency = value;
                  setState(() {});
                },
                hint: const Text('Select Currency'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: memoController,
                decoration: const InputDecoration(
                  labelText: 'Memo',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: maxAllowedPaymentsController,
                decoration: const InputDecoration(
                  labelText:
                      'Max allowed payments (optional) (unlimited is -1) (defaults is 1)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: webhookUrlController,
                decoration: const InputDecoration(
                  labelText: 'Webhook URL (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: generateQrCode,
                child: const Text('Generate QR Code'),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
