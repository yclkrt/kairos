import 'dart:convert';
import 'package:flutter/material.dart';

class Reminder {
  final String id;
  final DateTime date;
  final TimeOfDay? timeOfDay;
  final int reminderOffsetMinutes;
  final String title;
  final String? description;
  final DateTime createdAt;

  const Reminder({
    required this.id,
    required this.date,
    this.timeOfDay,
    this.reminderOffsetMinutes = 0,
    required this.title,
    this.description,
    required this.createdAt,
  });

  /// Calculates the actual notification time based on date, time, and offset
  DateTime get notificationDateTime {
    final baseTime = timeOfDay != null
        ? DateTime(date.year, date.month, date.day, timeOfDay!.hour,
            timeOfDay!.minute)
        : DateTime(date.year, date.month, date.day, 8, 0);
    return baseTime.subtract(Duration(minutes: reminderOffsetMinutes));
  }

  /// Returns the display time string (e.g., "09:30")
  String get timeDisplay {
    if (timeOfDay == null) return '--:--';
    final h = timeOfDay!.hour.toString().padLeft(2, '0');
    final m = timeOfDay!.minute.toString().padLeft(2, '0');
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
    TimeOfDay? timeOfDay,
    int? reminderOffsetMinutes,
    String? title,
    String? description,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      date: date ?? this.date,
      timeOfDay: timeOfDay ?? this.timeOfDay,
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
      'timeOfDay': timeOfDay != null
          ? {'hour': timeOfDay!.hour, 'minute': timeOfDay!.minute}
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
      timeOfDay: json['timeOfDay'] != null
          ? TimeOfDay(
              hour: json['timeOfDay']['hour'] as int,
              minute: json['timeOfDay']['minute'] as int,
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
