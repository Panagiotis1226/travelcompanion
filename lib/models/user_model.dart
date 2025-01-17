class UserModel {
  final String uid;
  final String email;
  final String name;
  String? profilePhotoUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.profilePhotoUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'profilePhotoUrl': profilePhotoUrl,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      profilePhotoUrl: map['profilePhotoUrl'],
    );
  }
} 