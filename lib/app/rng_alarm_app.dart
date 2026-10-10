import 'package:flutter/material.dart';
import 'package:rng_alarm/app/ui_theme.dart';
import 'package:rng_alarm/features/alarms/presentation/list/alarms_screen.dart';

/// Root widget of the alarm application
class RngAlarmApp extends StatelessWidget {
  const RngAlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Будильник', theme: UITheme.dark.toThemeData(), home: const AlarmsScreen());
  }
}
