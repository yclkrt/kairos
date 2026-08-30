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
          _buildButton(
            context,
            icon: Icons.play_arrow,
            label: 'Başlat',
            color: Colors.green,
            onPressed: () {
              ref.read(timerProvider.notifier).startTimer();
            },
          ),

        // ===== DURAKLAT BUTONU =====
        if (isRunning && !isPaused)
          _buildButton(
            context,
            icon: Icons.pause,
            label: 'Duraklat',
            color: Colors.orange,
            onPressed: () {
              ref.read(timerProvider.notifier).pauseTimer();
            },
          ),

        // ===== DEVAM ET BUTONU =====
        if (isRunning && isPaused)
          _buildButton(
            context,
            icon: Icons.play_arrow,
            label: 'Devam Et',
            color: Colors.blue,
            onPressed: () {
              ref.read(timerProvider.notifier).resumeTimer();
            },
          ),

        // ===== DURDUR/SIFIRLA BUTONU =====
        if (isRunning || isPaused)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: _buildButton(
              context,
              icon: Icons.stop,
              label: 'Sıfırla',
              color: Colors.red,
              onPressed: () {
                ref.read(timerProvider.notifier).resetTimer();
              },
            ),
          ),
      ],
    );
  }

  Widget _buildButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 28),
      label: Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        minimumSize: const Size(140, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
      ),
    );
  }
}
