import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairos/core/theme/app_colors.dart';
import 'package:kairos/features/training_schedule/providers/reminder_provider.dart';

class CalendarWidget extends ConsumerStatefulWidget {
  const CalendarWidget({super.key});

  @override
  ConsumerState<CalendarWidget> createState() => _CalendarWidgetState();
}

class _CalendarWidgetState extends ConsumerState<CalendarWidget> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final allRemindersAsync = ref.watch(allRemindersProvider);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildWeekdayLabels(),
            const SizedBox(height: 8),
            _buildCalendarGrid(allRemindersAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
            });
          },
          icon: const Icon(Icons.chevron_left_rounded),
          color: AppColors.primary,
        ),
        Text(
          _getMonthYearString(_currentMonth),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.lightText),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
            });
          },
          icon: const Icon(Icons.chevron_right_rounded),
          color: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildWeekdayLabels() {
    const weekdays = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        return SizedBox(
          width: 40,
          child: Center(
            child: Text(day, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.lightHint)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(AsyncValue<List<dynamic>> allRemindersAsync) {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startWeekday = firstDayOfMonth.weekday;
    final daysInMonth = lastDayOfMonth.day;
    final reminderDates = allRemindersAsync.when(
      data: (reminders) => reminders.map((r) => r.date).toList(),
      loading: () => <DateTime>[],
      error: (_, _) => <DateTime>[],
    );
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: startWeekday - 1 + daysInMonth,
      itemBuilder: (context, index) {
        if (index < startWeekday - 1) return const SizedBox();
        final day = index - startWeekday + 2;
        final date = DateTime(_currentMonth.year, _currentMonth.month, day);
        final isToday = _isSameDay(date, DateTime.now());
        final isSelected = _isSameDay(date, ref.watch(selectedDateProvider));
        final hasReminder = reminderDates.any((d) => _isSameDay(d, date));
        return GestureDetector(
          onTap: () => ref.read(selectedDateProvider.notifier).state = date,
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : isToday ? AppColors.primary.withValues(alpha: 0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isToday && !isSelected ? Border.all(color: AppColors.primary, width: 1.5) : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text('$day', style: TextStyle(fontSize: 14, fontWeight: isSelected || isToday ? FontWeight.w700 : FontWeight.w500, color: isSelected ? Colors.white : isToday ? AppColors.primary : AppColors.lightText)),
                if (hasReminder)
                  Positioned(bottom: 4, child: Container(width: 6, height: 6, decoration: BoxDecoration(color: isSelected ? Colors.white : AppColors.accent, shape: BoxShape.circle))),
              ],
            ),
          ),
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  String _getMonthYearString(DateTime date) {
    const months = ['Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran', 'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'];
    return '${months[date.month - 1]} ${date.year}';
  }
}
