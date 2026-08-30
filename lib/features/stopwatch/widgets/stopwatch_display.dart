import 'package:flutter/material.dart';
import 'dart:math' as math;

class StopWatchDisplay extends StatelessWidget {
  final String time;
  final bool isRunning;
  final bool isPaused;

  const StopWatchDisplay({
    super.key,
    required this.time,
    required this.isRunning,
    this.isPaused = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryColor = isRunning
        ? const Color(0xFF00E676)
        : isPaused
            ? const Color(0xFFFFAB00)
            : const Color(0xFFE84C3D);

    return Container(
      width: 310,
      height: 310,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: isRunning
            ? [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.4),
                  blurRadius: 50,
                  spreadRadius: 15,
                ),
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.15),
                  blurRadius: 100,
                  spreadRadius: 30,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 25,
                  spreadRadius: 5,
                  offset: const Offset(0, 10),
                ),
              ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dis halka - glow
          Container(
            width: 310,
            height: 310,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  primaryColor.withValues(alpha: 0.0),
                  primaryColor.withValues(alpha: 0.1),
                  primaryColor.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),

          // Ana daire
          Container(
            width: 295,
            height: 295,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.3, -0.3),
                colors: isDark
                    ? [
                        const Color(0xFF3A3A3A),
                        const Color(0xFF1E1E1E),
                        const Color(0xFF121212),
                      ]
                    : [
                        Colors.white,
                        const Color(0xFFE8E8E8),
                        const Color(0xFFD0D0D0),
                      ],
              ),
            ),
          ),

          // Progress Ring
          SizedBox(
            width: 285,
            height: 285,
            child: CustomPaint(
              painter: _ProgressRingPainter(
                progress: _getProgress(time),
                color: primaryColor,
                isRunning: isRunning,
                trackColor: isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.grey.withValues(alpha: 0.15),
              ),
            ),
          ),

          // ic daire - glass effect
          Container(
            width: 255,
            height: 255,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? const Color(0xFF1A1A1A).withValues(alpha: 0.9)
                  : const Color(0xFFFAFAFA).withValues(alpha: 0.9),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.white.withValues(alpha: 0.8),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 5,
                  offset: const Offset(0, 5),
                ),
                BoxShadow(
                  color: Colors.white.withValues(alpha: isDark ? 0.02 : 0.5),
                  blurRadius: 10,
                  spreadRadius: -5,
                  offset: const Offset(-5, -5),
                ),
              ],
            ),
          ),

          // Zaman gosterisi
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Dekoratif ust cizgi
              Container(
                width: 40,
                height: 2,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(1),
                  gradient: LinearGradient(
                    colors: [
                      primaryColor.withValues(alpha: 0.0),
                      primaryColor,
                      primaryColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),

              // Dakika:Saniye
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 100),
                style: TextStyle(
                  fontSize: 52,
                  fontWeight: FontWeight.w200,
                  fontFamily: 'monospace',
                  color: primaryColor,
                  letterSpacing: 3,
                  height: 1.0,
                  shadows: isRunning
                      ? [
                          Shadow(
                            color: primaryColor.withValues(alpha: 0.6),
                            blurRadius: 15,
                          ),
                          Shadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 30,
                          ),
                        ]
                      : null,
                ),
                child: Text(_mainTime(time)),
              ),

              // Milisaniye
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 50),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'monospace',
                  color: primaryColor.withValues(alpha: 0.7),
                  letterSpacing: 4,
                  shadows: isRunning
                      ? [
                          Shadow(
                            color: primaryColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: Text(_msTime(time)),
              ),

              const SizedBox(height: 12),

              // Animasyonlu noktalar
              if (isRunning) _buildPulseDots(primaryColor),

              if (!isRunning && !isPaused)
                Text(
                  'HAZIR',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: primaryColor.withValues(alpha: 0.5),
                    letterSpacing: 4,
                  ),
                ),

              if (isPaused)
                Text(
                  'DURAKLATILDI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: primaryColor.withValues(alpha: 0.7),
                    letterSpacing: 3,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPulseDots(Color color) {
    return SizedBox(
      height: 16,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.3, end: 1.0),
            duration: Duration(milliseconds: 600 + (index * 200)),
            builder: (context, value, child) {
              return AnimatedOpacity(
                opacity: isRunning ? value : 0.3,
                duration: Duration(milliseconds: 300 + (index * 100)),
                child: Container(
                  width: 4,
                  height: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  String _mainTime(String time) {
    // "00:00.00" -> "00:00"
    final parts = time.split('.');
    return parts.isNotEmpty ? parts[0] : '00:00';
  }

  String _msTime(String time) {
    // "00:00.00" -> ".00"
    final parts = time.split('.');
    return parts.length > 1 ? '.${parts[1]}' : '.00';
  }

  double _getProgress(String time) {
    try {
      final parts = time.split(':');
      final secondsPart = parts[1].split('.');
      final minutes = int.parse(parts[0]);
      final seconds = int.parse(secondsPart[0]);
      final totalSeconds = minutes * 60 + seconds;
      return (totalSeconds % 60) / 60;
    } catch (_) {
      return 0.0;
    }
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final bool isRunning;
  final Color trackColor;

  _ProgressRingPainter({
    required this.progress,
    required this.color,
    required this.isRunning,
    required this.trackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Track
    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Tick marks (dakika ișaretleri)
    for (int i = 0; i < 60; i++) {
      final angle = (i * 6 - 90) * math.pi / 180;
      final isMajor = i % 5 == 0;
      final innerRadius = radius - (isMajor ? 12 : 6);
      final outerRadius = radius - 2;

      final tickPaint = Paint()
        ..color = isMajor
            ? color.withValues(alpha: 0.3)
            : color.withValues(alpha: 0.1)
        ..strokeWidth = isMajor ? 2 : 1
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(
          center.dx + innerRadius * math.cos(angle),
          center.dy + innerRadius * math.sin(angle),
        ),
        Offset(
          center.dx + outerRadius * math.cos(angle),
          center.dy + outerRadius * math.sin(angle),
        ),
        tickPaint,
      );
    }

    // Progress arc
    if (progress > 0) {
      final progressPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round;

      if (isRunning) {
        progressPaint.shader = SweepGradient(
          startAngle: -math.pi / 2,
          endAngle: -math.pi / 2 + 2 * math.pi * progress,
          colors: [
            color.withValues(alpha: 0.8),
            color,
            color.withValues(alpha: 0.6),
          ],
          stops: [0.0, 0.5, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      } else {
        progressPaint.color = color.withValues(alpha: 0.6);
      }

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );

      // Glow dot at end
      final dotAngle = -math.pi / 2 + sweepAngle;
      final dotCenter = Offset(
        center.dx + radius * math.cos(dotAngle),
        center.dy + radius * math.sin(dotAngle),
      );

      // Dis glow
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(dotCenter, 8, glowPaint);

      // ic dot
      final dotPaint = Paint()..color = color;
      canvas.drawCircle(dotCenter, 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.isRunning != isRunning;
  }
}
