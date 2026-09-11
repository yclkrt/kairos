import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:sporlab/features/dashboard/data/step_tracker_service.dart';
import 'package:sporlab/features/dashboard/model/step_data.dart';

// Singleton StepTrackerService provider
final stepTrackerServiceProvider = Provider<StepTrackerService>((ref) {
  final service = StepTrackerService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Step data state notifier
class StepTrackerNotifier extends StateNotifier<StepData> {
  final StepTrackerService _service;
  StreamSubscription<StepData>? _subscription;
  bool _isInitialized = false;

  StepTrackerNotifier(this._service) : super(const StepData(isLoading: true));

  void initialize(BuildContext context) {
    if (_isInitialized) return;
    _isInitialized = true;
    
    _subscription = _service.stepDataStream.listen((data) {
      state = data;
    });
    _service.initialize(context);
  }

  /// Hedefi güncelle (örn. 6000, 10000 adım)
  Future<void> setGoal(int goal) async {
    await _service.setStepGoal(goal);
  }

  /// İzni tekrar kontrol et ve başlat
  Future<void> retryPermission(BuildContext context) async {
    final granted = await _service.checkAndRequestPermission();
    if (granted && context.mounted) {
      await _service.initialize(context);
    }
  }

  /// Test amaçlı adım ekleme
  Future<void> addSimulatedSteps(int count) async {
    await _service.addSimulatedSteps(count);
  }

  /// Bugünün adımlarını sıfırla
  Future<void> resetSteps() async {
    await _service.resetTodaySteps();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

// Step data provider for UI consumption
final stepTrackerProvider =
    StateNotifierProvider<StepTrackerNotifier, StepData>((ref) {
      final service = ref.watch(stepTrackerServiceProvider);
      return StepTrackerNotifier(service);
    });
