import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';

class LapData {
  final int lapNumber;
  final int totalMilliseconds;
  final int lapMilliseconds;

  LapData({
    required this.lapNumber,
    required this.totalMilliseconds,
    required this.lapMilliseconds,
  });

  String get formattedTotal {
    return _formatTime(totalMilliseconds);
  }

  String get formattedLap {
    return _formatTime(lapMilliseconds);
  }

  static String _formatTime(int ms) {
    final totalSeconds = ms ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final milliseconds = ((ms % 1000) ~/ 10).toString().padLeft(2, '0');
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.$milliseconds';
  }
}

class StopWatchState {
  final int milliseconds;
  final bool isRunning;
  final bool isPaused;
  final String displayTime;
  final List<LapData> laps;

  StopWatchState({
    required this.milliseconds,
    required this.isRunning,
    required this.isPaused,
    required this.displayTime,
    required this.laps,
  });

  factory StopWatchState.initial() {
    return StopWatchState(
      milliseconds: 0,
      isRunning: false,
      isPaused: false,
      displayTime: '00:00.00',
      laps: [],
    );
  }

  StopWatchState copyWith({
    int? milliseconds,
    bool? isRunning,
    bool? isPaused,
    String? displayTime,
    List<LapData>? laps,
  }) {
    return StopWatchState(
      milliseconds: milliseconds ?? this.milliseconds,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      displayTime: displayTime ?? this.displayTime,
      laps: laps ?? this.laps,
    );
  }

  static String formatTime(int ms) {
    final totalSeconds = ms ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    final milliseconds = ((ms % 1000) ~/ 10).toString().padLeft(2, '0');
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.$milliseconds';
  }

  StopWatchState updateWithMs(int newMs) {
    return copyWith(
      milliseconds: newMs,
      displayTime: formatTime(newMs),
    );
  }
}

class StopWatchNotifier extends StateNotifier<StopWatchState> {
  Timer? _timer;
  int _lastLapMs = 0;

  StopWatchNotifier() : super(StopWatchState.initial());

  void startTimer() {
    if (state.isRunning || state.isPaused) return;
    _lastLapMs = 0;
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      final newMs = state.milliseconds + 10;
      state = state.updateWithMs(newMs);
    });
    state = state.copyWith(isRunning: true, isPaused: false);
  }

  void pauseTimer() {
    if (!state.isRunning || state.isPaused) return;
    _timer?.cancel();
    _timer = null;
    state = state.copyWith(isPaused: true);
  }

  void resumeTimer() {
    if (!state.isRunning || !state.isPaused) return;
    _timer = Timer.periodic(const Duration(milliseconds: 10), (timer) {
      final newMs = state.milliseconds + 10;
      state = state.updateWithMs(newMs);
    });
    state = state.copyWith(isPaused: false);
  }

  void resetTimer() {
    _timer?.cancel();
    _timer = null;
    _lastLapMs = 0;
    state = StopWatchState.initial();
  }

  void addLap() {
    if (!state.isRunning) return;
    final lapTime = state.milliseconds - _lastLapMs;
    final lap = LapData(
      lapNumber: state.laps.length + 1,
      totalMilliseconds: state.milliseconds,
      lapMilliseconds: lapTime,
    );
    _lastLapMs = state.milliseconds;
    state = state.copyWith(laps: [...state.laps, lap]);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<StopWatchNotifier, StopWatchState>((
  ref,
) {
  return StopWatchNotifier();
});
