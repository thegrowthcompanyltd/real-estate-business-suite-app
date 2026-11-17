import 'package:shared_preferences/shared_preferences.dart';

class SavedPropertiesStore {
  static const _legacyKey = 'rebs_saved_property_ids';

  Future<Set<int>> load({int? userId}) async {
    final preferences = await SharedPreferences.getInstance();
    return _read(preferences.getStringList(_key(userId)));
  }

  Future<void> save(Set<int> ids, {int? userId}) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(_key(userId), ids.map((id) => '$id').toList(growable: false));
  }

  String _key(int? userId) => userId == null ? _legacyKey : '$_legacyKey.user.$userId';

  Set<int> _read(List<String>? values) => (values ?? const <String>[]).map(int.tryParse).whereType<int>().where((id) => id > 0).toSet();
}
