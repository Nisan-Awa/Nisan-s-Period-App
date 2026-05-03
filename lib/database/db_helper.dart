import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cycle.dart';
import '../models/log_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  
  DatabaseHelper._init();

  static const String _cyclesKey = 'cycles_data';
  static const String _logsKey = 'logs_data';

  // --- Cycle Operations ---
  Future<Cycle> createCycle(Cycle cycle) async {
    final prefs = await SharedPreferences.getInstance();
    final cyclesList = await readAllCycles();
    
    // Auto-increment ID logic for SharedPreferences
    final newId = cyclesList.isEmpty ? 1 : (cyclesList.first.id ?? 0) + 1;
    final newCycle = cycle.copyWith(id: newId);
    
    cyclesList.insert(0, newCycle); // Insert at beginning to keep descending order
    
    final String encodedData = jsonEncode(cyclesList.map((c) => c.toMap()).toList());
    await prefs.setString(_cyclesKey, encodedData);
    
    return newCycle;
  }

  Future<List<Cycle>> readAllCycles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? cyclesString = prefs.getString(_cyclesKey);
    
    if (cyclesString == null) return [];
    
    final List<dynamic> decodedData = jsonDecode(cyclesString);
    final cycles = decodedData.map((json) => Cycle.fromMap(json)).toList();
    
    // Ensure descending order
    cycles.sort((a, b) => b.startDate.compareTo(a.startDate));
    return cycles;
  }

  Future<int> updateCycle(Cycle cycle) async {
    final prefs = await SharedPreferences.getInstance();
    final cyclesList = await readAllCycles();
    
    final index = cyclesList.indexWhere((c) => c.id == cycle.id);
    if (index != -1) {
      cyclesList[index] = cycle;
      final String encodedData = jsonEncode(cyclesList.map((c) => c.toMap()).toList());
      await prefs.setString(_cyclesKey, encodedData);
      return 1; // Success
    }
    return 0; // Not found
  }

  // --- Log Operations ---
  Future<LogEntry> createLog(LogEntry log) async {
    final prefs = await SharedPreferences.getInstance();
    final logsList = await readAllLogs();
    
    final logDateStr = log.date.toIso8601String().substring(0, 10);
    final existingIndex = logsList.indexWhere((l) => l.date.toIso8601String().substring(0, 10) == logDateStr);

    if (existingIndex != -1) {
      // Update existing
      final existingId = logsList[existingIndex].id;
      final updatedLog = LogEntry(
        id: existingId,
        date: log.date,
        flowIntensity: log.flowIntensity,
        cramps: log.cramps,
        headache: log.headache,
        mood: log.mood,
        notes: log.notes,
      );
      logsList[existingIndex] = updatedLog;
      
      final String encodedData = jsonEncode(logsList.map((l) => l.toMap()).toList());
      await prefs.setString(_logsKey, encodedData);
      return updatedLog;
    } else {
      // Create new
      final newId = logsList.isEmpty ? 1 : (logsList.first.id ?? 0) + 1;
      final newLog = LogEntry(
        id: newId,
        date: log.date,
        flowIntensity: log.flowIntensity,
        cramps: log.cramps,
        headache: log.headache,
        mood: log.mood,
        notes: log.notes,
      );
      
      logsList.insert(0, newLog);
      
      final String encodedData = jsonEncode(logsList.map((l) => l.toMap()).toList());
      await prefs.setString(_logsKey, encodedData);
      return newLog;
    }
  }

  Future<List<LogEntry>> readAllLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final String? logsString = prefs.getString(_logsKey);
    
    if (logsString == null) return [];
    
    final List<dynamic> decodedData = jsonDecode(logsString);
    final logs = decodedData.map((json) => LogEntry.fromMap(json)).toList();
    
    // Ensure descending order
    logs.sort((a, b) => b.date.compareTo(a.date));
    return logs;
  }
}
