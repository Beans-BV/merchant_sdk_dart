import 'company_account.dart';

class GetCompanyAccountsResponse {
  final List<CompanyAccount> accounts;

  GetCompanyAccountsResponse({
    required this.accounts,
  });

  factory GetCompanyAccountsResponse.fromJson(Map<String, dynamic> json) {
    return GetCompanyAccountsResponse(
      accounts: (json['accounts'] as List<dynamic>)
          .map((accountJson) => CompanyAccount.fromJson(accountJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accounts': accounts.map((account) => account.toJson()).toList(),
    };
  }
}
