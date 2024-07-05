class UserModel {
  String id;
  String name;
  String email;
  String profilePictureUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.profilePictureUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  static UserModel fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      id: documentId,
      name: map['name'],
      email: map['email'],
      profilePictureUrl: map['profilePictureUrl'],
    );
  }
}
