import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kairos/features/dashboard/model/step_data.dart';

class StepTrackerService {
  static const String _keyStepGoal = 'kairos_step_goal';
  static const String _keyLastDate = 'kairos_step_last_date';
  static const String _keyBaselineSteps = 'kairos_step_baseline';
  static const String _keyRebootAccumulated = 'kairos_step_reboot_accumulated';
  static const String _keyLastRawSensorSteps = 'kairos_step_last_raw_sensor';
  static const String _keyTodaySteps = 'kairos_step_today_steps';
  static const String _keyHistoryPrefix = 'kairos_step_history_';

  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;

  final _stepDataController = StreamController<StepData>.broadcast();
  Stream<StepData> get stepDataStream => _stepDataController.stream;

  StepData _currentData = const StepData(isLoading: true);
  StepData get currentData => _currentData;

  /// Servisi başlat
  Future<void> initialize() async {
    _emitUpdate(_currentData.copyWith(isLoading: true));

    // 1. Önbellekteki verileri hemen yükle
    await _loadCachedData();

    // 2. İzinleri kontrol et ve sensör dinlemeyi başlat
    final hasPermission = await checkAndRequestPermission();
    if (hasPermission) {
      _startListening();
    } else {
      _emitUpdate(_currentData.copyWith(
        hasPermission: false,
        isLoading: false,
        errorMessage: 'Adım takibi için hareket sensörü izni gereklidir.',
      ));
    }
  }

  /// İzin kontrolü ve isteme
  Future<bool> checkAndRequestPermission() async {
    if (Platform.isAndroid) {
      final status = await Permission.activityRecognition.status;
      if (status.isGranted) return true;

      final requested = await Permission.activityRecognition.request();
      final isGranted = requested.isGranted;
      _emitUpdate(_currentData.copyWith(hasPermission: isGranted));
      return isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.sensors.status;
      if (status.isGranted) return true;

      final requested = await Permission.sensors.request();
      final isGranted = requested.isGranted;
      _emitUpdate(_currentData.copyWith(hasPermission: isGranted));
      return isGranted;
    }
    return true;
  }

  /// Sensör akışlarını dinlemeye başla
  void _startListening() {
    _stepCountSubscription?.cancel();
    _pedestrianStatusSubscription?.cancel();

    try {
      _stepCountSubscription = Pedometer.stepCountStream.listen(
        _onStepCount,
        onError: _onStepCountError,
        cancelOnError: false,
      );

      _pedestrianStatusSubscription = Pedometer.pedestrianStatusStream.listen(
        _onPedestrianStatus,
        onError: _onPedestrianStatusError,
        cancelOnError: false,
      );

      _emitUpdate(_currentData.copyWith(
        isSensorAvailable: true,
        hasPermission: true,
        isLoading: false,
        errorMessage: null,
      ));
    } catch (e) {
      debugPrint('Pedometer initialization error: $e');
      _emitUpdate(_currentData.copyWith(
        isSensorAvailable: false,
        isLoading: false,
        errorMessage: 'Cihazda adım sensörü bulunamadı veya erişilemedi.',
      ));
    }
  }

  /// Gelen adım sayımı verisini işle (Arka plan / Cihaz kapalıyken atılan adımları hesaplar)
  Future<void> _onStepCount(StepCount event) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final todayDateStr = _formatDateKey(now);

      final lastDateStr = prefs.getString(_keyLastDate) ?? todayDateStr;
      int baseline = prefs.getInt(_keyBaselineSteps) ?? event.steps;
      int rebootAccumulated = prefs.getInt(_keyRebootAccumulated) ?? 0;
      int lastRawSensor = prefs.getInt(_keyLastRawSensorSteps) ?? event.steps;

      int calculatedTodaySteps = 0;

      // Gün değiştiyse
      if (todayDateStr != lastDateStr) {
        // Eski günün adımlarını geçmişe kaydet
        final oldTodaySteps = prefs.getInt(_keyTodaySteps) ?? 0;
        await prefs.setInt('$_keyHistoryPrefix$lastDateStr', oldTodaySteps);

        // Yeni günü sıfırla
        baseline = event.steps;
        rebootAccumulated = 0;
        calculatedTodaySteps = 0;

        await prefs.setString(_keyLastDate, todayDateStr);
        await prefs.setInt(_keyBaselineSteps, baseline);
        await prefs.setInt(_keyRebootAccumulated, rebootAccumulated);
      } else {
        // Aynı gün içindeyiz
        // Cihaz yeniden başlatıldıysa (sensör adımı sıfırlanmış olabilir)
        if (event.steps < lastRawSensor) {
          rebootAccumulated += (lastRawSensor - baseline);
          baseline = event.steps;
          await prefs.setInt(_keyBaselineSteps, baseline);
          await prefs.setInt(_keyRebootAccumulated, rebootAccumulated);
        }

        calculatedTodaySteps = (event.steps - baseline) + rebootAccumulated;
        if (calculatedTodaySteps < 0) {
          calculatedTodaySteps = 0;
          baseline = event.steps;
          await prefs.setInt(_keyBaselineSteps, baseline);
        }
      }

