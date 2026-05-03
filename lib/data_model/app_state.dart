import 'package:flutter/material.dart';

import '../core/utils/date_utils.dart';
import '../core/utils/number_utils.dart';

class AppState {
  AppState({
    required this.name,
    required this.lastPeriodStart,
    required this.cycleLength,
    required this.periodLength,
    required this.isRegular,
    required this.trackingGoals,
    required this.remindersEnabled,
    required this.sensitiveNotificationsHidden,
    required this.notificationPermissionAsked,
    required this.privacyLockEnabled,
    required this.history,
    required this.todayLog,
    required this.logs,
    required this.reminders,
  });

  final String name;
  final DateTime lastPeriodStart;
  final int cycleLength;
  final int periodLength;
  final bool isRegular;
  final Set<String> trackingGoals;
  final bool remindersEnabled;
  final bool sensitiveNotificationsHidden;
  final bool notificationPermissionAsked;
  final bool privacyLockEnabled;
  final List<CycleRecord> history;
  final DailyLog todayLog;
  final List<DailyLogEntry> logs;
  final List<ReminderItem> reminders;

  factory AppState.sample() {
    final today = dateOnly(DateTime.now());
    final lastStart = today.subtract(const Duration(days: 26));
    return AppState(
      name: '',
      lastPeriodStart: lastStart,
      cycleLength: 28,
      periodLength: 5,
      isRegular: true,
      trackingGoals: {'Period', 'Symptoms', 'Mood', 'Ovulation', 'Self-care'},
      remindersEnabled: true,
      sensitiveNotificationsHidden: true,
      notificationPermissionAsked: false,
      privacyLockEnabled: false,
      history: [
        CycleRecord(
          start: lastStart.subtract(const Duration(days: 87)),
          length: 29,
          periodLength: 5,
        ),
        CycleRecord(
          start: lastStart.subtract(const Duration(days: 58)),
          length: 28,
          periodLength: 5,
        ),
        CycleRecord(
          start: lastStart.subtract(const Duration(days: 30)),
          length: 30,
          periodLength: 4,
        ),
      ],
      todayLog: DailyLog.defaults(),
      logs: [
        DailyLogEntry(
          date: today.subtract(const Duration(days: 2)),
          log: DailyLog.defaults().copyWith(
            mood: 'Tired',
            symptoms: {'Cramps', 'Fatigue'},
            painLevel: 4,
            activity: 'Stretching',
          ),
        ),
        DailyLogEntry(
          date: today.subtract(const Duration(days: 1)),
          log: DailyLog.defaults().copyWith(
            mood: 'Calm',
            symptoms: {'No symptoms'},
            painLevel: 1,
          ),
        ),
      ],
      reminders: ReminderItem.defaults(),
    );
  }

  AppState copyWith({
    String? name,
    DateTime? lastPeriodStart,
    int? cycleLength,
    int? periodLength,
    bool? isRegular,
    Set<String>? trackingGoals,
    bool? remindersEnabled,
    bool? sensitiveNotificationsHidden,
    bool? notificationPermissionAsked,
    bool? privacyLockEnabled,
    List<CycleRecord>? history,
    DailyLog? todayLog,
    List<DailyLogEntry>? logs,
    List<ReminderItem>? reminders,
  }) {
    return AppState(
      name: name ?? this.name,
      lastPeriodStart: lastPeriodStart ?? this.lastPeriodStart,
      cycleLength: cycleLength ?? this.cycleLength,
      periodLength: periodLength ?? this.periodLength,
      isRegular: isRegular ?? this.isRegular,
      trackingGoals: trackingGoals ?? this.trackingGoals,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      sensitiveNotificationsHidden:
          sensitiveNotificationsHidden ?? this.sensitiveNotificationsHidden,
      notificationPermissionAsked:
          notificationPermissionAsked ?? this.notificationPermissionAsked,
      privacyLockEnabled: privacyLockEnabled ?? this.privacyLockEnabled,
      history: history ?? this.history,
      todayLog: todayLog ?? this.todayLog,
      logs: logs ?? this.logs,
      reminders: reminders ?? this.reminders,
    );
  }

  DailyLog logFor(DateTime date) {
    final day = dateOnly(date);
    for (final entry in logs.reversed) {
      if (sameDay(entry.date, day)) return entry.log;
    }
    return sameDay(day, DateTime.now()) ? todayLog : DailyLog.defaults();
  }

  AppState saveLogFor(DateTime date, DailyLog log) {
    final day = dateOnly(date);
    final nextLogs = [
      for (final entry in logs)
        if (!sameDay(entry.date, day)) entry,
      DailyLogEntry(date: day, log: log),
    ]..sort((a, b) => a.date.compareTo(b.date));
    return copyWith(
      todayLog: sameDay(day, DateTime.now()) ? log : todayLog,
      logs: nextLogs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'lastPeriodStart': lastPeriodStart.toIso8601String(),
      'cycleLength': cycleLength,
      'periodLength': periodLength,
      'isRegular': isRegular,
      'trackingGoals': trackingGoals.toList(),
      'remindersEnabled': remindersEnabled,
      'sensitiveNotificationsHidden': sensitiveNotificationsHidden,
      'notificationPermissionAsked': notificationPermissionAsked,
      'privacyLockEnabled': privacyLockEnabled,
      'history': history.map((record) => record.toJson()).toList(),
      'todayLog': todayLog.toJson(),
      'logs': logs.map((entry) => entry.toJson()).toList(),
      'reminders': reminders.map((reminder) => reminder.toJson()).toList(),
    };
  }

