import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rng_alarm/di/injector.dart';
import 'package:rng_alarm/features/alarms/domain/alarm.dart';
import 'package:rng_alarm/features/alarms/domain/alarm_time.dart';
import 'package:rng_alarm/features/alarms/presentation/alarm_time_label.dart';
import 'package:rng_alarm/features/alarms/presentation/editor/alarm_editor_bloc.dart';

/// Screen for creating or editing one alarm
class AlarmEditorScreen extends StatefulWidget {
  const AlarmEditorScreen({super.key, this.alarm});

  /// Alarm opened for editing
  ///
  /// Null when the screen creates a new alarm
  final Alarm? alarm;

  @override
  State<AlarmEditorScreen> createState() => _AlarmEditorScreenState();
}

class _AlarmEditorScreenState extends State<AlarmEditorScreen> {
  late final AlarmEditorBloc _bloc;
  late final TextEditingController _nameController;
  late final StreamSubscription<AlarmEditorEffect> _effectsSubscription;
  var _didPop = false;

  @override
  void initState() {
    super.initState();
    _bloc = injector.get<AlarmEditorBloc>();
    _nameController = TextEditingController(text: widget.alarm?.name ?? '');
    _effectsSubscription = _bloc.effects.listen(_onEffect);
    _bloc.add(AlarmEditorStartedEvent(widget.alarm));
  }

  @override
  void dispose() {
    unawaited(_effectsSubscription.cancel());
    unawaited(_bloc.close());
    _nameController.dispose();
    super.dispose();
  }

  void _onEffect(AlarmEditorEffect effect) {
    if (_didPop || !mounted) {
      return;
    }

    switch (effect) {
      case AlarmEditorSavedEffect(:final alarm):
        _didPop = true;
        Navigator.pop(context, alarm);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.alarm != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Change alarm' : 'New alarm')),
      body: BlocBuilder<AlarmEditorBloc, AlarmEditorState>(
        bloc: _bloc,
        builder: (context, state) {
          return switch (state) {
            AlarmEditorEditingState() => ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Time'),
                  trailing: Text(alarmTimeLabel(state.time), style: Theme.of(context).textTheme.headlineSmall),
                  onTap: () => _pickTime(state.time),
                ),
                TextField(
                  key: const Key('testAlarmName'),
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (name) => _bloc.add(AlarmEditorNameChangedEvent(name)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Vibration'),
                  value: state.vibrates,
                  onChanged: (vibrates) => _bloc.add(AlarmEditorVibrationChangedEvent(vibrates)),
                ),
                const SizedBox(height: 24),
                FilledButton(onPressed: () => _bloc.add(const AlarmEditorSaveEvent()), child: const Text('Save')),
              ],
            ),
          };
        },
      ),
    );
  }

  Future<void> _pickTime(AlarmTime current) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
      builder: (context, child) {
        return MediaQuery(data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true), child: child ?? const SizedBox.shrink());
      },
    );
    if (picked == null) {
      return;
    }

    _bloc.add(AlarmEditorTimeChangedEvent(AlarmTime(hour: picked.hour, minute: picked.minute)));
  }
}
