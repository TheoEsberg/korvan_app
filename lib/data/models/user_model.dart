class UserModel {
  final String id;
  final String displayName;

  UserModel({required this.id, required this.displayName});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(id: json['id'], displayName: json['displayName']);
  }
}
