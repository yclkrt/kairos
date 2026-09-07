import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  int _matchTime = 180;
  bool _isRunning = false;

  void _addScore(bool isChung, int points) {
    setState(() {
      if (isChung) {
        _chungScore += points;
      } else {
        _hongScore += points;
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

  void _resetMatch() {
    setState(() {
      _chungScore = 0;
      _hongScore = 0;
      _chungPenalties = 0;
      _hongPenalties = 0;
      _currentRound = 1;
      _matchTime = 180;
      _isRunning = false;
    });
  }

  void _nextRound() {
    setState(() {
      _currentRound++;
      _matchTime = 180;
      _isRunning = false;
    });
  }

  String _formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'TUR',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                  color: isDark ? Colors.white54 : Colors.black45,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  gradient: isDark
                      ? AppGradients.taekwondoDark
                      : AppGradients.taekwondo,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_currentRound',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _formatTime(_matchTime),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w200,
              fontFamily: 'monospace',
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimerButton(
                icon: Icons.play_arrow,
                label: 'BAŞLAT',
                onTap: () => setState(() => _isRunning = true),
                gradient: isDark
                    ? AppGradients.trainingPlansDark
                    : AppGradients.trainingPlans,
              ),
              const SizedBox(width: 12),
              _buildTimerButton(
                icon: Icons.pause,
                label: 'DURDUR',
                onTap: () => setState(() => _isRunning = false),
                gradient: isDark
                    ? AppGradients.trainingScheduleDark
                    : AppGradients.trainingSchedule,
              ),
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 1,
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
        ? const LinearGradient(
            colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
          )
        : const LinearGradient(
            colors: [Color(0xFFC62828), Color(0xFFB71C1C)],
          );

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
            'PUAN EKLE',
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
                        _buildScoreButton('1', () => _addScore(true, 1),
                            const Color(0xFF1565C0)),
                        const SizedBox(width: 8),
                        _buildScoreButton('2', () => _addScore(true, 2),
                            const Color(0xFF1565C0)),
                        const SizedBox(width: 8),
                        _buildScoreButton('3', () => _addScore(true, 3),
                            const Color(0xFF1565C0)),
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
                        _buildScoreButton('1', () => _addScore(false, 1),
                            const Color(0xFFC62828)),
                        const SizedBox(width: 8),
                        _buildScoreButton('2', () => _addScore(false, 2),
                            const Color(0xFFC62828)),
                        const SizedBox(width: 8),
                        _buildScoreButton('3', () => _addScore(false, 3),
                            const Color(0xFFC62828)),
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
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18,
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
                child: _buildPenaltyButton(
                  label: 'CHUNG CEZA',
                  onTap: () => _addPenalty(true),
                  color: const Color(0xFF1565C0),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildPenaltyButton(
                  label: 'HONG CEZA',
                  onTap: () => _addPenalty(false),
                  color: const Color(0xFFC62828),
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
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
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
                        'SONRAKI TUR',
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
