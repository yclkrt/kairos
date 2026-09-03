import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairos/core/theme/app_colors.dart';
import 'package:kairos/core/widgets/main_scaffold.dart';
import 'package:kairos/features/training_schedule/widgets/calendar_widget.dart';
import 'package:kairos/features/training_schedule/widgets/reminder_list_widget.dart';

class TrainingSchedule extends ConsumerStatefulWidget {
  const TrainingSchedule({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TrainingScheduleState();
}

class _TrainingScheduleState extends ConsumerState<TrainingSchedule> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MainScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [const Color(0xFF2D2D2D), const Color(0xFF1A1A1A)]
                  : [AppColors.primary, AppColors.secondary],
            ),
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.workoutHigh, AppColors.workoutMedium],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.calendar_month_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'ANTRENMAN TAKVIMI',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0A0A0A), const Color(0xFF1A1A1A)]
                : [const Color(0xFFF8F9FA), const Color(0xFFE8E8E8)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const CalendarWidget(),
              const SizedBox(height: 20),
              const ReminderListWidget(),
            ],
          ),
        ),
      ),
    );
  }
}
