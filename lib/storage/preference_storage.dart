/// Key-value store for preferences
///
/// Write methods create a key or replace its value. A missing key reads as null
abstract interface class PreferenceStorage {
  /// Keys that currently have a value
  Future<Set<String>> readKeys();

  /// Whether [key] has a stored value
  Future<bool> contains(String key);

  /// Reads the string stored for [key]
  ///
  /// Null when [key] has no value
  Future<String?> readString(String key);

  /// Reads the integer stored for [key]
  ///
  /// Null when [key] has no value
  Future<int?> readInt(String key);

  /// Reads the floating-point number stored for [key]
  ///
  /// Null when [key] has no value
  Future<double?> readDouble(String key);

  /// Reads the boolean stored for [key]
  ///
  /// Null when [key] has no value
  Future<bool?> readBool(String key);

  /// Reads the string list stored for [key]
  ///
  /// Null when [key] has no value
  Future<List<String>?> readStringList(String key);

  /// Creates or replaces the string stored for [key]
  Future<void> writeString(String key, String value);

  /// Creates or replaces the integer stored for [key]
  Future<void> writeInt(String key, int value);

  /// Creates or replaces the floating-point number stored for [key]
  Future<void> writeDouble(String key, double value);

  /// Creates or replaces the boolean stored for [key]
  Future<void> writeBool(String key, bool value);

  /// Creates or replaces the string list stored for [key]
  Future<void> writeStringList(String key, List<String> value);

  /// Removes the value stored for [key]
  ///
  /// Does nothing when [key] is absent
  Future<void> delete(String key);

  /// Removes every value written through this store
  ///
  /// Values stored by other owners of the same preferences file stay in place
  Future<void> clear();
}
