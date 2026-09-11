import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lingo_easy/lingo_easy.dart';
import 'package:sporlab/core/theme/app_colors.dart';
import 'package:sporlab/core/theme/app_gradients.dart';
import 'package:sporlab/core/widgets/main_scaffold.dart';
import 'package:sporlab/features/dashboard/widgets/pedometer_card.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
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
                ? AppGradients.dashboardDark
                : AppGradients.dashboard,
          ),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              context.ln('dashboard').toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 3,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
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
          padding: const EdgeInsets.only(top: 16, bottom: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Greeting & Date Header
              _buildGreetingHeader(isDark),

              const SizedBox(height: 12),

              // Pedometer / Step Counter Main Card
              const PedometerCard(),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  /// Karşılama ve Tarih Bölümü
  Widget _buildGreetingHeader(bool isDark) {
    final now = DateTime.now();
    final months = [
      context.ln('january'),
      context.ln('february'),
      context.ln('march'),
      context.ln('april'),
      context.ln('may'),
      context.ln('june'),
      context.ln('july'),
      context.ln('august'),
      context.ln('september'),
      context.ln('october'),
      context.ln('november'),
      context.ln('december'),
    ];
    final days = [
      context.ln('monday'),
      context.ln('tuesday'),
      context.ln('wednesday'),
      context.ln('thursday'),
      context.ln('friday'),
      context.ln('saturday'),
      context.ln('sunday'),
    ];
    final dateStr =
        '${now.day} ${months[now.month - 1]} ${now.year}, ${days[now.weekday - 1]}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.ln('daily_summary').toUpperCase(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: isDark ? AppColors.darkHint : AppColors.lightHint,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.lightText,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.06)
                  : Colors.black.withValues(alpha: 0.04),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              size: 20,
              color: isDark ? Colors.white70 : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }
}
