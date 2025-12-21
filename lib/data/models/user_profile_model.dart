class UserProfileModel {
  final String id;
  final String displayName;
  final String email;
  final String role;
  final String? profileColorHex;
  final String? avatarUrl;

  UserProfileModel({
    required this.id,
    required this.displayName,
    required this.email,
    required this.role,
    this.profileColorHex,
    this.avatarUrl,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'].toString(),
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
      profileColorHex: json['profileColorHex'],
      avatarUrl: json['avatarUrl'],
    );
  }
}
