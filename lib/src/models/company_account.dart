import 'language_string.dart';

class CompanyAccount {
  final String id;
  final String companyId;
  final String stellarAccountId;
  final LanguageString name;
  final Uri? avatarUrl;

  const CompanyAccount({
    required this.id,
    required this.companyId,
    required this.stellarAccountId,
    required this.name,
    required this.avatarUrl,
  });

  factory CompanyAccount.fromJson(Map<String, dynamic> json) {
    return CompanyAccount(
      id: json['id'],
      companyId: json['companyId'],
      stellarAccountId: json['stellarAccountId'],
      name: LanguageString.fromJson(json['name'] ?? {}),
      avatarUrl:
          json['avatarUrl'] != null ? Uri.parse(json['avatarUrl']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'stellarAccountId': stellarAccountId,
      'name': name.toJson(),
      'avatarUrl': avatarUrl?.toString(),
    };
  }
}
