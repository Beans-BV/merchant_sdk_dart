import 'dart:async';
import 'dart:developer';

import 'package:beans_merchant_sdk/beans_merchant_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

import 'color_extensions.dart';
import 'constants.dart';

const books = [
  Books(
    name: 'Blockchain Basics',
    description: 'A Non-Technical Introduction in 25 Steps',
    authorName: 'Daniel Drescher',
    senderName: 'Eko Ebooks',
    price: 32500,
    imageAsset: 'assets/images/books/blockchain_basics.jpg',
  ),
];
final ngnNumberFormat = NumberFormat.currency(
  symbol: '₦',
  decimalDigits: 0,
);

final totalAmount = books.fold(
  .0,
  (value, e) => value + e.price,
);
final orderId = '00${DateTime.now().millisecondsSinceEpoch}';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            _EkoEbooksLogo(
              size: DefaultTextStyle.of(context).style.fontSize! * 2,
            ),
            const SizedBox(
              width: 16,
            ),
            const Text('EkoEbooks'),
          ],
        ),
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Badge(
              label: const Text('1'),
              child: IconButton(
                icon: const Icon(Icons.shopping_cart_rounded),
                onPressed: () {
                  log('Shopping cart pressed');
                },
              ),
            ),
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: CheckoutPage(),
      ),
    );
  }
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage>
    with SingleTickerProviderStateMixin {
  late final BeansMerchantSdk merchantSdk;
  late final TabController tabController;
  late final TextEditingController amountController;
  late final String orderId;

  @override
  void initState() {
    merchantSdk = BeansMerchantSdk.production(
      apiKey: Constants.ekoEbooksApiKey,
    );
    tabController = TabController(
      length: 4,
      vsync: this,
    );
    amountController = TextEditingController();
    orderId = '00${DateTime.now().millisecondsSinceEpoch}';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: TabBarView(
        controller: tabController,
        children: [
          _ShoppingBasketSubPage(
            goNext: () => tabController.animateTo(1),
          ),
          _AdditionalInformationSubPage(
            goNext: () => tabController.animateTo(2),
          ),
          _PaymentSubPage(
            tabController: tabController,
            goNext: () => tabController.animateTo(3),
          ),
          const _PaymentCompletedSubPage(),
        ],
      ),
    );
  }
}

class _ShoppingBasketSubPage extends StatelessWidget {
  const _ShoppingBasketSubPage({
    required this.goNext,
  });

