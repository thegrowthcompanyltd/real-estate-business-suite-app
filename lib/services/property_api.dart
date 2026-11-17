import 'dart:convert';

import 'package:http/http.dart' as http;

import 'app_config.dart';

class Property {
  const Property({
    required this.id,
    required this.title,
    required this.price,
    required this.currency,
    required this.location,
    required this.transaction,
    this.description = '',
    this.image,
    this.bedrooms,
    this.bathrooms,
    this.propertyType,
    this.area,
    this.gallery = const <String>[],
  });

  final int id;
  final String title;
  final String price;
  final String currency;
  final String location;
  final String transaction;
  final String description;
  final String? image;
  final String? bedrooms;
  final String? bathrooms;
  final String? propertyType;
  final String? area;
  final List<String> gallery;

  factory Property.fromJson(Map<String, dynamic> json) {
    final rawGallery = json['gallery'];
    return Property(
      id: _asInt(json['id']),
      title: _asString(json['title'], fallback: 'Untitled property'),
      price: _asString(json['price']),
      currency: _asString(json['currency']),
      location: _asString(json['location'], fallback: 'Location unavailable'),
      transaction: _asString(json['transaction']),
      description: _asString(json['description']),
      image: _nullableString(json['image']),
      bedrooms: _nullableString(json['bedrooms']),
      bathrooms: _nullableString(json['bathrooms']),
      propertyType: _nullableString(json['property_type']),
      area: _nullableString(json['area']),
      gallery: rawGallery is List ? rawGallery.whereType<String>().toList(growable: false) : const <String>[],
    );
  }

  static int _asInt(dynamic value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  static String _asString(dynamic value, {String fallback = ''}) => value == null ? fallback : '$value';
  static String? _nullableString(dynamic value) => value == null || '$value'.isEmpty ? null : '$value';
}

class PropertyApi {
  PropertyApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Property>> fetchProperties() async {
    final response = await _client.get(AppConfig.endpoint(AppConfig.propertiesPath)).timeout(const Duration(seconds: 20));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Property API returned HTTP ${response.statusCode}.');
    }
    final decoded = jsonDecode(response.body);
    if (decoded is! List) throw const FormatException('Property API returned an invalid response.');
    return decoded.whereType<Map<String, dynamic>>().map(Property.fromJson).toList(growable: false);
  }
}
