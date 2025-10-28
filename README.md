<h1>Beans Merchant Dart SDK</h1>

- [Introduction](#introduction)
  - [Use Cases](#use-cases)
- [Getting Started](#getting-started)
  - [How to Request an Account](#how-to-request-an-account)
    - [Company Details](#company-details)
    - [Stellar Account Details](#stellar-account-details)
  - [Installation](#installation)
  - [Usage](#usage)
- [API Reference](#api-reference)
  - [LanguageString](#languagestring)
  - [BeansMerchantSdk](#beansmerchantsdk)
    - [Constructors](#constructors)
    - [Methods](#methods)
      - [Fetch Stellar Currencies](#fetch-stellar-currencies)
      - [Generate Deeplink](#generate-deeplink)
      - [Generate PNG QR Code](#generate-png-qr-code)
      - [Generate SVG QR Code](#generate-svg-qr-code)
      - [Create Company Account](#create-company-account)
      - [Delete Company Account](#delete-company-account)
      - [Upload Company Account Avatar](#upload-company-account-avatar)
      - [Get Company Account Avatar](#get-company-account-avatar)
      - [Get Company Accounts](#get-company-accounts)
      - [Get Merchant Account](#get-merchant-account)
  - [Webhook Notifications](#webhook-notifications)
- [Examples](#examples)
  - [Checkout](#checkout)
  - [Deposit](#deposit)
  - [Account Management](#account-management)
  - [Developer](#developer)
- [Questions and Answers](#questions-and-answers)
  - [Do I have to use stroops?](#do-i-have-to-use-stroops)

# Introduction

The Beans Merchant SDK offers a comprehensive toolkit for integrating the advanced payment capabilities of the Beans platform directly into your JavaScript applications. This SDK is designed to simplify the integration process, allowing you to leverage the Beans Merchant API's full potential without needing to manage the intricacies of direct API calls. By incorporating the Beans Merchant SDK, developers can unlock a wide range of use cases.

## Use Cases

- **Build an In-Person Merchant POS:** Facilitate in-person point of sale at stores or restaurants by generating payment requests through QR codes. This combines the convenience of online transactions with the traditional in-store shopping experience.

- **Shopify App for Currency Flexibility:** Develop a Shopify application that empowers merchants to request payments in their preferred currency while offering customers the flexibility to pay in theirs. This functionality enhances the shopping experience, catering to a global customer base.

- **Integrate Beans as Your On/Off Ramp Partner:** Streamline your application's payment infrastructure by using Beans as your central on/off ramp partner. This integration saves significant development time and resources by eliminating the need to individually integrate multiple on/off ramp solutions.

- **Monetize Your GPT Applications:** For applications utilizing Generative Pre-trained Transformers (GPT), integrating Beans enables a monetization strategy where services can be accessed for free up to a certain limit, after which users are prompted to pay for additional usage or to purchase credits. This model is perfect for applications offering premium content or services on a per-use basis.

# Getting Started

## How to Request an Account

Welcome to Beans App! To start your journey as a merchant, please request an account by contacting us. Follow the steps below to ensure your application is processed smoothly.

Reach out to us via email at [merchants@beansapp.com](mailto:merchants@beansapp.com) with the following required details:

### Company Details

 - **Company Name:** Provide the official name of your company.
 - **Company Website:** Include the URL to your business website.
 - **Company Email Address:** This should be the official contact email for your business.
 - **Company Logo:** Attach a high-resolution logo (minimum dimensions 500x500 pixels).

### Stellar Account Details
To handle payments, please provide your Stellar account details:

 - **Beans App Account (reccomended):**
   - **Username:** Provide your Beans App username.
   - **Recommendation:** Using a Beans App account simplifies the withdrawal process.
   - **New Users:** To create a Beans App account, download the app [here](https://beansapp.com/download). 
 - **Custom Stellar Account:**
   - **Public Key:** Provide the public key if you prefer to receive payments in a custom Stellar account.

Thank you for choosing Beans App. We look forward to facilitating your business transactions!

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  beans_merchant_sdk: ^4.0.0
```

Then run:

```bash
flutter pub get
```

## Usage

```dart
import 'package:beans_merchant_sdk/beans_merchant_sdk.dart';

// Create an instance of BeansMerchantSdk for production
final sdk = BeansMerchantSdk.production(
  apiKey: 'your-api-key',
);

// Or for staging environment
final stagingSdk = BeansMerchantSdk.staging(
  apiKey: 'your-staging-api-key',
);

// Fetch currencies
final response = await sdk.fetchStellarCurrencies('stellarAccountId');
log('Available Stellar currencies: ${response.stellarCurrencies}');

// Generate deeplink
final deeplinkResponse = await sdk.generateDeeplink(
  'stellarAccountId', 
  'stellarCurrencyId', 
  100.0, 
  'memo',
  maxAllowedPayments: 1,
  webhookUrl: 'https://your-domain.com/webhook'
);
log('Generated deeplink: ${deeplinkResponse.deeplink}');

// Generate SVG QR code
final svgResponse = await sdk.generateSvgQrCode(
  'stellarAccountId', 
  'stellarCurrencyId', 
  100.0, 
  'memo',
  maxAllowedPayments: 1,
  webhookUrl: 'https://your-domain.com/webhook',
  size: 250
);
log('Generated deeplink: ${svgResponse.deeplink}');
log('Generated SVG QR code: ${svgResponse.svgQrCode}');

// Generate PNG QR code
final pngResponse = await sdk.generatePngQrCode(
  'stellarAccountId', 
  'stellarCurrencyId', 
  100.0, 
  'memo',
  maxAllowedPayments: 1,
  webhookUrl: 'https://your-domain.com/webhook',
  preferredSize: 250
);
log('Generated deeplink: ${pngResponse.deeplink}');
log('Generated PNG QR code: ${pngResponse.pngQrCodeBase64String}');

// Create a company account
final name = LanguageString.from({
  'en': "Marketing Account",
  'vn': "Tài khoản Marketing"
});
final accountResponse = await sdk.createCompanyAccount(
  "GBZX4364PEPQTDICMIQDZ56K4T75QZCR4NBEYKO6PDRJAHZKGUOJPCXB",
  name
);
log('Created company account: ${accountResponse.account.id}');

// Upload avatar for a company account
final imageBytes = await File('path_to_image.jpg').readAsBytes();
final updatedAccount = await sdk.uploadCompanyAccountAvatar(
  "me",
  "GBZX4364PEPQTDICMIQDZ56K4T75QZCR4NBEYKO6PDRJAHZKGUOJPCXB",
  imageBytes,
  "image/jpeg"
);
log('Account updated with avatar: ${updatedAccount.avatarId}');

// Get avatar for a company account
final avatarBytes = await sdk.getCompanyAccountAvatar(
  "me",
  accountId,
  avatarId
);
// Use avatarBytes to display the image

// Get all company accounts
final accounts = await sdk.getCompanyAccounts();
log('Total accounts: ${accounts.length}');

// Get specific merchant account
final account = await sdk.getMerchantAccount('stellarAccountId');
log('Account name: ${account.name}');

// Delete account
final deleteResponse = await sdk.deleteCompanyAccount('GCQYCNYU3T73JCQ2J36A3JJ5CUQO4DY4EOKMPUL5723ZH7N6XMMNPAA3');
log('Deleted account with ID: ${deleteResponse.account.id}');
log('Deletion status: ${deleteResponse.status}');
```

# API Reference

The Beans Merchant SDK provides a simple and intuitive interface for interacting with the Beans Merchant API. This section outlines the available methods and response objects provided by the SDK.

## LanguageString

The `LanguageString` class provides a specialized way to handle multi-language strings in the SDK. It's used for account names and other localized content where keys are language codes (e.g., 'en', 'vn') and values are the translated strings.

**Note:** The English language ('en') is required for all LanguageString instances.

### Constructors

#### Default Constructor
`LanguageString()`: Creates a LanguageString with an empty English translation.

#### From Map Constructor
`LanguageString.from(Map<String, String> base)`: Creates a LanguageString from an existing map. The map must contain an 'en' key.

#### From JSON Constructor
`LanguageString.fromJson(Map<String, dynamic> json)`: Creates a LanguageString from a JSON map. The JSON must contain an 'en' key.

#### From JSON String Constructor
`LanguageString.fromJsonString(String jsonString)`: Creates a LanguageString from a JSON string. The JSON must contain an 'en' key.

### Methods

#### Language Access
- `getLanguage(String languageCode)`: Gets the string for a specific language code. Returns null if not found.
- `getLanguageWithFallback(String languageCode, String fallbackLanguageCode)`: Gets the string with a fallback language.
- `getLanguageOrDefault(String languageCode, String defaultValue)`: Gets the string with a default value.

#### Utility Methods
- `hasLanguage(String languageCode)`: Checks if a specific language is available.
- `copyWith(Map<String, String> additionalTranslations)`: Creates a new LanguageString with additional translations.
- `toJson()`: Converts to a JSON map.
- `toJsonString()`: Converts to a JSON string.

#### Map-like Access
The LanguageString class provides map-like access using the `[]` operator:
```dart
final name = LanguageString.from({'en': 'Hello', 'vn': 'Xin chào'});
print(name['en']); // Output: Hello
name['fr'] = 'Bonjour'; // Add French translation
```

### Properties
- `languageCodes`: Gets all available language codes.
- `translations`: Gets all available translations.
- `languageCount`: Gets the number of available languages.
- `isEmpty`: Checks if there are no translations.
- `isNotEmpty`: Checks if there are translations.

### Example
```dart
// Create a LanguageString
final name = LanguageString.from({
  'en': "Marketing Account",
  'vn': "Tài khoản Marketing",
  'fr': "Compte Marketing"
});

// Access translations
print(name.getLanguage('en')); // Output: Marketing Account
print(name.getLanguageOrDefault('es', 'Default Name')); // Output: Default Name

// Check if language exists
if (name.hasLanguage('vn')) {
  print('Vietnamese translation available');
}

// Convert to JSON
final json = name.toJson();
print(json); // Output: {en: Marketing Account, vn: Tài khoản Marketing, fr: Compte Marketing}
```

## BeansMerchantSdk

The `BeansMerchantSdk` class provides methods for interacting with the Beans Merchant API.

### Constructors

#### Production Environment
`BeansMerchantSdk.production({required String apiKey, http.Client? httpClient})`: Initializes a new SDK instance for production environment.

Parameters:
- `apiKey`: Your Beans Merchant API key.
- `httpClient` *(optional)*: Custom HTTP client for testing or custom configurations.

#### Staging Environment
`BeansMerchantSdk.staging({required String apiKey, http.Client? httpClient})`: Initializes a new SDK instance for staging environment.

Parameters:
- `apiKey`: Your Beans Merchant API key.
- `httpClient` *(optional)*: Custom HTTP client for testing or custom configurations.

#### Custom Environment
`BeansMerchantSdk.custom({required Uri apiBaseUrl, required String apiKey, http.Client? httpClient})`: Initializes a new SDK instance with a custom API base URL.

Parameters:
- `apiBaseUrl`: The base URL of the merchant API.
- `apiKey`: Your Beans Merchant API key.
- `httpClient` *(optional)*: Custom HTTP client for testing or custom configurations.

### Methods

#### Fetch Stellar Currencies

*Retrieves available Stellar currencies for the specified account.*

Method Signature:<br>
*`Future<FetchStellarCurrenciesResponse> fetchStellarCurrencies(...)`*

Parameters:<br>
  - `stellarAccountId`: *Your Stellar account ID.*

Returns:<br>
`Future<FetchStellarCurrenciesResponse>`: *A future that resolves with the response object containing the available Stellar currencies.*

Return Object Properties:<br>
  - `stellarCurrencies`: *An array of Stellar currencies accessible for the specified Stellar Account.*

Example:<br>
```dart
final response = await sdk.fetchStellarCurrencies('stellarAccountId');
log('Available Stellar currencies: ${response.stellarCurrencies}');
```

#### Generate Deeplink

*Creates a payment request deeplink.*

Method Signature:<br>
*`Future<DeeplinkResponse> generateDeeplink(String stellarAccountId, String stellarCurrencyId, double amount, String memo, {int? maxAllowedPayments, String? webhookUrl})`*

Parameters:<br>
  - `stellarAccountId`: *Your Stellar account ID.*
  - `stellarCurrencyId`: *Stellar currency ID.*
  - `amount`: *Amount for the payment request (double).*
  - `memo`: *Memo for the payment request.*
  - `maxAllowedPayments`: *(Optional) Maximum number of payments allowed for the payment request.*
    - *Unlimited is -1*
    - *Default is 1*
  - `webhookUrl`: *(Optional) Webhook URL for payment received notification.*

Returns:<br>
`Future<DeeplinkResponse>`: A future that resolves with the response object containing the payment request deeplink.

Return Object Properties:<br>
  - `id`: *The ID of the payment request.*
  - `deeplink`: *The Beans App deeplink for the payment request.*

Example:<br>
```dart
final response = await sdk.generateDeeplink(
  'stellarAccountId', 
  'stellarCurrencyId', 
  100.0, 
  'memo',
  maxAllowedPayments: 1,
  webhookUrl: 'https://your-domain.com/webhook'
);
log('Generated deeplink: ${response.deeplink}');
```

#### Generate PNG QR Code

*Generates a PNG QR code for payment requests.*

Method Signature:<br>
*`Future<PngQrCodeResponse> generatePngQrCode(String stellarAccountId, String stellarCurrencyId, double amount, String memo, {int? maxAllowedPayments, String? webhookUrl, int? preferredSize})`*

Parameters:<br>
  - `stellarAccountId`: *Your Stellar account ID.*
  - `stellarCurrencyId`: *Stellar currency ID.*
  - `amount`: *Amount for the payment request (double).*
  - `memo`: *Memo for the payment request.*
  - `maxAllowedPayments`: *(Optional) Maximum number of payments allowed for the payment request.*
    - *Unlimited is -1*
    - *Default is 1*
  - `webhookUrl`: *(Optional) Webhook URL for payment received notification.*
  - `preferredSize`: *(Optional) Preferred size of the QR code. We will try to generate a QR code with a size as close as possible to the preferred size provided.*

Returns:<br>
`Future<PngQrCodeResponse>`: *A future that resolves with the response object containing the payment request PNG QR code.*

Return Object Properties:<br>
  - `id`: *The ID of the payment request.*
  - `deeplink`: *The Beans App deeplink for the payment request.*
  - `pngQrCodeBase64String`: *The base64 encoded PNG QR code containing the deeplink.*

Example:<br>
```dart
final response = await sdk.generatePngQrCode(
  'stellarAccountId', 
  'stellarCurrencyId', 
  100.0, 
  'memo',
  maxAllowedPayments: 1,
  webhookUrl: 'https://your-domain.com/webhook',
  preferredSize: 250
);
log('Generated deeplink: ${response.deeplink}');
log('Generated PNG QR code: ${response.pngQrCodeBase64String}');
```

#### Generate SVG QR Code

*Generates an SVG QR code for payment requests.*

Method Signature:<br>
*`Future<SvgQrCodeResponse> generateSvgQrCode(String stellarAccountId, String stellarCurrencyId, double amount, String memo, {int? maxAllowedPayments, String? webhookUrl, int? size})`*

Parameters:<br>
  - `stellarAccountId`: *Your Stellar account ID.*
  - `stellarCurrencyId`: *Stellar currency ID.*
  - `amount`: *Amount for the payment request (double).*
  - `memo`: *Memo for the payment request.*
  - `maxAllowedPayments`: *(Optional) Maximum number of payments allowed for the payment request.*
    - *Unlimited is -1*
    - *Default is 1*
  - `webhookUrl`: *(Optional) Webhook URL for payment received notification.*
  - `size`: *(Optional) Size of the QR code.*

Returns:<br>
`Future<SvgQrCodeResponse>`: *A future that resolves with the response object containing the payment request SVG QR code.*

Return Object Properties:<br>
  - `id`: *The ID of the payment request.*
  - `deeplink`: *The Beans App deeplink for the payment request.*
  - `svgQrCode`: *The SVG QR code containing the deeplink.*

Example:<br>
```dart
final response = await sdk.generateSvgQrCode(
  'stellarAccountId', 
  'stellarCurrencyId', 
  100.0, 
  'memo',
  maxAllowedPayments: 1,
  webhookUrl: 'https://your-domain.com/webhook',
  size: 250
);
log('Generated deeplink: ${response.deeplink}');
log('Generated SVG QR code: ${response.svgQrCode}');
```

#### Create Company Account

*Creates an account for the company.*

Method Signature:<br>
*`Future<CreateCompanyAccountResponse> createCompanyAccount(String stellarAccountId, LanguageString name)`*

Parameters:<br>
  - `stellarAccountId`: *The Stellar account ID for the account.*
  - `name`: *The name of the account in different languages as a LanguageString object.*

Returns:<br>
`Future<CreateCompanyAccountResponse>`: *A future that resolves with the response object containing the created company account.*

Return Object Properties:<br>
  - `account`: *The CompanyAccount object representing the created account.*

#### Delete Company Account

*Deletes an account for the company.*

Method Signature:<br>
*`Future<DeleteCompanyAccountResponse> deleteCompanyAccount(String stellarAccountId)`*

Parameters:<br>
  - `stellarAccountId`: *The Stellar account ID of the account to delete.*

Returns:<br>
`Future<DeleteCompanyAccountResponse>`: *A future that resolves with the response object containing information about the deleted account.*

Return Object Properties:<br>
  - `account`: *The CompanyAccount object representing the deleted account.*
  - `status`: *The status of the deletion operation, typically "deleted".*

Example:<br>
```dart
final response = await sdk.deleteCompanyAccount('GCQYCNYU3T73JCQ2J36A3JJ5CUQO4DY4EOKMPUL5723ZH7N6XMMNPAA3');
log('Deleted account with ID: ${response.account.id}');
log('Deletion status: ${response.status}');
```


#### Upload Company Account Avatar

*Uploads an avatar for a company account.*

Method Signature:<br>
*`Future<CompanyAccount> uploadCompanyAccountAvatar(String companyId, String stellarAccountId, dynamic imagePathOrBytes, [String? mimeType])`*

Parameters:<br>
  - `companyId`: *The ID of the company, or the string "me" to automatically resolve the ID from the provided API token.*
  - `stellarAccountId`: *The Stellar account ID of the account.*
  - `imagePathOrBytes`: *Either a String file path or Uint8List of image bytes.*
  - `mimeType`: *(Optional) The MIME type of the image (e.g., 'image/jpeg', 'image/png'). Required if using raw bytes.*

Returns:<br>
`Future<CompanyAccount>`: *A future that resolves with the updated CompanyAccount object.*

Example:<br>
```dart
final imageBytes = await File('path_to_image.jpg').readAsBytes();
final updatedAccount = await sdk.uploadCompanyAccountAvatar(
  "me",
  "GBZX4364PEPQTDICMIQDZ56K4T75QZCR4NBEYKO6PDRJAHZKGUOJPCXB",
  imageBytes,
  "image/jpeg"
);
log('Account updated with avatar: ${updatedAccount.avatarId}');
```

#### Get Company Account Avatar

*Gets the avatar for a company account.*

Method Signature:<br>
*`Future<Uint8List> getCompanyAccountAvatar(...)`*

Parameters:<br>
  - `companyId`: *The ID of the company, or the string "me" to automatically resolve the ID from the provided API token.*
  - `accountId`: *The ID of the account.*
  - `avatarId`: *The ID of the avatar.*

Returns:<br>
`Future<Uint8List>`: *A future that resolves with the image data as bytes.*

Example:<br>
```dart
final avatarBytes = await sdk.getCompanyAccountAvatar(
  "me",
  accountId,
  avatarId
);
// Use avatarBytes to display the image
```

#### Get Company Accounts

*Fetches all merchant accounts for the company.*

Method Signature:<br>
*`Future<List<CompanyAccount>> getCompanyAccounts()`*

Returns:<br>
`Future<List<CompanyAccount>>`: *A future that resolves with a list of all company accounts.*

Example:<br>
```dart
final accounts = await sdk.getCompanyAccounts();
log('Total accounts: ${accounts.length}');
for (final account in accounts) {
  log('Account: ${account.name} (${account.stellarAccountId})');
}
```

#### Get Merchant Account

*Fetches a specific merchant account by Stellar account ID.*

Method Signature:<br>
*`Future<CompanyAccount> getMerchantAccount(String stellarAccountId)`*

Parameters:<br>
  - `stellarAccountId`: *The Stellar account ID of the account to fetch.*

Returns:<br>
`Future<CompanyAccount>`: *A future that resolves with the CompanyAccount object.*

Example:<br>
```dart
final account = await sdk.getMerchantAccount('stellarAccountId');
log('Account name: ${account.name}');
log('Account ID: ${account.id}');
```

## Webhook Notifications

*Beans Merchant API sends a webhook notification to the provided URL when a payment is received.*

Example Webhook Payload:<br>
```json
{
  "PaymentRequestId": "e3cfa903-548f-475c-a9f2-ebf3f4e2fa17",
  "Memo": "example",
  "TransactionHash": "b7f4e42935eb120e3a6f43cdae3c6a511a346da77b7e17299aff0f8c72dcf3c0"
}
```

# Examples

We've provided examples to help you understand what you as a business can do with the Beans Merchant SDK.

## Checkout

We've added an example that showcases a simple checkout flow for a fictional e-commerce platform. This shows you how easy it is to generate a payment request for something like a checkout.

Find the full example code [here](https://github.com/Beans-BV/merchant_sdk_dart/blob/main/example/lib/checkout.dart).

## Deposit

We've added an example that showcases a simple deposit flow for a fictional decentralized exchange. This shows you how easy it is to generate a payment request for something like a deposit.

Find the full example code [here](https://github.com/Beans-BV/merchant_sdk_dart/blob/main/example/lib/deposit.dart).

## Account Management

We've added an example that demonstrates how to create and manage company accounts. This example shows how to:
- Create a new account with multi-language support
- Upload an avatar for the account
- Retrieve and display the avatar
- Delete an account when it's no longer needed

This functionality is particularly useful for businesses that need to manage multiple Stellar accounts under a single company account.

Find the full example code [here](https://github.com/Beans-BV/merchant_sdk_dart/blob/main/example/lib/account.dart).

## Developer

We've added an advanced example that showcases all the features of the Beans Merchant SDK. This example demonstrates how you can use the SDK to generate a payment request, a QR code, and a deeplink.

Find the full example code [here](https://github.com/Beans-BV/merchant_sdk_dart/blob/main/example/lib/developer.dart).

# Questions and Answers

## Do I have to use stroops?

Our platform utilizes Stellar blockchain technology to simplify digital transactions, making it accessible even to those unfamiliar with cryptocurrencies. We've streamlined the payment process using `Stellar Lumen (XLM)` and other cryptocurrencies, allowing you to transact in main currency units instead of dealing with complex conversions like `stroops`. For example, to request a payment of `1 XLM`, you just set the amoun to `"1"` and our system automatically handles the conversion to `10,000,000 stroops`, ensuring a user-friendly payment experience.
