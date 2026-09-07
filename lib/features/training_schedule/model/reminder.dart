import 'dart:convert';
import 'package:flutter/material.dart';

class Reminder {
  final String id;
  final DateTime date;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final int reminderOffsetMinutes;
  final String title;
  final String? description;
  final DateTime createdAt;

  const Reminder({
    required this.id,
    required this.date,
    this.startTime,
    this.endTime,
    this.reminderOffsetMinutes = 0,
    required this.title,
    this.description,
    required this.createdAt,
  });

  /// Calculates the actual notification time based on start time and offset
  DateTime get notificationDateTime {
    final baseTime = startTime != null
        ? DateTime(date.year, date.month, date.day, startTime!.hour,
            startTime!.minute)
        : DateTime(date.year, date.month, date.day, 8, 0);
    return baseTime.subtract(Duration(minutes: reminderOffsetMinutes));
  }

  /// Returns the display time string (e.g., "09:00 - 10:30" or "09:00")
  String get timeDisplay {
    String formatTime(TimeOfDay? time) {
      if (time == null) return '--:--';
      final h = time.hour.toString().padLeft(2, '0');
      final m = time.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }

    if (startTime == null) return '--:--';
    if (endTime == null) return formatTime(startTime);
    return '${formatTime(startTime)} - ${formatTime(endTime)}';
  }

  /// Returns the start time display string
  String get startTimeDisplay {
    if (startTime == null) return '--:--';
    final h = startTime!.hour.toString().padLeft(2, '0');
    final m = startTime!.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Returns the end time display string
  String get endTimeDisplay {
    if (endTime == null) return '--:--';
    final h = endTime!.hour.toString().padLeft(2, '0');
    final m = endTime!.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  /// Returns the offset display string (e.g., "15 dk önce")
  String get offsetDisplay {
    if (reminderOffsetMinutes == 0) return 'Tam zamanında';
    return '$reminderOffsetMinutes dk önce';
  }

  Reminder copyWith({
    String? id,
    DateTime? date,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int? reminderOffsetMinutes,
    String? title,
    String? description,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      reminderOffsetMinutes:
          reminderOffsetMinutes ?? this.reminderOffsetMinutes,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'startTime': startTime != null
          ? {'hour': startTime!.hour, 'minute': startTime!.minute}
          : null,
      'endTime': endTime != null
          ? {'hour': endTime!.hour, 'minute': endTime!.minute}
          : null,
      'reminderOffsetMinutes': reminderOffsetMinutes,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      startTime: json['startTime'] != null
          ? TimeOfDay(
              hour: json['startTime']['hour'] as int,
              minute: json['startTime']['minute'] as int,
            )
          : null,
      endTime: json['endTime'] != null
          ? TimeOfDay(
              hour: json['endTime']['hour'] as int,
              minute: json['endTime']['minute'] as int,
            )
          : null,
      reminderOffsetMinutes: json['reminderOffsetMinutes'] as int? ?? 0,
      title: json['title'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  static String encodeList(List<Reminder> reminders) {
    return jsonEncode(reminders.map((r) => r.toJson()).toList());
  }

  static List<Reminder> decodeList(String jsonString) {
    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((json) => Reminder.fromJson(json)).toList();
  }
}
