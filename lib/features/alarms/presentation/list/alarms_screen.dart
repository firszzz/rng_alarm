import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rng_alarm/di/injector.dart';
import 'package:rng_alarm/features/alarms/domain/alarm.dart';
import 'package:rng_alarm/features/alarms/presentation/editor/alarm_editor_screen.dart';
import 'package:rng_alarm/features/alarms/presentation/list/alarm_card.dart';
import 'package:rng_alarm/features/alarms/presentation/list/alarms_bloc.dart';

/// Main screen with the alarm list
class AlarmsScreen extends StatefulWidget {
  const AlarmsScreen({super.key});

  @override
  State<AlarmsScreen> createState() => _AlarmsScreenState();
}

class _AlarmsScreenState extends State<AlarmsScreen> {
  late final AlarmsBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = injector.get<AlarmsBloc>();
    _bloc.add(const AlarmsStartedEvent());
  }

  @override
  void dispose() {
    unawaited(_bloc.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Text('Alarm', style: Theme.of(context).textTheme.headlineLarge),
            ),
            Expanded(
              child: BlocBuilder<AlarmsBloc, AlarmsState>(
                bloc: _bloc,
                builder: (context, state) => switch (state) {
                  AlarmsContentState(:final alarms) when alarms.isEmpty => const Center(child: Text('No alarms')),
                  AlarmsContentState(:final alarms) => ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: alarms.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final alarm = alarms[index];
                      return AlarmCard(
                        alarm: alarm,
                        onTap: () => _openEditor(alarm),
                        onToggle: () => _bloc.add(AlarmsToggleEvent(alarm.id)),
                        onDelete: () => _bloc.add(AlarmsDeleteEvent(alarm.id)),
                      );
                    },
                  ),
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(onPressed: () => _openEditor(null), child: const Icon(Icons.add)),
    );
  }

  Future<void> _openEditor(Alarm? alarm) async {
    final saved = await Navigator.push<Alarm>(context, MaterialPageRoute(builder: (_) => AlarmEditorScreen(alarm: alarm)));
    if (saved != null && mounted) {
      _bloc.add(AlarmsUpsertEvent(saved));
    }
  }
}
