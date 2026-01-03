class UserListModel {
  final String id;
  final String displayName;

  UserListModel({required this.id, required this.displayName});

  factory UserListModel.fromJson(Map<String, dynamic> json) {
    return UserListModel(
      id: json['id'].toString(),
      displayName: json['displayName']?.toString() ?? '',
    );
  }
}
