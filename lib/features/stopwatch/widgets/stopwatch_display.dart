import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StopWatchDisplay extends ConsumerWidget {
  final String time;
  final bool isRunning;
  const StopWatchDisplay({
    super.key,
    required this.time,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isRunning
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        border: Border.all(
          color: isRunning ? Colors.green : Colors.grey,
          width: isRunning ? 3 : 1,
        ),
      ),
      child: Text(
        time,
        style: TextStyle(
          fontSize: 80,
          fontWeight: FontWeight.bold,
          fontFamily: 'monospace',
          color: isRunning ? Colors.green : Colors.grey,
        ),
      ),
    );
  }
}
