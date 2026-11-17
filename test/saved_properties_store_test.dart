import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../lib/services/saved_properties_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('saves and loads property IDs', () async {
    final store = SavedPropertiesStore();

    await store.save({9, 3, 9});

    expect(await store.load(), {9, 3});
  });

  test('isolates saved IDs by user', () async {
    final store = SavedPropertiesStore();

    await store.save({12}, userId: 4);
    await store.save({21}, userId: 7);

    expect(await store.load(userId: 4), {12});
    expect(await store.load(userId: 7), {21});
    expect(await store.load(), isEmpty);
  });

  test('ignores malformed and non-positive saved IDs', () async {
    SharedPreferences.setMockInitialValues({
      'rebs_saved_property_ids.user.4': ['12', 'invalid', '0', '-7'],
    });

    expect(await SavedPropertiesStore().load(userId: 4), {12});
  });
}
