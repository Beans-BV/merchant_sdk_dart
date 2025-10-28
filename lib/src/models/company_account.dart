import 'language_string.dart';

class CompanyAccount {
  final String id;
  final String companyId;
  final String stellarAccountId;
  final LanguageString name;
  final String? avatarId;

  CompanyAccount({
    required this.id,
    required this.companyId,
    required this.stellarAccountId,
    required this.name,
    this.avatarId,
  });

  factory CompanyAccount.fromJson(Map<String, dynamic> json) {
    return CompanyAccount(
      id: json['id'],
      companyId: json['companyId'],
      stellarAccountId: json['stellarAccountId'],
      name: LanguageString.fromJson(json['name'] ?? {}),
      avatarId: json['avatarId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'stellarAccountId': stellarAccountId,
      'name': name.toJson(),
      'avatarId': avatarId,
    };
  }
}
