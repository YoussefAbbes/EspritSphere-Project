class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role; // "admin" or "user"
  final String? profileImageUrl;

  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.profileImageUrl,
  });

  factory AppUser.fromMap(String id, Map<String, dynamic> data) {
    return AppUser(
      uid: id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user',
      profileImageUrl: data['profileImageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'profileImageUrl': profileImageUrl,
    };
  }
}
