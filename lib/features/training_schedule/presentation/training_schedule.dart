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
    return MainScaffold(
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        title: const Text(
          "ANTRENMAN TAKVİMİ",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            fontSize: 16,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Takvim",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.lightText,
              ),
            ),
            const SizedBox(height: 12),
            const CalendarWidget(),
            const SizedBox(height: 20),
            const ReminderListWidget(),
          ],
        ),
      ),
    );
  }
}
