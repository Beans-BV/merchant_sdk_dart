import 'package:beans_merchant_sdk/beans_merchant_sdk.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sdk_provider.dart';

/// Provider for payment generation state
final paymentProvider =
    StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  final sdk = ref.watch(sdkProvider);
  return PaymentNotifier(sdk);
});

/// Payment State
class PaymentState {
  final String amount;
  final String memo;
  final String maxPayments;
  final String webhookUrl;
  final bool isGeneratingPayment;
  final String? error;
  final Map<String, dynamic>? lastPaymentResponse;

  const PaymentState({
    this.amount = '10.50',
    this.memo = 'Demo Payment',
    this.maxPayments = '1',
    this.webhookUrl = '',
    this.isGeneratingPayment = false,
    this.error,
    this.lastPaymentResponse,
  });

  PaymentState copyWith({
    String? amount,
    String? memo,
    String? maxPayments,
    String? webhookUrl,
    bool? isGeneratingPayment,
    String? error,
    Map<String, dynamic>? lastPaymentResponse,
  }) {
    return PaymentState(
      amount: amount ?? this.amount,
      memo: memo ?? this.memo,
      maxPayments: maxPayments ?? this.maxPayments,
      webhookUrl: webhookUrl ?? this.webhookUrl,
      isGeneratingPayment: isGeneratingPayment ?? this.isGeneratingPayment,
      error: error,
      lastPaymentResponse: lastPaymentResponse ?? this.lastPaymentResponse,
    );
  }
}

/// Payment Notifier
class PaymentNotifier extends StateNotifier<PaymentState> {
  final BeansMerchantSdk _sdk;

  PaymentNotifier(this._sdk) : super(const PaymentState());

  void updateAmount(String amount) {
    state = state.copyWith(amount: amount);
  }

  void updateMemo(String memo) {
    state = state.copyWith(memo: memo);
  }

  void updateMaxPayments(String maxPayments) {
    state = state.copyWith(maxPayments: maxPayments);
  }

  void updateWebhookUrl(String webhookUrl) {
    state = state.copyWith(webhookUrl: webhookUrl);
  }

  Future<void> generateDeeplink({
    required String stellarAccountId,
    required String stellarCurrencyId,
  }) async {
    state = state.copyWith(isGeneratingPayment: true, error: null);

    try {
      final response = await _sdk.generateDeeplink(
        stellarAccountId,
        stellarCurrencyId,
        double.parse(state.amount),
        state.memo,
        maxAllowedPayments:
            state.maxPayments.isEmpty ? null : int.parse(state.maxPayments),
        webhookUrl: state.webhookUrl.isEmpty ? null : state.webhookUrl,
      );

      state = state.copyWith(
        isGeneratingPayment: false,
        lastPaymentResponse: {
          'type': 'Deeplink',
          'deeplink': response.deeplink,
          'paymentRequestId': response.id,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isGeneratingPayment: false,
        error: e.toString(),
      );
    }
  }

  Future<void> generateSvgQrCode({
    required String stellarAccountId,
    required String stellarCurrencyId,
  }) async {
    state = state.copyWith(isGeneratingPayment: true, error: null);

    try {
      final response = await _sdk.generateSvgQrCode(
        stellarAccountId,
        stellarCurrencyId,
        double.parse(state.amount),
        state.memo,
        maxAllowedPayments:
            state.maxPayments.isEmpty ? null : int.parse(state.maxPayments),
        webhookUrl: state.webhookUrl.isEmpty ? null : state.webhookUrl,
        size: 256,
      );

      state = state.copyWith(
        isGeneratingPayment: false,
        lastPaymentResponse: {
          'type': 'SVG QR Code',
          'svgQrCode': response.svgQrCode,
          'deeplink': response.deeplink,
          'paymentRequestId': response.id,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isGeneratingPayment: false,
        error: e.toString(),
      );
    }
  }

  Future<void> generatePngQrCode({
    required String stellarAccountId,
    required String stellarCurrencyId,
  }) async {
    state = state.copyWith(isGeneratingPayment: true, error: null);

    try {
      final response = await _sdk.generatePngQrCode(
        stellarAccountId,
        stellarCurrencyId,
        double.parse(state.amount),
        state.memo,
        maxAllowedPayments:
            state.maxPayments.isEmpty ? null : int.parse(state.maxPayments),
        webhookUrl: state.webhookUrl.isEmpty ? null : state.webhookUrl,
        preferredSize: 512,
      );

      if (response.pngQrCodeBase64String.isEmpty) {
        throw Exception('PNG QR Code generated but no image data received');
      }

      // Extract base64 string from data URL if present
      String base64String = response.pngQrCodeBase64String;
      if (base64String.startsWith('data:image/png;base64,')) {
        base64String = base64String.substring('data:image/png;base64,'.length);
      }

      state = state.copyWith(
        isGeneratingPayment: false,
        lastPaymentResponse: {
          'type': 'PNG QR Code',
          'pngQrCodeBase64String': base64String,
          'deeplink': response.deeplink,
          'paymentRequestId': response.id,
        },
      );
    } catch (e) {
      state = state.copyWith(
        isGeneratingPayment: false,
        error: e.toString(),
      );
    }
  }

  void clearLastResponse() {
    state = state.copyWith(lastPaymentResponse: null);
  }
}
