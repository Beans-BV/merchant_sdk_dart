import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets.dart';

class ComprehensiveDemoScreen extends ConsumerStatefulWidget {
  const ComprehensiveDemoScreen({super.key});

  @override
  ConsumerState<ComprehensiveDemoScreen> createState() =>
      _ComprehensiveDemoScreenState();
}

class _ComprehensiveDemoScreenState extends ConsumerState<ComprehensiveDemoScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comprehensive SDK Demo'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Setup'),
            Tab(text: 'Stellar Currencies'),
            Tab(text: 'Accounts'),
            Tab(text: 'Payments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          SetupTab(),
          StellarCurrenciesTab(),
          AccountsTab(),
          PaymentsTab(),
        ],
      ),
    );
  }
}
