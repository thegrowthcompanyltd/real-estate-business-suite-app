import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../lib/services/auth_api.dart';

class _FakeClient extends http.BaseClient {
  _FakeClient(this.body, this.statusCode);

  final Map<String, dynamic> body;
  final int statusCode;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(body))),
      statusCode,
      headers: {'content-type': 'application/json'},
      request: request,
    );
  }
}

void main() {
  test('parses a token session and expiry', () async {
    final api = AuthApi(
      client: _FakeClient({
        'token': 'rebs_test_token',
        'expires_at': '2030-01-01T00:00:00Z',
        'user': {'id': 7, 'email': 'agent@example.com', 'name': 'Agent', 'role': 'rebs_agent'},
      }, 200),
    );

    final session = await api.login(email: 'agent@example.com', password: 'a-secure-password');

    expect(session.token, 'rebs_test_token');
    expect(session.user.id, 7);
    expect(session.user.role, 'rebs_agent');
    expect(session.expiresAt, DateTime.utc(2030, 1, 1));
  });

  test('converts API error messages into AuthApiException', () async {
    final api = AuthApi(client: _FakeClient({'message': 'Invalid email or password.'}, 401));

    expect(
      () => api.login(email: 'wrong@example.com', password: 'wrong-password'),
      throwsA(isA<AuthApiException>().having((error) => error.statusCode, 'statusCode', 401)),
    );
  });
}
