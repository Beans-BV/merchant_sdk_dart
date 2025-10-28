import 'package:beans_merchant_sdk/beans_merchant_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sdk_provider.dart';

/// Provider for stellar currencies state
final stellarCurrenciesProvider =
    StateNotifierProvider<StellarCurrenciesNotifier, StellarCurrenciesState>(
        (ref) {
  final sdk = ref.watch(sdkProvider);
  return StellarCurrenciesNotifier(sdk);
});

/// Stellar Currencies State
class StellarCurrenciesState {
  final List<StellarCurrency> currencies;
  final bool isLoading;
  final String? error;
  final String? selectedCurrencyId;

  const StellarCurrenciesState({
    this.currencies = const [],
    this.isLoading = false,
    this.error,
    this.selectedCurrencyId,
  });

  StellarCurrenciesState copyWith({
    List<StellarCurrency>? currencies,
    bool? isLoading,
    String? error,
    String? selectedCurrencyId,
  }) {
    return StellarCurrenciesState(
      currencies: currencies ?? this.currencies,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedCurrencyId: selectedCurrencyId ?? this.selectedCurrencyId,
    );
  }

  StellarCurrency? get selectedCurrency {
    if (selectedCurrencyId == null) return null;
    try {
      return currencies.firstWhere((c) => c.id == selectedCurrencyId);
    } catch (e) {
      return null;
    }
  }
}

/// Stellar Currencies Notifier
class StellarCurrenciesNotifier extends StateNotifier<StellarCurrenciesState> {
  final BeansMerchantSdk _sdk;

  StellarCurrenciesNotifier(this._sdk) : super(const StellarCurrenciesState());

  Future<void> loadCurrencies(String stellarAccountId) async {
    if (stellarAccountId.isEmpty) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _sdk.fetchStellarCurrencies(stellarAccountId);
      final currencies = response.stellarCurrencies;

      state = state.copyWith(
        currencies: currencies,
        isLoading: false,
        selectedCurrencyId: currencies.isNotEmpty ? currencies.first.id : null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void selectCurrency(String currencyId) {
    state = state.copyWith(selectedCurrencyId: currencyId);
  }

  void refresh(String stellarAccountId) {
    loadCurrencies(stellarAccountId);
  }
}
