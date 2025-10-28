import 'company_account.dart';

class GetCompanyAccountResponse {
  final CompanyAccount account;

  GetCompanyAccountResponse({
    required this.account,
  });

  factory GetCompanyAccountResponse.fromJson(Map<String, dynamic> json) {
    return GetCompanyAccountResponse(
      account: CompanyAccount.fromJson(json['account']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account.toJson(),
    };
  }
}
