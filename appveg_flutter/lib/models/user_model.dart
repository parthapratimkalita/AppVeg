class User {
  final String id;
  final String email;
  final String username;
  final String name;
  final DateTime createdAt;
  final List<String> favorites;
  final String? profileImageUrl;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.name,
    required this.createdAt,
    this.favorites = const [],
    this.profileImageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      favorites: List<String>.from(json['favorites'] as List? ?? []),
      profileImageUrl: json['profile_image_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'favorites': favorites,
      'profile_image_url': profileImageUrl,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? name,
    DateTime? createdAt,
    List<String>? favorites,
    String? profileImageUrl,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      favorites: favorites ?? this.favorites,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    );
  }
}
