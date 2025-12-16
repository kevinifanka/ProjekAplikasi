import 'dart:collection';
import 'package:flutter/foundation.dart';

class AttendanceRecord {
  final String employeeName;
  final String position;
  final bool isClockIn;
  final DateTime timestamp;
  final String address;
  final String? photoPath;
  final String? note;
  final String locationType; // e.g., WFH, WFO, Field

  AttendanceRecord({
    required this.employeeName,
    required this.position,
    required this.isClockIn,
    required this.timestamp,
    required this.address,
    this.photoPath,
    this.note,
    this.locationType = 'WFO',
  });

  String get statusText => isClockIn ? 'Clock In' : 'Clock Out';
  String get fullTimeText => _formatTime(timestamp);

  static String _formatTime(DateTime ts) {
    final two = (int n) => n.toString().padLeft(2, '0');
    return '${two(ts.hour)}:${two(ts.minute)}';
  }
}

class AttendanceService extends ChangeNotifier {
  static final AttendanceService _instance = AttendanceService._internal();
  factory AttendanceService() => _instance;
  AttendanceService._internal();

  final List<AttendanceRecord> _records = <AttendanceRecord>[];

  UnmodifiableListView<AttendanceRecord> get attendanceRecords => UnmodifiableListView(_records);

  void addRecord(AttendanceRecord record) {
    _records.add(record);
    _records.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
  }

  List<AttendanceRecord> getWorkingEmployees() {
    // Simplified: last record per employee determines working/not
    final Map<String, AttendanceRecord> lastByEmployee = {};
    for (final r in _records) {
      final key = r.employeeName;
      final existing = lastByEmployee[key];
      if (existing == null || r.timestamp.isAfter(existing.timestamp)) {
        lastByEmployee[key] = r;
      }
    }
    return lastByEmployee.values.where((r) => r.isClockIn).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
}