  factory AppState.fromJson(Map<String, dynamic> json) {
    final fallback = AppState.sample();
    return AppState(
      name: json['name'] as String? ?? fallback.name,
      lastPeriodStart: dateOnly(
        DateTime.tryParse(json['lastPeriodStart'] as String? ?? '') ??
            fallback.lastPeriodStart,
      ),
      cycleLength: clampInt(
        (json['cycleLength'] as num?)?.toInt() ?? fallback.cycleLength,
        21,
        45,
      ),
      periodLength: clampInt(
        (json['periodLength'] as num?)?.toInt() ?? fallback.periodLength,
        2,
        10,
      ),
      isRegular: json['isRegular'] as bool? ?? fallback.isRegular,
      trackingGoals:
          ((json['trackingGoals'] as List<dynamic>?) ??
                  fallback.trackingGoals.toList())
              .cast<String>()
              .toSet(),
      remindersEnabled:
          json['remindersEnabled'] as bool? ?? fallback.remindersEnabled,
      sensitiveNotificationsHidden:
          json['sensitiveNotificationsHidden'] as bool? ??
          fallback.sensitiveNotificationsHidden,
      notificationPermissionAsked:
          json['notificationPermissionAsked'] as bool? ??
          fallback.notificationPermissionAsked,
      privacyLockEnabled:
          json['privacyLockEnabled'] as bool? ?? fallback.privacyLockEnabled,
      history: ((json['history'] as List<dynamic>?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(CycleRecord.fromJson)
          .toList()
          .ifEmpty(fallback.history),
      todayLog: json['todayLog'] is Map<String, dynamic>
          ? DailyLog.fromJson(json['todayLog'] as Map<String, dynamic>)
          : fallback.todayLog,
      logs: ((json['logs'] as List<dynamic>?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(DailyLogEntry.fromJson)
          .toList()
          .ifEmpty(fallback.logs),
      reminders: ((json['reminders'] as List<dynamic>?) ?? const [])
          .whereType<Map<String, dynamic>>()
          .map(ReminderItem.fromJson)
          .toList()
          .ifEmpty(fallback.reminders),
    );
  }
}

class CycleRecord {
  const CycleRecord({
    required this.start,
    required this.length,
    required this.periodLength,
    this.ignoredForPrediction = false,
  });

  final DateTime start;
  final int length;
  final int periodLength;
  final bool ignoredForPrediction;

  CycleRecord copyWith({
    DateTime? start,
    int? length,
    int? periodLength,
    bool? ignoredForPrediction,
  }) {
    return CycleRecord(
      start: start ?? this.start,
      length: length ?? this.length,
      periodLength: periodLength ?? this.periodLength,
      ignoredForPrediction: ignoredForPrediction ?? this.ignoredForPrediction,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start.toIso8601String(),
      'length': length,
      'periodLength': periodLength,
      'ignoredForPrediction': ignoredForPrediction,
    };
  }

  factory CycleRecord.fromJson(Map<String, dynamic> json) {
    return CycleRecord(
      start: dateOnly(
        DateTime.tryParse(json['start'] as String? ?? '') ??
            dateOnly(DateTime.now()),
      ),
      length: clampInt((json['length'] as num?)?.toInt() ?? 28, 1, 60),
      periodLength: clampInt(
        (json['periodLength'] as num?)?.toInt() ?? 5,
        1,
        14,
      ),
      ignoredForPrediction: json['ignoredForPrediction'] as bool? ?? false,
    );
  }
}

class DailyLog {
  const DailyLog({
    required this.flow,
    required this.mood,
    required this.symptoms,
    required this.discharge,
    required this.activity,
    required this.painLevel,
    required this.hadSex,
    required this.protectedSex,
    required this.hideIntimacy,
    required this.notes,
  });

  final String flow;
  final String mood;
  final Set<String> symptoms;
  final String discharge;
  final String activity;
  final double painLevel;
  final bool hadSex;
  final bool protectedSex;
  final bool hideIntimacy;
  final String notes;

  factory DailyLog.defaults() {
    return const DailyLog(
      flow: 'None',
      mood: 'Calm',
      symptoms: {'No symptoms'},
      discharge: 'None',
      activity: 'Walking',
      painLevel: 2,
      hadSex: false,
      protectedSex: false,
      hideIntimacy: true,
      notes: '',
    );
  }

  DailyLog copyWith({
    String? flow,
    String? mood,
    Set<String>? symptoms,
    String? discharge,
    String? activity,
    double? painLevel,
    bool? hadSex,
    bool? protectedSex,
    bool? hideIntimacy,
    String? notes,
  }) {
    return DailyLog(
      flow: flow ?? this.flow,
      mood: mood ?? this.mood,
      symptoms: symptoms ?? this.symptoms,
      discharge: discharge ?? this.discharge,
      activity: activity ?? this.activity,
      painLevel: painLevel ?? this.painLevel,
      hadSex: hadSex ?? this.hadSex,
      protectedSex: protectedSex ?? this.protectedSex,
      hideIntimacy: hideIntimacy ?? this.hideIntimacy,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'flow': flow,
      'mood': mood,
      'symptoms': symptoms.toList(),
      'discharge': discharge,
      'activity': activity,
      'painLevel': painLevel,
      'hadSex': hadSex,
      'protectedSex': protectedSex,
      'hideIntimacy': hideIntimacy,
      'notes': notes,
    };
  }

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    final fallback = DailyLog.defaults();
    return DailyLog(
      flow: json['flow'] as String? ?? fallback.flow,
      mood: json['mood'] as String? ?? fallback.mood,
      symptoms:
          ((json['symptoms'] as List<dynamic>?) ?? fallback.symptoms.toList())
              .cast<String>()
              .toSet(),
      discharge: json['discharge'] as String? ?? fallback.discharge,
      activity: json['activity'] as String? ?? fallback.activity,
      painLevel: clampDouble(
        (json['painLevel'] as num?)?.toDouble() ?? fallback.painLevel,
        0,
        10,
      ),
      hadSex: json['hadSex'] as bool? ?? fallback.hadSex,
      protectedSex: json['protectedSex'] as bool? ?? fallback.protectedSex,
      hideIntimacy: json['hideIntimacy'] as bool? ?? fallback.hideIntimacy,
      notes: json['notes'] as String? ?? fallback.notes,
    );
  }
}

class DailyLogEntry {
  const DailyLogEntry({required this.date, required this.log});

  final DateTime date;
  final DailyLog log;

  Map<String, dynamic> toJson() {
    return {'date': date.toIso8601String(), 'log': log.toJson()};
  }

  factory DailyLogEntry.fromJson(Map<String, dynamic> json) {
    return DailyLogEntry(
      date:
          DateTime.tryParse(json['date'] as String? ?? '') ??
          dateOnly(DateTime.now()),
      log: json['log'] is Map<String, dynamic>
          ? DailyLog.fromJson(json['log'] as Map<String, dynamic>)
          : DailyLog.defaults(),
    );
  }
}

class ReminderItem {
  const ReminderItem({
    required this.title,
    required this.message,
    required this.time,
    required this.enabled,
    required this.icon,
  });

  final String title;
  final String message;
  final TimeOfDay time;
  final bool enabled;
  final IconData icon;

  ReminderItem copyWith({
    bool? enabled,
    TimeOfDay? time,
    String? message,
    String? title,
  }) {
    return ReminderItem(
      title: title ?? this.title,
      message: message ?? this.message,
      time: time ?? this.time,
      enabled: enabled ?? this.enabled,
      icon: icon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'hour': time.hour,
      'minute': time.minute,
      'enabled': enabled,
    };
  }

  factory ReminderItem.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String? ?? 'Reminder';
    return ReminderItem(
      title: title,
      message: json['message'] as String? ?? 'How are you feeling today?',
      time: TimeOfDay(
        hour: clampInt((json['hour'] as num?)?.toInt() ?? 8, 0, 23),
        minute: clampInt((json['minute'] as num?)?.toInt() ?? 0, 0, 59),
      ),
      enabled: json['enabled'] as bool? ?? true,
      icon: _iconForReminder(title),
    );
  }

  static IconData _iconForReminder(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('period')) return Icons.water_drop_outlined;
    if (lower.contains('care')) return Icons.spa_outlined;
    if (lower.contains('medication')) return Icons.medication_outlined;
    return Icons.edit_note_outlined;
  }

  static List<ReminderItem> defaults() {
    return const [
      ReminderItem(
        title: 'Period start',
        message: 'Your period may start soon. Keep supplies nearby.',
        time: TimeOfDay(hour: 8, minute: 30),
        enabled: true,
        icon: Icons.water_drop_outlined,
      ),
      ReminderItem(
        title: 'Daily check-in',
        message: 'How are you feeling today?',
        time: TimeOfDay(hour: 20, minute: 0),
        enabled: true,
        icon: Icons.edit_note_outlined,
      ),
      ReminderItem(
        title: 'Self-care',
        message: 'Take a quiet moment for hydration, rest, or stretching.',
        time: TimeOfDay(hour: 18, minute: 15),
        enabled: false,
        icon: Icons.spa_outlined,
      ),
    ];
  }
}

extension _NonEmptyList<T> on List<T> {
  List<T> ifEmpty(List<T> fallback) => isEmpty ? fallback : this;
}
