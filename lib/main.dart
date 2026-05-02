import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const PeriodTrackerApp());
}

const appName = 'LunaCycle';

class AppColors {
  static const primaryPink = Color(0xFFFF4F93);
  static const softBlush = Color(0xFFFFEAF2);
  static const lightRose = Color(0xFFFFD6E5);
  static const lavender = Color(0xFFE9DDFF);
  static const creamWhite = Color(0xFFFFF8FA);
  static const deepText = Color(0xFF2B2230);
  static const softText = Color(0xFF8A7F8F);
  static const successGreen = Color(0xFF7BDCB5);
  static const warningPeach = Color(0xFFFFB88C);
  static const periodPink = Color(0xFFFF5A7D);
  static const fertilePurple = Color(0xFFB88CFF);
  static const ovulationBlue = Color(0xFF8EA7FF);
}

class PeriodTrackerApp extends StatelessWidget {
  const PeriodTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.creamWhite,
        fontFamily: 'Nunito',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryPink,
          primary: AppColors.primaryPink,
          secondary: AppColors.fertilePurple,
          surface: Colors.white,
          brightness: Brightness.light,
        ),
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: AppColors.deepText,
          displayColor: AppColors.deepText,
          fontFamily: 'Nunito',
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: AppColors.primaryPink,
          inactiveTrackColor: AppColors.lightRose,
          thumbColor: AppColors.primaryPink,
        ),
      ),
      home: const LunaCycleRoot(),
    );
  }
}

class LunaCycleRoot extends StatefulWidget {
  const LunaCycleRoot({super.key});

  @override
  State<LunaCycleRoot> createState() => _LunaCycleRootState();
}

