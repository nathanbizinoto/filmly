class User {
  int? id;
  final String email;
  final String passwordHash; // Senha será armazenada como hash
  final String? name;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    this.id,
    required this.email,
    required this.passwordHash,
    this.name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  // Converter para Map (para SQLite)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email.toLowerCase().trim(), // Normaliza o email
      'password_hash': passwordHash,
      'name': name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Criar User a partir de Map (do SQLite)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      passwordHash: map['password_hash'],
      name: map['name'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  User copyWith({
    int? id,
    String? email,
    String? passwordHash,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User{id: $id, email: $email, name: $name}';
  }
}

