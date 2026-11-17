import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_api.dart';

class AuthSessionStore {
  AuthSessionStore({FlutterSecureStorage? storage}) : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'rebs_auth_session';
  final FlutterSecureStorage _storage;

  Future<void> save(AuthSession session) async {
    await _storage.write(
      key: _key,
      value: jsonEncode({
        'token': session.token,
        'expires_at': session.expiresAt?.toIso8601String(),
        'user': {
          'id': session.user.id,
          'email': session.user.email,
          'name': session.user.name,
          'role': session.user.role,
        },
      }),
    );
  }

  Future<AuthSession?> load() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final session = AuthSession.fromJson(decoded.cast<String, dynamic>());
      if (session.token.isEmpty || (session.expiresAt != null && session.expiresAt!.isBefore(DateTime.now().toUtc()))) {
        await clear();
        return null;
      }
      return session;
    } catch (_) {
      await clear();
      return null;
    }
  }

  Future<void> clear() => _storage.delete(key: _key);
}
