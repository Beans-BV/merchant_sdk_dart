import 'dart:convert';

import 'package:beans_merchant_sdk/beans_merchant_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';

import '../providers/company_accounts_provider.dart';
import '../providers/payment_provider.dart';
import '../providers/sdk_provider.dart';
import '../providers/stellar_currencies_provider.dart';

class PaymentsTab extends ConsumerStatefulWidget {
  const PaymentsTab({super.key});

  @override
  ConsumerState<PaymentsTab> createState() => _PaymentsTabState();
}

class _PaymentsTabState extends ConsumerState<PaymentsTab> {
  final _amountController = TextEditingController(text: '10.50');
  final _memoController = TextEditingController(text: 'Demo Payment');
  final _maxPaymentsController = TextEditingController(text: '1');
  final _webhookUrlController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _memoController.dispose();
    _maxPaymentsController.dispose();
    _webhookUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final currenciesState = ref.watch(stellarCurrenciesProvider);
    final accountsState = ref.watch(companyAccountsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Payment Configuration
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Configuration',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: currenciesState.selectedCurrencyId,
                    decoration:
                        const InputDecoration(labelText: 'Select Currency'),
                    items: currenciesState.currencies
                        .map((currency) => DropdownMenuItem(
                              value: currency.id,
                              child:
                                  Text('${currency.name} (${currency.code})'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        ref
                            .read(stellarCurrenciesProvider.notifier)
                            .selectCurrency(value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<CompanyAccount>(
                    initialValue: accountsState.selectedAccount,
                    decoration: const InputDecoration(
                        labelText: 'Select Destination Account'),
                    items: accountsState.accounts
                        .map((account) => DropdownMenuItem(
                              value: account,
                              child: Text(
                                  '${account.name['en']} (${account.stellarAccountId})'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      ref
                          .read(companyAccountsProvider.notifier)
                          .selectAccount(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    onChanged: (value) {
                      ref.read(paymentProvider.notifier).updateAmount(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _memoController,
                    decoration: const InputDecoration(labelText: 'Memo'),
                    onChanged: (value) {
                      ref.read(paymentProvider.notifier).updateMemo(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _maxPaymentsController,
                    decoration: const InputDecoration(
                        labelText: 'Max Allowed Payments (optional)'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      ref
                          .read(paymentProvider.notifier)
                          .updateMaxPayments(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _webhookUrlController,
                    decoration: const InputDecoration(
                        labelText: 'Webhook URL (optional)'),
                    onChanged: (value) {
                      ref
                          .read(paymentProvider.notifier)
                          .updateWebhookUrl(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Payment Generation Methods
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Payment Generation Methods',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (paymentState.error != null)
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
                                'Error: ${paymentState.error}',
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  kIsWeb
                      ? Row(
                          children: [
                            FilledButton.icon(
                              onPressed: paymentState.isGeneratingPayment
                                  ? null
                                  : () => _generateDeeplink(),
                              icon: paymentState.isGeneratingPayment
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.link),
                              label: const Text('Generate Deeplink'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              onPressed: paymentState.isGeneratingPayment
                                  ? null
                                  : () => _generateSvgQrCode(),
                              icon: paymentState.isGeneratingPayment
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.qr_code),
                              label: const Text('Generate SVG QR'),
                            ),
                            const SizedBox(width: 8),
                            FilledButton.icon(
                              onPressed: paymentState.isGeneratingPayment
                                  ? null
                                  : () => _generatePngQrCode(),
                              icon: paymentState.isGeneratingPayment
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.image),
                              label: const Text('Generate PNG QR'),
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: paymentState.isGeneratingPayment
                                    ? null
                                    : () => _generateDeeplink(),
                                icon: paymentState.isGeneratingPayment
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.link),
                                label: const Text('Generate Deeplink'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: paymentState.isGeneratingPayment
                                    ? null
                                    : () => _generateSvgQrCode(),
                                icon: paymentState.isGeneratingPayment
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.qr_code),
                                label: const Text('Generate SVG QR'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: paymentState.isGeneratingPayment
                                    ? null
                                    : () => _generatePngQrCode(),
                                icon: paymentState.isGeneratingPayment
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      )
                                    : const Icon(Icons.image),
                                label: const Text('Generate PNG QR'),
                              ),
                            ),
                          ],
                        ),
                ],
              ),
            ),
          ),
          if (paymentState.lastPaymentResponse != null) ...[
            const SizedBox(height: 16),
            PaymentResultCard(
              paymentResponse: paymentState.lastPaymentResponse!,
              isDark: isDark,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _generateDeeplink() async {
    final currenciesState = ref.read(stellarCurrenciesProvider);
    final config = ref.read(sdkConfigProvider);

    if (currenciesState.selectedCurrency == null) {
      _showSnackBar('Please select a currency first', isError: true);
      return;
    }

    try {
      await ref.read(paymentProvider.notifier).generateDeeplink(
            stellarAccountId: config.stellarAccountId,
            stellarCurrencyId: currenciesState.selectedCurrency!.id,
          );

      _showSnackBar('Deeplink generated successfully!');

      // Launch deeplink if not web
      if (!kIsWeb && ref.read(paymentProvider).lastPaymentResponse != null) {
        final deeplink = ref
            .read(paymentProvider)
            .lastPaymentResponse!['deeplink'] as String;
        await launchUrl(Uri.parse(deeplink));
      }
    } catch (e) {
      _showSnackBar('Failed to generate deeplink: $e', isError: true);
    }
  }

  Future<void> _generateSvgQrCode() async {
    final currenciesState = ref.read(stellarCurrenciesProvider);
    final config = ref.read(sdkConfigProvider);

    if (currenciesState.selectedCurrency == null) {
      _showSnackBar('Please select a currency first', isError: true);
      return;
    }

    try {
      await ref.read(paymentProvider.notifier).generateSvgQrCode(
            stellarAccountId: config.stellarAccountId,
            stellarCurrencyId: currenciesState.selectedCurrency!.id,
          );

      _showSnackBar('SVG QR Code generated successfully!');
    } catch (e) {
      _showSnackBar('Failed to generate SVG QR Code: $e', isError: true);
    }
  }

  Future<void> _generatePngQrCode() async {
    final currenciesState = ref.read(stellarCurrenciesProvider);
    final config = ref.read(sdkConfigProvider);

    if (currenciesState.selectedCurrency == null) {
      _showSnackBar('Please select a currency first', isError: true);
      return;
    }

    try {
      await ref.read(paymentProvider.notifier).generatePngQrCode(
            stellarAccountId: config.stellarAccountId,
            stellarCurrencyId: currenciesState.selectedCurrency!.id,
          );

      _showSnackBar('PNG QR Code generated successfully!');
    } catch (e) {
      _showSnackBar('Failed to generate PNG QR Code: $e', isError: true);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }
}

// Payment Result Card with Better Dark Theme Support
class PaymentResultCard extends StatelessWidget {
  const PaymentResultCard({
    super.key,
    required this.paymentResponse,
    required this.isDark,
  });

  final Map<String, dynamic> paymentResponse;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  'Payment Generated (${paymentResponse['type']})',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Better readable response container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[900] : Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.grey[700]! : Colors.grey[200]!,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Response Details:',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.grey[200] : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : Colors.grey[300]!,
                      ),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Text(
                        const JsonEncoder.withIndent('  ')
                            .convert(paymentResponse),
                        style: TextStyle(
                          fontFamily: 'monospace',
                          color: isDark ? Colors.green[300] : Colors.green[800],
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (paymentResponse['svgQrCode'] != null) ...[
              const SizedBox(height: 20),
              Text(
                'QR Code Preview:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[200] : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.string(
                      paymentResponse['svgQrCode'],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
            if (paymentResponse['pngQrCodeBase64'] != null) ...[
              const SizedBox(height: 20),
              Text(
                'PNG QR Code Preview:',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.grey[200] : Colors.grey[800],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? Colors.black.withValues(alpha: 0.3)
                            : Colors.grey.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.memory(
                      base64Decode(paymentResponse['pngQrCodeBase64']),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
