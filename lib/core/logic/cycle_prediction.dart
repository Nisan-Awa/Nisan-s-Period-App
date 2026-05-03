import 'dart:math' as math;

import '../../data_model/app_state.dart';
import '../utils/date_utils.dart';

class CyclePrediction {
  CyclePrediction(this.state) {
    today = dateOnly(DateTime.now());
    final learnedLength = _learnedCycleLength();
    final learnedPeriod = _learnedPeriodLength();
    effectiveCycleLength = learnedLength;
    effectivePeriodLength = learnedPeriod;
    currentCycleStart = _currentCycleStart();
    nextPeriodStart = _nextPeriodStart();
    nextPeriodEnd = nextPeriodStart.add(
      Duration(days: effectivePeriodLength - 1),
    );
    ovulationDay = nextPeriodStart.subtract(const Duration(days: 14));
    fertileStart = ovulationDay.subtract(const Duration(days: 5));
    fertileEnd = ovulationDay.add(const Duration(days: 1));
    cycleDay = today.difference(currentCycleStart).inDays + 1;
    daysUntilPeriod = nextPeriodStart.difference(today).inDays;
  }

  final AppState state;
  late final DateTime today;
  late final DateTime currentCycleStart;
  late final DateTime nextPeriodStart;
  late final DateTime nextPeriodEnd;
  late final DateTime fertileStart;
  late final DateTime fertileEnd;
  late final DateTime ovulationDay;
  late final int cycleDay;
  late final int daysUntilPeriod;
  late final int effectiveCycleLength;
  late final int effectivePeriodLength;

  int _learnedCycleLength() {
    if (state.history.length < 3) return state.cycleLength;
    final latest = state.history.takeLast(math.min(state.history.length, 6));
    return (latest.map((e) => e.length).reduce((a, b) => a + b) / latest.length)
        .round();
  }

  int _learnedPeriodLength() {
    if (state.history.length < 3) return state.periodLength;
    final latest = state.history.takeLast(math.min(state.history.length, 6));
    return (latest.map((e) => e.periodLength).reduce((a, b) => a + b) /
            latest.length)
        .round();
  }

  DateTime _currentCycleStart() {
    var start = dateOnly(state.lastPeriodStart);
    while (!start.add(Duration(days: effectiveCycleLength)).isAfter(today)) {
      start = start.add(Duration(days: effectiveCycleLength));
    }
    return start;
  }

  DateTime _nextPeriodStart() {
    var next = dateOnly(state.lastPeriodStart);
    while (!next.isAfter(today)) {
      next = next.add(Duration(days: effectiveCycleLength));
    }
    return next;
  }

  String get confidence {
    if (state.history.length >= 6 && _cycleVariation <= 3 && state.isRegular) {
      return 'High confidence';
    }
    if (state.history.length >= 3 && _cycleVariation <= 7) {
      return 'Medium confidence';
    }
    return 'Low confidence';
  }

  int get _cycleVariation {
    if (state.history.isEmpty) {
      return 99;
    }
    final lengths = state.history.map((e) => e.length).toList();
    return lengths.reduce(math.max) - lengths.reduce(math.min);
  }

  bool isPeriodDay(DateTime date) {
    final day = dateOnly(date);
    for (
      var start = currentCycleStart.subtract(
        Duration(days: effectiveCycleLength * 2),
      );
      start.isBefore(
        nextPeriodStart.add(Duration(days: effectiveCycleLength * 2)),
      );
      start = start.add(Duration(days: effectiveCycleLength))
    ) {
      final end = start.add(Duration(days: effectivePeriodLength - 1));
      if (!day.isBefore(start) && !day.isAfter(end)) {
        return true;
      }
    }
    return false;
  }

  bool isPredictedPeriodDay(DateTime date) {
    final day = dateOnly(date);
    return !day.isBefore(nextPeriodStart) && !day.isAfter(nextPeriodEnd);
  }

  bool isFertileDay(DateTime date) {
    final day = dateOnly(date);
    return !day.isBefore(fertileStart) && !day.isAfter(fertileEnd);
  }

  bool isOvulationDay(DateTime date) => sameDay(date, ovulationDay);

  String get phase {
    if (isPeriodDay(today)) return 'Period phase';
    if (isFertileDay(today)) return 'Fertile window';
    if (today.isAfter(fertileEnd) && today.isBefore(nextPeriodStart)) {
      return 'Pre-period phase';
    }
    return 'Follicular phase';
  }

  String get statusTitle {
    if (isPeriodDay(today)) {
      final periodDay = today.difference(currentCycleStart).inDays + 1;
      return 'Period Day $periodDay';
    }
    if (daysUntilPeriod == 1) return 'Period expected tomorrow';
    if (daysUntilPeriod <= 0) return 'Period is later than expected';
    if (daysUntilPeriod <= 3) return 'Period expected in $daysUntilPeriod days';
    return 'Cycle Day $cycleDay';
  }

  String get ringCenterTop {
    if (daysUntilPeriod <= 3 && !isPeriodDay(today)) {
      return '$daysUntilPeriod days';
    }
    return 'Day $cycleDay';
  }

  String get ringCenterBottom {
    if (isPeriodDay(today)) return 'period phase';
    if (daysUntilPeriod <= 3) return 'until period';
    return phase.toLowerCase();
  }
}

extension _ListTakeLast<T> on List<T> {
  List<T> takeLast(int count) => sublist(math.max(0, length - count));
}
