class StellarCurrency {
  const StellarCurrency({
    required this.id,
    required this.name,
    required this.code,
    required this.issuerId,
    required this.issuerName,
    required this.precision,
    required this.iconUrl,
  });

  final String id;
  final String name;
  final String code;
  final String issuerId;
  final String issuerName;
  final int precision;
  final String iconUrl;

  factory StellarCurrency.fromJson(Map<String, dynamic> json) {
    return StellarCurrency(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      issuerId: json['issuerId'],
      issuerName: json['issuerName'],
      precision: json['precision'],
      iconUrl: json['iconUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'issuerId': issuerId,
      'issuerName': issuerName,
      'precision': precision,
      'iconUrl': iconUrl,
    };
  }
}
