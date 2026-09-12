import 'dart:async';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:lingo_easy/lingo_easy.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sporlab/features/dashboard/model/step_data.dart';

class StepTrackerService {
  static const String _keyStepGoal = 'sporlab_step_goal';
  static const String _keyLastDate = 'sporlab_step_last_date';
  static const String _keyBaselineSteps = 'sporlab_step_baseline';
  static const String _keyRebootAccumulated = 'sporlab_step_reboot_accumulated';
  static const String _keyLastRawSensorSteps = 'sporlab_step_last_raw_sensor';
  static const String _keyTodaySteps = 'sporlab_step_today_steps';
  static const String _keyHistoryPrefix = 'sporlab_step_history_';

  StreamSubscription<StepCount>? _stepCountSubscription;
  StreamSubscription<PedestrianStatus>? _pedestrianStatusSubscription;

  final _stepDataController = StreamController<StepData>.broadcast();
  Stream<StepData> get stepDataStream => _stepDataController.stream;

  StepData _currentData = const StepData(isLoading: true);
  StepData get currentData => _currentData;

  // Localized error messages (set during initialize)
  String _localizedPermissionError = '';
  String _localizedSensorNotFoundError = '';
  String _localizedSensorDataError = '';

  // Localized day names (set during initialize)
  List<String> _localizedDaysShort = [];

  // Localized status texts (set during initialize)
  String _localizedStatusWalking = '';
  String _localizedStatusStopped = '';
  String _localizedStatusUnknown = '';

  // Localized time unit texts (set during initialize)
  String _localizedHourShort = '';
  String _localizedMinuteShort = '';

  /// Servisi başlat
  Future<void> initialize(BuildContext context) async {
    // Localize error messages and day names before async operations
    _localizedPermissionError = context.ln(
      'motion_sensor_permission_is_required_for_step_tracking',
    );
    _localizedSensorNotFoundError = context.ln(
      'a_step_sensor_could_not_be_found_or_accessed_on_the_device',
    );
    _localizedSensorDataError = context.ln(
      'step_sensor_data_cannot_be_read',
    );

    // Localize day names (Monday first, Sunday last)
    _localizedDaysShort = [
      context.ln('mon'),
      context.ln('tue'),
      context.ln('wed'),
      context.ln('thu'),
      context.ln('fri'),
      context.ln('sat'),
      context.ln('sun'),
    ];

    // Localize status texts
    _localizedStatusWalking = context.ln('status_walking');
    _localizedStatusStopped = context.ln('status_stopped');
    _localizedStatusUnknown = context.ln('status_unknown');

    // Localize time unit texts
    _localizedHourShort = context.ln('hour_short');
    _localizedMinuteShort = context.ln('minute_short');

    _emitUpdate(_currentData.copyWith(isLoading: true));

    // 1. Önbellekteki verileri hemen yükle
    await _loadCachedData();

    // 2. İzinleri kontrol et ve sensör dinlemeyi başlat
    final hasPermission = await checkAndRequestPermission();
    if (hasPermission) {
      _startListening();
    } else {
      _emitUpdate(
        _currentData.copyWith(
          hasPermission: false,
          isLoading: false,
          errorKey: _localizedPermissionError,
        ),
      );
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

      _emitUpdate(
        _currentData.copyWith(
          isSensorAvailable: true,
          hasPermission: true,
          isLoading: false,
          errorMessage: null,
        ),
      );
    } catch (e) {
      debugPrint('Pedometer initialization error: $e');
      _emitUpdate(
        _currentData.copyWith(
          isSensorAvailable: false,
          isLoading: false,
          errorKey: _localizedSensorNotFoundError,
        ),
      );
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
      await prefs.setInt(
        '$_keyHistoryPrefix$todayDateStr',
        calculatedTodaySteps,
      );

      // Haftalık verileri güncelle
      final weekly = await _loadWeeklyHistory(prefs, now, calculatedTodaySteps);

      _emitUpdate(
        _currentData.copyWith(
          todaySteps: calculatedTodaySteps,
          isSensorAvailable: true,
          hasPermission: true,
          isLoading: false,
          errorMessage: null,
          weeklySteps: weekly,
        ),
      );
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
    _emitUpdate(
      _currentData.copyWith(
        isSensorAvailable: false,
        isLoading: false,
        errorKey: _localizedSensorDataError,
      ),
    );
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

    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dateKey = _formatDateKey(date);
      final dayName = _localizedDaysShort[date.weekday - 1];

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
    _emitUpdate(
      _currentData.copyWith(todaySteps: newTotal, weeklySteps: weekly),
    );
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
    _emitUpdate(_currentData.copyWith(todaySteps: 0, weeklySteps: weekly));
  }

  /// Dil değiştiğinde lokalizasyonu güncelle
  void changeLanguage(BuildContext context) {
    // Hata mesajlarını güncelle
    _localizedPermissionError = context.ln(
      'motion_sensor_permission_is_required_for_step_tracking',
    );
    _localizedSensorNotFoundError = context.ln(
      'a_step_sensor_could_not_be_found_or_accessed_on_the_device',
    );
    _localizedSensorDataError = context.ln(
      'step_sensor_data_cannot_be_read',
    );

    // Gün isimlerini güncelle
    _localizedDaysShort = [
      context.ln('mon'),
      context.ln('tue'),
      context.ln('wed'),
      context.ln('thu'),
      context.ln('fri'),
      context.ln('sat'),
      context.ln('sun'),
    ];

    // Durum metinlerini güncelle
    _localizedStatusWalking = context.ln('status_walking');
    _localizedStatusStopped = context.ln('status_stopped');
    _localizedStatusUnknown = context.ln('status_unknown');

    // Zaman birimi metinlerini güncelle
    _localizedHourShort = context.ln('hour_short');
    _localizedMinuteShort = context.ln('minute_short');

    // Mevcut weeklySteps map'inin anahtarlarını güncelle (değerleri koru)
    if (_currentData.weeklySteps.isNotEmpty) {
      final oldWeekly = _currentData.weeklySteps;
      final newWeekly = <String, int>{};
      final oldKeys = oldWeekly.keys.toList();
      for (int i = 0; i < oldKeys.length && i < _localizedDaysShort.length; i++) {
        newWeekly[_localizedDaysShort[i]] = oldWeekly[oldKeys[i]] ?? 0;
      }
      _currentData = _currentData.copyWith(weeklySteps: newWeekly);
    }

    // Mevcut veriyi güncelle ve yeniden gönder
    _emitUpdate(_currentData);
  }

  /// StepData'ya lokalize edilmiş metinleri ekle
  StepData _withLocalizedTexts(StepData data) {
    return data.copyWith(
      statusWalkingText: _localizedStatusWalking,
      statusStoppedText: _localizedStatusStopped,
      statusUnknownText: _localizedStatusUnknown,
      hourShortText: _localizedHourShort,
      minuteShortText: _localizedMinuteShort,
    );
  }

  void _emitUpdate(StepData data) {
    _currentData = _withLocalizedTexts(data);
    if (!_stepDataController.isClosed) {
      _stepDataController.add(_currentData);
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
