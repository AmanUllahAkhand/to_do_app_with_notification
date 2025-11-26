// lib/data/models/user_model.dart
class User {
  final int id;
  final String name;
  final String email;
  final String? createdAt;
  final String? updatedAt;

  User({required this.id, required this.name, required this.email, this.createdAt, this.updatedAt});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }
}

// lib/data/models/auth_response.dart
class RegisterResponse {
  final String message;
  final User? user;

  RegisterResponse({required this.message, this.user});

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      message: json['message'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class LoginResponse {
  final String message;
  final String token;
  final User user;

  LoginResponse({required this.message, required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message'],
      token: json['token'],
      user: User.fromJson(json['user']),
    );
  }
}