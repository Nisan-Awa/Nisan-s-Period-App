import 'package:flutter/foundation.dart';
import '../models/cycle.dart';
import '../models/log_entry.dart';
import '../database/db_helper.dart';

class TrackingProvider extends ChangeNotifier {
  List<Cycle> _cycles = [];
  List<LogEntry> _logs = [];

  List<Cycle> get cycles => _cycles;
  List<LogEntry> get logs => _logs;

  // Prediction Data
  DateTime? _predictedStartWindow;
  DateTime? _predictedEndWindow;

  DateTime? get predictedStartWindow => _predictedStartWindow;
  DateTime? get predictedEndWindow => _predictedEndWindow;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  TrackingProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    _cycles = await DatabaseHelper.instance.readAllCycles();
    _logs = await DatabaseHelper.instance.readAllLogs();

    _calculatePrediction();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> logPeriodStart(DateTime date) async {
    // End the previous cycle if exists
    if (_cycles.isNotEmpty && _cycles.first.endDate == null) {
      final updatedPrevCycle = _cycles.first.copyWith(
        endDate: date.subtract(const Duration(days: 1)),
      );
      await DatabaseHelper.instance.updateCycle(updatedPrevCycle);
    }

    // Create new cycle
    final newCycle = Cycle(startDate: date);
    await DatabaseHelper.instance.createCycle(newCycle);

    // Log the heavy flow for this day
    await saveLog(LogEntry(date: date, flowIntensity: 'medium'));

    await loadData();
  }

  Future<void> saveLog(LogEntry log) async {
    await DatabaseHelper.instance.createLog(log);
    await loadData();
  }

  void _calculatePrediction() {
    if (_cycles.isEmpty) {
      _predictedStartWindow = null;
      _predictedEndWindow = null;
      return;
    }

    final validCycles = _cycles.where((c) => !c.isIgnored && c.endDate != null).toList();

    if (validCycles.isEmpty) {
      // Default to 28 days if we don't have historical valid finished cycles
      _predictedStartWindow = _cycles.first.startDate.add(const Duration(days: 28));
      _predictedEndWindow = _predictedStartWindow!.add(const Duration(days: 2));
      return;
    }

    // Calculate average cycle length
    int totalDays = 0;
    for (var c in validCycles) {
      totalDays += c.endDate!.difference(c.startDate).inDays + 1;
    }

    int avgCycleLength = totalDays ~/ validCycles.length;

    // Simple deterministic window logic (+/- 2 days around average)
    final latestStartDate = _cycles.first.startDate;
    final expectedCenter = latestStartDate.add(Duration(days: avgCycleLength));
    
    _predictedStartWindow = expectedCenter.subtract(const Duration(days: 2));
    _predictedEndWindow = expectedCenter.add(const Duration(days: 2));
  }
}
