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
  const AuthSession({required this.token, required this.user, this.expiresAt});

  final String token;
  final AuthUser user;
  final DateTime? expiresAt;

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        token: json['token'] as String? ?? '',
        user: AuthUser.fromJson((json['user'] as Map?)?.cast<String, dynamic>() ?? const {}),
        expiresAt: DateTime.tryParse(json['expires_at'] as String? ?? ''),
      );
}

class AuthApiException implements Exception {
  const AuthApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

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
    return _sessionFromResponse(response, fallback: 'Login failed. Please check your details and try again.');
  }

  Future<void> register({required String name, required String email, required String password, String? plan}) async {
    final response = await _client
        .post(
          AppConfig.endpoint(AppConfig.authRegisterPath),
          headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode({'name': name.trim(), 'email': email.trim(), 'password': password, if (plan != null) 'plan': plan}),
        )
        .timeout(const Duration(seconds: 20));
    if (response.statusCode < 200 || response.statusCode >= 300) throw _error(response, 'Registration failed. Please review your details and try again.');
  }

  AuthSession _sessionFromResponse(http.Response response, {required String fallback}) {
    if (response.statusCode < 200 || response.statusCode >= 300) throw _error(response, fallback);
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) throw const AuthApiException('The authentication response was invalid.');
    final session = AuthSession.fromJson(decoded.cast<String, dynamic>());
    if (session.token.isEmpty) throw const AuthApiException('The authentication response did not include a session token.');
    return session;
  }

  AuthApiException _error(http.Response response, String fallback) {
    var message = fallback;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['message'] is String) message = decoded['message'] as String;
    } catch (_) {
      // Keep the safe fallback for non-JSON responses.
    }
    return AuthApiException(message, statusCode: response.statusCode);
  }
}
