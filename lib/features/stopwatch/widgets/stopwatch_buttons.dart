import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairos/features/stopwatch/providers/stopwatch_provider.dart';

class StopWatchButtons extends ConsumerWidget {
  final bool isRunning;
  final bool isPaused;

  const StopWatchButtons({
    super.key,
    required this.isRunning,
    required this.isPaused,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // ===== BAŞLAT BUTONU =====
        if (!isRunning && !isPaused)
          _GradientButton(
            icon: Icons.play_arrow_rounded,
            label: 'BAŞLAT',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF00E676), Color(0xFF00C853), Color(0xFF009624)],
            ),
            onPressed: () {
              ref.read(timerProvider.notifier).startTimer();
            },
          ),

        // ===== DURAKLAT BUTONU =====
        if (isRunning && !isPaused)
          _GradientButton(
            icon: Icons.pause_rounded,
            label: 'DURAKLAT',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFAB00), Color(0xFFFF8F00), Color(0xFFE65100)],
            ),
            onPressed: () {
              ref.read(timerProvider.notifier).pauseTimer();
            },
          ),

        // ===== DEVAM ET BUTONU =====
        if (isRunning && isPaused)
          _GradientButton(
            icon: Icons.play_arrow_rounded,
            label: 'DEVAM ET',
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF40C4FF), Color(0xFF0288D1), Color(0xFF01579B)],
            ),
            onPressed: () {
              ref.read(timerProvider.notifier).resumeTimer();
            },
          ),

        // ===== SIFIRLA BUTONU =====
        if (isRunning || isPaused)
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: _CircleButton(
              icon: Icons.stop_rounded,
              color: const Color(0xFFE84C3D),
              onPressed: () {
                ref.read(timerProvider.notifier).resetTimer();
              },
            ),
          ),
      ],
    );
  }
}

class _GradientButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient gradient;
  final VoidCallback onPressed;

  const _GradientButton({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: gradient.colors.last.withValues(alpha: 0.3),
            blurRadius: 10,
            spreadRadius: -2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(18),          splashColor: Colors.white.withValues(alpha: 0.2),
          highlightColor: Colors.white.withValues(alpha: 0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 24),
                const SizedBox(width: 10),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _CircleButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.5),
            blurRadius: 15,
            spreadRadius: 3,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          splashColor: Colors.white.withValues(alpha: 0.3),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}
