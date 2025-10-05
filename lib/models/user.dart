class User {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String department;
  final bool isStaff;
  final String? password;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.department,
    required this.isStaff,
    this.password,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      department: json['department'] ?? '',
      isStaff: json['is_staff'] ?? false,
      password: json['password'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'department': department,
      'is_staff': isStaff,
      if (password != null) 'password': password,
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? department,
    bool? isStaff,
    String? password,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      department: department ?? this.department,
      isStaff: isStaff ?? this.isStaff,
      password: password ?? this.password,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, username: $username, email: $email, name: $firstName $lastName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
