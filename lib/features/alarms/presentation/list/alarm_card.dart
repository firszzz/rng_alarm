import 'package:flutter/material.dart';
import 'package:rng_alarm/app/ui_theme.dart';
import 'package:rng_alarm/features/alarms/domain/alarm.dart';
import 'package:rng_alarm/features/alarms/presentation/alarm_time_label.dart';

/// Row of one alarm
class AlarmCard extends StatelessWidget {
  const AlarmCard({super.key, required this.alarm, required this.onTap, required this.onToggle, required this.onDelete});

  /// Alarm shown in the row
  final Alarm alarm;

  /// Invoked when the row is tapped
  final VoidCallback onTap;

  /// Invoked when the enabled switch changes
  final VoidCallback onToggle;

  /// Invoked after the row is dismissed
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = UITheme.of(context);
    final name = alarm.name.trim().isEmpty ? 'Alarm' : alarm.name.trim();
    final timeColor = alarm.isEnabled ? theme.onSurface : theme.disabledTime;

    return Dismissible(
      key: ValueKey(alarm.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: ColoredBox(
        color: theme.destructiveSurface,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Icon(Icons.delete_outline, color: theme.onDestructive),
          ),
        ),
      ),
      child: Material(
        color: theme.surface,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 8, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FittedBox(
                        alignment: Alignment.centerLeft,
                        fit: BoxFit.scaleDown,
                        child: Text(
                          AlarmLabels.alarmWindowLabel(alarm.from, alarm.to),
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.w400, color: timeColor, height: 1.1),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(name, style: TextStyle(fontSize: 14, color: theme.secondaryText)),
                    ],
                  ),
                ),
                Switch(key: Key('testAlarmSwitch_${alarm.id}'), value: alarm.isEnabled, onChanged: (_) => onToggle()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
