import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:period_tracker_app/core/logic/cycle_prediction.dart';
import 'package:period_tracker_app/main.dart';

void main() {
  test('theme mode is saved and restored', () {
    final state = AppState.sample().copyWith(themeMode: ThemeMode.dark);

    final restored = AppState.fromJson(state.toJson());

    expect(restored.themeMode, ThemeMode.dark);
  });

  test('isPeriodDay prefers saved history over averaged projection', () {
    final state = AppState.sample().copyWith(
      lastPeriodStart: DateTime(2026, 5, 1),
      cycleLength: 28,
      periodLength: 5,
      history: [
        CycleRecord(start: DateTime(2026, 3, 1), length: 28, periodLength: 5),
        CycleRecord(start: DateTime(2026, 3, 29), length: 28, periodLength: 5),
        CycleRecord(start: DateTime(2026, 4, 20), length: 22, periodLength: 4),
      ],
    );

    final prediction = CyclePrediction(state);

    expect(prediction.isPeriodDay(DateTime(2026, 4, 20)), isTrue);
    expect(prediction.isPeriodDay(DateTime(2026, 4, 23)), isTrue);
    expect(prediction.isPeriodDay(DateTime(2026, 4, 24)), isFalse);
  });
}
