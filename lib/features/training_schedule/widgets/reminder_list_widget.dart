import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lingo_easy/lingo_easy.dart';
import 'package:sporlab/core/theme/app_colors.dart';
import 'package:sporlab/features/training_schedule/model/reminder.dart';
import 'package:sporlab/features/training_schedule/providers/reminder_provider.dart';

class ReminderListWidget extends ConsumerWidget {
  const ReminderListWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final remindersAsync = ref.watch(remindersForSelectedDateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF2D2D2D), const Color(0xFF1A1A1A)]
              : [Colors.white, const Color(0xFFF5F5F5)],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.accent.withValues(alpha: 0.2)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, ref, selectedDate),
            const SizedBox(height: 16),
            _buildReminderList(remindersAsync, context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    WidgetRef ref,
    DateTime selectedDate,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.workoutLow],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.alarm_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    context.ln('reminders').toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: isDark ? Colors.white : AppColors.lightText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(
                  _formatDate(selectedDate, context),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkHint : AppColors.lightHint,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _showAddReminderDialog(context, ref),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.workoutHigh, AppColors.workoutMedium],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.workoutHigh.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReminderList(
    AsyncValue<List<Reminder>> remindersAsync,
    BuildContext context,
    WidgetRef ref,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return remindersAsync.when(
      data: (reminders) {
        if (reminders.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 32.0),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.event_note_rounded,
                    size: 48,
                    color: (isDark ? AppColors.darkHint : AppColors.lightHint)
                        .withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.ln('there_are_on_reminders_for_this_date'),
                    style: TextStyle(
                      color: (isDark ? AppColors.darkHint : AppColors.lightHint)
                          .withValues(alpha: 0.5),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          children: reminders
              .map((r) => _buildReminderItem(context, ref, r))
              .toList(),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      ),
      error: (e, _) => Text(
        '${context.ln('error')}: $e',
        style: const TextStyle(color: AppColors.error),
      ),
    );
  }

  Widget _buildReminderItem(
    BuildContext context,
    WidgetRef ref,
    Reminder reminder,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.accent, AppColors.workoutLow],
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reminder.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.lightText,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (reminder.startTime != null) ...[
                      const Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reminder.timeDisplay,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (reminder.reminderOffsetMinutes > 0) ...[
                      const Icon(
                        Icons.notifications_active_rounded,
                        size: 14,
                        color: AppColors.workoutMedium,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        reminder.reminderOffsetMinutes == 0
                            ? context.ln(reminder.offsetDisplayKey)
                            : '${reminder.offsetValue} ${context.ln(reminder.offsetDisplayKey)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.workoutMedium,
                        ),
                      ),
                    ],
                  ],
                ),
                if (reminder.description != null &&
                    reminder.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    reminder.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkHint : AppColors.lightHint,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showDeleteConfirmation(context, ref, reminder),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddReminderDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final selectedDate = ref.read(selectedDateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) {
        TimeOfDay? selectedStartTime;
        TimeOfDay? selectedEndTime;
        int selectedOffset = 0;
        final List<int> offsetOptions = [0, 5, 10, 15, 30, 60];
        bool isCustomOffset = false;
        final customOffsetController = TextEditingController();

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  AppColors.workoutHigh,
                                  AppColors.workoutMedium,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add_alarm_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Text(
                            context.ln('new_reminder').toUpperCase(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                              color: isDark
                                  ? Colors.white
                                  : AppColors.lightText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: titleController,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.lightText,
                        ),
                        decoration: InputDecoration(
                          hintText: context.ln('title'),
                          hintStyle: TextStyle(
                            color:
                                (isDark
                                        ? AppColors.darkHint
                                        : AppColors.lightHint)
                                    .withValues(alpha: 0.5),
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.workoutHigh,
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.title_rounded,
                            color: isDark
                                ? AppColors.darkHint
                                : AppColors.lightHint,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: descController,
                        maxLines: 3,
                        style: TextStyle(
                          color: isDark ? Colors.white : AppColors.lightText,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              '${context.ln('explanation')} (${context.ln('optional').toLowerCase()})',
                          hintStyle: TextStyle(
                            color:
                                (isDark
                                        ? AppColors.darkHint
                                        : AppColors.lightHint)
                                    .withValues(alpha: 0.5),
                          ),
                          filled: true,
                          fillColor: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.1),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.1)
                                  : Colors.black.withValues(alpha: 0.1),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: AppColors.workoutHigh,
                              width: 2,
                            ),
                          ),
                          prefixIcon: Icon(
                            Icons.description_rounded,
                            color: isDark
                                ? AppColors.darkHint
                                : AppColors.lightHint,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        context.ln('start_time').toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: isDark
                              ? AppColors.darkHint
                              : AppColors.lightHint,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: ctx,
                              initialTime: selectedStartTime ?? TimeOfDay.now(),
                              builder: (context, child) => Theme(
                                data: isDark
                                    ? ThemeData.dark().copyWith(
                                        colorScheme: const ColorScheme.dark(
                                          primary: AppColors.workoutHigh,
                                          surface: Color(0xFF2D2D2D),
                                        ),
                                      )
                                    : ThemeData.light().copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: AppColors.workoutHigh,
                                          surface: Colors.white,
                                        ),
                                      ),
                                child: child!,
                              ),
                            );
                            if (time != null) {
                              setDialogState(() => selectedStartTime = time);
                            }
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  color: isDark
                                      ? AppColors.darkHint
                                      : AppColors.lightHint,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  selectedStartTime != null
                                      ? '${selectedStartTime!.hour.toString().padLeft(2, '0')}:${selectedStartTime!.minute.toString().padLeft(2, '0')}'
                                      : context.ln('click_to_select_a_time'),
                                  style: TextStyle(
                                    color: selectedStartTime != null
                                        ? (isDark
                                              ? Colors.white
                                              : AppColors.lightText)
                                        : (isDark
                                                  ? AppColors.darkHint
                                                  : AppColors.lightHint)
                                              .withValues(alpha: 0.5),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      /// Bitiş Saati
                      const SizedBox(height: 20),
                      Text(
                        context.ln('end_time').toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: isDark
                              ? AppColors.darkHint
                              : AppColors.lightHint,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: ctx,
                              initialTime: selectedEndTime ?? TimeOfDay.now(),
                              builder: (context, child) => Theme(
                                data: isDark
                                    ? ThemeData.dark().copyWith(
                                        colorScheme: const ColorScheme.dark(
                                          primary: AppColors.workoutHigh,
                                          surface: Color(0xFF2D2D2D),
                                        ),
                                      )
                                    : ThemeData.light().copyWith(
                                        colorScheme: const ColorScheme.light(
                                          primary: AppColors.workoutHigh,
                                          surface: Colors.white,
                                        ),
                                      ),
                                child: child!,
                              ),
                            );
                            if (time != null) {
                              setDialogState(() => selectedEndTime = time);
                            }
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.1),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  color: isDark
                                      ? AppColors.darkHint
                                      : AppColors.lightHint,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  selectedEndTime != null
                                      ? '${selectedEndTime!.hour.toString().padLeft(2, '0')}:${selectedEndTime!.minute.toString().padLeft(2, '0')}'
                                      : context.ln('click_to_select_a_time'),
                                  style: TextStyle(
                                    color: selectedEndTime != null
                                        ? (isDark
                                              ? Colors.white
                                              : AppColors.lightText)
                                        : (isDark
                                                  ? AppColors.darkHint
                                                  : AppColors.lightHint)
                                              .withValues(alpha: 0.5),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Text(
                        context.ln('reminder_time').toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                          color: isDark
                              ? AppColors.darkHint
                              : AppColors.lightHint,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...offsetOptions.map((offset) {
                            final isSelected =
                                selectedOffset == offset && !isCustomOffset;
                            final label = offset == 0
                                ? context.ln('just_in_time')
                                : '$offset ${context.ln('minutes_before')}';
                            return GestureDetector(
                              onTap: () => setDialogState(() {
                                selectedOffset = offset;
                                isCustomOffset = false;
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [
                                            AppColors.workoutHigh,
                                            AppColors.workoutMedium,
                                          ],
                                        )
                                      : null,
                                  color: isSelected
                                      ? null
                                      : isDark
                                      ? Colors.white.withValues(alpha: 0.05)
                                      : Colors.black.withValues(alpha: 0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : isDark
                                        ? Colors.white.withValues(alpha: 0.1)
                                        : Colors.black.withValues(alpha: 0.1),
                                  ),
                                ),
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : isDark
                                        ? AppColors.darkHint
                                        : AppColors.lightHint,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            );
                          }),
                          GestureDetector(
                            onTap: () =>
                                setDialogState(() => isCustomOffset = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                gradient: isCustomOffset
                                    ? const LinearGradient(
                                        colors: [
                                          AppColors.workoutHigh,
                                          AppColors.workoutMedium,
                                        ],
                                      )
                                    : null,
                                color: isCustomOffset
                                    ? null
                                    : isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isCustomOffset
                                      ? Colors.transparent
                                      : isDark
                                      ? Colors.white.withValues(alpha: 0.1)
                                      : Colors.black.withValues(alpha: 0.1),
                                ),
                              ),
                              child: Text(
                                context.ln('special'),
                                style: TextStyle(
                                  color: isCustomOffset
                                      ? Colors.white
                                      : isDark
                                      ? AppColors.darkHint
                                      : AppColors.lightHint,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isCustomOffset) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: customOffsetController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.lightText,
                          ),
                          onChanged: (value) {
                            final parsed = int.tryParse(value);
                            if (parsed != null && parsed > 0) {
                              setDialogState(() => selectedOffset = parsed);
                            }
                          },
                          decoration: InputDecoration(
                            hintText: context.ln('enter_minutes'),
                            hintStyle: TextStyle(
                              color:
                                  (isDark
                                          ? AppColors.darkHint
                                          : AppColors.lightHint)
                                      .withValues(alpha: 0.5),
                            ),
                            filled: true,
                            fillColor: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.05),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.1),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.1)
                                    : Colors.black.withValues(alpha: 0.1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppColors.workoutHigh,
                                width: 2,
                              ),
                            ),
                            prefixIcon: Icon(
                              Icons.edit_rounded,
                              color: isDark
                                  ? AppColors.darkHint
                                  : AppColors.lightHint,
                            ),
                            suffixText: context.ln('minute_short'),
                            suffixStyle: TextStyle(
                              color: isDark
                                  ? AppColors.darkHint
                                  : AppColors.lightHint,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(
                                context.ln('cancel').toUpperCase(),
                                style: TextStyle(
                                  color: isDark
                                      ? AppColors.darkHint
                                      : AppColors.lightHint,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: ElevatedButton(
                              onPressed: () {
                                if (titleController.text.trim().isNotEmpty) {
                                  ref
                                      .read(reminderActionsProvider)
                                      .addReminder(
                                        date: selectedDate,
                                        title: titleController.text.trim(),
                                        description:
                                            descController.text.trim().isEmpty
                                            ? null
                                            : descController.text.trim(),
                                        startTime: selectedStartTime,
                                        endTime: selectedEndTime,
                                        reminderOffsetMinutes: selectedOffset,
                                      );
                                  Navigator.pop(ctx);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.workoutHigh,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 8,
                                shadowColor: AppColors.workoutHigh.withValues(
                                  alpha: 0.4,
                                ),
                              ),
                              child: Text(
                                context.ln('save').toUpperCase(),
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(
    BuildContext context,
    WidgetRef ref,
    Reminder reminder,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: isDark ? const Color(0xFF2D2D2D) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: AppColors.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                context.ln('deletion_confirmation').toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: isDark ? Colors.white : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '${reminder.title} ${context.ln('are_you_sure_you_want_to_delete_the_reminder')}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkHint : AppColors.lightHint,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        context.ln('give_up').toUpperCase(),
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkHint
                              : AppColors.lightHint,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 8,
                        shadowColor: AppColors.error.withValues(alpha: 0.4),
                      ),
                      onPressed: () {
                        ref
                            .read(reminderActionsProvider)
                            .deleteReminder(reminder.id);
                        Navigator.pop(ctx);
                      },
                      child: Text(
                        context.ln('delete').toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final days = [
      context.ln('monday'),
      context.ln('tuesday'),
      context.ln('wednesday'),
      context.ln('thursday'),
      context.ln('friday'),
      context.ln('saturday'),
      context.ln('sunday'),
    ];
    final months = [
      context.ln('january'),
      context.ln('february'),
      context.ln('march'),
      context.ln('april'),
      context.ln('may'),
      context.ln('june'),
      context.ln('july'),
      context.ln('august'),
      context.ln('september'),
      context.ln('october'),
      context.ln('november'),
      context.ln('december'),
    ];
    return '${days[date.weekday - 1]}, ${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
