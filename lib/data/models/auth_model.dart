// User/Auth Models

class UserModel {
  final int id;
  final String name;
  final String email;
  final String role;
  final String status;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        role: json['role'] as String? ?? 'user',
        status: json['status'] as String? ?? 'Active',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'status': status,
      };

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? status,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        role: role ?? this.role,
        status: status ?? this.status,
      );
}

class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
      };
}

class RegisterRequest {
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;

  const RegisterRequest({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation, // Sesuai dengan laravel validation rules
      };
}

class AuthResponse {
  final UserModel user;
  final String token;

  const AuthResponse({
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Menangani response terbungkus 'data' dari AuthController API Laravel
    final data = json['data'] as Map<String, dynamic>;
    return AuthResponse(
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      token: data['token'] as String,
    );
  }
}