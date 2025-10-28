import 'package:beans_merchant_sdk/beans_merchant_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants.dart';

/// Provider for SDK configuration state
final sdkConfigProvider =
    StateNotifierProvider<SdkConfigNotifier, SdkConfigState>((ref) {
  return SdkConfigNotifier();
});

/// Provider for the configured SDK instance
final sdkProvider = Provider<BeansMerchantSdk>((ref) {
  final config = ref.watch(sdkConfigProvider);
  return _createSdk(config);
});

/// Creates SDK instance based on configuration
BeansMerchantSdk _createSdk(SdkConfigState config) {
  if (config.useCustomSdk && config.customBaseUrl.isNotEmpty) {
    return BeansMerchantSdk.custom(
      apiKey: config.apiKey,
      apiBaseUrl: Uri.parse(config.customBaseUrl),
    );
  } else {
    switch (config.environment) {
      case 'production':
        return BeansMerchantSdk.production(apiKey: config.apiKey);
      default:
        return BeansMerchantSdk.staging(apiKey: config.apiKey);
    }
  }
}

/// SDK Configuration State
class SdkConfigState {
  final String environment;
  final String apiKey;
  final String stellarAccountId;
  final String customBaseUrl;
  final bool useCustomSdk;

  const SdkConfigState({
    this.environment = 'production',
    this.apiKey = Constants.beansApiKey,
    this.stellarAccountId = Constants.beansStellarAccountId,
    this.customBaseUrl = '',
    this.useCustomSdk = false,
  });

  SdkConfigState copyWith({
    String? environment,
    String? apiKey,
    String? stellarAccountId,
    String? customBaseUrl,
    bool? useCustomSdk,
  }) {
    return SdkConfigState(
      environment: environment ?? this.environment,
      apiKey: apiKey ?? this.apiKey,
      stellarAccountId: stellarAccountId ?? this.stellarAccountId,
      customBaseUrl: customBaseUrl ?? this.customBaseUrl,
      useCustomSdk: useCustomSdk ?? this.useCustomSdk,
    );
  }

  bool get isConfigured => apiKey.isNotEmpty && stellarAccountId.isNotEmpty;
}

/// SDK Configuration Notifier
class SdkConfigNotifier extends StateNotifier<SdkConfigState> {
  SdkConfigNotifier() : super(const SdkConfigState());

  void updateEnvironment(String environment) {
    state = state.copyWith(environment: environment);
  }

  void updateApiKey(String apiKey) {
    state = state.copyWith(apiKey: apiKey);
  }

  void updateStellarAccountId(String stellarAccountId) {
    state = state.copyWith(stellarAccountId: stellarAccountId);
  }

  void updateCustomBaseUrl(String customBaseUrl) {
    state = state.copyWith(customBaseUrl: customBaseUrl);
  }

  void toggleCustomSdk(bool useCustomSdk) {
    state = state.copyWith(useCustomSdk: useCustomSdk);
  }

  void reset() {
    state = const SdkConfigState();
  }
}
