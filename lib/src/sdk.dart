import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'exceptions/api_exception.dart';
import 'models/company_account.dart';
import 'models/create_company_account_response.dart';
import 'models/fetch_stellar_currencies_response.dart';
import 'models/language_string.dart';
import 'models/qr_code_response.dart';
import 'models/upload_avatar_response.dart';

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
      apiBaseUrl: Uri.https('api.beansapp.com', '/v4'),
      apiKey: apiKey,
      httpClient: httpClient,
    );
  }

  factory BeansMerchantSdk.staging({
    required String apiKey,
    http.Client? httpClient,
  }) {
    return BeansMerchantSdk.custom(
      apiBaseUrl: Uri.https('api.staging.beansapp.com', '/v4'),
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

  /// Creates a sub-account for the company
  /// 
  /// [stellarAccountId] The Stellar account ID for the sub-account
  /// [name] The name of the sub-account in different languages as a map where
  /// the key is the language code (e.g., 'en', 'vi') and the value is the name in that language
  Future<CreateCompanyAccountResponse> createCompanyAccount(
    String stellarAccountId,
    Map<String, String> name,
  ) async {
    final response = await httpClient.post(
      Uri.parse('$apiBaseUrl/companies/me/account'),
      headers: {
        'Content-Type': 'application/json',
        'X-Beans-Company-Api-Key': apiKey,
      },
      body: jsonEncode({
        'stellarAccountId': stellarAccountId,
        'name': name,
      }),
    );

    if (response.statusCode == 201) {
      return CreateCompanyAccountResponse.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException(
        response.statusCode,
        response,
        'Failed to create company account',
      );
    }
  }

  /// Uploads an avatar for a company sub-account
  /// 
  /// [companyId] The ID of the company or 'me' for the current company
  /// [stellarAccountId] The Stellar account ID of the sub-account
  /// [imageBytes] The image data as bytes
  /// [mimeType] The MIME type of the image (e.g., 'image/jpeg', 'image/png')
  Future<CompanyAccount> uploadCompanyAccountAvatar(
    String companyId,
    String stellarAccountId,
    Uint8List imageBytes,
    String mimeType,
  ) async {
    final uri = Uri.parse(
      '$apiBaseUrl/companies/$companyId/accounts/$stellarAccountId/avatar',
    );

    final request = http.MultipartRequest('PUT', uri);
    request.headers['X-Beans-Company-Api-Key'] = apiKey;

    final extension = mimeType.split('/').last;
    
    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: 'avatar.$extension',
        contentType: MediaType.parse(mimeType),
      ),
    );

    final streamedResponse = await httpClient.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return CompanyAccount.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException(
        response.statusCode,
        response,
        'Failed to upload company account avatar',
      );
    }
  }

  /// Gets the avatar for a company sub-account
  /// 
  /// [companyId] The ID of the company or 'me' for the current company
  /// [accountId] The ID of the sub-account
  /// [avatarId] The ID of the avatar
  Future<Uint8List> getCompanyAccountAvatar(
    String companyId,
    String accountId,
    String avatarId,
  ) async {
    final response = await httpClient.get(
      Uri.parse(
        '$apiBaseUrl/companies/$companyId/accounts/$accountId/avatar/$avatarId',
      ),
      headers: {
        'X-Beans-Company-Api-Key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw ApiException(
        response.statusCode,
        response,
        'Failed to get company account avatar',
      );
    }
  }
}
