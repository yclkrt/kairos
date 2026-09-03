import 'dart:convert';

class Reminder {
  final String id;
  final DateTime date;
  final String title;
  final String? description;
  final DateTime createdAt;

  const Reminder({
    required this.id,
    required this.date,
    required this.title,
    this.description,
    required this.createdAt,
  });

  Reminder copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? description,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
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
