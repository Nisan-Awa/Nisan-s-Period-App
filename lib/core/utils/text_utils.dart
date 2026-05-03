import '../../data_model/app_state.dart';

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
