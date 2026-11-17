import 'package:shared_preferences/shared_preferences.dart';

class SavedPropertiesStore {
  static const _key = 'rebs_saved_property_ids';

  Future<Set<int>> load() async {
    final preferences = await SharedPreferences.getInstance();
    return (preferences.getStringList(_key) ?? const <String>[])
        .map(int.tryParse)
        .whereType<int>()
        .toSet();
  }

  Future<void> save(Set<int> ids) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_key, ids.map((id) => '$id').toList(growable: false));
  }
}
