import 'package:flutter/foundation.dart';

enum StepStatus {
  walking,
  stopped,
  unknown,
}

@immutable
class StepData {
  final int todaySteps;
  final int stepGoal;
  final StepStatus status;
  final bool isSensorAvailable;
  final bool hasPermission;
  final bool isLoading;
  final String? errorMessage;
  final Map<String, int> weeklySteps; // e.g. {"Pzt": 6200, "Sal": 8400, ...}

  const StepData({
    this.todaySteps = 0,
    this.stepGoal = 8000,
    this.status = StepStatus.stopped,
    this.isSensorAvailable = true,
    this.hasPermission = true,
    this.isLoading = false,
    this.errorMessage,
    this.weeklySteps = const {},
  });

  /// İlerleme yüzdesi (0.0 - 1.0 arasında)
  double get progress => stepGoal > 0 ? (todaySteps / stepGoal).clamp(0.0, 1.0) : 0.0;

  /// Yüzde değeri (örn: %75)
  int get progressPercentage => (progress * 100).round();

  /// Yakılan kalori tahmini (~0.042 kcal / adım)
  int get caloriesBurned => (todaySteps * 0.042).round();

  /// Yürüyüş mesafesi (ortalama adım uzunluğu 0.762 m)
  double get distanceKm => (todaySteps * 0.762) / 1000.0;

  /// Mesafe gösterim metni (örn: "2.4 km")
  String get distanceDisplay => '${distanceKm.toStringAsFixed(2)} km';

  /// Aktif süre tahmini (dakika cinsinden, ~100 adım/dk)
  int get activeMinutes => (todaySteps / 100).round();

  /// Aktif süre gösterimi (örn: "42 dk" veya "1s 15dk")
  String get activeTimeDisplay {
    if (activeMinutes < 60) {
      return '$activeMinutes dk';
    }
    final hours = activeMinutes ~/ 60;
    final mins = activeMinutes % 60;
    return '${hours}s ${mins}dk';
  }

  /// Hedefe kalan adım sayısı
  int get remainingSteps => (stepGoal - todaySteps).clamp(0, stepGoal);

  /// Hedefe ulaşıldı mı
  bool get isGoalReached => todaySteps >= stepGoal;

  /// Durum metni (Türkçe)
  String get statusText {
    switch (status) {
      case StepStatus.walking:
        return 'Hareket Halinde';
      case StepStatus.stopped:
        return 'Hareketsiz';
      case StepStatus.unknown:
        return 'Bekleniyor';
    }
  }

  StepData copyWith({
    int? todaySteps,
    int? stepGoal,
    StepStatus? status,
    bool? isSensorAvailable,
    bool? hasPermission,
    bool? isLoading,
    String? errorMessage,
    Map<String, int>? weeklySteps,
  }) {
    return StepData(
      todaySteps: todaySteps ?? this.todaySteps,
      stepGoal: stepGoal ?? this.stepGoal,
      status: status ?? this.status,
      isSensorAvailable: isSensorAvailable ?? this.isSensorAvailable,
      hasPermission: hasPermission ?? this.hasPermission,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      weeklySteps: weeklySteps ?? this.weeklySteps,
    );
  }
}
