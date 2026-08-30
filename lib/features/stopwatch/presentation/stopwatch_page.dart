import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairos/core/widgets/main_scaffold.dart';
import 'package:kairos/features/stopwatch/providers/stopwatch_provider.dart';
import 'package:kairos/features/stopwatch/widgets/stopwatch_buttons.dart';
import 'package:kairos/features/stopwatch/widgets/stopwatch_display.dart';

class StopwatchPage extends ConsumerStatefulWidget {
  const StopwatchPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends ConsumerState<StopwatchPage> {
  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);

    return MainScaffold(
      appBar: AppBar(title: const Text("Kronometre")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Zaman Gösterici
            StopWatchDisplay(
              time: timerState.displayTime,
              isRunning: timerState.isRunning,
            ),

            const SizedBox(height: 40),

            // Kontrol Butonları
            StopWatchButtons(
              isRunning: timerState.isRunning,
              isPaused: timerState.isPaused,
            ),

            const SizedBox(height: 24),

            // Bilgi (Durum)
            _buildStatusText(timerState),

            const SizedBox(height: 16),

            // Kaç saniye geçti (debug için)
            Text(
              '⏱️ ${timerState.seconds} saniye geçti',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusText(StopWatchState state) {
    String status;
    Color color;

    if (state.isRunning && !state.isPaused) {
      status = '▶️ Çalışıyor...';
      color = Colors.green;
    } else if (state.isPaused) {
      status = '⏸️ Duraklatıldı';
      color = Colors.orange;
    } else if (state.seconds > 0) {
      status = '⏹️ Durduruldu';
      color = Colors.red;
    } else {
      status = '⏳ Hazır';
      color = Colors.grey;
    }

    return Text(
      status,
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: color),
    );
  }
}
