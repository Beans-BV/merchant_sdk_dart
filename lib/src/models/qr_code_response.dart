class PaymentRequestResponse {
  const PaymentRequestResponse({
    required this.id,
  });

  final String id;

  factory PaymentRequestResponse.fromJson(Map<String, dynamic> json) {
    return PaymentRequestResponse(
      id: json['id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}

class DeeplinkResponse extends PaymentRequestResponse {
  const DeeplinkResponse({
    required super.id,
    required this.deeplink,
  });

  final String deeplink;

  factory DeeplinkResponse.fromJson(Map<String, dynamic> json) {
    return DeeplinkResponse(
      id: json['id'],
      deeplink: json['deeplink'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'deeplink': deeplink,
    };
  }
}

class SvgQrCodeResponse extends DeeplinkResponse {
  const SvgQrCodeResponse({
    required super.id,
    required super.deeplink,
    required this.svgQrCode,
  });

  final String svgQrCode;

  factory SvgQrCodeResponse.fromJson(Map<String, dynamic> json) {
    return SvgQrCodeResponse(
      id: json['id'],
      deeplink: json['deeplink'],
      svgQrCode: json['svgQrCode'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'svgQrCode': svgQrCode,
    };
  }
}

class PngQrCodeResponse extends DeeplinkResponse {
  const PngQrCodeResponse({
    required super.id,
    required super.deeplink,
    required this.pngQrCodeDataUri,
  });

  final String pngQrCodeDataUri;

  factory PngQrCodeResponse.fromJson(Map<String, dynamic> json) {
    return PngQrCodeResponse(
      id: json['id'],
      deeplink: json['deeplink'],
      pngQrCodeDataUri: json['pngQrCodeDataUri'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'pngQrCodeDataUri': pngQrCodeDataUri,
    };
  }
}
