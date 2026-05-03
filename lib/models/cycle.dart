class Cycle {
  final int? id;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isIgnored;

  Cycle({
    this.id,
    required this.startDate,
    this.endDate,
    this.isIgnored = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_ignored': isIgnored ? 1 : 0,
    };
  }

  factory Cycle.fromMap(Map<String, dynamic> map) {
    return Cycle(
      id: map['id'],
      startDate: DateTime.parse(map['start_date']),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date']) : null,
      isIgnored: map['is_ignored'] == 1,
    );
  }

  Cycle copyWith({
    int? id,
    DateTime? startDate,
    DateTime? endDate,
    bool? isIgnored,
  }) {
    return Cycle(
      id: id ?? this.id,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isIgnored: isIgnored ?? this.isIgnored,
    );
  }
}
