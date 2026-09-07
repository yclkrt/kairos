import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairos/core/theme/app_colors.dart';
import 'package:kairos/core/theme/app_gradients.dart';
import 'package:kairos/core/widgets/main_scaffold.dart';

class TaekwondoScoreboardPage extends ConsumerStatefulWidget {
  const TaekwondoScoreboardPage({super.key});

  @override
  ConsumerState<TaekwondoScoreboardPage> createState() =>
      _TaekwondoScoreboardPageState();
}

class _TaekwondoScoreboardPageState
    extends ConsumerState<TaekwondoScoreboardPage> {
  int _chungScore = 0;
  int _hongScore = 0;
  int _chungPenalties = 0;
  int _hongPenalties = 0;
  int _currentRound = 1;
  int _roundDurationSec = 120; // Varsayılan 2 dakika (120 sn)
  int _remainingMs = 120 * 1000;
  bool _isRunning = false;
  Timer? _timer;
  DateTime? _lastTickTime;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_remainingMs <= 0) {
      setState(() {
        _remainingMs = _roundDurationSec * 1000;
      });
    }

    _timer?.cancel();
    _lastTickTime = DateTime.now();

    // 40ms (~25fps) aralıklarla hassas milisaniye/salise sayımı
    _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      final elapsed = now.difference(_lastTickTime!).inMilliseconds;
      _lastTickTime = now;

      if (_remainingMs > elapsed) {
        setState(() {
          _remainingMs -= elapsed;
        });
      } else {
        setState(() {
          _remainingMs = 0;
        });
        _pauseTimer();
        HapticFeedback.heavyImpact();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '$_currentRound. Raunt Tamamlandı!',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              backgroundColor: AppColors.accent,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    });

    setState(() {
      _isRunning = true;
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _pauseTimer();
    setState(() {
      _remainingMs = _roundDurationSec * 1000;
    });
  }

  void _addScore(bool isChung, int points) {
    setState(() {
      if (isChung) {
        _chungScore += points;
      } else {
        _hongScore += points;
      }
    });
  }

  void _subtractScore(bool isChung, int points) {
    setState(() {
      if (isChung) {
        _chungScore = (_chungScore - points).clamp(0, 999);
      } else {
        _hongScore = (_hongScore - points).clamp(0, 999);
      }
    });
  }

  void _addPenalty(bool isChung) {
    setState(() {
      if (isChung) {
        _chungPenalties++;
        _hongScore += 1;
      } else {
        _hongPenalties++;
        _chungScore += 1;
      }
    });
  }

  void _removePenalty(bool isChung) {
    setState(() {
      if (isChung && _chungPenalties > 0) {
        _chungPenalties--;
        _hongScore = (_hongScore - 1).clamp(0, 999);
      } else if (!isChung && _hongPenalties > 0) {
        _hongPenalties--;
        _chungScore = (_chungScore - 1).clamp(0, 999);
      }
    });
  }

  void _resetMatch() {
    _pauseTimer();
    setState(() {
      _chungScore = 0;
      _hongScore = 0;
      _chungPenalties = 0;
      _hongPenalties = 0;
      _currentRound = 1;
      _remainingMs = _roundDurationSec * 1000;
      _isRunning = false;
    });
  }

  void _nextRound() {
    _pauseTimer();
    setState(() {
      _currentRound++;
      _remainingMs = _roundDurationSec * 1000;
      _isRunning = false;
    });
  }

  void _setCustomRoundDuration(int totalSeconds) {
    _pauseTimer();
    setState(() {
      _roundDurationSec = totalSeconds;
      _remainingMs = totalSeconds * 1000;
    });
  }

  /// 1 dakikadan fazla ise: MM:SS
  /// 1 dakikadan az ise: SS.cs (Saniye ve Salise/Milisaniye)
  String _formatDisplayTime(int ms) {
    if (ms >= 60000) {
      final totalSec = ms ~/ 1000;
      final minutes = (totalSec ~/ 60).toString().padLeft(2, '0');
      final seconds = (totalSec % 60).toString().padLeft(2, '0');
      return '$minutes:$seconds';
    } else {
      final seconds = (ms ~/ 1000).toString().padLeft(2, '0');
      final centisecs = ((ms % 1000) ~/ 10).toString().padLeft(2, '0');
      return '$seconds.$centisecs';
    }
  }

  String _formatRoundBadgeTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  void _showDurationSettingsDialog(BuildContext context, bool isDark) {
    int selectedMinutes = _roundDurationSec ~/ 60;
    int selectedSeconds = _roundDurationSec % 60;
    final minController = TextEditingController(
      text: selectedMinutes.toString(),
    );
    final secController = TextEditingController(
      text: selectedSeconds.toString(),
    );

    final presetDurations = [
      {'label': '1 Dk', 'seconds': 60},
      {'label': '1.5 Dk', 'seconds': 90},
      {'label': '2 Dk (Standart)', 'seconds': 120},
      {'label': '3 Dk', 'seconds': 180},
      {'label': '5 Dk', 'seconds': 300},
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.white.withValues(alpha: 0.08)
                                  : Colors.black.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.timer_outlined,
                              color: AppColors.accent,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Raund Süresi Ayarla',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Hızlı Seçenekler',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white54 : Colors.black54,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: presetDurations.map((item) {
                          final secs = item['seconds'] as int;
                          final isSelected = _roundDurationSec == secs;
                          return ChoiceChip(
                            label: Text(item['label'] as String),
                            selected: isSelected,
                            selectedColor: AppColors.accent,
                            backgroundColor: isDark
                                ? Colors.white.withValues(alpha: 0.06)
                                : Colors.black.withValues(alpha: 0.04),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setDialogState(() {
                                  _setCustomRoundDuration(secs);
                                  minController.text = (secs ~/ 60).toString();
                                  secController.text = (secs % 60).toString();
                                });
                                Navigator.pop(ctx);
                              }
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Özel Süre Belirle',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white54 : Colors.black54,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: minController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Dakika',
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white60
                                      : Colors.black54,
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.03),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            ':',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: secController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.black87,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Saniye',
                                labelStyle: TextStyle(
                                  fontSize: 12,
                                  color: isDark
                                      ? Colors.white60
                                      : Colors.black54,
                                ),
                                filled: true,
                                fillColor: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.03),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: Text(
                                'İptal',
                                style: TextStyle(
                                  color: isDark
                                      ? Colors.white60
                                      : Colors.black54,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                final mins =
                                    int.tryParse(minController.text.trim()) ??
                                    0;
                                final secs =
                                    int.tryParse(secController.text.trim()) ??
                                    0;
                                final totalSecs = (mins * 60) + secs;
                                if (totalSecs > 0) {
                                  _setCustomRoundDuration(totalSecs);
                                  Navigator.pop(ctx);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Kaydet',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MainScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: isDark
                ? AppGradients.taekwondoDark
                : AppGradients.taekwondo,
          ),
        ),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.sports_martial_arts, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'TAEKWONDO SKOR',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Maçı Sıfırla',
            onPressed: _resetMatch,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [const Color(0xFF0D0D11), const Color(0xFF16161D)]
                : [const Color(0xFFF4F6FA), Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildTimerSection(isDark),
              const SizedBox(height: 20),
              _buildScoreboard(isDark),
              const SizedBox(height: 20),
              _buildScoringButtons(isDark),
              const SizedBox(height: 20),
              _buildPenaltySection(isDark),
              const SizedBox(height: 20),
              _buildControlButtons(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerSection(bool isDark) {
    final isPaused =
        !_isRunning &&
        _remainingMs < (_roundDurationSec * 1000) &&
        _remainingMs > 0;
    final isUnderOneMinute = _remainingMs < 60000;
    final isCriticalTime = _remainingMs <= 10000 && _isRunning;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tur Rozeti
              Row(
                children: [
                  Text(
                    'RAUND',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: isDark ? Colors.white54 : Colors.black45,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? AppGradients.taekwondoDark
                          : AppGradients.taekwondo,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_currentRound',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              // Raund Süresi Ayarlama Butonu
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showDurationSettingsDialog(context, isDark),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.07)
                          : Colors.black.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.1)
                            : Colors.black.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          _formatRoundBadgeTime(_roundDurationSec),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.edit_outlined,
                          size: 12,
                          color: isDark ? Colors.white38 : Colors.black38,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Süre Sayacı (1 dk altı ise SS.cs, üstü ise MM:SS)
          GestureDetector(
            onTap: () => _showDurationSettingsDialog(context, isDark),
            child: Column(
              children: [
                Text(
                  _formatDisplayTime(_remainingMs),
                  style: TextStyle(
                    fontSize: isUnderOneMinute ? 54 : 50,
                    fontWeight: FontWeight.w200,
                    fontFamily: 'monospace',
                    color: isCriticalTime
                        ? const Color(0xFFFF5252)
                        : (isDark ? Colors.white : Colors.black87),
                    letterSpacing: isUnderOneMinute ? 2 : 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Başlat / Duraklat Butonları
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!_isRunning) ...[
                // Süre çalışmıyorken: Tek BAŞLAT / DEVAM ET Butonu
                Expanded(
                  child: _buildTimerButton(
                    icon: Icons.play_arrow_rounded,
                    label: isPaused ? 'DEVAM ET' : 'BAŞLAT',
                    onTap: _startTimer,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                    ),
                  ),
                ),
                if (isPaused) ...[
                  const SizedBox(width: 10),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _resetTimer,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.08)
                              : Colors.black.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.replay_rounded,
                          size: 22,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ] else ...[
                // Süre çalışıyorken: Tek DURAKLAT Butonu
                Expanded(
                  child: _buildTimerButton(
                    icon: Icons.pause_rounded,
                    label: 'DURAKLAT',
                    onTap: _pauseTimer,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9900), Color(0xFFFF5E62)],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required LinearGradient gradient,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreboard(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _buildPlayerCard(
            isDark: isDark,
            playerName: 'CHUNG',
            score: _chungScore,
            penalties: _chungPenalties,
            isBlue: true,
          ),
        ),
        const SizedBox(width: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? const Color(0xFF2D2D3D) : const Color(0xFFE0E0E0),
          ),
          child: Text(
            'VS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white54 : Colors.black45,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildPlayerCard(
            isDark: isDark,
            playerName: 'HONG',
            score: _hongScore,
            penalties: _hongPenalties,
            isBlue: false,
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerCard({
    required bool isDark,
    required String playerName,
    required int score,
    required int penalties,
    required bool isBlue,
  }) {
    final gradient = isBlue
        ? const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF0D47A1)])
        : const LinearGradient(colors: [Color(0xFFC62828), Color(0xFFB71C1C)]);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            playerName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$score',
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w200,
              color: Colors.white,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'CEZA: $penalties',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoringButtons(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'PUAN EKLE / ÇIKAR',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white54 : Colors.black45,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'CHUNG',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1565C0),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildScoreButton(
                          '+1',
                          () => _addScore(true, 1),
                          const Color(0xFF1565C0),
                        ),
                        const SizedBox(width: 6),
                        _buildScoreButton(
                          '+2',
                          () => _addScore(true, 2),
                          const Color(0xFF1565C0),
                        ),
                        const SizedBox(width: 6),
                        _buildScoreButton(
                          '+3',
                          () => _addScore(true, 3),
                          const Color(0xFF1565C0),
                        ),
                        const SizedBox(width: 6),
                        _buildScoreButton(
                          '-1',
                          () => _subtractScore(true, 1),
                          Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'HONG',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC62828),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildScoreButton(
                          '+1',
                          () => _addScore(false, 1),
                          const Color(0xFFC62828),
                        ),
                        const SizedBox(width: 6),
                        _buildScoreButton(
                          '+2',
                          () => _addScore(false, 2),
                          const Color(0xFFC62828),
                        ),
                        const SizedBox(width: 6),
                        _buildScoreButton(
                          '+3',
                          () => _addScore(false, 3),
                          const Color(0xFFC62828),
                        ),
                        const SizedBox(width: 6),
                        _buildScoreButton(
                          '-1',
                          () => _subtractScore(false, 1),
                          Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreButton(String label, VoidCallback onTap, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 38,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPenaltySection(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E24) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'CEZA (GAM-JEOM)',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white54 : Colors.black45,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildPenaltyButton(
                        label: 'CHUNG CEZA',
                        onTap: () => _addPenalty(true),
                        color: const Color(0xFF1565C0),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      color: isDark ? Colors.white54 : Colors.black45,
                      tooltip: 'Cezayı Geri Al',
                      onPressed: () => _removePenalty(true),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: _buildPenaltyButton(
                        label: 'HONG CEZA',
                        onTap: () => _addPenalty(false),
                        color: const Color(0xFFC62828),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      color: isDark ? Colors.white54 : Colors.black45,
                      tooltip: 'Cezayı Geri Al',
                      onPressed: () => _removePenalty(false),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPenaltyButton({
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _resetMatch,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.1),
                  ),
                ),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.refresh, size: 18, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'SIFIRLA',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _nextRound,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? AppGradients.taekwondoDark
                      : AppGradients.taekwondo,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.skip_next, size: 18, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'RAUND',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
