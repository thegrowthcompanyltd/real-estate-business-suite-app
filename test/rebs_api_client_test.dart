import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import '../lib/services/rebs_api_client.dart';

class _FakeClient extends http.BaseClient {
  _FakeClient(this.responseBody, this.statusCode);

  final Object responseBody;
  final int statusCode;
  late http.BaseRequest lastRequest;
  String? lastBody;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    lastRequest = request;
    if (request is http.Request) lastBody = request.body;
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(responseBody))),
      statusCode,
      headers: {'content-type': 'application/json'},
      request: request,
    );
  }
}

void main() {
  test('fetches saved property IDs with bearer authentication', () async {
    final client = _FakeClient({'property_ids': ['8', 13, 'invalid']}, 200);

    final ids = await RebsApiClient(token: 'secret-token', client: client).fetchSavedPropertyIds();

    expect(ids, {8, 13});
    expect(client.lastRequest.method, 'GET');
    expect(client.lastRequest.headers['authorization'], 'Bearer secret-token');
    expect(client.lastRequest.url.path, '/wp-json/rebs/v1/saved-properties');
  });

  test('updates saved property IDs and filters non-positive IDs', () async {
    final client = _FakeClient({'property_ids': [4, 9]}, 200);

    final ids = await RebsApiClient(token: 'secret-token', client: client).updateSavedPropertyIds({4, 0, -2, 9});

    expect(ids, {4, 9});
    expect(client.lastRequest.method, 'POST');
    expect(jsonDecode(client.lastBody!), {'property_ids': [4, 9]});
  });

  test('converts authenticated API errors into RebsApiException', () async {
    final client = _FakeClient({'message': 'Session expired.'}, 401);

    expect(
      () => RebsApiClient(token: 'expired-token', client: client).fetchSavedPropertyIds(),
      throwsA(isA<RebsApiException>().having((error) => error.statusCode, 'statusCode', 401)),
    );
  });
}
