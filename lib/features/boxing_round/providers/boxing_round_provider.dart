import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:audioplayers/audioplayers.dart';

enum RoundStatus { idle, running, paused, resting, finished }

class BoxingRoundState {
  final int currentRound;
  final int totalRounds;
  final int roundDurationSeconds;
  final int restDurationSeconds;
  final int remainingSeconds;
  final RoundStatus status;
  final bool isWorkoutActive;

  BoxingRoundState({
    required this.currentRound,
    required this.totalRounds,
    required this.roundDurationSeconds,
    required this.restDurationSeconds,
    required this.remainingSeconds,
    required this.status,
    required this.isWorkoutActive,
  });

  factory BoxingRoundState.initial() {
    return BoxingRoundState(
      currentRound: 1,
      totalRounds: 3,
      roundDurationSeconds: 180,
      restDurationSeconds: 60,
      remainingSeconds: 180,
      status: RoundStatus.idle,
      isWorkoutActive: false,
    );
  }

  BoxingRoundState copyWith({
    int? currentRound,
    int? totalRounds,
    int? roundDurationSeconds,
    int? restDurationSeconds,
    int? remainingSeconds,
    RoundStatus? status,
    bool? isWorkoutActive,
  }) {
    return BoxingRoundState(
      currentRound: currentRound ?? this.currentRound,
      totalRounds: totalRounds ?? this.totalRounds,
      roundDurationSeconds: roundDurationSeconds ?? this.roundDurationSeconds,
      restDurationSeconds: restDurationSeconds ?? this.restDurationSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
      isWorkoutActive: isWorkoutActive ?? this.isWorkoutActive,
    );
  }

  String get formattedTime {
    final minutes = remainingSeconds ~/ 60;
    final seconds = remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  double get progress {
    final totalSeconds =
        status == RoundStatus.resting ? restDurationSeconds : roundDurationSeconds;
    if (totalSeconds == 0) return 0;
    return 1 - (remainingSeconds / totalSeconds);
  }

  String get statusText {
    switch (status) {
      case RoundStatus.idle:
        return 'HAZIR';
      case RoundStatus.running:
        return 'RAUND $currentRound';
      case RoundStatus.paused:
        return 'DURAKLATILDI';
      case RoundStatus.resting:
        return 'DINLENME';
      case RoundStatus.finished:
        return 'TAMAMLANDI!';
    }
  }
}

class BoxingRoundNotifier extends StateNotifier<BoxingRoundState> {
  Timer? _timer;
  final AudioPlayer _audioPlayer = AudioPlayer();

  BoxingRoundNotifier() : super(BoxingRoundState.initial());

  void updateTotalRounds(int rounds) {
    if (state.status == RoundStatus.idle) {
      state = state.copyWith(
        totalRounds: rounds,
        currentRound: 1,
        remainingSeconds: state.roundDurationSeconds,
      );
    }
  }

  void updateRoundDuration(int seconds) {
    if (state.status == RoundStatus.idle) {
      state = state.copyWith(
        roundDurationSeconds: seconds,
        remainingSeconds: seconds,
      );
    }
  }

  void updateRestDuration(int seconds) {
    if (state.status == RoundStatus.idle) {
      state = state.copyWith(restDurationSeconds: seconds);
    }
  }

  Future<void> _playSound(bool isStart) async {
    try {
      if (isStart) {
        await _audioPlayer.play(AssetSource('sounds/boxing_bell_short.mp3'));
      } else {
        await _audioPlayer.play(AssetSource('sounds/boxing_bell_long.mp3'));
      }
    } catch (e) {
      // Sound playback failed silently
    }
  }

  void startWorkout() {
    if (state.status == RoundStatus.idle || state.status == RoundStatus.finished) {
      _startRound();
    } else if (state.status == RoundStatus.paused) {
      _resumeTimer();
    }
  }

  void _startRound() {
    _playSound(true);
    state = state.copyWith(
      status: RoundStatus.running,
      isWorkoutActive: true,
      remainingSeconds: state.roundDurationSeconds,
      currentRound: 1,
    );
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.remainingSeconds > 0) {
        state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
      } else {
        _onTimerComplete();
      }
    });
  }

  void _onTimerComplete() {
    _timer?.cancel();

    if (state.status == RoundStatus.running) {
      _playSound(false);

      if (state.currentRound >= state.totalRounds) {
        state = state.copyWith(
          status: RoundStatus.finished,
          isWorkoutActive: false,
        );
        _playSound(false);
      } else {
        state = state.copyWith(
          status: RoundStatus.resting,
          remainingSeconds: state.restDurationSeconds,
        );
        _startTimer();
      }
    } else if (state.status == RoundStatus.resting) {
      _playSound(true);
      state = state.copyWith(
        status: RoundStatus.running,
        currentRound: state.currentRound + 1,
        remainingSeconds: state.roundDurationSeconds,
      );
      _startTimer();
    }
  }

  void pauseTimer() {
    if (state.status == RoundStatus.running || state.status == RoundStatus.resting) {
      _timer?.cancel();
      state = state.copyWith(status: RoundStatus.paused);
    }
  }

  void _resumeTimer() {
    if (state.status == RoundStatus.paused) {
      final wasResting = state.remainingSeconds <= state.restDurationSeconds &&
          state.currentRound < state.totalRounds;
      state = state.copyWith(
        status: wasResting ? RoundStatus.resting : RoundStatus.running,
      );
      _startTimer();
    }
  }

  void resetWorkout() {
    _timer?.cancel();
    state = BoxingRoundState.initial();
  }

  void skipToNext() {
    if (state.status == RoundStatus.running || state.status == RoundStatus.resting) {
      _timer?.cancel();
      _onTimerComplete();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}

final boxingRoundProvider =
    StateNotifierProvider<BoxingRoundNotifier, BoxingRoundState>((ref) {
  return BoxingRoundNotifier();
});
