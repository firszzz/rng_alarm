import 'package:flutter_test/flutter_test.dart';
import 'package:rng_alarm/features/alarms/data/alarms_storage.dart';
import 'package:rng_alarm/features/alarms/data/dto/alarm_dto.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('$AlarmsStorage', () {
    late SharedPreferences preferences;
    late AlarmsStorage storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      preferences = await SharedPreferences.getInstance();
      storage = AlarmsStorage(preferences);
    });

    test('Writes and reads a string', () async {
      await storage.writeString('name', 'Alarm');

      expect(await storage.readString('name'), 'Alarm');
      expect(await storage.contains('name'), isTrue);
    });

    test('Writes and reads an int', () async {
      await storage.writeInt('count', 2);

      expect(await storage.readInt('count'), 2);
    });

    test('Writes and reads a double', () async {
      await storage.writeDouble('volume', 0.5);

      expect(await storage.readDouble('volume'), 0.5);
    });

    test('Writes and reads a bool', () async {
      await storage.writeBool('enabled', true);

      expect(await storage.readBool('enabled'), isTrue);
    });

    test('Writes and reads a string list', () async {
      await storage.writeStringList('ids', ['1', '2']);

      expect(await storage.readStringList('ids'), ['1', '2']);
    });

    test('Reads null when a key is missing', () async {
      expect(await storage.readString('missing'), isNull);
      expect(await storage.contains('missing'), isFalse);
    });

    test('Deletes one key', () async {
      await storage.writeString('name', 'Alarm');

      await storage.delete('name');

      expect(await storage.readString('name'), isNull);
    });

    test('Clear removes only keys written through this store', () async {
      await preferences.setString('plugin.key', 'stay');
      await storage.writeString('name', 'Alarm');

      await storage.clear();

      expect(preferences.getString('plugin.key'), 'stay');
      expect(await storage.readKeys(), isEmpty);
    });

    test('Keeps the hidden ring minute in an alarm record', () async {
      final record = AlarmDto(
        id: '1',
        nativeId: 7,
        fromHour: 6,
        fromMinute: 40,
        toHour: 7,
        toMinute: 0,
        name: 'Подъём',
        isEnabled: true,
        vibrates: true,
        ringHour: 6,
        ringMinute: 47,
        scheduledAt: DateTime(2026, 10, 11, 6, 47),
      );

      await storage.writeRecords([record]);

      expect(await storage.readRecords(), [record]);
    });
  });
}
