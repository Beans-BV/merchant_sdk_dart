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
  - [BeansMerchantSdkDomain](#beansmerchantsdkdomain)
    - [Constants](#constants)
  - [BeansMerchantSdk](#beansmerchantsdk)
    - [Constructor](#constructor)
    - [Methods](#methods)
      - [Fetch Stellar Currencies](#fetch-stellar-currencies)
      - [Generate Deeplink](#generate-deeplink)
      - [Generate PNG QR Code](#generate-png-qr-code)
      - [Generate SVG QR Code](#generate-svg-qr-code)
      - [Create Company Account](#create-company-account)
      - [Delete Company Account](#delete-company-account)
      - [Upload Company Account Avatar](#upload-company-account-avatar)
      - [Get Company Account Avatar](#get-company-account-avatar)
  - [Webhook Notifications](#webhook-notifications)
- [Examples](#examples)
  - [Checkout](#checkout)
  - [Deposit](#deposit)
  - [Sub-account Management](#sub-account-management)
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

You can install the package using npm:

```bash
npm install beans-merchant-sdk
```

## Usage

```dart
import 'package:beans_merchant_sdk/beans_merchant_sdk.dart';

// Create an instance of BeansMerchantSdk
final sdk = BeansMerchantSdk(
  apiKey: 'apiKey',
);

// Fetch currencies
final response = await sdk.fetchStellarCurrencies('stellarAccountId');
log('Available Stellar currencies: ${response.stellarCurrencies}');

// Generate deeplink
final response = await.generateDeeplink('stellarAccountId', 'stellarCurrencyId', 100, 'memo', 1, 'https://your-domain.com/webhook');
log('Generated deeplink: ${response.deeplink}');

// Generate SVG QR code
final response = await sdk.generateSvgQRCode('stellarAccountId', 'stellarCurrencyId', 100, 'memo', 1, 'https://your-domain.com/webhook', 250);
log('Generated deeplink: ${response.deeplink}');
log('Generated SVG QR code: ${response.svgQrCode}');

// Generate PNG QR code
final response = await merchant.generatePngQRCode('stellarAccountId', 'stellarCurrencyId', 100, 'memo', 1, 'https://your-domain.com/webhook', 250);
log('Generated deeplink: ${response.deeplink}');
log('Generated PNG QR code: ${response.pngQrCodeBase64String}');

// Create a company sub-account
final name = {
  'en': "Marketing Account",
  'vi': "Tài khoản Marketing"
};
final accountResponse = await sdk.createCompanyAccount(
  "GBZX4364PEPQTDICMIQDZ56K4T75QZCR4NBEYKO6PDRJAHZKGUOJPCXB",
  name
);
log('Created company account: ${accountResponse.account.id}');

// Upload avatar for a company sub-account
final imageBytes = await File('path_to_image.jpg').readAsBytes();
final updatedAccount = await sdk.uploadCompanyAccountAvatar(
  "me",
  "GBZX4364PEPQTDICMIQDZ56K4T75QZCR4NBEYKO6PDRJAHZKGUOJPCXB",
  imageBytes,
  "image/jpeg"
);
log('Account updated with avatar: ${updatedAccount.avatarId}');

// Get avatar for a company sub-account
final avatarBytes = await sdk.getCompanyAccountAvatar(
  "me",
  accountId,
  avatarId
);
// Use avatarBytes to display the image

// Xóa sub-account
final response = await sdk.deleteCompanyAccount('GCQYCNYU3T73JCQ2J36A3JJ5CUQO4DY4EOKMPUL5723ZH7N6XMMNPAA3');
log('Deleted account with ID: ${response.account.id}');
log('Deletion status: ${response.status}');
```

# API Reference

The Beans Merchant SDK provides a simple and intuitive interface for interacting with the Beans Merchant API. This section outlines the available methods and response objects provided by the SDK.

## BeansMerchantSdkDomain

The `BeansMerchantSdkDomain` class provides constants for setting the API domain.

### Constants

- `production`: The production API domain (`api.beansapp.com`).
- `staging`: The sandbox API domain (`api.staging.beansapp.com`).

## BeansMerchantSdk

The `BeansMerchantSdk` class provides methods for interacting with the Beans Merchant API.

### Constructor

`BeansMerchantSdk(...)`: Initializes a new SDK instance.

Parameters:
- `apiDomain` *(optional)*: The domain of the merchant API. *Default is `api.beansapp.com`.*
- `apiKey`: Your Beans Merchant API key.

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
*`Future<DeeplinkResponse> generateDeeplink(...)`*

Parameters:<br>
  - `stellarAccountId`: *Your Stellar account ID.*
  - `currencyId`: *Stellar currency ID.*
  - `amount`: *Amount for the payment request.*
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
final response = await.generateDeeplink('stellarAccountId', 'stellarCurrencyId', 100, 'memo', 1, 'https://your-domain.com/webhook');
log('Generated deeplink: ${response.deeplink}');
```

#### Generate PNG QR Code

*Generates a PNG QR code for payment requests.*

Method Signature:<br>
*`Future<PngQrCodeResponse> generatePngQrCode(...)`*

Parameters:<br>
  - `stellarAccountId`: *Your Stellar account ID.*
  - `currencyId`: *Stellar currency ID.*
  - `amount`: *Amount for the payment request.*
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
final response = await merchant.generatePngQRCode('stellarAccountId', 'stellarCurrencyId', 100, 'memo', 1, 'https://your-domain.com/webhook', 250);
log('Generated deeplink: ${response.deeplink}');
log('Generated PNG QR code: ${response.pngQrCodeBase64String}');
```

#### Generate SVG QR Code

*Generates an SVG QR code for payment requests.*

Method Signature:<br>
*`Future<SvgQrCodeResponse> generateSvgQrCode(...)`*

Parameters:<br>
  - `stellarAccountId`: *Your Stellar account ID.*
  - `currencyId`: *Stellar currency ID.*
  - `amount`: *Amount for the payment request.*
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
final response = await sdk.generateSvgQRCode('stellarAccountId', 'stellarCurrencyId', 100, 'memo', 1, 'https://your-domain.com/webhook', 250);
log('Generated deeplink: ${response.deeplink}');
log('Generated SVG QR code: ${response.svgQrCode}');
```

#### Create Company Account

*Creates a sub-account for the company.*

Method Signature:<br>
*`Future<CreateCompanyAccountResponse> createCompanyAccount(...)`*

Parameters:<br>
  - `stellarAccountId`: *The Stellar account ID for the sub-account.*
  - `name`: *The name of the sub-account in different languages as a LanguageString object.*

Returns:<br>
`Future<CreateCompanyAccountResponse>`: *A future that resolves with the response object containing the created company account.*

Return Object Properties:<br>
  - `account`: *The CompanyAccount object representing the created sub-account.*

#### Delete Company Account

*Deletes a sub-account for the company.*

Method Signature:<br>
*`Future<DeleteCompanyAccountResponse> deleteCompanyAccount(...)`*

Parameters:<br>
  - `stellarAccountId`: *The Stellar account ID of the sub-account to delete.*

Returns:<br>
`Future<DeleteCompanyAccountResponse>`: *A future that resolves with the response object containing information about the deleted sub-account.*

Return Object Properties:<br>
  - `account`: *The CompanyAccount object representing the deleted sub-account.*
  - `status`: *The status of the deletion operation, typically "deleted".*

Example:<br>
```dart
final name = LanguageString(
  en: "Marketing Account",
  vi: "Tài khoản Marketing"
);
final response = await sdk.createCompanyAccount(
  "GBZX4364PEPQTDICMIQDZ56K4T75QZCR4NBEYKO6PDRJAHZKGUOJPCXB",
  name
);
log('Created company account: ${response.account.id}');

final response = await sdk.deleteCompanyAccount('GCQYCNYU3T73JCQ2J36A3JJ5CUQO4DY4EOKMPUL5723ZH7N6XMMNPAA3');
log('Deleted account with ID: ${response.account.id}');
log('Deletion status: ${response.status}');
```


#### Upload Company Account Avatar

*Uploads an avatar for a company sub-account.*

Method Signature:<br>
*`Future<CompanyAccount> uploadCompanyAccountAvatar(...)`*

Parameters:<br>
  - `companyId`: *The ID of the company or 'me' for the current company.*
  - `stellarAccountId`: *The Stellar account ID of the sub-account.*
  - `imageBytes`: *The image data as Uint8List (bytes).*
  - `mimeType`: *The MIME type of the image (e.g., 'image/jpeg', 'image/png').*

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

*Gets the avatar for a company sub-account.*

Method Signature:<br>
*`Future<Uint8List> getCompanyAccountAvatar(...)`*

Parameters:<br>
  - `companyId`: *The ID of the company or 'me' for the current company.*
  - `accountId`: *The ID of the sub-account.*
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

## Webhook Notifications

*Beans Merchant API sends a webhook notification to the provided URL when a payment is received.*

Example Webhook Payload:<br>
```darton
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

## Sub-account Management

We've added an example that demonstrates how to create and manage company sub-accounts. This example shows how to:
- Create a new sub-account with multi-language support
- Upload an avatar for the sub-account
- Retrieve and display the avatar
- Delete a sub-account when it's no longer needed

This functionality is particularly useful for businesses that need to manage multiple Stellar accounts under a single company account.

Find the full example code [here](https://github.com/Beans-BV/merchant_sdk_dart/blob/main/example/lib/subaccount.dart).

## Developer

We've added an advanced example that showcases all the features of the Beans Merchant SDK. This example demonstrates how you can use the SDK to generate a payment request, a QR code, and a deeplink.

Find the full example code [here](https://github.com/Beans-BV/merchant_sdk_dart/blob/main/example/lib/developer.dart).

# Questions and Answers

## Do I have to use stroops?

Our platform utilizes Stellar blockchain technology to simplify digital transactions, making it accessible even to those unfamiliar with cryptocurrencies. We've streamlined the payment process using `Stellar Lumen (XLM)` and other cryptocurrencies, allowing you to transact in main currency units instead of dealing with complex conversions like `stroops`. For example, to request a payment of `1 XLM`, you just set the amoun to `"1"` and our system automatically handles the conversion to `10,000,000 stroops`, ensuring a user-friendly payment experience.
