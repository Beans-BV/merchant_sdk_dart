class CompanyAccount {
  final String id;
  final String companyId;
  final String stellarAccountId;
  final Map<String, String> name;
  final String? avatarId;

  CompanyAccount({
    required this.id,
    required this.companyId,
    required this.stellarAccountId,
    required this.name,
    this.avatarId,
  });

  factory CompanyAccount.fromJson(Map<String, dynamic> json) {
    final Map<String, String> nameMap = {};
    if (json['name'] is Map) {
      (json['name'] as Map).forEach((key, value) {
        if (value is String) {
          nameMap[key.toString()] = value;
        }
      });
    }

    return CompanyAccount(
      id: json['id'],
      companyId: json['companyId'],
      stellarAccountId: json['stellarAccountId'],
      name: nameMap,
      avatarId: json['avatarId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyId': companyId,
      'stellarAccountId': stellarAccountId,
      'name': name,
      'avatarId': avatarId,
    };
  }
} 