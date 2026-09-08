import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairos/core/theme/app_colors.dart';
import 'package:kairos/core/theme/app_gradients.dart';
import 'package:kairos/core/widgets/main_scaffold.dart';
import 'package:kairos/features/boxing_round/providers/boxing_round_provider.dart';

class BoxingRoundPage extends ConsumerStatefulWidget {
  const BoxingRoundPage({super.key});

  @override
  ConsumerState<BoxingRoundPage> createState() => _BoxingRoundPageState();
}

class _BoxingRoundPageState extends ConsumerState<BoxingRoundPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final roundState = ref.watch(boxingRoundProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MainScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDark ? AppGradients.boxingDark : AppGradients.boxing,
          ),
        ),
        title: const Text(
          'BOX RAUND',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        actions: [
          if (roundState.isWorkoutActive)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                ),
                child: Text(
                  '${roundState.currentRound}/${roundState.totalRounds}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0A0A0A), const Color(0xFF1A0A0A), const Color(0xFF0D0D0D)]
                : [const Color(0xFFFFF5F5), const Color(0xFFFFFFFF), const Color(0xFFF8F8F8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildStatusHeader(roundState, isDark),
              Expanded(child: _buildMainContent(roundState, isDark)),
              _buildControlButtons(roundState, isDark),
              _buildSettingsPanel(roundState, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusHeader(BoxingRoundState state, bool isDark) {
    Color statusColor;
    IconData statusIcon;
    switch (state.status) {
      case RoundStatus.running:
        statusColor = AppColors.workoutHigh;
        statusIcon = Icons.sports_mma;
      case RoundStatus.resting:
        statusColor = AppColors.workoutRest;
        statusIcon = Icons.self_improvement;
      case RoundStatus.paused:
        statusColor = AppColors.warning;
        statusIcon = Icons.pause_circle_outline;
      case RoundStatus.finished:
        statusColor = AppColors.success;
        statusIcon = Icons.emoji_events;
      case RoundStatus.idle:
        statusColor = isDark ? Colors.white54 : Colors.black54;
        statusIcon = Icons.play_circle_outline;
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(statusIcon, color: statusColor, size: 24),
              const SizedBox(width: 8),
              Text(
                state.statusText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4,
                  color: statusColor,
                ),
              ),
            ],
          ),
          if (state.status == RoundStatus.running ||
              state.status == RoundStatus.resting ||
              state.status == RoundStatus.paused)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Raund \${state.currentRound} / \${state.totalRounds}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BoxingRoundState state, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildTimerCircle(state, isDark),
          const SizedBox(height: 40),
          _buildRoundIndicators(state, isDark),
        ],
      ),
    );
  }

  Widget _buildTimerCircle(BoxingRoundState state, bool isDark) {
    final isRunning = state.status == RoundStatus.running;
    final isResting = state.status == RoundStatus.resting;
    final progress = state.progress;
    final primaryColor = isResting ? AppColors.workoutRest : AppColors.workoutHigh;
    final secondaryColor = isResting ? const Color(0xFF1565C0) : const Color(0xFFC62828);
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final shouldPulse = isRunning || isResting;
        final scale = shouldPulse ? _pulseAnimation.value : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [primaryColor.withValues(alpha: 0.2), secondaryColor.withValues(alpha: 0.1)],
              ),
              boxShadow: [BoxShadow(color: primaryColor.withValues(alpha: 0.3), blurRadius: 30, spreadRadius: 5)],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 240,
                  height: 240,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 10))],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isResting ? Icons.self_improvement : Icons.sports_mma, size: 40, color: primaryColor),
                      const SizedBox(height: 12),
                      Text(
                        state.formattedTime,
                        style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, fontFamily: 'monospace', letterSpacing: 4, color: isDark ? Colors.white : const Color(0xFF1A1A1A)),
                      ),
                      const SizedBox(height: 4),
                      Text(isResting ? 'DINLENME' : 'RAUND', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 3, color: primaryColor)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRoundIndicators(BoxingRoundState state, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(state.totalRounds, (index) {
          final roundNumber = index + 1;
          final isCompleted = roundNumber < state.currentRound &&
              (state.status == RoundStatus.running || state.status == RoundStatus.resting || state.status == RoundStatus.finished);
          final isCurrent = roundNumber == state.currentRound &&
              (state.status == RoundStatus.running || state.status == RoundStatus.paused);
          Color dotColor;
          if (isCompleted) {
            dotColor = AppColors.success;
          } else if (isCurrent) {
            dotColor = AppColors.workoutHigh;
          } else {
            dotColor = isDark ? Colors.white24 : Colors.black26;
          }
          return Row(
            children: [
              Container(
                width: isCurrent ? 16 : 12,
                height: isCurrent ? 16 : 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dotColor,
                  boxShadow: isCurrent ? [BoxShadow(color: dotColor.withValues(alpha: 0.5), blurRadius: 10, spreadRadius: 2)] : null,
                ),
                child: isCompleted ? const Icon(Icons.check, size: 8, color: Colors.white) : null,
              ),
              if (index < state.totalRounds - 1)
                Container(width: 20, height: 2, color: isCompleted ? AppColors.success : (isDark ? Colors.white12 : Colors.black12)),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildControlButtons(BoxingRoundState state, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (state.status == RoundStatus.idle || state.status == RoundStatus.finished)
            GestureDetector(
              onTap: () => ref.read(boxingRoundProvider.notifier).startWorkout(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFE84C3D), Color(0xFFC62828)]),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: const Color(0xFFE84C3D).withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
                    SizedBox(width: 8),
                    Text('BAŞLAT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.white)),
                  ],
                ),
              ),
            )
          else ...[
            GestureDetector(
              onTap: () => ref.read(boxingRoundProvider.notifier).resetWorkout(),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2)),
                ),
                child: Icon(Icons.stop_rounded, color: isDark ? Colors.white54 : Colors.black54, size: 24),
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () {
                if (state.status == RoundStatus.running || state.status == RoundStatus.resting) {
                  ref.read(boxingRoundProvider.notifier).pauseTimer();
                } else if (state.status == RoundStatus.paused) {
                  ref.read(boxingRoundProvider.notifier).startWorkout();
                }
              },
              child: Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: state.status == RoundStatus.paused
                        ? [const Color(0xFF2ECC71), const Color(0xFF27AE60)]
                        : [const Color(0xFFE84C3D), const Color(0xFFC62828)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (state.status == RoundStatus.paused ? const Color(0xFF2ECC71) : const Color(0xFFE84C3D)).withValues(alpha: 0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(state.status == RoundStatus.paused ? Icons.play_arrow_rounded : Icons.pause_rounded, color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(width: 20),
            GestureDetector(
              onTap: () => ref.read(boxingRoundProvider.notifier).skipToNext(),
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
                  border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.2)),
                ),
                child: Icon(Icons.skip_next_rounded, color: isDark ? Colors.white54 : Colors.black54, size: 24),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSettingsPanel(BoxingRoundState state, bool isDark) {
    final isEditable = state.status == RoundStatus.idle;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('AYARLAR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 3, color: isDark ? Colors.white38 : Colors.black38)),
          const SizedBox(height: 16),
          _buildSettingRow(
            icon: Icons.format_list_numbered_rounded,
            label: 'Raund Sayısı',
            value: '\${state.totalRounds}',
            isEditable: isEditable,
            onDecrement: state.totalRounds > 1 ? () => ref.read(boxingRoundProvider.notifier).updateTotalRounds(state.totalRounds - 1) : null,
            onIncrement: state.totalRounds < 20 ? () => ref.read(boxingRoundProvider.notifier).updateTotalRounds(state.totalRounds + 1) : null,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildSettingRow(
            icon: Icons.timer_outlined,
            label: 'Raund Süresi',
            value: '\${(state.roundDurationSeconds / 60).toInt()} dk',
            isEditable: isEditable,
            onDecrement: state.roundDurationSeconds > 30 ? () => ref.read(boxingRoundProvider.notifier).updateRoundDuration(state.roundDurationSeconds - 30) : null,
            onIncrement: state.roundDurationSeconds < 600 ? () => ref.read(boxingRoundProvider.notifier).updateRoundDuration(state.roundDurationSeconds + 30) : null,
            isDark: isDark,
          ),
          const SizedBox(height: 12),
          _buildSettingRow(
            icon: Icons.self_improvement,
            label: 'Dinlenme Süresi',
            value: '\${state.restDurationSeconds} sn',
            isEditable: isEditable,
            onDecrement: state.restDurationSeconds > 10 ? () => ref.read(boxingRoundProvider.notifier).updateRestDuration(state.restDurationSeconds - 10) : null,
            onIncrement: state.restDurationSeconds < 300 ? () => ref.read(boxingRoundProvider.notifier).updateRestDuration(state.restDurationSeconds + 10) : null,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isEditable,
    required VoidCallback? onDecrement,
    required VoidCallback? onIncrement,
    required bool isDark,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [const Color(0xFFE84C3D).withValues(alpha: 0.2), const Color(0xFFC62828).withValues(alpha: 0.1)]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFFE84C3D), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.black87)),
              Text(value, style: TextStyle(fontSize: 11, color: isDark ? Colors.white38 : Colors.black38)),
            ],
          ),
        ),
        if (isEditable) ...[
          _buildStepButton(icon: Icons.remove, onTap: onDecrement, isDark: isDark),
          const SizedBox(width: 8),
          _buildStepButton(icon: Icons.add, onTap: onIncrement, isDark: isDark),
        ],
      ],
    );
  }

  Widget _buildStepButton({required IconData icon, required VoidCallback? onTap, required bool isDark}) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isEnabled
              ? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05))
              : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02)),
          border: Border.all(
            color: isEnabled
                ? (isDark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.1))
                : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
          ),
        ),
        child: Icon(icon, size: 18, color: isEnabled ? (isDark ? Colors.white70 : Colors.black54) : (isDark ? Colors.white24 : Colors.black26)),
      ),
    );
  }
}
