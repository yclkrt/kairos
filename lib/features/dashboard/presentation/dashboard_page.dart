import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kairos/core/router/app_router.dart';
import 'package:kairos/core/theme/app_colors.dart';
import 'package:kairos/core/theme/app_gradients.dart';
import 'package:kairos/core/widgets/main_scaffold.dart';
import 'package:kairos/features/dashboard/widgets/pedometer_card.dart';

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
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'ANA PANEL',
              style: TextStyle(
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

              // Quick Actions Section
              _buildQuickActions(context, isDark),
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
      'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
      'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık'
    ];
    final days = [
      'Pazartesi', 'Salı', 'Çarşamba', 'Perşembe', 'Cuma', 'Cumartesi', 'Pazar'
    ];
    final dateStr = '${now.day} ${months[now.month - 1]} ${now.year}, ${days[now.weekday - 1]}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GÜNLÜK ÖZET',
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

  /// Hızlı Erişim Kartları
  Widget _buildQuickActions(BuildContext context, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              'HIZLI ERİŞİM',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: isDark ? AppColors.darkHint : AppColors.lightHint,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  context: context,
                  isDark: isDark,
                  title: 'Antrenman\nProgramı',
                  icon: Icons.calendar_month_rounded,
                  gradient: isDark
                      ? AppGradients.trainingScheduleDark
                      : AppGradients.trainingSchedule,
                  route: Routes.trainingSchedule,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionTile(
                  context: context,
                  isDark: isDark,
                  title: 'Antrenman\nPlanları',
                  icon: Icons.assignment_rounded,
                  gradient: isDark
                      ? AppGradients.trainingPlansDark
                      : AppGradients.trainingPlans,
                  route: Routes.trainingPlans,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionTile(
                  context: context,
                  isDark: isDark,
                  title: 'Kronometre\n& Sayaç',
                  icon: Icons.timer_rounded,
                  gradient: isDark
                      ? AppGradients.stopwatchDark
                      : AppGradients.stopwatch,
                  route: Routes.stopwatch,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildActionTile(
                  context: context,
                  isDark: isDark,
                  title: 'Taekwondo\nSkor',
                  icon: Icons.sports_martial_arts,
                  gradient: isDark
                      ? AppGradients.taekwondoDark
                      : AppGradients.taekwondo,
                  route: Routes.taekwondoScoreboard,
                ),
              ),
              const Expanded(child: SizedBox()),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required bool isDark,
    required String title,
    required IconData icon,
    required LinearGradient gradient,
    required String route,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => context.push(route),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
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
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: gradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: gradient.colors.first.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                  color: isDark ? Colors.white : AppColors.lightText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
