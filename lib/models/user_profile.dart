class UserProfile {
  final String id;
  final String email;
  final String preferredName;

  const UserProfile({
    required this.id,
    required this.email,
    required this.preferredName,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        id: json['id'] as String,
        email: json['email'] as String,
        preferredName: json['preferredName'] as String? ?? '',
      );
}
