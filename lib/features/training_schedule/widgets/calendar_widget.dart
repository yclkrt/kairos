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
                ? AppColors.workoutHigh.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            _buildWeekdayLabels(),
            const SizedBox(height: 12),
            _buildCalendarGrid(allRemindersAsync),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavButton(Icons.chevron_left_rounded, () {
            setState(() {
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
            });
          }),
          Column(
            children: [
              Text(
                _getMonthYearString(_currentMonth).toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 3,
                  color: isDark ? Colors.white : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                width: 40,
                height: 3,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.workoutHigh, AppColors.workoutMedium],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          _buildNavButton(Icons.chevron_right_rounded, () {
            setState(() {
              _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
            });
          }),
        ],
      ),
    );
  }

  Widget _buildNavButton(IconData icon, VoidCallback onTap) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      AppColors.workoutHigh.withValues(alpha: 0.2),
                      AppColors.workoutMedium.withValues(alpha: 0.1),
                    ]
                  : [
                      AppColors.workoutHigh.withValues(alpha: 0.1),
                      AppColors.workoutMedium.withValues(alpha: 0.05),
                    ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.workoutHigh.withValues(alpha: isDark ? 0.3 : 0.2),
              width: 1,
            ),
          ),
          child: Icon(icon, color: AppColors.workoutHigh, size: 24),
        ),
      ),
    );
  }

  Widget _buildWeekdayLabels() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const weekdays = ['PZT', 'SAL', 'CAR', 'PER', 'CUM', 'CMT', 'PAZ'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays.map((day) {
          final isWeekend = day == 'CMT' || day == 'PAZ';
          return SizedBox(
            width: 40,
            child: Center(
              child: Text(
                day,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: isWeekend
                      ? AppColors.workoutHigh.withValues(alpha: 0.7)
                      : (isDark ? AppColors.darkHint : AppColors.lightHint),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getMonthYearString(DateTime date) {
    const months = ['Ocak', 'Subat', 'Mart', 'Nisan', 'Mayis', 'Haziran', 'Temmuz', 'Agustos', 'Eylul', 'Ekim', 'Kasim', 'Aralik'];
    return '${months[date.month - 1]} ${date.year}';
  }

  bool _isSameDay(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildCalendarGrid(AsyncValue<List<dynamic>> allRemindersAsync) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
      ),
      itemCount: startWeekday - 1 + daysInMonth,
      itemBuilder: (context, index) {
        if (index < startWeekday - 1) return const SizedBox();
        final day = index - startWeekday + 2;
        final date = DateTime(_currentMonth.year, _currentMonth.month, day);
        final isToday = _isSameDay(date, DateTime.now());
        final isSelected = _isSameDay(date, ref.watch(selectedDateProvider));
        final hasReminder = reminderDates.any((d) => _isSameDay(d, date));
        final isWeekend = date.weekday == 6 || date.weekday == 7;
        return GestureDetector(
          onTap: () => ref.read(selectedDateProvider.notifier).state = date,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.workoutHigh, AppColors.workoutMedium],
                    )
                  : isToday
                      ? LinearGradient(
                          colors: isDark
                              ? [
                                  AppColors.workoutHigh.withValues(alpha: 0.15),
                                  AppColors.workoutMedium.withValues(alpha: 0.1),
                                ]
                              : [
                                  AppColors.workoutHigh.withValues(alpha: 0.1),
                                  AppColors.workoutMedium.withValues(alpha: 0.05),
                                ],
                        )
                      : null,
              borderRadius: BorderRadius.circular(14),
              border: isSelected
                  ? null
                  : isToday
                      ? Border.all(color: AppColors.workoutHigh, width: 2)
                      : hasReminder
                          ? Border.all(color: AppColors.accent.withValues(alpha: 0.5), width: 1)
                          : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.workoutHigh.withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : isToday
                            ? AppColors.workoutHigh
                            : isWeekend
                                ? (isDark ? AppColors.darkHint.withValues(alpha: 0.6) : AppColors.lightHint.withValues(alpha: 0.6))
                                : (isDark ? AppColors.darkText : AppColors.lightText),
                  ),
                ),
                if (hasReminder)
                  Positioned(
                    bottom: 5,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? const LinearGradient(colors: [Colors.white, Color(0xFFE0E0E0)])
                            : const LinearGradient(colors: [AppColors.accent, AppColors.workoutLow]),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
