import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kairos/core/theme/app_colors.dart';
import 'package:kairos/core/widgets/main_scaffold.dart';
import 'package:kairos/features/stopwatch/providers/stopwatch_provider.dart';
import 'package:kairos/features/stopwatch/widgets/stopwatch_buttons.dart';
import 'package:kairos/features/stopwatch/widgets/stopwatch_display.dart';

class StopwatchPage extends ConsumerStatefulWidget {
  const StopwatchPage({super.key});

  @override
  ConsumerState<StopwatchPage> createState() => _StopwatchPageState();
}

class _StopwatchPageState extends ConsumerState<StopwatchPage>
    with TickerProviderStateMixin {
  late AnimationController _lapAnimController;

  @override
  void initState() {
    super.initState();
    _lapAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _lapAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(timerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MainScaffold(
      appBar: AppBar(
        title: const Text(
          'KRONOMETRE',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            fontSize: 16,
          ),
        ),
        backgroundColor: Color(0xFFF0F0F0),
        elevation: 0,
        actions: [
          // Tur sayisi gosterimi
          if (timerState.laps.isNotEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE84C3D).withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  '${timerState.laps.length} TUR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white70 : Colors.black54,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0A0A0A),
                    const Color(0xFF1A1A1A),
                    const Color(0xFF0D0D0D),
                  ]
                : [
                    const Color(0xFFF0F0F0),
                    const Color(0xFFE8E8E8),
                    Colors.white,
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // ===== ZAMAN GOSTERGESI =====
              StopWatchDisplay(
                time: timerState.displayTime,
                isRunning: timerState.isRunning,
                isPaused: timerState.isPaused,
              ),

              const SizedBox(height: 28),

              // ===== KONTROL BUTONLARI =====
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Ana kontroller
                    StopWatchButtons(
                      isRunning: timerState.isRunning,
                      isPaused: timerState.isPaused,
                    ),

                    // TUR BUTONU (sadece calisirken)
                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: timerState.isRunning && !timerState.isPaused
                          ? Padding(
                              padding: const EdgeInsets.only(top: 16),
                              child: _buildLapButton(isDark),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ===== TUR LISTESI =====
              if (timerState.laps.isNotEmpty)
                Expanded(child: _buildLapList(timerState.laps, isDark)),

              // ===== ALT BILGI =====
              if (timerState.laps.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: _buildFooter(isDark),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLapButton(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE84C3D).withValues(alpha: 0.6),
          width: 1.5,
        ),
        color: isDark
            ? const Color(0xFFE84C3D).withValues(alpha: 0.1)
            : const Color(0xFFE84C3D).withValues(alpha: 0.05),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ref.read(timerProvider.notifier).addLap();
            _lapAnimController.forward().then((_) {
              _lapAnimController.reverse();
            });
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.flag_rounded,
                  color: const Color(0xFFE84C3D),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'TUR EKLE',
                  style: TextStyle(
                    color: Color(0xFFE84C3D),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLapList(List<LapData> laps, bool isDark) {
    return Column(
      children: [
        // Baslik
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: const Color(0xFFE84C3D),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'TURLAR',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white54 : Colors.black45,
                  letterSpacing: 2,
                ),
              ),
              const Spacer(),
              // En iyi ve en kotu tur gostergesi
              if (laps.length > 1) ...[
                _buildLapStat(
                  'EN İYİ',
                  _getBestLap(laps),
                  const Color(0xFF00E676),
                  isDark,
                ),
                const SizedBox(width: 12),
                _buildLapStat(
                  'EN KÖTÜ',
                  _getWorstLap(laps),
                  const Color(0xFFFF5252),
                  isDark,
                ),
              ],
            ],
          ),
        ),

        // Liste
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: laps.length,
            reverse: true,
            itemBuilder: (context, index) {
              final lap = laps[laps.length - 1 - index];
              final lapNumber = laps.length - index;

              return _buildLapItem(lap, lapNumber, laps, isDark);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLapItem(
    LapData lap,
    int displayNumber,
    List<LapData> allLaps,
    bool isDark,
  ) {
    final isBest =
        allLaps.length > 1 && lap.lapMilliseconds == _getBestLapMs(allLaps);
    final isWorst =
        allLaps.length > 1 && lap.lapMilliseconds == _getWorstLapMs(allLaps);

    final accentColor = isBest
        ? const Color(0xFF00E676)
        : isWorst
        ? const Color(0xFFFF5252)
        : (isDark ? Colors.white24 : Colors.black12);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: isDark
            ? Colors.white.withValues(alpha: 0.04)
            : Colors.black.withValues(alpha: 0.02),
        border: Border.all(
          color: isBest || isWorst
              ? accentColor.withValues(alpha: 0.5)
              : accentColor,
          width: isBest || isWorst ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Tur numarasi
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accentColor.withValues(alpha: 0.15),
              ),
              child: Center(
                child: Text(
                  '${lap.lapNumber}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isBest
                        ? const Color(0xFF00E676)
                        : isWorst
                        ? const Color(0xFFFF5252)
                        : (isDark ? Colors.white54 : Colors.black54),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Tur suresi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tur Süresi',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white30 : Colors.black38,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lap.formattedLap,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      fontFamily: 'monospace',
                      color: isBest
                          ? const Color(0xFF00E676)
                          : isWorst
                          ? const Color(0xFFFF5252)
                          : (isDark ? Colors.white70 : Colors.black87),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),

            // Toplam sure
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Toplam',
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark ? Colors.white30 : Colors.black38,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  lap.formattedTotal,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    fontFamily: 'monospace',
                    color: isDark ? Colors.white38 : Colors.black38,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLapStat(String label, LapData? lap, Color color, bool isDark) {
    if (lap == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withValues(alpha: 0.1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            lap.formattedLap,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              fontFamily: 'monospace',
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  LapData? _getBestLap(List<LapData> laps) {
    if (laps.isEmpty) return null;
    return laps.reduce((a, b) => a.lapMilliseconds < b.lapMilliseconds ? a : b);
  }

  LapData? _getWorstLap(List<LapData> laps) {
    if (laps.isEmpty) return null;
    return laps.reduce((a, b) => a.lapMilliseconds > b.lapMilliseconds ? a : b);
  }

  int _getBestLapMs(List<LapData> laps) {
    return _getBestLap(laps)?.lapMilliseconds ?? 0;
  }

  int _getWorstLapMs(List<LapData> laps) {
    return _getWorstLap(laps)?.lapMilliseconds ?? 0;
  }

  Widget _buildFooter(bool isDark) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.08),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _getCurrentDateTime(),
          style: TextStyle(
            fontSize: 10,
            color: isDark ? Colors.white24 : Colors.black26,
            letterSpacing: 1,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _getCurrentDateTime() {
    final now = DateTime.now();
    final day = now.day.toString().padLeft(2, '0');
    final month = now.month.toString().padLeft(2, '0');
    final year = now.year;
    return '$day/$month/$year';
  }
}
