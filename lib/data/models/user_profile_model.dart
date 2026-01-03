class UserProfileModel {
  final String id;
  final String displayName;
  final String email;
  final String role;
  final String? profileColorHex;
  final bool hasAvatar;

  UserProfileModel({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
    this.profileColorHex,
    required this.hasAvatar,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'].toString(),
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      profileColorHex: json['profileColorHex'],
      hasAvatar: json['hasAvatar'] ?? false,
    );
  }
}
