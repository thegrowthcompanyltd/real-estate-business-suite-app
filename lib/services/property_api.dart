import 'dart:convert';

import 'package:http/http.dart' as http;

class Property {
  const Property({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    required this.location,
    required this.transaction,
  });

  final int id;
  final String title;
  final String price;
  final String currency;
  final String location;
  final String transaction;

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Untitled property',
      price: '${json['price'] ?? ''}',
      currency: json['currency'] as String? ?? '',
      location: json['location'] as String? ?? 'Location unavailable',
      transaction: json['transaction'] as String? ?? '',
    );
  }
}

class PropertyApi {
  PropertyApi({http.Client? client}) : _client = client ?? http.Client();

  static final _endpoint = Uri.parse(
    'https://realtyeasy.sitesavvvy.com/wp-json/rebs/v1/properties',
  );

  final http.Client _client;

  Future<List<Property>> fetchProperties() async {
    final response = await _client.get(_endpoint).timeout(const Duration(seconds: 20));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Property API returned HTTP ${response.statusCode}.');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const FormatException('Property API returned an invalid response.');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(Property.fromJson)
        .toList(growable: false);
  }
}
