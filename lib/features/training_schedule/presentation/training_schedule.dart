import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lingo_easy/lingo_easy.dart';
import 'package:sporlab/core/theme/app_colors.dart';
import 'package:sporlab/core/widgets/main_scaffold.dart';
import 'package:sporlab/features/training_schedule/providers/reminder_provider.dart';
import 'package:sporlab/features/training_schedule/providers/voice_command_provider.dart';
import 'package:sporlab/features/training_schedule/widgets/calendar_widget.dart';
import 'package:sporlab/features/training_schedule/widgets/reminder_list_widget.dart';
import 'package:sporlab/core/services/voice_command_service.dart';

class TrainingSchedule extends ConsumerStatefulWidget {
  const TrainingSchedule({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _TrainingScheduleState();
}

class _TrainingScheduleState extends ConsumerState<TrainingSchedule>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleVoiceCommand() {
    final voiceState = ref.read(voiceCommandStateProvider);
    if (voiceState.isListening) {
      _animationController.stop();
      _animationController.reset();
      ref.read(voiceCommandStateProvider.notifier).stopListening();
    } else {
      _animationController.repeat(reverse: true);
      ref.read(voiceCommandStateProvider.notifier).startListening();
    }
  }

  void _showVoiceResultDialog(VoiceCommandData data) {
    final selectedDate = ref.read(selectedDateProvider);
    showDialog(
      context: context,
      builder: (ctx) => _buildVoiceResultDialog(ctx, data, selectedDate),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final voiceState = ref.watch(voiceCommandStateProvider);

    // Listen for voice command completion
    ref.listen<VoiceCommandState>(voiceCommandStateProvider, (previous, next) {
      if (previous?.isListening == true && next.isListening == false) {
        _animationController.stop();
        _animationController.reset();

        if (next.recognizedText.isNotEmpty) {
          final data = parseVoiceCommand(next.recognizedText);
          _showVoiceResultDialog(data);
          ref.read(voiceCommandStateProvider.notifier).clearRecognizedText();
        }

        if (next.errorKey != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.ln(next.errorKey!)),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
          ref.read(voiceCommandStateProvider.notifier).clearError();
        }
      }
    });

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
            Text(
              context.ln('training_schedule').toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          _buildVoiceButton(
            voiceState.isListening,
            isDark,
            voiceState.isAvailable,
          ),
        ],
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
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const CalendarWidget(),
                  const SizedBox(height: 20),
                  const ReminderListWidget(),
                ],
              ),
            ),
            if (voiceState.isListening)
              _buildListeningOverlay(voiceState.recognizedText, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildVoiceButton(bool isListening, bool isDark, bool isAvailable) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: isListening ? _pulseAnimation.value : 1.0,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isAvailable || !isListening ? _toggleVoiceCommand : null,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isListening
                          ? [AppColors.error, AppColors.workoutHigh]
                          : isDark
                          ? [
                              Colors.white.withValues(alpha: 0.15),
                              Colors.white.withValues(alpha: 0.05),
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.3),
                              Colors.white.withValues(alpha: 0.1),
                            ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isListening
                          ? AppColors.error.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.2),
                      width: 1.5,
                    ),
                    boxShadow: isListening
                        ? [
                            BoxShadow(
                              color: AppColors.error.withValues(alpha: 0.4),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildListeningOverlay(String recognizedText, bool isDark) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [
                    const Color(0xFF1A1A1A).withValues(alpha: 0.95),
                    const Color(0xFF1A1A1A),
                  ]
                : [Colors.white.withValues(alpha: 0.95), Colors.white],
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkHint : AppColors.lightHint,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    "${context.ln('listening').toUpperCase()}...",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                      color: isDark ? Colors.white : AppColors.lightText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (recognizedText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.1)
                          : Colors.black.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Text(
                    recognizedText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : AppColors.lightText,
                    ),
                  ),
                )
              else
                Text(
                  '${context.ln('state_your_reminder')}...',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkHint : AppColors.lightHint,
                    height: 1.4,
                  ),
                ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  _animationController.stop();
                  _animationController.reset();
                  ref.read(voiceCommandStateProvider.notifier).stopListening();
                },
                child: Text(
                  context.ln('cancel').toUpperCase(),
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVoiceResultDialog(
    BuildContext ctx,
    VoiceCommandData data,
    DateTime selectedDate,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
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
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.workoutLow],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              context.ln('reminder_found').toUpperCase(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: isDark ? Colors.white : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 16),
            _buildResultRow(
              icon: Icons.title_rounded,
              label: context.ln('title'),
              value: data.title,
              isDark: isDark,
            ),
            if (data.time != null) ...[
              const SizedBox(height: 12),
              _buildResultRow(
                icon: Icons.access_time_rounded,
                label: context.ln('hour'),
                value:
                    '${data.time!.hour.toString().padLeft(2, '0')}:${data.time!.minute.toString().padLeft(2, '0')}',
                isDark: isDark,
              ),
            ],
            if (data.offsetMinutes > 0) ...[
              const SizedBox(height: 12),
              _buildResultRow(
                icon: Icons.notifications_active_rounded,
                label: context.ln('notification'),
                value: '${data.offsetMinutes} ${context.ln('minutes_before')}',
                isDark: isDark,
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
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
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      ref
                          .read(reminderActionsProvider)
                          .addReminder(
                            date: selectedDate,
                            title: data.title,
                            description: data.description,
                            startTime: data.time,
                            reminderOffsetMinutes: data.offsetMinutes,
                          );
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            '${data.title} ${context.ln('reminder_added')}',
                          ),
                          backgroundColor: AppColors.accent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 8,
                      shadowColor: AppColors.accent.withValues(alpha: 0.4),
                    ),
                    child: Text(
                      context.ln('add').toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.accent),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkHint : AppColors.lightHint,
                  letterSpacing: 1,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.lightText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required Animation<double> animation,
    required this.builder,
    this.child,
  }) : super(listenable: animation);

  @override
  Widget build(BuildContext context) {
    return builder(context, child);
  }
}
