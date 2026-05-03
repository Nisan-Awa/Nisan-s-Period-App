class LogEntry {
  final int? id;
  final DateTime date;
  final String flowIntensity; // none, light, medium, heavy
  final String cramps; // none, mild, moderate, severe
  final bool headache;
  final String mood; // neutral, happy, sad, irritable
  final String notes;

  LogEntry({
    this.id,
    required this.date,
    this.flowIntensity = 'none',
    this.cramps = 'none',
    this.headache = false,
    this.mood = 'neutral',
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String().substring(0, 10), // Store as YYYY-MM-DD
      'flow_intensity': flowIntensity,
      'cramps': cramps,
      'headache': headache ? 1 : 0,
      'mood': mood,
      'notes': notes,
    };
  }

  factory LogEntry.fromMap(Map<String, dynamic> map) {
    return LogEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      flowIntensity: map['flow_intensity'],
      cramps: map['cramps'],
      headache: map['headache'] == 1,
      mood: map['mood'],
      notes: map['notes'],
    );
  }
}
