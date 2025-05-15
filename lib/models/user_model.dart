class User {
  final String id;
  final String username;
  final String email;
  final String role;
  final String avatarUrl;
  final String joinDate;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    required this.avatarUrl,
    required this.joinDate, 
    required String phone,
  });

  // Create a copy of the user with updated fields
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? avatarUrl,
    String? joinDate,
    required String phone,
  }) {
    return User(
      id: id ?? this.id,
      username: name ?? this.username,
      email: email ?? this.email,
      role: role ?? this.role,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      joinDate: joinDate ?? this.joinDate, 
      phone: phone,
    );
  }

  // Convert user to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': username,
      'email': email,
      'role': role,
      'avatarUrl': avatarUrl,
      'joinDate': joinDate,
    };
  }

  // Create a user from a map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['name'],
      email: map['email'],
      role: map['role'],
      avatarUrl: map['avatarUrl'],
      joinDate: map['joinDate'], 
      phone:map['phone'],
    );
  }

  get phone => null;
}
