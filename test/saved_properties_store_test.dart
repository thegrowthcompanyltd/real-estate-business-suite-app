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

  test('ignores malformed saved IDs', () async {
    SharedPreferences.setMockInitialValues({
      'rebs_saved_property_ids': ['12', 'invalid', '7'],
    });

    expect(await SavedPropertiesStore().load(), {12, 7});
  });
}
