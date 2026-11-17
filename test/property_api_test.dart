import 'package:flutter_test/flutter_test.dart';

import '../lib/services/property_api.dart';

void main() {
  test('parses extended property fields and gallery', () {
    final property = Property.fromJson({
      'id': '42',
      'title': 'City apartment',
      'price': 250000,
      'currency': 'EUR',
      'location': 'Lisbon',
      'transaction': 'sale',
      'description': 'Bright two-bedroom apartment.',
      'image': 'https://example.com/main.jpg',
      'bedrooms': 2,
      'bathrooms': 1,
      'property_type': 'Apartment',
      'area': '86 m²',
      'gallery': ['https://example.com/one.jpg', 7, 'https://example.com/two.jpg'],
    });

    expect(property.id, 42);
    expect(property.title, 'City apartment');
    expect(property.price, '250000');
    expect(property.bedrooms, '2');
    expect(property.bathrooms, '1');
    expect(property.propertyType, 'Apartment');
    expect(property.gallery, ['https://example.com/one.jpg', 'https://example.com/two.jpg']);
  });

  test('uses safe defaults for missing property values', () {
    final property = Property.fromJson({'id': 'not-a-number'});

    expect(property.id, 0);
    expect(property.title, 'Untitled property');
    expect(property.location, 'Location unavailable');
    expect(property.image, isNull);
    expect(property.gallery, isEmpty);
  });
}
