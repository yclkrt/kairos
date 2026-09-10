import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sporlab/core/theme/app_colors.dart';
import 'package:sporlab/core/theme/app_gradients.dart';
import 'package:sporlab/core/widgets/main_scaffold.dart';

enum MatchPhase {
  fighting, // Normal raunt devam ediyor veya başlatılmayı bekliyor
  announcingWinner, // Raunt kazananı ekranda gösteriliyor (3 saniye)
  restTime, // 1 dakikalık dinlenme süresi geriye sayıyor
  matchOver, // Maç tamamlandı
}

class TaekwondoScoreboardPage extends ConsumerStatefulWidget {
  const TaekwondoScoreboardPage({super.key});

  @override
  ConsumerState<TaekwondoScoreboardPage> createState() =>
      _TaekwondoScoreboardPageState();
}

class _TaekwondoScoreboardPageState
    extends ConsumerState<TaekwondoScoreboardPage> {
  // Best of 3 Raunt Takibi
  int _chungRoundsWon = 0;
  int _hongRoundsWon = 0;
  int _currentRound = 1;

  // Raunt İçi Puanlar ve Cezalar (Her rauntta sıfırlanır)
  int _chungScore = 0;
  int _hongScore = 0;
  int _chungPenalties = 0;
  int _hongPenalties = 0;

  // Süre Yönetimi
  int _roundDurationSec = 120; // Varsayılan 2 dakika (120 sn)
  int _remainingMs = 120 * 1000;
  bool _isRunning = false;
  Timer? _timer;
  DateTime? _lastTickTime;

  // Mola / Dinlenme Yönetimi (1 Dakika)
  MatchPhase _phase = MatchPhase.fighting;
  int _restRemainingMs = 60 * 1000;
  Timer? _restTimer;
  Timer? _announcementTimer;

  String _lastRoundWinnerName = '';
  Color _lastRoundWinnerColor = Colors.blue;
  String _lastRoundReason = '';
  String _lastRoundBadge = '';

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    _announcementTimer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_phase != MatchPhase.fighting) return;

    if (_remainingMs <= 0) {
      setState(() {
        _remainingMs = _roundDurationSec * 1000;
      });
    }

    _timer?.cancel();
    _lastTickTime = DateTime.now();

    // 40ms (~25fps) aralıklarla hassas milisaniye sayımı
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
        _handleTimeOut();
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

  /// Puan Ekle
  void _addScore(bool isChung, int points) {
    if (_phase != MatchPhase.fighting) return;

    setState(() {
      if (isChung) {
        _chungScore += points;
      } else {
        _hongScore += points;
      }
    });

    _checkAutomaticRoundEnd();
  }

  /// Puan Çıkar (Hatalı giriş düzeltme)
  void _subtractScore(bool isChung, int points) {
    if (_phase != MatchPhase.fighting) return;

    setState(() {
      if (isChung) {
        _chungScore = (_chungScore - points).clamp(0, 999);
      } else {
        _hongScore = (_hongScore - points).clamp(0, 999);
      }
    });
  }

  /// Ceza (Gam-jeom) Ekle (+1 puan rakibe verilir)
  void _addPenalty(bool isChung) {
    if (_phase != MatchPhase.fighting) return;

    setState(() {
      if (isChung) {
        _chungPenalties++;
        _hongScore += 1;
      } else {
        _hongPenalties++;
        _chungScore += 1;
      }
    });

    _checkAutomaticRoundEnd();
  }

  /// Ceza Geri Al
  void _removePenalty(bool isChung) {
    if (_phase != MatchPhase.fighting) return;

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

  /// Otomatik Raunt Bitiş Kuralları Kontrolü (12 Puan Farkı veya 5 Ceza)
  void _checkAutomaticRoundEnd() {
    if (_phase != MatchPhase.fighting) return;

    // 1. Kural: 5 Ceza (Gam-jeom) Kuralı
    if (_chungPenalties >= 5) {
      _endRound(
        winnerIsChung: false,
        reason: 'Chung 5 Ceza Aldı (Gam-jeom Sınırı)',
        badge: '5 CEZA',
      );
      return;
    }
    if (_hongPenalties >= 5) {
      _endRound(
        winnerIsChung: true,
        reason: 'Hong 5 Ceza Aldı (Gam-jeom Sınırı)',
        badge: '5 CEZA',
      );
      return;
    }

    // 2. Kural: 12 Puan Farkı Kuralı (Point Gap - PTG)
    if (_chungScore - _hongScore >= 12) {
      _endRound(
        winnerIsChung: true,
        reason: '12 Puan Farkı Üstünlüğü ($_chungScore - $_hongScore)',
        badge: '12 PUAN FARKI (PTG)',
      );
      return;
    }
    if (_hongScore - _chungScore >= 12) {
      _endRound(
        winnerIsChung: false,
        reason: '12 Puan Farkı Üstünlüğü ($_hongScore - $_chungScore)',
        badge: '12 PUAN FARKI (PTG)',
      );
      return;
    }
  }

  /// Süre Bittiğinde Kazananı Belirle
  void _handleTimeOut() {
    HapticFeedback.heavyImpact();

    if (_chungScore > _hongScore) {
      _endRound(
        winnerIsChung: true,
        reason: 'Süre Bitimi Puan Üstünlüğü ($_chungScore - $_hongScore)',
        badge: 'SÜRE BİTİMİ',
      );
    } else if (_hongScore > _chungScore) {
      _endRound(
        winnerIsChung: false,
        reason: 'Süre Bitimi Puan Üstünlüğü ($_hongScore - $_chungScore)',
        badge: 'SÜRE BİTİMİ',
      );
    } else {
      // Puanlar eşitse: Beraberlik Çözümü Dialogu
      _showTieBreakerDialog();
    }
  }

  /// Beraberlik Durumunda Hakem Kararı / Üstünlük Seçimi
  void _showTieBreakerDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.balance, color: AppColors.warning),
            SizedBox(width: 10),
            Text('Raunt Berabere Bitti'),
          ],
        ),
        content: Text(
          'Puanlar eşit ($_chungScore - $_hongScore).\nTaekwondo kurallarına göre teknik üstünlük sağlayan tarafı seçiniz:',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _endRound(
                winnerIsChung: true,
                reason: 'Teknik Üstünlük / Hakem Kararı',
                badge: 'BERABERLİK ÇÖZÜMÜ',
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1565C0),
            ),
            child: const Text(
              'CHUNG KAZANDI',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _endRound(
                winnerIsChung: false,
                reason: 'Teknik Üstünlük / Hakem Kararı',
                badge: 'BERABERLİK ÇÖZÜMÜ',
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFC62828),
            ),
            child: const Text(
              'HONG KAZANDI',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Raundu Sonlandır, Kazananı Göster ve 1 Dakikalık Dinlenme Süresini Başlat
  void _endRound({
    required bool winnerIsChung,
    required String reason,
    required String badge,
  }) {
    _pauseTimer();
    HapticFeedback.vibrate();

    int newChungWins = _chungRoundsWon;
    int newHongWins = _hongRoundsWon;

    if (winnerIsChung) {
      newChungWins++;
    } else {
      newHongWins++;
    }

    final winnerName = winnerIsChung ? 'CHUNG (MAVİ)' : 'HONG (KIRMIZI)';
    final winnerColor = winnerIsChung
        ? const Color(0xFF1565C0)
        : const Color(0xFFC62828);

    setState(() {
      _chungRoundsWon = newChungWins;
      _hongRoundsWon = newHongWins;
      _lastRoundWinnerName = winnerName;
      _lastRoundWinnerColor = winnerColor;
      _lastRoundReason = reason;
      _lastRoundBadge = badge;
    });

    // Maç Bitti mi? (2 Raunt Kazanan Şampiyon Olur)
    final matchWon = newChungWins >= 2 || newHongWins >= 2;

    if (matchWon) {
      setState(() {
        _phase = MatchPhase.matchOver;
      });
      _showMatchWinnerDialog(
        winnerName: winnerName,
        winnerColor: winnerColor,
        reason: reason,
        finalScore: '$newChungWins - $newHongWins',
      );
    } else {
      // 1. Adım: Kazananı 3.5 saniye göster
      setState(() {
        _phase = MatchPhase.announcingWinner;
      });

      _announcementTimer?.cancel();
      _announcementTimer = Timer(const Duration(milliseconds: 5000), () {
        if (!mounted) return;
        _startRestTimer();
      });
    }
  }

  /// 1 Dakikalık Dinlenme / Mola Süresini Başlat
  void _startRestTimer() {
    _restTimer?.cancel();
    setState(() {
      _phase = MatchPhase.restTime;
      _restRemainingMs = 60 * 1000; // 1 Dakika (60 saniye)
    });

    _lastTickTime = DateTime.now();

    _restTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      final elapsed = now.difference(_lastTickTime!).inMilliseconds;
      _lastTickTime = now;

      if (_restRemainingMs > elapsed) {
        setState(() {
          _restRemainingMs -= elapsed;
        });
      } else {
        timer.cancel();
        _autoPrepareNextRound();
      }
    });
  }

  /// Dinlenme Süresi Bitince Sonraki Raundu Otomatik Hazırla
  void _autoPrepareNextRound() {
    _restTimer?.cancel();
    HapticFeedback.heavyImpact();

    setState(() {
      _currentRound++;
      _chungScore = 0;
      _hongScore = 0;
      _chungPenalties = 0;
      _hongPenalties = 0;
      _remainingMs = _roundDurationSec * 1000;
      _isRunning = false;
      _phase = MatchPhase.fighting;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '$_currentRound. Raunt Başlamaya Hazır!',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.accent,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Maç Kazananı Kutlama Dialogu
  void _showMatchWinnerDialog({
    required String winnerName,
    required Color winnerColor,
    required String reason,
    required String finalScore,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: isDark ? const Color(0xFF1E1E24) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: winnerColor.withValues(alpha: 0.15),
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    size: 48,
                    color: winnerColor,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'MAÇ ŞAMPİYONU',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 3,
                    color: AppColors.warning,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  winnerName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: winnerColor,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Raunt Skoru: $finalScore',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  reason,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _resetMatch();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: winnerColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'YENİ MAÇ BAŞLAT',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Tüm Maçı Sıfırla
  void _resetMatch() {
    _pauseTimer();
    _restTimer?.cancel();
    _announcementTimer?.cancel();
    setState(() {
      _chungRoundsWon = 0;
      _hongRoundsWon = 0;
      _currentRound = 1;
      _chungScore = 0;
      _hongScore = 0;
      _chungPenalties = 0;
      _hongPenalties = 0;
      _remainingMs = _roundDurationSec * 1000;
      _isRunning = false;
      _phase = MatchPhase.fighting;
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
    if (_phase != MatchPhase.fighting) return;

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
              const SizedBox(height: 16),
              _buildScoreboard(isDark),
              const SizedBox(height: 16),
              _buildScoringButtons(isDark),
              const SizedBox(height: 16),
              _buildPenaltySection(isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimerSection(bool isDark) {
    // 1. Durum: Raunt Kazananı Duyuru Alanı (3.5 Saniye)
    if (_phase == MatchPhase.announcingWinner) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E24) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _lastRoundWinnerColor.withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _lastRoundWinnerColor.withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _lastRoundWinnerColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_currentRound. RAUND BİTTİ ($_lastRoundBadge)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: _lastRoundWinnerColor,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'RAUND KAZANANI',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
                color: isDark ? Colors.white54 : Colors.black45,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _lastRoundWinnerName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: _lastRoundWinnerColor,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _lastRoundReason,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  '1 Dk Dinlenme Süresi Başlıyor...',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    // 2. Durum: 1 Dakikalık Dinlenme / Mola Süresi
    if (_phase == MatchPhase.restTime) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E24) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF11998E).withValues(alpha: 0.4),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF11998E).withValues(alpha: 0.2),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF11998E), Color(0xFF38EF7D)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'DİNLENME ARASI (MOLA)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
                // Dinlenmeyi Atla Butonu
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _autoPrepareNextRound,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Molayı Geç',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.skip_next, size: 14),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _formatDisplayTime(_restRemainingMs),
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w200,
                fontFamily: 'monospace',
                color: _restRemainingMs <= 10000
                    ? const Color(0xFFFF5252)
                    : const Color(0xFF38EF7D),
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_currentRound + 1}. Raunt otomatik başlayacak',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      );
    }

    // 3. Durum: Normal Raunt / Dövüş Ekranı
    final isPaused =
        !_isRunning &&
        _remainingMs < (_roundDurationSec * 1000) &&
        _remainingMs > 0;
    final isUnderOneMinute = _remainingMs < 60000;
    final isCriticalTime = _remainingMs <= 10000 && _isRunning;

    return Container(
      padding: const EdgeInsets.all(18),
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
              // Raund Rozeti ve Best of 3 Durumu
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? AppGradients.taekwondoDark
                          : AppGradients.taekwondo,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'RAUND $_currentRound/3',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 1,
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
          const SizedBox(height: 12),

          // Süre Sayacı (1 dk altı ise SS.cs, üstü ise MM:SS)
          GestureDetector(
            onTap: () => _showDurationSettingsDialog(context, isDark),
            child: Column(
              children: [
                Text(
                  _formatDisplayTime(_remainingMs),
                  style: TextStyle(
                    fontSize: isUnderOneMinute ? 54 : 48,
                    fontWeight: FontWeight.w200,
                    fontFamily: 'monospace',
                    color: isCriticalTime
                        ? const Color(0xFFFF5252)
                        : (isDark ? Colors.white : Colors.black87),
                    letterSpacing: isUnderOneMinute ? 2 : 4,
                  ),
                ),
                if (isUnderOneMinute)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      'SANİYE . SALİSE',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: isCriticalTime
                            ? const Color(0xFFFF5252).withValues(alpha: 0.8)
                            : (isDark ? Colors.white38 : Colors.black38),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 14),

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
            roundsWon: _chungRoundsWon,
            isBlue: true,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF2D2D3D)
                    : const Color(0xFFE0E0E0),
              ),
              child: Text(
                'VS',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'BEST OF 3',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPlayerCard(
            isDark: isDark,
            playerName: 'HONG',
            score: _hongScore,
            penalties: _hongPenalties,
            roundsWon: _hongRoundsWon,
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
    required int roundsWon,
    required bool isBlue,
  }) {
    final gradient = isBlue
        ? const LinearGradient(colors: [Color(0xFF1565C0), Color(0xFF0D47A1)])
        : const LinearGradient(colors: [Color(0xFFC62828), Color(0xFFB71C1C)]);

    return Container(
      padding: const EdgeInsets.all(14),
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
          // Oyuncu Adı
          Text(
            playerName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 6),

          // Kazanılan Raunt Noktaları (Best of 3 Takibi)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildRoundDot(filled: roundsWon >= 1),
              const SizedBox(width: 6),
              _buildRoundDot(filled: roundsWon >= 2),
            ],
          ),
          const SizedBox(height: 8),

          // Canlı Puan
          Text(
            '$score',
            style: const TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w200,
              color: Colors.white,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 6),

          // Ceza Durumu (5 Ceza Sınırı)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: penalties >= 4
                  ? Colors.red.shade900.withValues(alpha: 0.8)
                  : Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: penalties >= 4
                  ? Border.all(color: Colors.yellowAccent, width: 1.5)
                  : null,
            ),
            child: Text(
              'CEZA: $penalties / 5',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: penalties >= 4 ? Colors.yellowAccent : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundDot({required bool filled}) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled
            ? Colors.amberAccent
            : Colors.white.withValues(alpha: 0.25),
        border: Border.all(
          color: filled ? Colors.amber : Colors.white.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: filled
            ? [
                BoxShadow(
                  color: Colors.amberAccent.withValues(alpha: 0.8),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }

  Widget _buildScoringButtons(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(14),
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
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white54 : Colors.black45,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    const Text(
                      'CHUNG',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1565C0),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildScoreButton(
                          '+1',
                          () => _addScore(true, 1),
                          const Color(0xFF1565C0),
                        ),
                        const SizedBox(width: 4),
                        _buildScoreButton(
                          '+2',
                          () => _addScore(true, 2),
                          const Color(0xFF1565C0),
                        ),
                        const SizedBox(width: 4),
                        _buildScoreButton(
                          '+3',
                          () => _addScore(true, 3),
                          const Color(0xFF1565C0),
                        ),
                        const SizedBox(width: 4),
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
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC62828),
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildScoreButton(
                          '+1',
                          () => _addScore(false, 1),
                          const Color(0xFFC62828),
                        ),
                        const SizedBox(width: 4),
                        _buildScoreButton(
                          '+2',
                          () => _addScore(false, 2),
                          const Color(0xFFC62828),
                        ),
                        const SizedBox(width: 4),
                        _buildScoreButton(
                          '+3',
                          () => _addScore(false, 3),
                          const Color(0xFFC62828),
                        ),
                        const SizedBox(width: 4),
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
                fontSize: 13,
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
      padding: const EdgeInsets.all(14),
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'CEZA (GAM-JEOM)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white54 : Colors.black45,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
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
}
