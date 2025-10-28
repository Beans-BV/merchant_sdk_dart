## 5.0.0
* Added `LanguageString` class for better multi-language support
* Added `getCompanyAccounts()` method to fetch all company accounts
* 
* **BREAKING CHANGES:**
*  - Renamed `getMerchantAccount()` to `getCompanyAccount()` for consistency
*  - `createCompanyAccount()` now requires `LanguageString` instead of `Map<String, String>`
*  - English language ('en') is now required for all `LanguageString` instances

## 4.0.0
* Beans API v4 support
* 
* **BREAKING CHANGES:**
*  - API version increased from v3 to v4

## 2.0.0
* Improved the SDK initialization process
* 
* **BREAKING CHANGES:**
*  - Removed `BeansMerchantSdkDomain` class
*  - Added static factory method `BeansMerchantSdk.production(..)` to instantiate the SDK
*  - Added static factory method `BeansMerchantSdk.staging(..)` to instantiate the SDK
*  - Added static factory method `BeansMerchantSdk.custom(..)` to instantiate the SDK

## 1.0.1
* Updated `README.md`

## 1.0.0
* Initial release