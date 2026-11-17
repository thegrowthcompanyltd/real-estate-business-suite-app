import 'dart:convert';

import 'package:http/http.dart' as http;

import 'app_config.dart';

class RebsApiException implements Exception {
  const RebsApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class RebsApiClient {
  RebsApiClient({required this.token, http.Client? client}) : _client = client ?? http.Client();

  final String token;
  final http.Client _client;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<Map<String, dynamic>> currentUser() async {
    final response = await _client.get(AppConfig.endpoint(AppConfig.authMePath), headers: _headers).timeout(const Duration(seconds: 20));
    return _decodeObject(response, fallback: 'Unable to load your account.');
  }

  Future<Set<int>> fetchSavedPropertyIds() async {
    final response = await _client.get(AppConfig.endpoint(AppConfig.savedPropertiesPath), headers: _headers).timeout(const Duration(seconds: 20));
    final decoded = _decodeObject(response, fallback: 'Unable to load saved properties.');
    final rawIds = decoded['property_ids'];
    if (rawIds is! List) throw const RebsApiException('The saved-property response was invalid.');
    return rawIds.map(_asInt).whereType<int>().where((id) => id > 0).toSet();
  }

  Future<Set<int>> updateSavedPropertyIds(Set<int> ids) async {
    final response = await _client
        .post(
          AppConfig.endpoint(AppConfig.savedPropertiesPath),
          headers: _headers,
          body: jsonEncode({'property_ids': ids.where((id) => id > 0).toList(growable: false)}),
        )
        .timeout(const Duration(seconds: 20));
    final decoded = _decodeObject(response, fallback: 'Unable to save your property list.');
    final rawIds = decoded['property_ids'];
    if (rawIds is! List) throw const RebsApiException('The saved-property response was invalid.');
    return rawIds.map(_asInt).whereType<int>().where((id) => id > 0).toSet();
  }

  Future<int> submitLead({required String name, required String email, int? propertyId, String? phone, String? message}) async {
    final body = <String, dynamic>{
      'name': name.trim(),
      'email': email.trim(),
      if (propertyId != null) 'property_id': propertyId,
      if (phone != null && phone.trim().isNotEmpty) 'phone': phone.trim(),
      if (message != null && message.trim().isNotEmpty) 'message': message.trim(),
    };
    final response = await _client.post(AppConfig.endpoint(AppConfig.leadsPath), headers: _headers, body: jsonEncode(body)).timeout(const Duration(seconds: 20));
    final decoded = _decodeObject(response, fallback: 'Unable to submit your inquiry.');
    final id = decoded['lead_id'];
    if (id is int) return id;
    if (id is num) return id.toInt();
    throw const RebsApiException('The inquiry response was invalid.');
  }

  int? _asInt(dynamic value) => value is num ? value.toInt() : int.tryParse('$value');

  Map<String, dynamic> _decodeObject(http.Response response, {required String fallback}) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = fallback;
      try {
        final error = jsonDecode(response.body);
        if (error is Map && error['message'] is String) message = error['message'] as String;
      } catch (_) {
        // Keep the safe fallback when the server response is not JSON.
      }
      throw RebsApiException(message, statusCode: response.statusCode);
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) throw const RebsApiException('The server returned an invalid response.');
    return decoded.cast<String, dynamic>();
  }
}
