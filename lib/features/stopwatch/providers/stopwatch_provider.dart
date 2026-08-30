import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';

class StopWatchState {
  final int seconds;
  final bool isRunning;
  final bool isPaused;
  final String displayTime;

  StopWatchState({
    required this.seconds,
    required this.isRunning,
    required this.isPaused,
    required this.displayTime,
  });

  //Başlangıç Durumu
  factory StopWatchState.initial() {
    return StopWatchState(
      seconds: 0,
      isRunning: false,
      isPaused: false,
      displayTime: '00:00',
    );
  }

  //State'i güncellemek için copyWith metodu
  StopWatchState copyWith({
    int? seconds,
    bool? isRunning,
    bool? isPaused,
    String? displayTime,
  }) {
    return StopWatchState(
      seconds: seconds ?? this.seconds,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
      displayTime: displayTime ?? this.displayTime,
    );
  }

  //displayTime'ı otomatik hesapla
  String _formatTime(int totalSeconds) {
    final minuets = totalSeconds ~/ 60;
    final remainingSeconds = totalSeconds % 60;
    return '${minuets.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Yeni state oluştururken
  StopWatchState updateWithSeconds(int newSeconds) {
    return copyWith(
      seconds: newSeconds,
      isRunning: isRunning,
      isPaused: isPaused,
      displayTime: _formatTime(newSeconds),
    );
  }
}

// notifier (iş mantığı)

class StopWatchNotifier extends StateNotifier<StopWatchState> {
  Timer? _timer;

  StopWatchNotifier() : super(StopWatchState.initial());

  // ====== timer'ı başlat ======
  void startTimer() {
    //zaten çalışıyorsa duraklat
    if (state.isRunning || state.isPaused) return;

    //timer'ı başlat
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // her saniye state'i güncelle
      final newSeconds = state.seconds + 1;
      state = state.updateWithSeconds(newSeconds);
    });

    // State'i güncelle
    state = state.copyWith(isRunning: true, isPaused: false);
  }

  // ===== Timer'ı Durdur =====
  void stopTimer() {
    // Çalışmıyorsa işlem yapma
    if (!state.isRunning) return;

    // Timer'ı iptal et
    _timer?.cancel();
    _timer = null;

    // State'i güncelle
    state = state.copyWith(isRunning: false, isPaused: false);
  }

  // ===== Timer'ı Duraklat =====
  void pauseTimer() {
    // Çalışmıyorsa veya zaten duraklatılmışsa işlem yapma
    if (!state.isRunning || state.isPaused) return;

    // Timer'ı iptal et
    _timer?.cancel();
    _timer = null;

    // State'i güncelle
    state = state.copyWith(isPaused: true);
  }

  // ===== Timer'ı Devam Ettir =====
  void resumeTimer() {
    // Çalışmıyorsa veya duraklatılmamışsa işlem yapma
    if (!state.isRunning || !state.isPaused) return;

    // Timer'ı yeniden başlat
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newSeconds = state.seconds + 1;
      state = state.updateWithSeconds(newSeconds);
    });

    // State'i güncelle
    state = state.copyWith(isPaused: false);
  }

  // ===== Timer'ı Sıfırla =====
  void resetTimer() {
    // Timer'ı durdur
    _timer?.cancel();
    _timer = null;

    // State'i sıfırla
    state = StopWatchState.initial();
  }

  // ===== Temizlik =====
  @override
  void dispose() {
    _timer?.cancel();
    _timer = null;
    super.dispose();
  }
}

// ============ PROVIDER ============
final timerProvider = StateNotifierProvider<StopWatchNotifier, StopWatchState>((
  ref,
) {
  return StopWatchNotifier();
});