  final VoidCallback goNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    final subtotalText = Text.rich(
      style: textTheme.bodyLarge,
      TextSpan(
        children: [
          TextSpan(
            text: 'Subtotal (${books.length} items): ',
          ),
          TextSpan(
            text: ngnNumberFormat.format(totalAmount),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(flex: 6),
        Expanded(
          flex: 66,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Shopping Basket',
                      style: textTheme.titleLarge,
                    ),
                    for (final product in books) ...[
                      const Divider(
                        height: 32,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: const ShapeDecoration(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8),
                                ),
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Image.asset(
                              product.imageAsset,
                              width: 128,
                              height: 128,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(
                            width: 16,
                          ),
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: product.name,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const TextSpan(
                                              text: ': ',
                                            ),
                                            TextSpan(
                                              text: product.description,
                                              style: textTheme.bodyLarge,
                                            ),
                                            TextSpan(
                                              text: ' (e-book)',
                                              style: textTheme.bodyLarge,
                                            ),
                                          ],
                                        ),
                                        style: textTheme.bodyLarge!,
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        'In stock',
                                        style: textTheme.bodySmall!.copyWith(
                                          color: Colors.green,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text.rich(
                                        // 'Sent from: ${product.senderName}',
                                        style: textTheme.bodySmall,
                                        TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: 'Sent from: ',
                                            ),
                                            TextSpan(
                                              text: product.senderName,
                                              style: const TextStyle(
                                                color: Colors.blueAccent,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Text(
                                        'Gift options not available',
                                        style: textTheme.bodySmall!,
                                      ),
                                      const SizedBox(
                                        height: 4,
                                      ),
                                      Row(
                                        children: [
                                          Text(
                                            'Quantity: 1',
                                            style: textTheme.bodySmall!,
                                          ),
                                          const VerticalDivider(
                                            width: 16,
                                          ),
                                          Text(
                                            'Edit',
                                            style:
                                                textTheme.bodySmall!.copyWith(
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                          const VerticalDivider(
                                            width: 16,
                                          ),
                                          Text(
                                            'Delete',
                                            style:
                                                textTheme.bodySmall!.copyWith(
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                          const VerticalDivider(
                                            width: 16,
                                          ),
                                          Text(
                                            'Share',
                                            style:
                                                textTheme.bodySmall!.copyWith(
                                              color: Colors.blueAccent,
                                            ),
                                          ),
                                          const Spacer(),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 16,
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      ngnNumberFormat.format(product.price),
                                      style: textTheme.bodyLarge!.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 8,
                                    ),
                                    Text(
                                      '(${ngnNumberFormat.format(product.price)} / peice)',
                                      style: textTheme.bodySmall!,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                    const Divider(
                      height: 32,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: subtotalText,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Spacer(flex: 1),
        Expanded(
          flex: 24,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    subtotalText,
                    const SizedBox(
                      height: 4,
                    ),
                    Text(
                      'Free shipping',
                      style: textTheme.bodySmall,
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: goNext,
                        child: const Text('Proceed to Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Spacer(flex: 6),
      ],
    );
  }
}

class _AdditionalInformationSubPage extends StatelessWidget {
  const _AdditionalInformationSubPage({
    required this.goNext,
  });

  final VoidCallback goNext;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Spacer(flex: 6),
        Expanded(
          flex: 66,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '1 Personal information',
                  style: textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 4,
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Full name',
                            ),
                            initialValue: 'Adebayo Okafor',
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                            initialValue: 'adebayo@okafor.ng',
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Phone number',
                            ),
                            initialValue: '0812 345 6789',
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Address',
                            ),
                            initialValue: '123 Victoria Island Road',
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'City',
                            ),
                            initialValue: 'Lagos',
                          ),
                          const SizedBox(
                            height: 4,
                          ),
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Zip code',
                            ),
                            initialValue: '101233',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(
                  height: 32,
                ),
                Text(
                  '2 Choose a delivery address',
                  style: textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 4,
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Checkbox(
                                value: true,
                                onChanged: (value) {},
                              ),
                              const Text('Same as personal address'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const Divider(
                  height: 32,
                ),
                Text(
                  '3 Payment method',
                  style: textTheme.titleLarge,
                ),
                const SizedBox(
                  height: 4,
                ),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: RadioGroup(
                        groupValue: 'beans',
                        onChanged: (value) {},
                        child: const Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ListTile(
                              title: Text('Beans App'),
                              subtitle: Text(
                                'Pay with your preferred currency. Free of charge.',
                              ),
                              leading: Radio(
                                value: 'beans',
                              ),
                            ),
                            ListTile(
                              title: Text('iDEAL'),
                              leading: Radio(
                                value: 'ideal',
                              ),
                            ),
                            ListTile(
                              title: Text('Credit Card'),
                              leading: Radio(
                                value: 'credit_card',
                              ),
                            ),
                            ListTile(
                              title: Text('Monthly invoice'),
                              subtitle: Text(
                                'Pay within 14 days of receiving invoice. Free of charge with timely payment.',
                              ),
                              leading: Radio(
                                value: 'monthly_invoice',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(flex: 1),
        Expanded(
          flex: 24,
          child: Card(
            margin: const EdgeInsets.only(top: 36),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: goNext,
                        child: const Text('Buy now'),
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Text.rich(
                      const TextSpan(
                        children: [
                          TextSpan(
                            text:
                                'By placing your order you agree to EkoEbooks\'s ',
                          ),
                          TextSpan(
                            text: 'Conditions of Use & Sale',
                            style: TextStyle(
                              color: Colors.blueAccent,
                            ),
                          ),
                          TextSpan(
                            text: '. Please see our ',
                          ),
                          TextSpan(
                            text: 'Privacy Notice',
                            style: TextStyle(
                              color: Colors.blueAccent,
                            ),
                          ),
                          TextSpan(
                            text: ', our ',
                          ),
                          TextSpan(
                            text: 'Cookies Notice',
                            style: TextStyle(
                              color: Colors.blueAccent,
                            ),
                          ),
                          TextSpan(
                            text: ' and our ',
                          ),
                          TextSpan(
                            text: 'Interest-Based Ads Notice',
                            style: TextStyle(
                              color: Colors.blueAccent,
                            ),
                          ),
                          TextSpan(
                            text: '.',
                          ),
                        ],
                      ),
                      style: textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const Divider(
                      height: 16,
                    ),
                    Text(
                      'Order Summary',
                      style: textTheme.bodyLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 12,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Items:',
                            style: textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          ngnNumberFormat.format(totalAmount),
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Postage & packaging:',
                            style: textTheme.bodySmall,
                          ),
                        ),
                        Text(
                          '₦0.00',
                          style: textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const Divider(
                      height: 16,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Order Total:',
                            style: textTheme.bodyLarge!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          ngnNumberFormat.format(totalAmount),
                          style: textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Spacer(flex: 6),
      ],
    );
  }
}

class _PaymentSubPage extends StatefulWidget {
  const _PaymentSubPage({
    required this.tabController,
    required this.goNext,
  });

  final TabController tabController;
  final VoidCallback goNext;

  @override
  State<_PaymentSubPage> createState() => _PaymentSubPageState();
}

class _PaymentSubPageState extends State<_PaymentSubPage> {
  late final BeansMerchantSdk merchantSdk;

  String? svgString;
  Timer? timer;

  @override
  void initState() {
    merchantSdk = BeansMerchantSdk.production(
      apiKey: Constants.ekoEbooksApiKey,
    );
    widget.tabController.addListener(listener);
    listener();
    super.initState();
  }

  @override
  void dispose() {
    widget.tabController.removeListener(listener);
    super.dispose();
  }

  Future<void> listener() async {
    if (widget.tabController.index != 2) {
      return;
    }
    final response = await merchantSdk.generateSvgQrCode(
      Constants.ekoEbooksStellarAccountId,
      Constants.ngnStellarCurrencyId,
      totalAmount,
      orderId,
    );
    if (!mounted) {
      return;
    }
    final surfaceContainer = Theme.of(context).colorScheme.surfaceContainerLow;

    svgString = response.svgQrCode
        .replaceAll('#FFFFFF', surfaceContainer.toHexString())
        .replaceAll('#000000', '#FFFFFF');
    setState(() {});

    timer = Timer.periodic(
      const Duration(seconds: 22),
      (timer) async {
        timer.cancel();
        widget.goNext();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 600,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(
              height: 64,
            ),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Pay with Beans App ',
                  ),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Builder(
                      builder: (context) {
                        final size = textTheme.titleLarge!.fontSize! * 1.5;
                        return Image.asset(
                          'assets/images/logos/beans_logo.png',
                          width: size,
                          height: size,
                        );
                      },
                    ),
                  ),
                ],
              ),
              style: textTheme.titleLarge,
            ),
            const SizedBox(
              height: 64,
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'To',
                          style: textTheme.bodyMedium!,
                        ),
                        Text(
                          'Amount',
                          style: textTheme.bodyMedium!,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'EkoEbooks Payments United States',
                          style: textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          ngnNumberFormat.format(totalAmount),
                          style: textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: Text(orderId),
                    ),
                    const Divider(
                      height: 16,
                    ),
                    const SizedBox(
                      height: 32,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 32,
                      ),
                      child: SizedBox.square(
                        dimension: 256,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: svgString != null
                              ? GestureDetector(
                                  onTap: () {
                                    timer?.cancel();
                                    widget.goNext();
                                  },
                                  child: SvgPicture.string(
                                    svgString!,
                                  ),
                                )
                              : const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    Text(
                      'Scan the QR code to pay with Beans App',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(
                      height: 32,
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

class _PaymentCompletedSubPage extends StatelessWidget {
  const _PaymentCompletedSubPage();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.topCenter,
      child: SizedBox(
        width: 600,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Payment received',
                  style: theme.textTheme.titleLarge!.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Text(
                  'Thank you for your purchase!',
                  style: theme.textTheme.bodyLarge,
                ),
                const SizedBox(
                  height: 16,
                ),
                const Icon(
                  Icons.check_circle_rounded,
                  size: 128,
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EkoEbooksLogo extends StatelessWidget {
  const _EkoEbooksLogo({
    required this.size,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: const ShapeDecoration(
        shape: CircleBorder(),
      ),
      child: Image.asset(
        'assets/images/logos/eko_ebooks_logo.jpg',
        width: size,
        height: size,
      ),
    );
  }
}

class Books {
  const Books({
    required this.name,
    required this.description,
    required this.authorName,
    required this.senderName,
    required this.price,
    required this.imageAsset,
  });

  final String name;
  final String description;
  final String authorName;
  final String senderName;
  final double price;
  final String imageAsset;
}