class _LunaCycleRootState extends State<LunaCycleRoot> {
  AppState _state = AppState.sample();
  var _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadState();
  }

  Future<void> _loadState() async {
    final loaded = await AppStorage.load();
    if (!mounted) return;
    final next = loaded ?? AppState.sample();
    setState(() {
      _state = next;
      _loaded = true;
    });
    DeviceServices.scheduleReminders(
      next.reminders,
      enabled: next.remindersEnabled,
      hideSensitive: next.sensitiveNotificationsHidden,
    );
  }

  void _update(AppState next) {
    final previous = _state;
    setState(() => _state = next);
    AppStorage.save(next);
    if (_shouldSyncReminders(previous, next)) {
      DeviceServices.scheduleReminders(
        next.reminders,
        enabled: next.remindersEnabled,
        hideSensitive: next.sensitiveNotificationsHidden,
      );
    }
  }

  bool _shouldSyncReminders(AppState previous, AppState next) {
    if (previous.remindersEnabled != next.remindersEnabled ||
        previous.sensitiveNotificationsHidden !=
            next.sensitiveNotificationsHidden ||
        previous.reminders.length != next.reminders.length) {
      return true;
    }
    for (var index = 0; index < previous.reminders.length; index++) {
      final current = previous.reminders[index];
      final updated = next.reminders[index];
      if (current.title != updated.title ||
          current.message != updated.message ||
          current.enabled != updated.enabled ||
          current.time.hour != updated.time.hour ||
          current.time.minute != updated.time.minute) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const SoftScaffold(
        child: Center(
          child: CircularProgressIndicator(color: AppColors.primaryPink),
        ),
      );
    }
    return MainShell(state: _state, onChanged: _update);
  }
}

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
  });

  final DateTime start;
  final int length;
  final int periodLength;

  Map<String, dynamic> toJson() {
    return {
      'start': start.toIso8601String(),
      'length': length,
      'periodLength': periodLength,
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

class AppStorage {
  static const _channel = MethodChannel('luna_cycle/storage');

  static Future<AppState?> load() async {
    String? raw;
    try {
      raw = await _channel.invokeMethod<String>('load');
    } catch (_) {
      return null;
    }
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return AppState.fromJson(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(AppState state) async {
    try {
      await _channel.invokeMethod<void>('save', jsonEncode(state.toJson()));
    } catch (_) {
      // Tests and unsupported platforms can run without the native storage bridge.
    }
  }

  static Future<void> clear() async {
    try {
      await _channel.invokeMethod<void>('clear');
    } catch (_) {
      // Tests and unsupported platforms can run without the native storage bridge.
    }
  }
}

class DeviceServices {
  static const _channel = MethodChannel('luna_cycle/device');

  static Future<bool> areNotificationsEnabled() async {
    try {
      return await _channel.invokeMethod<bool>('areNotificationsEnabled') ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<bool> requestNotificationPermission() async {
    try {
      return await _channel.invokeMethod<bool>('requestNotifications') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<bool> scheduleReminders(
    List<ReminderItem> reminders, {
    required bool enabled,
    required bool hideSensitive,
  }) async {
    try {
      await _channel.invokeMethod<void>('scheduleReminders', {
        'enabled': enabled,
        'hideSensitive': hideSensitive,
        'reminders': reminders
            .where((reminder) => reminder.enabled)
            .map(
              (reminder) => {
                'title': reminder.title,
                'message': hideSensitive
                    ? 'You have a LunaCycle reminder.'
                    : reminder.message,
                'hour': reminder.time.hour,
                'minute': reminder.time.minute,
              },
            )
            .toList(),
      });
      return true;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<bool> showTestNotification({
    required bool hideSensitive,
  }) async {
    try {
      return await _channel.invokeMethod<bool>('showTestNotification', {
            'title': 'LunaCycle',
            'message': hideSensitive
                ? 'You have a LunaCycle reminder.'
                : 'Reminders are ready. LunaCycle will gently check in with you.',
            'hideSensitive': hideSensitive,
          }) ??
          false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  static Future<bool> unlockWithDeviceCredential() async {
    try {
      return await _channel.invokeMethod<bool>('unlock') ?? false;
    } on PlatformException {
      return false;
    } on MissingPluginException {
      return false;
    }
  }
}

extension _NonEmptyList<T> on List<T> {
  List<T> ifEmpty(List<T> fallback) => isEmpty ? fallback : this;
}

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

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.state,
    required this.onComplete,
  });

  final AppState state;
  final ValueChanged<AppState> onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late AppState _draft = widget.state;
  var _step = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      _OnboardingDate(
        state: _draft,
        onChanged: (date) =>
            setState(() => _draft = _draft.copyWith(lastPeriodStart: date)),
      ),
      _OnboardingSliders(
        state: _draft,
        onChanged: (next) => setState(() => _draft = next),
      ),
      _OnboardingRegularity(
        state: _draft,
        onChanged: (regular) =>
            setState(() => _draft = _draft.copyWith(isRegular: regular)),
      ),
      _OnboardingGoals(
        state: _draft,
        onChanged: (goals) =>
            setState(() => _draft = _draft.copyWith(trackingGoals: goals)),
      ),
      _OnboardingPrivacy(
        state: _draft,
        onChanged: (next) => setState(() => _draft = next),
      ),
    ];
    final isLast = _step == screens.length - 1;

    return SoftScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 24),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        value: (_step + 1) / screens.length,
                        backgroundColor: Colors.white.withValues(alpha: 0.7),
                        color: AppColors.primaryPink,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_step + 1}/${screens.length}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ],
              ),
              const SizedBox(height: 26),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: screens[_step],
                ),
              ),
              Row(
                children: [
                  if (_step > 0)
                    TextButton(
                      onPressed: () => setState(() => _step--),
                      child: const Text('Back'),
                    ),
                  const Spacer(),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryPink,
                      minimumSize: const Size(150, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    onPressed: () {
                      if (isLast) {
                        widget.onComplete(_draft);
                      } else {
                        setState(() => _step++);
                      }
                    },
                    child: Text(isLast ? 'Start tracking' : 'Next'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingShell extends StatelessWidget {
  const _OnboardingShell({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: Colors.white.withValues(alpha: 0.86),
          child: Icon(icon, color: AppColors.primaryPink, size: 30),
        ),
        const SizedBox(height: 18),
        Text(
          title,
          style: const TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.softText,
            height: 1.4,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 26),
        Expanded(child: child),
      ],
    );
  }
}

class _OnboardingDate extends StatelessWidget {
  const _OnboardingDate({required this.state, required this.onChanged});

  final AppState state;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return _OnboardingShell(
      icon: Icons.event_rounded,
      title: 'When did your last period start?',
      subtitle:
          'This gives LunaCycle a gentle starting point. Predictions improve as you keep tracking.',
      child: Center(
        child: SoftCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.water_drop_rounded,
                color: AppColors.periodPink,
                size: 46,
              ),
              const SizedBox(height: 12),
              Text(
                formatDate(state.lastPeriodStart),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: state.lastPeriodStart,
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365),
                    ),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) onChanged(dateOnly(picked));
                },
                icon: const Icon(Icons.calendar_month_outlined),
                label: const Text('Choose date'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingSliders extends StatelessWidget {
  const _OnboardingSliders({required this.state, required this.onChanged});

  final AppState state;
  final ValueChanged<AppState> onChanged;

  @override
  Widget build(BuildContext context) {
    return _OnboardingShell(
      icon: Icons.tune_rounded,
      title: 'Let us personalize your rhythm.',
      subtitle:
          'Typical cycles often vary. Choose what feels closest to your usual pattern.',
      child: Column(
        children: [
          SliderPanel(
            label: 'Period usually lasts',
            value: state.periodLength,
            min: 2,
            max: 10,
            unit: 'days',
            onChanged: (value) =>
                onChanged(state.copyWith(periodLength: value)),
          ),
          const SizedBox(height: 14),
          SliderPanel(
            label: 'Average cycle length',
            value: state.cycleLength,
            min: 21,
            max: 45,
            unit: 'days',
            onChanged: (value) => onChanged(state.copyWith(cycleLength: value)),
          ),
        ],
      ),
    );
  }
}

class _OnboardingRegularity extends StatelessWidget {
  const _OnboardingRegularity({required this.state, required this.onChanged});

  final AppState state;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _OnboardingShell(
      icon: Icons.auto_graph_rounded,
      title: 'Are your cycles usually regular?',
      subtitle:
          'Irregular cycles are supported. The app will show lower confidence when predictions need more history.',
      child: Column(
        children: [
          SelectableCard(
            selected: state.isRegular,
            icon: Icons.calendar_today_rounded,
            title: 'Mostly regular',
            subtitle: 'My cycle length is usually close each month.',
            onTap: () => onChanged(true),
          ),
          const SizedBox(height: 14),
          SelectableCard(
            selected: !state.isRegular,
            icon: Icons.waves_rounded,
            title: 'Often irregular',
            subtitle: 'My cycle changes noticeably from month to month.',
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _OnboardingGoals extends StatelessWidget {
  const _OnboardingGoals({required this.state, required this.onChanged});

  final AppState state;
  final ValueChanged<Set<String>> onChanged;

  static const goals = [
    'Period',
    'Symptoms',
    'Mood',
    'Ovulation',
    'Pregnancy chance estimate',
    'Medication',
    'Self-care',
  ];

  @override
  Widget build(BuildContext context) {
    return _OnboardingShell(
      icon: Icons.favorite_rounded,
      title: 'What would you like to track?',
      subtitle: 'Your data stays private and belongs to you.',
      child: Align(
        alignment: Alignment.topLeft,
        child: Wrap(
          spacing: 10,
          runSpacing: 12,
          children: goals.map((goal) {
            return SelectableChip(
              label: goal,
              icon: _goalIcon(goal),
              selected: state.trackingGoals.contains(goal),
              onTap: () {
                final next = {...state.trackingGoals};
                next.contains(goal) ? next.remove(goal) : next.add(goal);
                onChanged(next);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  IconData _goalIcon(String goal) {
    return switch (goal) {
      'Mood' => Icons.mood_outlined,
      'Symptoms' => Icons.healing_outlined,
      'Ovulation' => Icons.local_florist_outlined,
      'Medication' => Icons.medication_outlined,
      'Self-care' => Icons.spa_outlined,
      _ => Icons.water_drop_outlined,
    };
  }
}

class _OnboardingPrivacy extends StatelessWidget {
  const _OnboardingPrivacy({required this.state, required this.onChanged});

  final AppState state;
  final ValueChanged<AppState> onChanged;

  @override
  Widget build(BuildContext context) {
    return _OnboardingShell(
      icon: Icons.lock_rounded,
      title: 'Make it private and gentle.',
      subtitle:
          'You can hide sensitive notifications and add an app lock later in Settings.',
      child: Column(
        children: [
          SwitchTileCard(
            icon: Icons.notifications_active_outlined,
            title: 'Gentle reminders',
            subtitle: 'Period, daily log, and self-care reminders.',
            value: state.remindersEnabled,
            onChanged: (value) =>
                onChanged(state.copyWith(remindersEnabled: value)),
          ),
          const SizedBox(height: 14),
          SwitchTileCard(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy lock',
            subtitle: 'Show a soft PIN or biometric lock screen.',
            value: state.privacyLockEnabled,
            onChanged: (value) =>
                onChanged(state.copyWith(privacyLockEnabled: value)),
          ),
        ],
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key, required this.state, required this.onChanged});

  final AppState state;
  final ValueChanged<AppState> onChanged;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with WidgetsBindingObserver {
  var _tab = 0;
  var _authenticating = false;
  var _mustUnlockOnResume = false;
  String? _logFocus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _mustUnlockOnResume = widget.state.privacyLockEnabled;
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _authenticateIfNeeded(),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant MainShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.state.privacyLockEnabled &&
        widget.state.privacyLockEnabled) {
      _mustUnlockOnResume = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      if (widget.state.privacyLockEnabled) {
        _mustUnlockOnResume = true;
      }
    }
    if (state == AppLifecycleState.resumed) {
      _authenticateIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      TodayScreen(
        state: widget.state,
        onChanged: widget.onChanged,
        onOpenSettings: _openSettings,
        onLogSection: _openLogSection,
      ),
      CalendarScreen(state: widget.state),
      DailyLogScreen(
        state: widget.state,
        initialSection: _logFocus,
        onChanged: widget.onChanged,
        onCancel: () => setState(() => _tab = 0),
      ),
      InsightsScreen(state: widget.state),
      SelfCareScreen(
        state: widget.state,
        onChanged: widget.onChanged,
        onOpenSettings: _openSettings,
      ),
    ];

    return SoftScaffold(
      child: PopScope(
        canPop: true,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop && widget.state.privacyLockEnabled) {
            _mustUnlockOnResume = true;
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBody: true,
          body: Stack(
            children: [
              SafeArea(
                bottom: false,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 240),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.025),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: KeyedSubtree(key: ValueKey(_tab), child: pages[_tab]),
                ),
              ),
              if (_authenticating)
                const Positioned.fill(
                  child: ColoredBox(
                    color: AppColors.creamWhite,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryPink,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: _authenticating
              ? null
              : BottomNav(
                  selectedIndex: _tab,
                  onSelected: (index) => setState(() => _tab = index),
                ),
        ),
      ),
    );
  }

  Future<void> _authenticateIfNeeded() async {
    if (!mounted ||
        _authenticating ||
        !widget.state.privacyLockEnabled ||
        !_mustUnlockOnResume) {
      return;
    }
    setState(() => _authenticating = true);
    final unlocked = await DeviceServices.unlockWithDeviceCredential();
    if (!mounted) return;
    if (unlocked) {
      setState(() {
        _authenticating = false;
        _mustUnlockOnResume = false;
      });
    } else {
      SystemNavigator.pop();
    }
  }

  void _openLogSection(String section) {
    setState(() {
      _logFocus = section;
      _tab = 2;
    });
  }

  Future<void> _openSettings() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            SettingsScreen(state: widget.state, onChanged: widget.onChanged),
      ),
    );
  }
}

class TodayScreen extends StatelessWidget {
  const TodayScreen({
    super.key,
    required this.state,
    required this.onChanged,
    required this.onOpenSettings,
    required this.onLogSection,
  });

  final AppState state;
  final ValueChanged<AppState> onChanged;
  final VoidCallback onOpenSettings;
  final ValueChanged<String> onLogSection;

  @override
  Widget build(BuildContext context) {
    final prediction = CyclePrediction(state);
    final todayLog = state.logFor(DateTime.now());
    return AppScrollView(
      children: [
        HeaderBar(
          title:
              '${timeGreeting()}, ${state.name.trim().isEmpty ? 'there' : state.name.trim()}',
          subtitle: 'Today, ${formatDate(DateTime.now(), includeYear: false)}',
          actionIcon: state.privacyLockEnabled
              ? Icons.lock_outline
              : Icons.person_outline,
          onAction: onOpenSettings,
        ),
        const SizedBox(height: 18),
        StatusCard(
          prediction: prediction,
          onPrimary: () => _showCycleDatesSheet(context, prediction),
          onPeriodStarted: () => _showPeriodStartedSheet(context, prediction),
        ),
        const SizedBox(height: 18),
        ResponsiveGrid(
          children: [
            MetricCard(
              icon: Icons.autorenew_rounded,
              label: 'Cycle Day',
              value: 'Day ${prediction.cycleDay}',
              supporting: prediction.phase,
            ),
            MetricCard(
              icon: Icons.water_drop_outlined,
              label: 'Next Period',
              value: formatShort(prediction.nextPeriodStart),
              supporting:
                  '${formatShort(prediction.nextPeriodStart)} - ${formatShort(prediction.nextPeriodEnd)}',
            ),
            MetricCard(
              icon: Icons.local_florist_outlined,
              label: 'Fertile Window',
              value:
                  '${formatShort(prediction.fertileStart)}-${formatShort(prediction.fertileEnd)}',
              supporting: 'Estimate only',
            ),
            MetricCard(
              icon: Icons.mood_outlined,
              label: 'Mood Today',
              value: todayLog.mood,
              supporting: 'Logged check-in',
            ),
            MetricCard(
              icon: Icons.healing_outlined,
              label: 'Symptoms',
              value: todayLog.symptoms.take(2).join(', '),
              supporting: todayLog.symptoms.length > 2
                  ? '+${todayLog.symptoms.length - 2} more'
                  : 'Daily log',
            ),
            MetricCard(
              icon: Icons.verified_outlined,
              label: 'Prediction',
              value: prediction.confidence,
              supporting: 'Improves with history',
            ),
          ],
        ),
        const SizedBox(height: 20),
        SectionTitle(title: 'Today\'s Check-in', trailing: 'Quick daily log'),
        SoftCard(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ActionPill(
                icon: Icons.water_drop_outlined,
                label: 'Log flow',
                onTap: () => onLogSection('flow'),
              ),
              ActionPill(
                icon: Icons.mood_outlined,
                label: 'Log mood',
                onTap: () => onLogSection('mood'),
              ),
              ActionPill(
                icon: Icons.healing_outlined,
                label: 'Symptoms',
                onTap: () => onLogSection('symptoms'),
              ),
              ActionPill(
                icon: Icons.note_add_outlined,
                label: 'Add note',
                onTap: () => onLogSection('notes'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const MedicalDisclaimer(),
      ],
    );
  }

  Future<void> _showCycleDatesSheet(
    BuildContext context,
    CyclePrediction prediction,
  ) async {
    DateTime lastStart = state.lastPeriodStart;
    var cycleLength = state.cycleLength;
    var periodLength = state.periodLength;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.creamWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                22,
                4,
                22,
                24 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cycle Dates',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Update the exact date your period started. LunaCycle uses this everywhere: Today, Calendar, Insights, and Self-Care.',
                    style: TextStyle(
                      color: AppColors.softText,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  InfoRow(
                    icon: Icons.water_drop_outlined,
                    title: 'Last period started',
                    value: formatDate(lastStart),
                  ),
                  FilledButton.icon(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: lastStart,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 730),
                        ),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (picked != null) {
                        setSheetState(() => lastStart = dateOnly(picked));
                      }
                    },
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: const Text('Choose Start Date'),
                  ),
                  const SizedBox(height: 12),
                  SliderPanel(
                    label: 'Usual cycle length',
                    value: cycleLength,
                    min: 21,
                    max: 45,
                    unit: 'days',
                    onChanged: (value) =>
                        setSheetState(() => cycleLength = value),
                  ),
                  const SizedBox(height: 12),
                  SliderPanel(
                    label: 'Usual period length',
                    value: periodLength,
                    min: 2,
                    max: 10,
                    unit: 'days',
                    onChanged: (value) =>
                        setSheetState(() => periodLength = value),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () {
                      onChanged(
                        state.copyWith(
                          lastPeriodStart: lastStart,
                          cycleLength: cycleLength,
                          periodLength: periodLength,
                        ),
                      );
                      Navigator.of(sheetContext).pop();
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Save Cycle Dates'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primaryPink,
                      minimumSize: const Size.fromHeight(54),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _showPeriodStartedSheet(
    BuildContext context,
    CyclePrediction prediction,
  ) async {
    DateTime startDate = dateOnly(DateTime.now());
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.creamWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (_, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Period Started',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Use this when bleeding begins. It updates your current cycle and improves future estimates.',
                    style: TextStyle(
                      color: AppColors.softText,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 16),
                  InfoRow(
                    icon: Icons.event_available_outlined,
                    title: 'Start date',
                    value: formatDate(startDate),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: startDate,
                              firstDate: DateTime.now().subtract(
                                const Duration(days: 90),
                              ),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setSheetState(() => startDate = dateOnly(picked));
                            }
                          },
                          icon: const Icon(Icons.edit_calendar_outlined),
                          label: const Text('Change Date'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () {
                            final normalizedStart = dateOnly(startDate);
                            final cycleLengthDelta = normalizedStart
                                .difference(dateOnly(state.lastPeriodStart))
                                .inDays;
                            final nextCycleLength = clampInt(
                              cycleLengthDelta > 0
                                  ? cycleLengthDelta
                                  : prediction.effectiveCycleLength,
                              21,
                              45,
                            );
                            final updatedHistory = [
                              for (final record in state.history)
                                if (!sameDay(record.start, normalizedStart))
                                  record,
                              CycleRecord(
                                start: normalizedStart,
                                length: nextCycleLength,
                                periodLength: state.periodLength,
                              ),
                            ]..sort((a, b) => a.start.compareTo(b.start));
                            onChanged(
                              state.copyWith(
                                lastPeriodStart: normalizedStart,
                                cycleLength: nextCycleLength,
                                history: updatedHistory,
                              ),
                            );
                            final messenger = ScaffoldMessenger.of(context);
                            Navigator.of(sheetContext).pop();
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Period start updated to ${formatDate(normalizedStart)}.',
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.check_rounded),
                          label: const Text('Confirm'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    required this.prediction,
    required this.onPrimary,
    required this.onPeriodStarted,
  });

  final CyclePrediction prediction;
  final VoidCallback onPrimary;
  final VoidCallback onPeriodStarted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Color(0xFFFFE2EE), Color(0xFFF1E8FF)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withValues(alpha: 0.14),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prediction.statusTitle,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        height: 1.06,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Next period: ${formatShort(prediction.nextPeriodStart)} - ${formatShort(prediction.nextPeriodEnd)}',
                      style: const TextStyle(
                        color: AppColors.softText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.76),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  prediction.confidence.replaceAll(' confidence', ''),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primaryPink,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(height: 226, child: CycleRing(prediction: prediction)),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onPrimary,
                  icon: const Icon(Icons.edit_calendar_outlined),
                  label: const Text('Update Cycle Dates'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryPink,
                    minimumSize: const Size.fromHeight(54),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filledTonal(
                tooltip: 'Mark period started',
                onPressed: onPeriodStarted,
                icon: const Icon(Icons.water_drop_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CycleRing extends StatefulWidget {
  const CycleRing({super.key, required this.prediction});

  final CyclePrediction prediction;

  @override
  State<CycleRing> createState() => _CycleRingState();
}

class _CycleRingState extends State<CycleRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return CustomPaint(
          painter: CycleRingPainter(widget.prediction, _controller.value),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.prediction.ringCenterTop,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.prediction.ringCenterBottom,
                  style: const TextStyle(
                    color: AppColors.softText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'estimate',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.primaryPink,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CycleRingPainter extends CustomPainter {
  CycleRingPainter(this.prediction, this.progress);

  final CyclePrediction prediction;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 16;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18
      ..strokeCap = StrokeCap.round
      ..color = AppColors.softBlush;
    canvas.drawCircle(center, radius, base);

    void arc(int startDay, int length, Color color, {double glow = 0}) {
      final sweep =
          (length / prediction.effectiveCycleLength) * math.pi * 2 * progress;
      final start =
          -math.pi / 2 +
          ((startDay - 1) / prediction.effectiveCycleLength) * math.pi * 2;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 18
        ..strokeCap = StrokeCap.round
        ..color = color;
      if (glow > 0) {
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, glow);
      }
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
    }

    arc(1, prediction.effectivePeriodLength, AppColors.periodPink);
    final fertileStartDay =
        prediction.fertileStart
            .difference(prediction.currentCycleStart)
            .inDays +
        1;
    arc(math.max(1, fertileStartDay), 7, AppColors.fertilePurple);

    final currentAngle =
        -math.pi / 2 +
        ((prediction.cycleDay - 1) / prediction.effectiveCycleLength) *
            math.pi *
            2;
    final current =
        center +
        Offset(math.cos(currentAngle), math.sin(currentAngle)) * radius;
    canvas.drawCircle(current, 11, Paint()..color = Colors.white);
    canvas.drawCircle(current, 7, Paint()..color = AppColors.primaryPink);

    final ovulationDay =
        prediction.ovulationDay
            .difference(prediction.currentCycleStart)
            .inDays +
        1;
    if (ovulationDay >= 1 && ovulationDay <= prediction.effectiveCycleLength) {
      final angle =
          -math.pi / 2 +
          ((ovulationDay - 1) / prediction.effectiveCycleLength) * math.pi * 2;
      final dot = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      canvas.drawCircle(
        dot,
        10,
        Paint()..color = AppColors.ovulationBlue.withValues(alpha: 0.26),
      );
      canvas.drawCircle(dot, 5, Paint()..color = AppColors.ovulationBlue);
    }
  }

  @override
  bool shouldRepaint(covariant CycleRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.prediction != prediction;
  }
}

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, required this.state});

  final AppState state;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _visibleMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _visibleMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final prediction = CyclePrediction(widget.state);
    final firstDay = _visibleMonth;
    final daysInMonth = DateTime(
      _visibleMonth.year,
      _visibleMonth.month + 1,
      0,
    ).day;
    final leading = firstDay.weekday % 7;

    return AppScrollView(
      children: [
        HeaderBar(
          title: _monthName(_visibleMonth.month),
          subtitle: '${_visibleMonth.year} cycle calendar',
          actionIcon: Icons.info_outline,
          onAction: () => _showLegend(context),
        ),
        Row(
          children: [
            IconButton.filledTonal(
              tooltip: 'Previous month',
              onPressed: () => setState(
                () => _visibleMonth = DateTime(
                  _visibleMonth.year,
                  _visibleMonth.month - 1,
                ),
              ),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Center(
                child: Text(
                  '${_monthName(_visibleMonth.month)} ${_visibleMonth.year}',
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
            IconButton.filledTonal(
              tooltip: 'Next month',
              onPressed: () => setState(
                () => _visibleMonth = DateTime(
                  _visibleMonth.year,
                  _visibleMonth.month + 1,
                ),
              ),
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SoftCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              const Row(
                children: [
                  WeekLabel('S'),
                  WeekLabel('M'),
                  WeekLabel('T'),
                  WeekLabel('W'),
                  WeekLabel('T'),
                  WeekLabel('F'),
                  WeekLabel('S'),
                ],
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: leading + daysInMonth,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 0.82,
                ),
                itemBuilder: (context, index) {
                  if (index < leading) return const SizedBox.shrink();
                  final day = DateTime(
                    _visibleMonth.year,
                    _visibleMonth.month,
                    index - leading + 1,
                  );
                  final log = widget.state.logFor(day);
                  return CalendarDay(
                    date: day,
                    prediction: prediction,
                    hasSymptoms: !log.symptoms.contains('No symptoms'),
                    onTap: () => _showDaySheet(context, day, prediction),
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            LegendPill(color: AppColors.periodPink, label: 'Period'),
            LegendPill(color: AppColors.lightRose, label: 'Predicted period'),
            LegendPill(color: AppColors.fertilePurple, label: 'Fertile window'),
            LegendPill(color: AppColors.ovulationBlue, label: 'Ovulation'),
            LegendPill(color: Colors.white, label: 'Today', bordered: true),
          ],
        ),
      ],
    );
  }

  void _showLegend(BuildContext context) => _showMessageSheet(
    context,
    'Calendar colors',
    'Period, fertile window, ovulation, and today are highlighted without relying on color alone.',
  );

  void _showDaySheet(
    BuildContext context,
    DateTime day,
    CyclePrediction prediction,
  ) {
    final status = prediction.isPeriodDay(day)
        ? 'Period day'
        : prediction.isPredictedPeriodDay(day)
        ? 'Predicted period'
        : prediction.isFertileDay(day)
        ? 'Fertile window estimate'
        : 'Cycle day ${day.difference(prediction.currentCycleStart).inDays + 1}';
    final log = widget.state.logFor(day);
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.creamWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(22, 6, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              formatDate(day),
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            InfoRow(
              icon: Icons.auto_graph_outlined,
              title: 'Cycle status',
              value: status,
            ),
            InfoRow(
              icon: Icons.water_drop_outlined,
              title: 'Flow',
              value: log.flow == 'None' && prediction.isPeriodDay(day)
                  ? 'Expected period day'
                  : log.flow,
            ),
            InfoRow(icon: Icons.mood_outlined, title: 'Mood', value: log.mood),
            InfoRow(
              icon: Icons.healing_outlined,
              title: 'Symptoms',
              value: log.symptoms.join(', '),
            ),
            InfoRow(
              icon: Icons.note_alt_outlined,
              title: 'Notes',
              value: log.notes.isEmpty
                  ? 'No notes saved for this date.'
                  : log.notes,
            ),
          ],
        ),
      ),
    );
  }
}

class DailyLogScreen extends StatefulWidget {
  const DailyLogScreen({
    super.key,
    required this.state,
    required this.initialSection,
    required this.onChanged,
    required this.onCancel,
  });

  final AppState state;
  final String? initialSection;
  final ValueChanged<AppState> onChanged;
  final VoidCallback onCancel;

  @override
  State<DailyLogScreen> createState() => _DailyLogScreenState();
}

class _DailyLogScreenState extends State<DailyLogScreen> {
  late DailyLog _draft;
  late final TextEditingController _notes;
  late final ScrollController _scrollController;
  var _saved = false;
  var _lastInitialSection = '';

  final _sectionKeys = {
    'flow': GlobalKey(),
    'mood': GlobalKey(),
    'symptoms': GlobalKey(),
    'discharge': GlobalKey(),
    'pain': GlobalKey(),
    'activity': GlobalKey(),
    'notes': GlobalKey(),
  };

  static const flows = ['None', 'Spotting', 'Light', 'Medium', 'Heavy'];
  static const moods = [
    'Happy',
    'Calm',
    'Sensitive',
    'Sad',
    'Irritated',
    'Anxious',
    'Tired',
    'Energetic',
  ];
  static const symptoms = [
    'Cramps',
    'Headache',
    'Acne',
    'Bloating',
    'Breast tenderness',
    'Back pain',
    'Nausea',
    'Fatigue',
    'Cravings',
    'Mood swings',
    'Insomnia',
    'Dizziness',
    'No symptoms',
  ];
  static const discharge = [
    'None',
    'Sticky',
    'Creamy',
    'Watery',
    'Egg-white',
    'Unusual',
  ];
  static const activities = [
    'None',
    'Walking',
    'Running',
    'Gym',
    'Yoga',
    'Cycling',
    'Stretching',
  ];

  @override
  void initState() {
    super.initState();
    _draft = widget.state.todayLog;
    _notes = TextEditingController(text: _draft.notes);
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToInitial());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DailyLogScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state.todayLog != widget.state.todayLog && !_saved) {
      _draft = widget.state.todayLog;
      _notes.text = _draft.notes;
    }
    if (oldWidget.initialSection != widget.initialSection) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToInitial());
    }
  }

  @override
  Widget build(BuildContext context) {
    final painLevel = clampDouble(_draft.painLevel, 0, 10);
    return AppScrollView(
      controller: _scrollController,
      children: [
        HeaderBar(
          title: 'Record Daily Health',
          subtitle: 'Cycle Day ${CyclePrediction(widget.state).cycleDay}',
          actionIcon: Icons.close_rounded,
          onAction: _cancel,
        ),
        const SizedBox(height: 16),
        DailyLogSection(
          key: _sectionKeys['flow'],
          title: 'Menstrual Flow',
          helper: 'Choose what feels closest today.',
          children: flows
              .map(
                (flow) => SelectableChip(
                  label: flow,
                  icon: Icons.water_drop_outlined,
                  selected: _draft.flow == flow,
                  onTap: () => _set(_draft.copyWith(flow: flow)),
                ),
              )
              .toList(),
        ),
        DailyLogSection(
          key: _sectionKeys['mood'],
          title: 'Mood',
          children: moods
              .map(
                (mood) => SelectableChip(
                  label: mood,
                  icon: mood == 'Calm'
                      ? Icons.self_improvement_outlined
                      : Icons.mood_outlined,
                  selected: _draft.mood == mood,
                  onTap: () => _set(_draft.copyWith(mood: mood)),
                ),
              )
              .toList(),
        ),
        DailyLogSection(
          key: _sectionKeys['symptoms'],
          title: 'Symptoms',
          children: symptoms
              .map(
                (symptom) => SelectableChip(
                  label: symptom,
                  icon: symptom == 'No symptoms'
                      ? Icons.check_circle_outline
                      : Icons.healing_outlined,
                  selected: _draft.symptoms.contains(symptom),
                  onTap: () {
                    final next = {..._draft.symptoms};
                    if (symptom == 'No symptoms') {
                      next
                        ..clear()
                        ..add(symptom);
                    } else {
                      next.remove('No symptoms');
                      next.contains(symptom)
                          ? next.remove(symptom)
                          : next.add(symptom);
                      if (next.isEmpty) next.add('No symptoms');
                    }
                    _set(_draft.copyWith(symptoms: next));
                  },
                ),
              )
              .toList(),
        ),
        DailyLogSection(
          key: _sectionKeys['discharge'],
          title: 'Discharge',
          helper: 'Discharge can change naturally during your cycle.',
          children: discharge
              .map(
                (item) => SelectableChip(
                  label: item,
                  icon: Icons.opacity_rounded,
                  selected: _draft.discharge == item,
                  onTap: () => _set(_draft.copyWith(discharge: item)),
                ),
              )
              .toList(),
        ),
        SoftCard(
          key: _sectionKeys['pain'],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(
                title: 'Pain Level',
                trailing: _painLabel(painLevel),
              ),
              Slider(
                value: painLevel,
                min: 0,
                max: 10,
                divisions: 10,
                label: painLevel.round().toString(),
                onChanged: (value) =>
                    _set(_draft.copyWith(painLevel: clampDouble(value, 0, 10))),
              ),
              const Wrap(
                alignment: WrapAlignment.spaceBetween,
                spacing: 12,
                runSpacing: 6,
                children: [
                  Text(
                    '0 No pain',
                    style: TextStyle(
                      color: AppColors.softText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '10 Severe pain',
                    style: TextStyle(
                      color: AppColors.softText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        DailyLogSection(
          key: _sectionKeys['activity'],
          title: 'Physical Activity',
          children: activities
              .map(
                (activity) => SelectableChip(
                  label: activity,
                  icon: activity == 'Yoga'
                      ? Icons.self_improvement_outlined
                      : Icons.directions_walk_outlined,
                  selected: _draft.activity == activity,
                  onTap: () => _set(_draft.copyWith(activity: activity)),
                ),
              )
              .toList(),
        ),
        SoftCard(
          child: Column(
            children: [
              SwitchTileCard(
                embedded: true,
                icon: Icons.visibility_off_outlined,
                title: 'Hide intimacy section',
                subtitle: 'Keep privacy-sensitive details out of sight.',
                value: _draft.hideIntimacy,
                onChanged: (value) =>
                    _set(_draft.copyWith(hideIntimacy: value)),
              ),
              if (!_draft.hideIntimacy) ...[
                const Divider(height: 18),
                SwitchTileCard(
                  embedded: true,
                  icon: Icons.favorite_border_rounded,
                  title: 'Had sex',
                  subtitle: 'Private and discreet.',
                  value: _draft.hadSex,
                  onChanged: (value) => _set(_draft.copyWith(hadSex: value)),
                ),
                SwitchTileCard(
                  embedded: true,
                  icon: Icons.shield_outlined,
                  title: 'Protected',
                  subtitle: 'This is a log, not contraception advice.',
                  value: _draft.protectedSex,
                  onChanged: (value) =>
                      _set(_draft.copyWith(protectedSex: value)),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        SoftCard(
          key: _sectionKeys['notes'],
          child: TextField(
            controller: _notes,
            minLines: 4,
            maxLines: 6,
            onChanged: (value) => _set(_draft.copyWith(notes: value)),
            decoration: InputDecoration(
              labelText: 'Private notes',
              hintText: 'Write anything about how you feel today...',
              filled: true,
              fillColor: AppColors.creamWhite,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: _cancel,
          icon: const Icon(Icons.close_rounded),
          label: const Text('Cancel Changes'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.deepText,
            side: const BorderSide(color: AppColors.lightRose),
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: _save,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              _saved ? Icons.check_circle_rounded : Icons.favorite_rounded,
              key: ValueKey(_saved),
            ),
          ),
          label: Text(_saved ? 'Saved' : 'Save Today\'s Log'),
          style: FilledButton.styleFrom(
            backgroundColor: _saved
                ? AppColors.successGreen
                : AppColors.primaryPink,
            foregroundColor: AppColors.deepText,
            minimumSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ),
      ],
    );
  }

  void _set(DailyLog next) {
    final safeDraft = next.copyWith(
      painLevel: clampDouble(next.painLevel, 0, 10),
    );
    setState(() {
      _draft = safeDraft;
      _saved = false;
    });
  }

  void _save() {
    widget.onChanged(widget.state.saveLogFor(DateTime.now(), _draft));
    setState(() => _saved = true);
  }

  void _cancel() {
    setState(() {
      _draft = widget.state.todayLog;
      _notes.text = _draft.notes;
      _saved = false;
    });
    widget.onCancel();
  }

  void _scrollToInitial() {
    final section = widget.initialSection;
    if (!mounted ||
        section == null ||
        section == 'overview' ||
        section == _lastInitialSection) {
      return;
    }
    _lastInitialSection = section;
    final context = _sectionKeys[section]?.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  String _painLabel(double value) {
    if (value <= 2) return 'Mild';
    if (value <= 6) return 'Moderate';
    return 'Strong';
  }
}

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key, required this.state});

  final AppState state;

  @override
  Widget build(BuildContext context) {
    final prediction = CyclePrediction(state);
    final avgCycle = state.history.isEmpty
        ? state.cycleLength
        : (state.history.map((e) => e.length).reduce((a, b) => a + b) /
                  state.history.length)
              .round();
    final avgPeriod = state.history.isEmpty
        ? state.periodLength
        : (state.history.map((e) => e.periodLength).reduce((a, b) => a + b) /
                  state.history.length)
              .round();
    final logged = state.logs.map((entry) => entry.log).toList();
    final commonMood = mostCommon(logged.map((log) => log.mood));
    final commonSymptoms = mostCommonSymptoms(logged);
    final averagePain = logged.isEmpty
        ? state.todayLog.painLevel
        : logged.map((log) => log.painLevel).reduce((a, b) => a + b) /
              logged.length;
    final commonFlow = mostCommon(logged.map((log) => log.flow));

    return AppScrollView(
      children: [
        const HeaderBar(
          title: 'Cycle Insights',
          subtitle: 'Patterns, not diagnoses',
          actionIcon: Icons.insights_outlined,
        ),
        const SizedBox(height: 16),
        ResponsiveGrid(
          children: [
            InsightCard(
              icon: Icons.autorenew_rounded,
              title: 'Average cycle',
              value: '$avgCycle days',
              note: 'Last ${state.history.length} cycles',
            ),
            InsightCard(
              icon: Icons.water_drop_outlined,
              title: 'Average period',
              value: '$avgPeriod days',
              note: 'Based on logged history',
            ),
            InsightCard(
              icon: Icons.timeline_rounded,
              title: 'Regularity',
              value: state.isRegular ? 'Steady' : 'Variable',
              note: prediction.confidence,
            ),
            InsightCard(
              icon: Icons.favorite_border_rounded,
              title: 'Common mood',
              value: commonMood,
              note: 'From saved daily logs',
            ),
            InsightCard(
              icon: Icons.opacity_rounded,
              title: 'Common flow',
              value: commonFlow,
              note: 'From period-day logs',
            ),
          ],
        ),
        const SizedBox(height: 18),
        SectionTitle(title: 'Cycle Length Trend'),
        SoftCard(
          child: SizedBox(
            height: 150,
            child: TrendChart(records: state.history),
          ),
        ),
        const SizedBox(height: 18),
        SectionTitle(title: 'Patterns'),
        InfoRow(
          icon: Icons.healing_outlined,
          title: 'Most common symptoms',
          value: commonSymptoms,
        ),
        InfoRow(
          icon: Icons.monitor_heart_outlined,
          title: 'Pain trend',
          value:
              '${averagePain.toStringAsFixed(1)}/10 average from saved logs. Higher pain days receive gentler self-care suggestions.',
        ),
        InfoRow(
          icon: Icons.opacity_rounded,
          title: 'Discharge pattern',
          value:
              'Most recent: ${state.logFor(DateTime.now()).discharge}. This is used only as a cycle clue, not a diagnosis.',
        ),
        InfoRow(
          icon: Icons.local_florist_outlined,
          title: 'Predicted fertile window',
          value:
              '${formatShort(prediction.fertileStart)} - ${formatShort(prediction.fertileEnd)}',
        ),
        InfoRow(
          icon: Icons.water_drop_outlined,
          title: 'Predicted next period',
          value:
              '${formatShort(prediction.nextPeriodStart)} - ${formatShort(prediction.nextPeriodEnd)}',
        ),
        const SizedBox(height: 16),
        SoftCard(
          color: AppColors.lavender.withValues(alpha: 0.72),
          child: Text(
            'Your saved logs suggest $commonMood mood is common and $commonSymptoms are worth watching. Your cycle settings are $avgCycle days with a $avgPeriod-day period. If a pattern feels unusual for you, consider speaking with a qualified healthcare professional.',
            style: TextStyle(fontWeight: FontWeight.w700, height: 1.45),
          ),
        ),
        const SizedBox(height: 16),
        const MedicalDisclaimer(),
      ],
    );
  }
}

class SelfCareScreen extends StatelessWidget {
  const SelfCareScreen({
    super.key,
    required this.state,
    required this.onChanged,
    required this.onOpenSettings,
  });

  final AppState state;
  final ValueChanged<AppState> onChanged;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    final prediction = CyclePrediction(state);
    final todayLog = state.logFor(DateTime.now());
    final tips = _tipsFor(prediction.phase, todayLog);
    return AppScrollView(
      children: [
        HeaderBar(
          title: 'Self-Care',
          subtitle: prediction.phase,
          actionIcon: Icons.settings_outlined,
          onAction: onOpenSettings,
        ),
        const SizedBox(height: 16),
        SoftCard(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFEEF5), Color(0xFFEDE4FF)],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.nightlight_round,
                color: AppColors.primaryPink,
                size: 34,
              ),
              const SizedBox(height: 12),
              Text(
                todayLog.painLevel >= 6
                    ? 'Gentle care today'
                    : 'Take it easy today',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'Your body has patterns. Let\'s understand them gently.',
                style: TextStyle(
                  color: AppColors.deepText.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        SectionTitle(title: 'Recommended Support'),
        ...tips.map((tip) => CareTipCard(tip: tip)),
        const SizedBox(height: 18),
        SectionTitle(title: 'Reminders'),
        FutureBuilder<bool>(
          future: DeviceServices.areNotificationsEnabled(),
          builder: (context, snapshot) {
            final notificationsAllowed =
                snapshot.data ?? state.remindersEnabled;
            final shouldShowEnableCard =
                !state.remindersEnabled || !notificationsAllowed;
            if (!shouldShowEnableCard) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SoftCard(
                color: AppColors.softBlush,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Enable phone reminders',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'LunaCycle can send gentle period, check-in, and self-care reminders even when the app is closed.',
                      style: TextStyle(
                        color: AppColors.softText,
                        fontWeight: FontWeight.w700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () async {
                        final granted =
                            await DeviceServices.requestNotificationPermission();
                        if (!context.mounted) return;
                        final next = state.copyWith(
                          notificationPermissionAsked: true,
                          remindersEnabled: granted,
                        );
                        onChanged(next);
                        if (granted) {
                          final scheduled =
                              await DeviceServices.scheduleReminders(
                                next.reminders,
                                enabled: next.remindersEnabled,
                                hideSensitive:
                                    next.sensitiveNotificationsHidden,
                              );
                          final testShown =
                              await DeviceServices.showTestNotification(
                                hideSensitive:
                                    next.sensitiveNotificationsHidden,
                              );
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                scheduled && testShown
                                    ? 'Reminders are enabled and saved on this phone.'
                                    : 'Reminders were enabled, but Android is still blocking notifications. Check phone notification settings.',
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Notification permission was not granted. You can try again here or enable it in phone settings.',
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.notifications_active_outlined),
                      label: const Text('Allow Reminders'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        ...state.reminders.asMap().entries.map((entry) {
          return ReminderCard(
            item: entry.value,
            onChanged: (enabled) {
              final reminders = [...state.reminders];
              reminders[entry.key] = reminders[entry.key].copyWith(
                enabled: enabled,
              );
              onChanged(state.copyWith(reminders: reminders));
            },
            onEdit: () => _editReminder(context, entry.key),
          );
        }),
      ],
    );
  }

  Future<void> _editReminder(BuildContext context, int index) async {
    var reminder = state.reminders[index];
    final messageController = TextEditingController(text: reminder.message);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.creamWhite,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                22,
                4,
                22,
                24 + MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      labelText: 'Reminder message',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: reminder.time,
                      );
                      if (picked != null) {
                        setSheetState(
                          () => reminder = reminder.copyWith(time: picked),
                        );
                      }
                    },
                    icon: const Icon(Icons.schedule_outlined),
                    label: Text('Time: ${reminder.time.format(context)}'),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: () {
                      final reminders = [...state.reminders];
                      reminders[index] = reminder.copyWith(
                        message: messageController.text.trim().isEmpty
                            ? reminder.message
                            : messageController.text.trim(),
                        enabled: true,
                      );
                      onChanged(state.copyWith(reminders: reminders));
                      Navigator.of(sheetContext).pop();
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Save Reminder'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    messageController.dispose();
  }

  List<CareTip> _tipsFor(String phase, DailyLog log) {
    final personalized = <CareTip>[];
    if (log.painLevel >= 6) {
      personalized.add(
        const CareTip(
          Icons.thermostat_outlined,
          'Pain support',
          'Use warmth, rest, and gentle movement. If pain feels severe or unusual, consider medical support.',
        ),
      );
    }
    if (log.symptoms.contains('Headache')) {
      personalized.add(
        const CareTip(
          Icons.local_drink_outlined,
          'Headache care',
          'Hydrate, rest your eyes, and note whether headaches repeat around the same cycle day.',
        ),
      );
    }
    if (log.mood == 'Anxious' ||
        log.mood == 'Irritated' ||
        log.mood == 'Sensitive') {
      personalized.add(
        const CareTip(
          Icons.self_improvement_outlined,
          'Mood support',
          'Try a calmer schedule, breathing, journaling, or a short walk if it feels good.',
        ),
      );
    }
    if (phase == 'Period phase') {
      return [
        ...personalized,
        CareTip(
          Icons.hotel_outlined,
          'Rest',
          'Give your body a slower pace when you can.',
        ),
        CareTip(
          Icons.local_drink_outlined,
          'Hydration',
          'Keep water nearby and sip often.',
        ),
        CareTip(
          Icons.thermostat_outlined,
          'Warm compress',
          'Warmth may feel comforting for cramps.',
        ),
        CareTip(
          Icons.self_improvement_outlined,
          'Gentle stretching',
          'Soft movement can help some people feel better.',
        ),
      ];
    }
    if (phase == 'Fertile window') {
      return [
        ...personalized,
        CareTip(
          Icons.opacity_rounded,
          'Track discharge',
          'Changes can be a useful cycle clue.',
        ),
        CareTip(
          Icons.bolt_outlined,
          'Notice energy',
          'Some people feel more energetic around this phase.',
        ),
        CareTip(
          Icons.lock_outline,
          'Private notes',
          'Keep intimacy details discreet if you log them.',
        ),
      ];
    }
    return [
      ...personalized,
      CareTip(
        Icons.inventory_2_outlined,
        'Prepare supplies',
        'Keep pads, tampons, or cups nearby before your period.',
      ),
      CareTip(
        Icons.bedtime_outlined,
        'Sleep well',
        'Rest can support mood and energy.',
      ),
      CareTip(
        Icons.spa_outlined,
        'Reduce stress',
        'A calm moment can make tracking feel lighter.',
      ),
      CareTip(
        Icons.restaurant_outlined,
        'Balanced meals',
        'Choose food that helps you feel steady.',
      ),
    ];
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    required this.state,
    required this.onChanged,
  });

  final AppState state;
  final ValueChanged<AppState> onChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppState state;
  var _togglingAppLock = false;

  @override
  void initState() {
    super.initState();
    state = widget.state;
  }

  void onChanged(AppState next) {
    if (mounted) {
      setState(() => state = next);
    }
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return SoftScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Settings'),
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.deepText,
          elevation: 0,
        ),
        body: AppScrollView(
          topPadding: 6,
          children: [
            SettingsAction(
              icon: Icons.person_outline,
              title: 'Your name',
              subtitle: state.name.trim().isEmpty
                  ? 'Add your name for personal greetings.'
                  : 'Greeting as ${state.name.trim()}.',
              onTap: () => _editName(context),
            ),
            SettingsAction(
              icon: Icons.event_available_outlined,
              title: 'Last period start date',
              subtitle:
                  'Currently ${formatDate(state.lastPeriodStart)}. Used for Today, Calendar, Insights, and Self-Care.',
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: state.lastPeriodStart,
                  firstDate: DateTime.now().subtract(const Duration(days: 730)),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                if (picked != null) {
                  onChanged(state.copyWith(lastPeriodStart: dateOnly(picked)));
                }
              },
            ),
            SliderPanel(
              label: 'Usual cycle length',
              value: state.cycleLength,
              min: 21,
              max: 45,
              unit: 'days',
              onChanged: (value) =>
                  onChanged(state.copyWith(cycleLength: value)),
            ),
            const SizedBox(height: 14),
            SliderPanel(
              label: 'Usual period length',
              value: state.periodLength,
              min: 2,
              max: 10,
              unit: 'days',
              onChanged: (value) =>
                  onChanged(state.copyWith(periodLength: value)),
            ),
            const SizedBox(height: 14),
            SwitchTileCard(
              icon: Icons.lock_outline,
              title: 'App lock',
              subtitle: _togglingAppLock
                  ? 'Checking your phone lock...'
                  : 'Uses your phone screen lock, fingerprint, or face unlock when available.',
              value: state.privacyLockEnabled,
              onChanged: _togglingAppLock ? null : _toggleAppLock,
            ),
            const SizedBox(height: 14),
            SwitchTileCard(
              icon: Icons.notifications_off_outlined,
              title: 'Hide sensitive notifications',
              subtitle: state.sensitiveNotificationsHidden
                  ? 'Phone notifications show discreet LunaCycle text.'
                  : 'Phone notifications can show your selected reminder message.',
              value: state.sensitiveNotificationsHidden,
              onChanged: (value) async {
                final next = state.copyWith(
                  sensitiveNotificationsHidden: value,
                );
                onChanged(next);
                final updated = await DeviceServices.scheduleReminders(
                  next.reminders,
                  enabled: next.remindersEnabled,
                  hideSensitive: next.sensitiveNotificationsHidden,
                );
                if (!mounted || updated) return;
                ScaffoldMessenger.of(this.context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Could not refresh reminder notifications on this phone. Please try again.',
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            SettingsAction(
              icon: Icons.ios_share_outlined,
              title: 'Export data',
              subtitle: 'Prepare a private copy of your logs.',
              onTap: () => _showMessageSheet(
                context,
                'Export data',
                'Export is prepared for a future release. Your current logs are stored locally on this phone.',
              ),
            ),
            SettingsAction(
              icon: Icons.phone_android_outlined,
              title: 'Saved on this phone',
              subtitle: 'Your cycle and health logs stay in local app storage.',
              onTap: () => _showMessageSheet(
                context,
                'Local storage',
                'Your LunaCycle data is saved in this phone app storage. Removing the app can remove the saved data.',
              ),
            ),
            SettingsAction(
              icon: Icons.info_outline,
              title: 'About LunaCycle',
              subtitle: 'Purpose, inspiration, support, and app guidance.',
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const AboutScreen())),
            ),
            SettingsAction(
              icon: Icons.gavel_outlined,
              title: 'Terms of Service',
              subtitle: 'Usage terms and health-information limits.',
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const TermsScreen())),
            ),
            SettingsAction(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'How local health data is handled.',
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
              ),
            ),
            SettingsAction(
              icon: Icons.delete_outline,
              title: 'Delete data',
              subtitle: 'Clear cycle and health logs from this device.',
              danger: true,
              onTap: () async {
                await AppStorage.clear();
                onChanged(AppState.sample());
                if (context.mounted) {
                  _showMessageSheet(
                    context,
                    'Data reset',
                    'Local LunaCycle data has been reset on this phone.',
                  );
                }
              },
            ),
            const SizedBox(height: 14),
            const MedicalDisclaimer(),
          ],
        ),
      ),
    );
  }

  Future<void> _editName(BuildContext context) async {
    final controller = TextEditingController(text: state.name);
    final savedName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          scrollable: true,
          backgroundColor: AppColors.creamWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          title: const Text('Your Name'),
          content: TextField(
            controller: controller,
            autofocus: true,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            decoration: InputDecoration(
              hintText: 'Enter your first name',
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
    if (!mounted) {
      controller.dispose();
      return;
    }
    if (savedName != null) {
      onChanged(state.copyWith(name: savedName));
    }
    controller.dispose();
  }

  Future<void> _toggleAppLock(bool enabled) async {
    if (!enabled) {
      onChanged(state.copyWith(privacyLockEnabled: false));
      return;
    }
    setState(() => _togglingAppLock = true);
    final unlocked = await DeviceServices.unlockWithDeviceCredential();
    if (!mounted) return;
    setState(() => _togglingAppLock = false);
    if (unlocked) {
      onChanged(state.copyWith(privacyLockEnabled: true));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'App lock is on. LunaCycle will ask for your phone lock when reopened.',
          ),
        ),
      );
      return;
    }
    onChanged(state.copyWith(privacyLockEnabled: false));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'App lock was not enabled. Confirm your phone lock and try again.',
        ),
      ),
    );
  }
}

class SafeSheet extends StatelessWidget {
  const SafeSheet({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          22,
          4,
          22,
          24 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoDocumentScreen(
      title: 'About LunaCycle',
      icon: Icons.nightlight_round,
      sections: [
        InfoSection(
          'What LunaCycle Does',
          'LunaCycle is a private period and wellness companion for girls, women, ladies, mothers, and anyone who menstruates. It helps track period dates, daily health logs, symptoms, mood, discharge, activity, reminders, and cycle patterns.',
        ),
        InfoSection(
          'How Predictions Work',
          'Predictions are estimates based on your saved period dates, usual cycle length, period length, and daily logs. They improve as you track more cycles, but they are not medical advice, contraception, diagnosis, or fertility treatment guidance.',
        ),
        InfoSection(
          'Inspiration',
          'This app was inspired by TREASURE MANGIRI EBIMOBOERE.',
        ),
        InfoSection('Support', 'For help or support, visit nisanawa.tech.'),
      ],
    );
  }
}

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoDocumentScreen(
      title: 'Terms of Service',
      icon: Icons.gavel_outlined,
      sections: [
        InfoSection(
          'Use of the App',
          'LunaCycle is for personal cycle tracking, wellness reflection, reminders, and general self-care support. You are responsible for the information you enter and decisions you make from it.',
        ),
        InfoSection(
          'Health Disclaimer',
          'The app does not provide medical advice, diagnosis, contraception, fertility treatment, or emergency guidance. If symptoms are severe, unusual, or concerning, speak with a qualified healthcare professional.',
        ),
        InfoSection(
          'Predictions',
          'Cycle, ovulation, fertile-window, and period estimates can be wrong because bodies and cycles change. Do not rely on app predictions as contraception or as proof of pregnancy or fertility status.',
        ),
        InfoSection(
          'Data',
          'Your data is saved in local app storage on this phone. If you delete the app or clear app data, your saved LunaCycle data may be removed.',
        ),
      ],
    );
  }
}

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const InfoDocumentScreen(
      title: 'Privacy Policy',
      icon: Icons.privacy_tip_outlined,
      sections: [
        InfoSection(
          'Local-First Storage',
          'LunaCycle stores your profile, period dates, daily logs, reminder settings, and privacy preferences in local app storage on this phone.',
        ),
        InfoSection(
          'Sensitive Health Data',
          'Period dates, symptoms, moods, intimacy logs, discharge logs, notes, and reminders can be sensitive. The app includes privacy lock and discreet notification options to help protect them.',
        ),
        InfoSection(
          'Sharing',
          'This build does not upload, sell, or share your cycle logs. Export and cloud sync are not active features.',
        ),
        InfoSection(
          'Notifications',
          'If you allow reminders, Android may show LunaCycle notifications. You can keep reminder previews discreet with Hide sensitive notifications.',
        ),
      ],
    );
  }
}

class InfoDocumentScreen extends StatelessWidget {
  const InfoDocumentScreen({
    super.key,
    required this.title,
    required this.icon,
    required this.sections,
  });

  final String title;
  final IconData icon;
  final List<InfoSection> sections;

  @override
  Widget build(BuildContext context) {
    return SoftScaffold(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(title),
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.deepText,
          elevation: 0,
        ),
        body: AppScrollView(
          topPadding: 8,
          children: [
            SoftCard(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFEEF5), Color(0xFFEDE4FF)],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(icon, color: AppColors.primaryPink),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ...sections.map(
              (section) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SoftCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        section.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        section.body,
                        style: const TextStyle(
                          color: AppColors.softText,
                          fontWeight: FontWeight.w700,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoSection {
  const InfoSection(this.title, this.body);

  final String title;
  final String body;
}

class PrivacyLockScreen extends StatelessWidget {
  const PrivacyLockScreen({super.key, required this.onUnlock});

  final Future<void> Function() onUnlock;

  @override
  Widget build(BuildContext context) {
    return SoftScaffold(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 92,
                height: 92,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: AppColors.primaryPink,
                  size: 42,
                ),
              ),
              const SizedBox(height: 22),
              const Text(
                'LunaCycle Locked',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 10),
              const Text(
                'Use your phone security to continue.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.softText,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 26),
              FilledButton.icon(
                onPressed: onUnlock,
                icon: const Icon(Icons.fingerprint),
                label: const Text('Unlock LunaCycle'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primaryPink,
                  minimumSize: const Size.fromHeight(54),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNav extends StatelessWidget {
  const BottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    const tabs = [
      (Icons.favorite_outline, Icons.favorite, 'Today'),
      (Icons.calendar_month_outlined, Icons.calendar_month, 'Calendar'),
      (Icons.add_rounded, Icons.add_rounded, 'Log'),
      (Icons.insights_outlined, Icons.insights, 'Insights'),
      (Icons.spa_outlined, Icons.spa, 'Self-Care'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Container(
        height: 74,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.88),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryPink.withValues(alpha: 0.16),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(tabs.length, (index) {
            final selected = index == selectedIndex;
            final tab = tabs[index];
            final isCenter = index == 2;
            return Expanded(
              child: Tooltip(
                message: tab.$3,
                child: InkWell(
                  borderRadius: BorderRadius.circular(999),
                  onTap: () => onSelected(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    height: isCenter ? 58 : 54,
                    margin: EdgeInsets.symmetric(
                      horizontal: isCenter ? 4 : 0,
                      vertical: isCenter ? 0 : 8,
                    ),
                    decoration: BoxDecoration(
                      color: isCenter
                          ? AppColors.primaryPink
                          : (selected
                                ? AppColors.softBlush
                                : Colors.transparent),
                      shape: isCenter ? BoxShape.circle : BoxShape.rectangle,
                      borderRadius: isCenter
                          ? null
                          : BorderRadius.circular(999),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          selected ? tab.$2 : tab.$1,
                          color: isCenter
                              ? Colors.white
                              : (selected
                                    ? AppColors.primaryPink
                                    : AppColors.softText),
                          size: isCenter ? 30 : 22,
                        ),
                        if (!isCenter) ...[
                          const SizedBox(height: 2),
                          FittedBox(
                            child: Text(
                              tab.$3,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: selected
                                    ? AppColors.primaryPink
                                    : AppColors.softText,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class SoftScaffold extends StatelessWidget {
  const SoftScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFF1F7), Color(0xFFFFE3EF), Color(0xFFFFF8FA)],
          stops: [0, 0.45, 1],
        ),
      ),
      child: Stack(
        children: [
          const Positioned(
            top: 72,
            right: -28,
            child: SoftOrb(size: 128, color: AppColors.lavender),
          ),
          const Positioned(
            top: 220,
            left: -46,
            child: SoftOrb(size: 112, color: AppColors.lightRose),
          ),
          const Positioned(bottom: 140, right: 32, child: SparkleField()),
          child,
        ],
      ),
    );
  }
}

class SoftOrb extends StatelessWidget {
  const SoftOrb({super.key, required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.24),
          boxShadow: [
            BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 34),
          ],
        ),
      ),
    );
  }
}

class SparkleField extends StatelessWidget {
  const SparkleField({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Opacity(
        opacity: 0.22,
        child: Column(
          children: List.generate(5, (index) {
            return Padding(
              padding: EdgeInsets.only(left: index.isEven ? 18 : 0, bottom: 10),
              child: Icon(
                Icons.auto_awesome,
                size: 14 + index.toDouble(),
                color: AppColors.primaryPink,
              ),
            );
          }),
        ),
      ),
    );
  }
}

class AppScrollView extends StatelessWidget {
  const AppScrollView({
    super.key,
    required this.children,
    this.topPadding = 18,
    this.controller,
  });

  final List<Widget> children;
  final double topPadding;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: controller,
      padding: EdgeInsets.fromLTRB(18, topPadding, 18, 112),
      children: children,
    );
  }
}

class HeaderBar extends StatelessWidget {
  const HeaderBar({
    super.key,
    required this.title,
    required this.subtitle,
    required this.actionIcon,
    this.onAction,
  });

  final String title;
  final String subtitle;
  final IconData actionIcon;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  height: 1.08,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.softText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        IconButton.filledTonal(
          onPressed: onAction,
          icon: Icon(actionIcon),
          tooltip: 'Open settings',
        ),
      ],
    );
  }
}

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.color,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null
            ? color ?? Colors.white.withValues(alpha: 0.88)
            : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryPink.withValues(alpha: 0.10),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: child,
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.supporting,
  });

  final IconData icon;
  final String label;
  final String value;
  final String supporting;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.softBlush,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.primaryPink, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.softText,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? 'None' : value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              height: 1.08,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            supporting,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.softText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class InsightCard extends StatelessWidget {
  const InsightCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.note,
  });

  final IconData icon;
  final String title;
  final String value;
  final String note;

  @override
  Widget build(BuildContext context) {
    return MetricCard(icon: icon, label: title, value: value, supporting: note);
  }
}

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: children
              .map((child) => SizedBox(width: itemWidth, child: child))
              .toList(),
        );
      },
    );
  }
}

class SelectableChip extends StatelessWidget {
  const SelectableChip({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width - 52,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primaryPink
                  : Colors.white.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: selected ? AppColors.primaryPink : AppColors.lightRose,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.primaryPink.withValues(alpha: 0.18),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: selected ? Colors.white : AppColors.primaryPink,
                ),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: selected ? Colors.white : AppColors.deepText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DailyLogSection extends StatelessWidget {
  const DailyLogSection({
    super.key,
    required this.title,
    required this.children,
    this.helper,
  });

  final String title;
  final String? helper;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: SoftCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            if (helper != null) ...[
              const SizedBox(height: 5),
              Text(
                helper!,
                style: const TextStyle(
                  color: AppColors.softText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 14),
            Wrap(spacing: 9, runSpacing: 10, children: children),
          ],
        ),
      ),
    );
  }
}

class CalendarDay extends StatelessWidget {
  const CalendarDay({
    super.key,
    required this.date,
    required this.prediction,
    required this.hasSymptoms,
    required this.onTap,
  });

  final DateTime date;
  final CyclePrediction prediction;
  final bool hasSymptoms;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isToday = sameDay(date, DateTime.now());
    final isPeriod = prediction.isPeriodDay(date);
    final isPredicted = prediction.isPredictedPeriodDay(date);
    final isFertile = prediction.isFertileDay(date);
    final isOvulation = prediction.isOvulationDay(date);
    final color = isPeriod
        ? AppColors.periodPink
        : isPredicted
        ? AppColors.lightRose
        : isFertile
        ? AppColors.lavender
        : Colors.white.withValues(alpha: 0.78);
    final textColor = isPeriod ? Colors.white : AppColors.deepText;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isToday
                ? AppColors.primaryPink
                : Colors.white.withValues(alpha: 0.85),
            width: isToday ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${date.day}',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isOvulation) const TinyDot(color: AppColors.ovulationBlue),
                if (hasSymptoms) const TinyDot(color: AppColors.warningPeach),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ReminderCard extends StatelessWidget {
  const ReminderCard({
    super.key,
    required this.item,
    required this.onChanged,
    required this.onEdit,
  });

  final ReminderItem item;
  final ValueChanged<bool> onChanged;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onEdit,
        child: SoftCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.softBlush,
                child: Icon(item.icon, color: AppColors.primaryPink),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.time.format(context)} - ${item.message}',
                      style: const TextStyle(
                        color: AppColors.softText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tap to edit message or time',
                      style: TextStyle(
                        color: AppColors.primaryPink,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: item.enabled,
                activeThumbColor: AppColors.primaryPink,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CareTip {
  const CareTip(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}

class CareTipCard extends StatelessWidget {
  const CareTipCard({super.key, required this.tip});

  final CareTip tip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InfoRow(icon: tip.icon, title: tip.title, value: tip.body),
    );
  }
}

class TrendChart extends StatelessWidget {
  const TrendChart({super.key, required this.records});

  final List<CycleRecord> records;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: TrendChartPainter(records));
  }
}

class TrendChartPainter extends CustomPainter {
  TrendChartPainter(this.records);

  final List<CycleRecord> records;

  @override
  void paint(Canvas canvas, Size size) {
    final values = records.isEmpty
        ? [28, 29, 28, 30]
        : records.map((e) => e.length).toList();
    final minValue = values.reduce(math.min) - 2;
    final maxValue = values.reduce(math.max) + 2;
    final paint = Paint()
      ..color = AppColors.primaryPink
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final fill = Paint()..color = AppColors.primaryPink.withValues(alpha: 0.12);
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : i / (values.length - 1) * size.width;
      final y =
          size.height -
          ((values[i] - minValue) / (maxValue - minValue)) * size.height;
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = Colors.white);
      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = AppColors.primaryPink,
      );
    }
    final area = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(area, fill);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant TrendChartPainter oldDelegate) =>
      oldDelegate.records != records;
}

class SliderPanel extends StatelessWidget {
  const SliderPanel({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  final String label;
  final int value;
  final int min;
  final int max;
  final String unit;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                '$value $unit',
                style: const TextStyle(
                  color: AppColors.primaryPink,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            label: '$value $unit',
            onChanged: (next) => onChanged(next.round()),
          ),
        ],
      ),
    );
  }
}

class SelectableCard extends StatelessWidget {
  const SelectableCard({
    super.key,
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: SoftCard(
        color: selected
            ? AppColors.softBlush
            : Colors.white.withValues(alpha: 0.86),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: selected
                  ? AppColors.primaryPink
                  : AppColors.lightRose,
              child: Icon(
                icon,
                color: selected ? Colors.white : AppColors.primaryPink,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.softText,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primaryPink,
              ),
          ],
        ),
      ),
    );
  }
}

class SwitchTileCard extends StatelessWidget {
  const SwitchTileCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.onChanged,
    this.embedded = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool embedded;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      children: [
        CircleAvatar(
          backgroundColor: AppColors.softBlush,
          child: Icon(icon, color: AppColors.primaryPink),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.softText,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeThumbColor: AppColors.primaryPink,
          onChanged: onChanged,
        ),
      ],
    );
    return embedded ? content : SoftCard(child: content);
  }
}

class SettingsAction extends StatelessWidget {
  const SettingsAction({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.danger = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool danger;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: SoftCard(
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: danger
                    ? const Color(0xFFFFE1E1)
                    : AppColors.softBlush,
                child: Icon(
                  icon,
                  color: danger ? AppColors.periodPink : AppColors.primaryPink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: danger
                            ? AppColors.periodPink
                            : AppColors.deepText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.softText,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.softText,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActionPill extends StatelessWidget {
  const ActionPill({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.deepText,
        side: const BorderSide(color: AppColors.lightRose),
        backgroundColor: AppColors.creamWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({super.key, required this.title, this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
            ),
          ),
          if (trailing != null)
            Flexible(
              child: Text(
                trailing!,
                textAlign: TextAlign.right,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.softText,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SoftCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.primaryPink),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: AppColors.softText,
                      fontWeight: FontWeight.w700,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MedicalDisclaimer extends StatelessWidget {
  const MedicalDisclaimer({super.key});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: const Color(0xFFFFF3D8),
      padding: const EdgeInsets.all(14),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: Color(0xFF9B6A00)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Cycle predictions are estimates based on your logged data. This app does not provide medical advice, diagnosis, contraception, or fertility treatment guidance. If your period is very late, unusually painful, very heavy, or concerning, consider speaking with a qualified healthcare professional.',
              style: TextStyle(fontWeight: FontWeight.w700, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class WeekLabel extends StatelessWidget {
  const WeekLabel(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Center(
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.softText,
          fontWeight: FontWeight.w900,
        ),
      ),
    ),
  );
}

class LegendPill extends StatelessWidget {
  const LegendPill({
    super.key,
    required this.color,
    required this.label,
    this.bordered = false,
  });

  final Color color;
  final String label;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: bordered
                  ? Border.all(color: AppColors.primaryPink)
                  : null,
            ),
          ),
          const SizedBox(width: 7),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class TinyDot extends StatelessWidget {
  const TinyDot({super.key, required this.color});
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    width: 6,
    height: 6,
    margin: const EdgeInsets.symmetric(horizontal: 1.5),
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

void _showMessageSheet(BuildContext context, String title, String body) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.creamWhite,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(22, 6, 22, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.softText,
              height: 1.4,
            ),
          ),
        ],
      ),
    ),
  );
}

DateTime dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

bool sameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

int clampInt(int value, int min, int max) => value.clamp(min, max).toInt();

double clampDouble(num value, double min, double max) {
  final safe = value.isFinite ? value.toDouble() : min;
  return safe.clamp(min, max).toDouble();
}

String timeGreeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good morning';
  if (hour < 17) return 'Good afternoon';
  return 'Good evening';
}

String mostCommon(Iterable<String> values) {
  final counts = <String, int>{};
  for (final value in values) {
    if (value.trim().isEmpty) continue;
    counts[value] = (counts[value] ?? 0) + 1;
  }
  if (counts.isEmpty) return 'Not enough data';
  final entries = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return entries.first.key;
}

String mostCommonSymptoms(List<DailyLog> logs) {
  final symptoms = <String>[];
  for (final log in logs) {
    symptoms.addAll(log.symptoms.where((item) => item != 'No symptoms'));
  }
  if (symptoms.isEmpty) return 'No repeated symptoms yet';
  final primary = mostCommon(symptoms);
  final distinct = symptoms.toSet().length;
  return distinct > 1 ? '$primary and related symptoms' : primary;
}

String formatDate(DateTime date, {bool includeYear = true}) {
  final value = '${_monthName(date.month)} ${date.day}';
  return includeYear ? '$value, ${date.year}' : value;
}

String formatShort(DateTime date) =>
    '${_monthShortName(date.month)} ${date.day}';

String _monthName(int month) {
  const months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];
  return months[month - 1];
}

String _monthShortName(int month) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return months[month - 1];
}
