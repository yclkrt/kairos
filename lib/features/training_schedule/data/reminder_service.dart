import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kairos/features/training_schedule/model/reminder.dart';

class ReminderService {
  static const String _storageKey = 'training_reminders';

  Future<List<Reminder>> getAllReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    return Reminder.decodeList(jsonString);
  }

  Future<List<Reminder>> getRemindersForDate(DateTime date) async {
    final reminders = await getAllReminders();
    return reminders.where((r) => _isSameDay(r.date, date)).toList();
  }

  Future<void> addReminder(Reminder reminder) async {
    final prefs = await SharedPreferences.getInstance();
    final reminders = await getAllReminders();
    reminders.add(reminder);
    await prefs.setString(_storageKey, Reminder.encodeList(reminders));
  }

  Future<void> updateReminder(Reminder reminder) async {
    final prefs = await SharedPreferences.getInstance();
    final reminders = await getAllReminders();
    final index = reminders.indexWhere((r) => r.id == reminder.id);
    if (index != -1) {
      reminders[index] = reminder;
      await prefs.setString(_storageKey, Reminder.encodeList(reminders));
    }
  }

  Future<void> deleteReminder(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final reminders = await getAllReminders();
    reminders.removeWhere((r) => r.id == id);
    await prefs.setString(_storageKey, Reminder.encodeList(reminders));
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

final reminderServiceProvider = Provider<ReminderService>((ref) => ReminderService());