      // Verileri kaydet
      await prefs.setInt(_keyLastRawSensorSteps, event.steps);
      await prefs.setInt(_keyTodaySteps, calculatedTodaySteps);
      await prefs.setInt('$_keyHistoryPrefix$todayDateStr', calculatedTodaySteps);

      // Haftalık verileri güncelle
      final weekly = await _loadWeeklyHistory(prefs, now, calculatedTodaySteps);

      _emitUpdate(_currentData.copyWith(
        todaySteps: calculatedTodaySteps,
        isSensorAvailable: true,
        hasPermission: true,
        isLoading: false,
        errorMessage: null,
        weeklySteps: weekly,
      ));
    } catch (e) {
      debugPrint('Error processing step count: $e');
    }
  }

  void _onPedestrianStatus(PedestrianStatus event) {
    StepStatus status;
    switch (event.status.toLowerCase()) {
      case 'walking':
        status = StepStatus.walking;
        break;
      case 'stopped':
        status = StepStatus.stopped;
        break;
      default:
        status = StepStatus.unknown;
        break;
    }
    _emitUpdate(_currentData.copyWith(status: status));
  }

  void _onStepCountError(dynamic error) {
    debugPrint('Pedometer Step Count Error: $error');
    _emitUpdate(_currentData.copyWith(
      isSensorAvailable: false,
      isLoading: false,
      errorMessage: 'Adım sensörü verisi alınamıyor.',
    ));
  }

  void _onPedestrianStatusError(dynamic error) {
    debugPrint('Pedometer Pedestrian Status Error: $error');
  }

  /// Kayıtlı önbellek verilerini yükle
  Future<void> _loadCachedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final todayDateStr = _formatDateKey(now);
      final lastDateStr = prefs.getString(_keyLastDate);

      final goal = prefs.getInt(_keyStepGoal) ?? 8000;
      int steps = 0;

      if (lastDateStr == todayDateStr) {
        steps = prefs.getInt(_keyTodaySteps) ?? 0;
      }

      final weekly = await _loadWeeklyHistory(prefs, now, steps);

      _currentData = _currentData.copyWith(
        todaySteps: steps,
        stepGoal: goal,
        weeklySteps: weekly,
        isLoading: false,
      );
      _emitUpdate(_currentData);
    } catch (e) {
      debugPrint('Error loading cached step data: $e');
    }
  }

  /// Son 7 günün adım geçmişini yükle
  Future<Map<String, int>> _loadWeeklyHistory(
    SharedPreferences prefs,
    DateTime now,
    int todaySteps,
  ) async {
    final Map<String, int> result = {};
    const daysShort = ['Pzt', 'Sal', 'Çar', 'Per', 'Cum', 'Cmt', 'Paz'];

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = _formatDateKey(date);
      final dayName = daysShort[date.weekday - 1];

      if (i == 0) {
        result[dayName] = todaySteps;
      } else {
        final stepVal = prefs.getInt('$_keyHistoryPrefix$dateKey') ?? 0;
        result[dayName] = stepVal;
      }
    }
    return result;
  }

  /// Günlük hedefi güncelle
  Future<void> setStepGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyStepGoal, goal);
    _emitUpdate(_currentData.copyWith(stepGoal: goal));
  }

  /// Test / Manuel ekleme (Örn. simülatörde test amaçlı)
  Future<void> addSimulatedSteps(int count) async {
    final prefs = await SharedPreferences.getInstance();
    final newTotal = _currentData.todaySteps + count;
    final now = DateTime.now();
    final todayDateStr = _formatDateKey(now);

    await prefs.setInt(_keyTodaySteps, newTotal);
    await prefs.setInt('$_keyHistoryPrefix$todayDateStr', newTotal);

    final weekly = await _loadWeeklyHistory(prefs, now, newTotal);
    _emitUpdate(_currentData.copyWith(
      todaySteps: newTotal,
      weeklySteps: weekly,
    ));
  }

  /// Bugünün adımlarını sıfırla
  Future<void> resetTodaySteps() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayDateStr = _formatDateKey(now);

    final lastRaw = prefs.getInt(_keyLastRawSensorSteps) ?? 0;
    await prefs.setInt(_keyBaselineSteps, lastRaw);
    await prefs.setInt(_keyRebootAccumulated, 0);
    await prefs.setInt(_keyTodaySteps, 0);
    await prefs.setInt('$_keyHistoryPrefix$todayDateStr', 0);

    final weekly = await _loadWeeklyHistory(prefs, now, 0);
    _emitUpdate(_currentData.copyWith(
      todaySteps: 0,
      weeklySteps: weekly,
    ));
  }

  void _emitUpdate(StepData data) {
    _currentData = data;
    if (!_stepDataController.isClosed) {
      _stepDataController.add(data);
    }
  }

  String _formatDateKey(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  void dispose() {
    _stepCountSubscription?.cancel();
    _pedestrianStatusSubscription?.cancel();
    _stepDataController.close();
  }
}
