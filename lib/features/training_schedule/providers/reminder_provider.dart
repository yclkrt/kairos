import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:kairos/features/training_schedule/data/reminder_service.dart';
import 'package:kairos/features/training_schedule/model/reminder.dart';

// Selected date provider
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Reminders for the selected date
final remindersForSelectedDateProvider = FutureProvider<List<Reminder>>((ref) async {
  final selectedDate = ref.watch(selectedDateProvider);
  final service = ref.read(reminderServiceProvider);
  return service.getRemindersForDate(selectedDate);
});

// All reminders (for calendar markers)
final allRemindersProvider = FutureProvider<List<Reminder>>((ref) async {
  final service = ref.read(reminderServiceProvider);
  return service.getAllReminders();
});

// Reminder actions provider
final reminderActionsProvider = Provider<ReminderActions>((ref) {
  final service = ref.read(reminderServiceProvider);
  return ReminderActions(service, ref);
});

class ReminderActions {
  final ReminderService _service;
  final Ref _ref;

  ReminderActions(this._service, this._ref);

  Future<void> addReminder({
    required DateTime date,
    required String title,
    String? description,
  }) async {
    final reminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime(date.year, date.month, date.day),
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
    await _service.addReminder(reminder);
    _ref.invalidate(allRemindersProvider);
    _ref.invalidate(remindersForSelectedDateProvider);
  }

  Future<void> updateReminder(Reminder reminder) async {
    await _service.updateReminder(reminder);
    _ref.invalidate(allRemindersProvider);
    _ref.invalidate(remindersForSelectedDateProvider);
  }

  Future<void> deleteReminder(String id) async {
    await _service.deleteReminder(id);
    _ref.invalidate(allRemindersProvider);
    _ref.invalidate(remindersForSelectedDateProvider);
  }
}
