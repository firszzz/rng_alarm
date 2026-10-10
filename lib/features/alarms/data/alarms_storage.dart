import 'dart:convert';

import 'package:rng_alarm/features/alarms/data/dto/alarm_dto.dart';
import 'package:rng_alarm/storage/preference_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Preference store that also keeps the alarm list
///
/// Typed values go through [PreferenceStorage]. Alarm records, including the
/// hidden ring minute, are stored under a separate key. Keys are namespaced so
/// [clear] does not remove values owned by other users of the same file, such
/// as the native alarm plugin
class AlarmsStorage implements PreferenceStorage {
  AlarmsStorage(this._preferences);

  static const _prefix = 'pref.';
  static const _recordsKey = 'alarms';

  final SharedPreferences _preferences;

  /// Alarm records in list order
  ///
  /// Empty when nothing has been saved
  Future<List<AlarmDto>> readRecords() async {
    final raw = await readString(_recordsKey);
    if (raw == null || raw.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(raw);
    if (decoded is! List<dynamic>) {
      throw const FormatException('Alarm records must be a JSON list');
    }

    return decoded.map((item) {
      if (item is! Map) {
        throw const FormatException('An alarm record must be a JSON object');
      }
      return AlarmDto.fromJson(Map<String, dynamic>.from(item));
    }).toList();
  }

  /// Replaces the stored alarm list
  Future<void> writeRecords(List<AlarmDto> records) {
    final encoded = jsonEncode(records.map((record) => record.toJson()).toList());
    return writeString(_recordsKey, encoded);
  }

  @override
  Future<Set<String>> readKeys() async {
    return _preferences.getKeys().where((key) => key.startsWith(_prefix)).map((key) => key.substring(_prefix.length)).toSet();
  }

  @override
  Future<bool> contains(String key) async => _preferences.containsKey(_key(key));

  @override
  Future<String?> readString(String key) async => _preferences.getString(_key(key));

  @override
  Future<int?> readInt(String key) async => _preferences.getInt(_key(key));

  @override
  Future<double?> readDouble(String key) async => _preferences.getDouble(_key(key));

  @override
  Future<bool?> readBool(String key) async => _preferences.getBool(_key(key));

  @override
  Future<List<String>?> readStringList(String key) async {
    final value = _preferences.getStringList(_key(key));
    return value == null ? null : List<String>.of(value);
  }

  @override
  Future<void> writeString(String key, String value) => _write(() => _preferences.setString(_key(key), value));

  @override
  Future<void> writeInt(String key, int value) => _write(() => _preferences.setInt(_key(key), value));

  @override
  Future<void> writeDouble(String key, double value) => _write(() => _preferences.setDouble(_key(key), value));

  @override
  Future<void> writeBool(String key, bool value) => _write(() => _preferences.setBool(_key(key), value));

  @override
  Future<void> writeStringList(String key, List<String> value) {
    return _write(() => _preferences.setStringList(_key(key), value));
  }

  @override
  Future<void> delete(String key) => _write(() => _preferences.remove(_key(key)));

  @override
  Future<void> clear() async {
    final keys = await readKeys();
    for (final key in keys) {
      await delete(key);
    }
  }

  Future<void> _write(Future<bool> Function() write) async {
    final saved = await write();
    if (!saved) {
      throw StateError('Preference write failed');
    }
  }

  String _key(String key) => '$_prefix$key';
}
