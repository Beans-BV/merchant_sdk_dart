import 'dart:developer';

import 'package:beans_merchant_sdk/beans_merchant_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';

import 'constants.dart';

class DepositScreen extends StatelessWidget {
  const DepositScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UnaSwap'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          // max width for web is 600
          constraints: const BoxConstraints(
            maxWidth: kIsWeb ? 384 : double.infinity,
          ),
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: DepositPage(),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_list),
            label: 'Filter',
          ),
        ],
      ),
    );
  }
}

class DepositPage extends StatefulWidget {
  const DepositPage({super.key});

  @override
  State<DepositPage> createState() => _DepositPageState();
}

class _DepositPageState extends State<DepositPage>
    with SingleTickerProviderStateMixin {
  late final BeansMerchantSdk merchantSdk;
  late final TabController tabBarController;
  late final TextEditingController amountController;
  late final String depositId;

  @override
  void initState() {
    merchantSdk = BeansMerchantSdk.production(
      apiKey: Constants.unaSwapApiKey,
    );
    tabBarController = TabController(
      length: 3,
      vsync: this,
    );
    amountController = TextEditingController();
    depositId = 'D00${DateTime.now().millisecondsSinceEpoch}';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TabBarView(
        controller: tabBarController,
        children: [
          _DepositSubPage(
            amountController: amountController,
            goNext: () => tabBarController.animateTo(1),
          ),
          _PaymentProviderSubPage(
            merchantSdk: merchantSdk,
            amountController: amountController,
            depositId: depositId,
            goNext: () => tabBarController.animateTo(2),
          ),
          _DepositCompletedSubPage(
            depositId: depositId,
          ),
        ],
      ),
    );
  }
}

class _DepositSubPage extends StatefulWidget {
  const _DepositSubPage({
    required this.amountController,
    required this.goNext,
  });

  final TextEditingController amountController;
  final VoidCallback goNext;

  @override
  State<_DepositSubPage> createState() => _DepositSubPageState();
}

class _DepositSubPageState extends State<_DepositSubPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const _UnaSwapLogo(),
        const SizedBox(
          height: 32,
        ),
        TextField(
          controller: widget.amountController,
          decoration: const InputDecoration(
            labelText: 'Amount',
            suffixText: Constants.xlmStellarCurrencyCode,
            border: OutlineInputBorder(),
          ),
          keyboardType: const TextInputType.numberWithOptions(
            signed: false,
            decimal: true,
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
            TextInputFormatter.withFunction((oldValue, newValue) {
              return newValue.copyWith(
                text: newValue.text.replaceAll(',', '.'),
              );
            }),
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          autofocus: true,
        ),
        const SizedBox(
          height: 16,
        ),
        ElevatedButton(
          child: const Text('Continue'),
          onPressed: () async {
            final amount = double.tryParse(
              widget.amountController.text,
            );
            if (amount == null) {
              return;
            }
            FocusManager.instance.primaryFocus?.unfocus();
            setState(() {});
            widget.goNext();
          },
        ),
      ],
    );
  }
}

class _PaymentProviderSubPage extends StatefulWidget {
  const _PaymentProviderSubPage({
    required this.merchantSdk,
    required this.amountController,
    required this.depositId,
    required this.goNext,
  });

  final BeansMerchantSdk merchantSdk;
  final TextEditingController amountController;
  final String depositId;
  final VoidCallback goNext;

  @override
  State<_PaymentProviderSubPage> createState() =>
      _PaymentProviderSubPageState();
}

// app lifecycle
class _PaymentProviderSubPageState extends State<_PaymentProviderSubPage> {
  static const beansPaymentProvider = 'beans';

  bool isProcessing = false;

  String? selectedPaymentProvider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const _UnaSwapLogo(),
        const SizedBox(
          height: 32,
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            return DropdownMenu(
              hintText: 'Select payment provider',
              width: constraints.maxWidth,
              dropdownMenuEntries: const [
                DropdownMenuEntry(
                  label: 'Credit Card',
                  value: 'credit_card',
                ),
                DropdownMenuEntry(
                  label: 'Bank Transfer',
                  value: 'bank_transfer',
                ),
                DropdownMenuEntry(
                  label: 'Beans App',
                  value: beansPaymentProvider,
                ),
              ],
              onSelected: (value) {
                selectedPaymentProvider = value;
                setState(() {});
              },
            );
          },
        ),
        const SizedBox(
          height: 16,
        ),
        AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: selectedPaymentProvider != null ? 1 : 0,
          child: ElevatedButton(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isProcessing) ...[
                  SizedBox.square(
                    dimension: DefaultTextStyle.of(context).style.fontSize!,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                const Text('Continue'),
              ],
            ),
            onPressed: () async {
              if (selectedPaymentProvider != beansPaymentProvider) {
                return;
              }
              isProcessing = true;
              setState(() {});

              final response = await widget.merchantSdk.generateSvgQrCode(
                Constants.unaSwapStellarAccountId,
                Constants.xlmStellarCurrencyId,
                double.parse(widget.amountController.text),
                widget.depositId,
              );
              if (kIsWeb) {
                final svgString = response.svgQrCode
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
                          SvgPicture.string(svgString),
                          const SizedBox(
                            height: 16,
                          ),
                          const Text(
                            'Scan the QR to open Beans App',
                          ),
                        ],
                      ),
                    );
                  },
                );
                // Go next in 12 seconds
                await Future.delayed(const Duration(seconds: 17));
                if (context.mounted) {
                  Navigator.of(context).pop();
                }
              } else {
                log('Opening: ${response.deeplink}');
                await launchUrl(
                  Uri.parse(response.deeplink),
                  mode: LaunchMode.externalApplication,
                );
              }
              isProcessing = false;
              setState(() {});
              widget.goNext();
            },
          ),
        ),
      ],
    );
  }
}

class _DepositCompletedSubPage extends StatelessWidget {
  const _DepositCompletedSubPage({
    required this.depositId,
  });

  final String depositId;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const _UnaSwapLogo(),
        const SizedBox(
          height: 32,
        ),
        Text(
          'Deposit completed',
          style: TextStyle(
            fontSize: DefaultTextStyle.of(context).style.fontSize! * 1.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        Text(
          'ID: $depositId',
          style: const TextStyle(
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}

class _UnaSwapLogo extends StatelessWidget {
  const _UnaSwapLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        color: Colors.orange,
        shape: CircleBorder(),
      ),
      child: Image.asset(
        'assets/images/logos/una_swap_logo.png',
        width: 128,
        height: 128,
      ),
    );
  }
}
