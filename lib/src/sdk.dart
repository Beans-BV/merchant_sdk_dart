import 'dart:convert';

import 'package:http/http.dart' as http;

import 'exceptions/api_exception.dart';
import 'models/fetch_stellar_currencies_response.dart';
import 'models/qr_code_response.dart';

class BeansMerchantSdk {
  BeansMerchantSdk.custom({
    required this.apiBaseUrl,
    required this.apiKey,
    http.Client? httpClient,
  }) : httpClient = httpClient ?? http.Client();

  factory BeansMerchantSdk.production({
    required String apiKey,
    http.Client? httpClient,
  }) {
    return BeansMerchantSdk.custom(
      apiBaseUrl: Uri.https('api.beansapp.com', '/v3'),
      apiKey: apiKey,
      httpClient: httpClient,
    );
  }

  factory BeansMerchantSdk.staging({
    required String apiKey,
    http.Client? httpClient,
  }) {
    return BeansMerchantSdk.custom(
      apiBaseUrl: Uri.https('api.staging.beansapp.com', '/v3'),
      apiKey: apiKey,
      httpClient: httpClient,
    );
  }

  final Uri apiBaseUrl;
  final String apiKey;
  final http.Client httpClient;

  Future<FetchStellarCurrenciesResponse> fetchStellarCurrencies(
    String stellarAccountId,
  ) async {
    final response = await httpClient.get(
      Uri.parse(
        '$apiBaseUrl/companies/me/accounts/$stellarAccountId/stellar-currencies',
      ),
      headers: {
        'X-Beans-Company-Api-Key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      return FetchStellarCurrenciesResponse.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException(
        response.statusCode,
        response,
        'Failed to fetch stellar currencies',
      );
    }
  }

  Future<DeeplinkResponse> generateDeeplink(
    String stellarAccountId,
    String stellarCurrencyId,
    double amount,
    String memo, {
    int? maxAllowedPayments,
    String? webhookUrl,
  }) async {
    return await generatePaymentRequest<DeeplinkResponse>(
      stellarAccountId,
      {
        "stellarCurrencyId": stellarCurrencyId,
        "amount": amount,
        "memo": memo,
        "maxAllowedPayments": maxAllowedPayments,
        "paymentReceivedWebHookUrl": webhookUrl,
        "deeplink": {
          "include": true,
        }
      },
    );
  }

  Future<PngQrCodeResponse> generatePngQrCode(
    String stellarAccountId,
    String stellarCurrencyId,
    double amount,
    String memo, {
    int? maxAllowedPayments,
    String? webhookUrl,
    int? preferredSize,
  }) async {
    return await generatePaymentRequest<PngQrCodeResponse>(
      stellarAccountId,
      {
        "stellarCurrencyId": stellarCurrencyId,
        "amount": amount,
        "memo": memo,
        "maxAllowedPayments": maxAllowedPayments,
        "paymentReceivedWebHookUrl": webhookUrl,
        "deeplink": {"include": true},
        "pngQrCodeBase64String": {
          "include": true,
          "preferredSize": preferredSize
        }
      },
    );
  }

  Future<SvgQrCodeResponse> generateSvgQrCode(
    String stellarAccountId,
    String stellarCurrencyId,
    double amount,
    String memo, {
    int? maxAllowedPayments,
    String? webhookUrl,
    int? size,
  }) async {
    return await generatePaymentRequest<SvgQrCodeResponse>(
      stellarAccountId,
      {
        "stellarCurrencyId": stellarCurrencyId,
        "amount": amount,
        "memo": memo,
        "maxAllowedPayments": maxAllowedPayments,
        "paymentReceivedWebHookUrl": webhookUrl,
        "deeplink": {"include": true},
        "svgQrCode": {
          "include": true,
          "size": size,
        }
      },
    );
  }

  Future<T> generatePaymentRequest<T extends PaymentRequestResponse>(
    String stellarAccountId,
    Map<String, dynamic> body,
  ) async {
    final response = await httpClient.post(
      Uri.parse(
        '$apiBaseUrl/companies/me/accounts/$stellarAccountId/payment-request',
      ),
      headers: {
        'Content-Type': 'application/json',
        'X-Beans-Company-Api-Key': apiKey,
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 201) {
      return fromJson<T>(jsonDecode(response.body));
    } else {
      throw ApiException(
        response.statusCode,
        response,
        'Failed to generate payment request',
      );
    }
  }

  T fromJson<T>(Map<String, dynamic> json) {
    if (T == DeeplinkResponse) {
      return DeeplinkResponse.fromJson(json) as T;
    } else if (T == SvgQrCodeResponse) {
      return SvgQrCodeResponse.fromJson(json) as T;
    } else if (T == PngQrCodeResponse) {
      return PngQrCodeResponse.fromJson(json) as T;
    } else {
      throw Exception('Unknown class');
    }
  }
}
