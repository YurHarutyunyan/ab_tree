class UserModel {
  final String? id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String passwordHash;
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.passwordHash,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to JSON for MongoDB
  Map<String, dynamic> toJson() {
    return {
      if (id != null) '_id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id']?.toString(),
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      passwordHash: json['passwordHash'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  // Create a copy with updated fields
  UserModel copyWith({
    String? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? passwordHash,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
