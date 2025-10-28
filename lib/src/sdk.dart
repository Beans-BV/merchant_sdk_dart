import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'exceptions/api_exception.dart';
import 'models/company_account.dart';
import 'models/create_company_account_response.dart';
import 'models/delete_company_account_response.dart';
import 'models/fetch_stellar_currencies_response.dart';
import 'models/get_company_account_response.dart';
import 'models/get_company_accounts_response.dart';
import 'models/language_string.dart';
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
      headers: {'X-Beans-Company-Api-Key': apiKey},
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
    return await generatePaymentRequest<DeeplinkResponse>(stellarAccountId, {
      "stellarCurrencyId": stellarCurrencyId,
      "amount": amount,
      "memo": memo,
      "maxAllowedPayments": maxAllowedPayments,
      "paymentReceivedWebHookUrl": webhookUrl,
      "deeplink": {"include": true},
    });
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
    return await generatePaymentRequest<PngQrCodeResponse>(stellarAccountId, {
      "stellarCurrencyId": stellarCurrencyId,
      "amount": amount,
      "memo": memo,
      "maxAllowedPayments": maxAllowedPayments,
      "paymentReceivedWebHookUrl": webhookUrl,
      "deeplink": {"include": true},
      "pngQrCodeBase64String": {
        "include": true,
        "preferredSize": preferredSize,
      },
    });
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
    return await generatePaymentRequest<SvgQrCodeResponse>(stellarAccountId, {
      "stellarCurrencyId": stellarCurrencyId,
      "amount": amount,
      "memo": memo,
      "maxAllowedPayments": maxAllowedPayments,
      "paymentReceivedWebHookUrl": webhookUrl,
      "deeplink": {"include": true},
      "svgQrCode": {"include": true, "size": size},
    });
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

  /// Creates an account for the company
  ///
  /// [stellarAccountId] The Stellar account ID for the account
  /// [name] The name of the account in different languages as a LanguageString
  Future<CreateCompanyAccountResponse> createCompanyAccount(
    String stellarAccountId,
    LanguageString name,
  ) async {
    final response = await httpClient.post(
      Uri.parse('$apiBaseUrl/companies/me/account'),
      headers: {
        'Content-Type': 'application/json',
        'X-Beans-Company-Api-Key': apiKey,
      },
      body: jsonEncode(
          {'stellarAccountId': stellarAccountId, 'name': name.toJson()}),
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

  /// Uploads an avatar for a company account
  ///
  /// Can accept either a file path or raw image bytes
  /// [companyId] The ID of the company or 'me' for the current company
  /// [stellarAccountId] The Stellar account ID of the account
  /// [imagePathOrBytes] Either a String file path or Uint8List of image bytes
  /// [mimeType] Optional MIME type of the image. Required if using imageBytes
  Future<CompanyAccount> uploadCompanyAccountAvatar(
    String companyId,
    String stellarAccountId,
    dynamic imagePathOrBytes, [
    String? mimeType,
  ]) async {
    final uri = Uri.parse(
      '$apiBaseUrl/companies/$companyId/accounts/$stellarAccountId/avatar',
    );

    final request = http.MultipartRequest('PUT', uri);
    request.headers['X-Beans-Company-Api-Key'] = apiKey;

    if (imagePathOrBytes is String) {
      // Handle file path
      final extension = imagePathOrBytes.split('.').last.toLowerCase();
      final detectedMimeType = _getMimeTypeFromExtension(extension);

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imagePathOrBytes,
          contentType: MediaType.parse(detectedMimeType),
        ),
      );
    } else if (imagePathOrBytes is Uint8List) {
      // Handle raw bytes
      if (mimeType == null) {
        throw ArgumentError('mimeType is required when using raw bytes');
      }
      final extension = mimeType.split('/').last;

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imagePathOrBytes,
          filename: 'avatar.$extension',
          contentType: MediaType.parse(mimeType),
        ),
      );
    } else {
      throw ArgumentError(
        'imagePathOrBytes must be either a String path or Uint8List bytes',
      );
    }

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

  String _getMimeTypeFromExtension(String extension) {
    switch (extension.toLowerCase()) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      default:
        throw ArgumentError('Unsupported file extension: $extension');
    }
  }

  /// Gets the avatar for a company account
  ///
  /// [companyId] The ID of the company or 'me' for the current company
  /// [accountId] The ID of the account
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
      headers: {'X-Beans-Company-Api-Key': apiKey},
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

  /// Deletes an account for the company
  ///
  /// [stellarAccountId] The Stellar account ID of the account to delete
  Future<DeleteCompanyAccountResponse> deleteCompanyAccount(
    String stellarAccountId,
  ) async {
    final response = await httpClient.delete(
      Uri.parse('$apiBaseUrl/companies/me/accounts/$stellarAccountId'),
      headers: {
        'Content-Type': 'application/json',
        'X-Beans-Company-Api-Key': apiKey,
      },
    );

    if (response.statusCode == 200) {
      return DeleteCompanyAccountResponse.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException(
        response.statusCode,
        response,
        'Failed to delete company account',
      );
    }
  }

  /// Fetches all merchant accounts
  Future<GetCompanyAccountsResponse> getCompanyAccounts() async {
    final response = await httpClient.get(
      Uri.parse('$apiBaseUrl/companies/me/accounts'),
      headers: {'X-Beans-Company-Api-Key': apiKey},
    );

    if (response.statusCode == 200) {
      return GetCompanyAccountsResponse.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException(
        response.statusCode,
        response,
        'Failed to fetch merchant accounts',
      );
    }
  }

  /// Fetches a specific company account by Stellar account ID
  Future<GetCompanyAccountResponse> getCompanyAccount(
      String stellarAccountId) async {
    final response = await httpClient.get(
      Uri.parse('$apiBaseUrl/companies/me/accounts/$stellarAccountId'),
      headers: {'X-Beans-Company-Api-Key': apiKey},
    );

    if (response.statusCode == 200) {
      return GetCompanyAccountResponse.fromJson(jsonDecode(response.body));
    } else {
      throw ApiException(
        response.statusCode,
        response,
        'Failed to fetch company account',
      );
    }
  }
}
