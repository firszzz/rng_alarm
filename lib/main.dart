import 'package:flutter/widgets.dart';
import 'package:rng_alarm/app/rng_alarm_app.dart';
import 'package:rng_alarm/di/injector.dart';
import 'package:rng_alarm/features/alarms/di/alarms_di.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AlarmsDI.init(injector);

  runApp(const RngAlarmApp());
}
