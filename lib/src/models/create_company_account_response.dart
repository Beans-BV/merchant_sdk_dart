import 'company_account.dart';

class CreateCompanyAccountResponse {
  final CompanyAccount account;

  CreateCompanyAccountResponse({
    required this.account,
  });

  factory CreateCompanyAccountResponse.fromJson(Map<String, dynamic> json) {
    return CreateCompanyAccountResponse(
      account: CompanyAccount.fromJson(json['account']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'account': account.toJson(),
    };
  }
} 