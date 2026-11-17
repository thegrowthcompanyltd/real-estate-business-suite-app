import 'dart:convert';

import 'package:http/http.dart' as http;

import 'app_config.dart';

class AuthUser {
  const AuthUser({required this.id, required this.email, required this.name, required this.role});

  final int id;
  final String email;
  final String name;
  final String role;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as int? ?? 0,
        email: json['email'] as String? ?? '',
        name: json['name'] as String? ?? '',
        role: json['role'] as String? ?? 'client',
      );
}

class AuthSession {
  const AuthSession({required this.token, required this.user});

  final String token;
  final AuthUser user;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        token: json['token'] as String? ?? '',
        user: AuthUser.fromJson((json['user'] as Map?)?.cast<String, dynamic>() ?? const {}),
      );
}

class AuthApiException implements Exception {
  const AuthApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class AuthApi {
  AuthApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<AuthSession> login({required String email, required String password}) async {
    final response = await _client
        .post(
          AppConfig.endpoint(AppConfig.authLoginPath),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode({'email': email.trim(), 'password': password}),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException('Login failed. Please check your details and try again.');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) throw const AuthApiException('The login response was invalid.');
    return AuthSession.fromJson(decoded.cast<String, dynamic>());
  }

  Future<AuthSession> register({required String name, required String email, required String password}) async {
    final response = await _client
        .post(
          AppConfig.endpoint(AppConfig.authRegisterPath),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode({'name': name.trim(), 'email': email.trim(), 'password': password}),
        )
        .timeout(const Duration(seconds: 20));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw AuthApiException('Registration failed. Please review your details and try again.');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) throw const AuthApiException('The registration response was invalid.');
    return AuthSession.fromJson(decoded.cast<String, dynamic>());
  }
}
