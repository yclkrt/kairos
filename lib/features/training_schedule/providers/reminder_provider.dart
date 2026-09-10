import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sporlab/core/services/notification_service.dart';
import 'package:sporlab/features/training_schedule/data/reminder_service.dart';
import 'package:sporlab/features/training_schedule/model/reminder.dart';

// Notification service provider
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

// Selected date provider
final selectedDateProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Reminders for the selected date
final remindersForSelectedDateProvider = FutureProvider<List<Reminder>>((
  ref,
) async {
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
  final notificationService = ref.read(notificationServiceProvider);
  return ReminderActions(service, notificationService, ref);
});

class ReminderActions {
  final ReminderService _service;
  final NotificationService _notificationService;
  final Ref _ref;

  ReminderActions(this._service, this._notificationService, this._ref);

  Future<void> addReminder({
    required DateTime date,
    required String title,
    String? description,
    TimeOfDay? startTime,
    TimeOfDay? endTime,
    int reminderOffsetMinutes = 0,
  }) async {
    final reminder = Reminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime(date.year, date.month, date.day),
      startTime: startTime,
      endTime: endTime,
      reminderOffsetMinutes: reminderOffsetMinutes,
      title: title,
      description: description,
      createdAt: DateTime.now(),
    );
    await _service.addReminder(reminder);

    // Schedule the notification
    await _notificationService.scheduleReminderNotification(
      id: int.parse(reminder.id) % 100000,
      title: title,
      body: description,
      scheduledDate: reminder.notificationDateTime,
    );

    _ref.invalidate(allRemindersProvider);
    _ref.invalidate(remindersForSelectedDateProvider);
  }

  Future<void> updateReminder(Reminder reminder) async {
    await _service.updateReminder(reminder);

    // Cancel old notification and reschedule
    await _notificationService.cancelNotification(
      int.parse(reminder.id) % 100000,
    );
    await _notificationService.scheduleReminderNotification(
      id: int.parse(reminder.id) % 100000,
      title: reminder.title,
      body: reminder.description,
      scheduledDate: reminder.notificationDateTime,
    );

    _ref.invalidate(allRemindersProvider);
    _ref.invalidate(remindersForSelectedDateProvider);
  }

  Future<void> deleteReminder(String id) async {
    await _service.deleteReminder(id);

    // Cancel the notification
    await _notificationService.cancelNotification(int.parse(id) % 100000);

    _ref.invalidate(allRemindersProvider);
    _ref.invalidate(remindersForSelectedDateProvider);
  }
}
