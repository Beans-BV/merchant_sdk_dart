import 'package:example/account.dart';
import 'package:example/developer.dart';
import 'package:example/theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'checkout.dart';
import 'deposit.dart';

void main() {
  runApp(
    MaterialApp(
      title: 'Beans Merchant SDK examples',
      darkTheme: darkTheme,
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Merchant SDK examples'),
      ),
      body: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    const spacer = SizedBox(
      height: 16,
    );
    return SizedBox(
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (kIsWeb) ...[
            FilledButton.tonal(
              child: const Text('Checkout'),
              onPressed: () {
                final navigator = Navigator.of(context);
                navigator.push(
                  MaterialPageRoute(
                    builder: (context) => const CheckoutScreen(),
                  ),
                );
              },
            ),
            spacer,
          ],
          FilledButton.tonal(
            child: const Text('Deposit'),
            onPressed: () {
              final navigator = Navigator.of(context);
              navigator.push(
                MaterialPageRoute(
                  builder: (context) => const DepositScreen(),
                ),
              );
            },
          ),
          spacer,
          FilledButton.tonal(
            child: const Text('Account management'),
            onPressed: () {
              final navigator = Navigator.of(context);
              navigator.push(
                MaterialPageRoute(
                  builder: (context) => const AccountScreen(),
                ),
              );
            },
          ),
          spacer,
          FilledButton.tonal(
            child: const Text('Advanced (for developers)'),
            onPressed: () {
              final navigator = Navigator.of(context);
              navigator.push(
                MaterialPageRoute(
                  builder: (context) => const DeveloperScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
