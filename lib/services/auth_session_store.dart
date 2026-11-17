import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'auth_api.dart';

class AuthSessionStore {
  static const _key = 'rebs_auth_session';

  Future<void> save(AuthSession session) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_key, jsonEncode({
      'token': session.token,
      'expires_at': session.expiresAt?.toIso8601String(),
      'user': {
        'id': session.user.id,
        'email': session.user.email,
        'name': session.user.name,
        'role': session.user.role,
      },
    }));
  }

  Future<AuthSession?> load() async {
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(_key);
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

  Future<void> clear() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_key);
  }
}
