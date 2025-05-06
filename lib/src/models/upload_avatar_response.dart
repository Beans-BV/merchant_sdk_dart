class UploadAvatarResponse {
  final String avatarId;

  UploadAvatarResponse({
    required this.avatarId,
  });

  factory UploadAvatarResponse.fromJson(Map<String, dynamic> json) {
    return UploadAvatarResponse(
      avatarId: json['avatarId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'avatarId': avatarId,
    };
  }
} 