import 'company_account.dart';

/// Response object returned when deleting a company account
class DeleteCompanyAccountResponse {
  /// The deleted account
  final CompanyAccount account;

  /// The status of the deletion operation
  final String status;

  DeleteCompanyAccountResponse({
    required this.account,
    required this.status,
  });

  factory DeleteCompanyAccountResponse.fromJson(Map<String, dynamic> json) {
    return DeleteCompanyAccountResponse(
      account: CompanyAccount.fromJson(json['account'] as Map<String, dynamic>),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'account': account.toJson(),
        'status': status,
      };
}
