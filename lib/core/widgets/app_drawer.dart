// lib/core/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sporlab/core/providers/theme_provider.dart';
import 'package:sporlab/core/router/app_router.dart';
import 'package:sporlab/core/theme/app_colors.dart';
import 'package:sporlab/core/theme/app_gradients.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).matchedLocation;
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isDark
                ? [AppColors.darkBackground, Color(0xFF0D0D0D)]
                : [AppColors.lightBackground, Color(0xFFE8E8E8)],
          ),
        ),
        child: Column(
          children: [
            _buildSportyHeader(context, isDark),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                children: [
                  _buildThemeSwitch(context, ref, isDark),
                  _buildModernMenuItem(
                    context: context,
                    icon: Icons.dashboard_rounded,
                    title: 'Ana Panel',
                    subtitle: 'Genel bakış',
                    route: Routes.dashboard,
                    currentLocation: currentLocation,
                    onTap: () => _navigate(context, Routes.dashboard),
                    gradientColors: AppGradients.dashboardIcon,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 16),
                  _buildSectionLabel('ANTRENMAN', isDark),
                  const SizedBox(height: 8),
                  _buildModernMenuItem(
                    context: context,
                    icon: Icons.calendar_month,
                    title: 'Antrenman Takvimi',
                    subtitle: 'Takvim ve Hatırlatıcılar',
                    route: Routes.trainingSchedule,
                    currentLocation: currentLocation,
                    onTap: () => _navigate(context, Routes.trainingSchedule),
                    gradientColors: AppGradients.trainingScheduleIcon,
                    isDark: isDark,
                  ),
                  _buildModernMenuItem(
                    context: context,
                    icon: Icons.fitness_center_rounded,
                    title: 'Antrenmanlarım',
                    subtitle: 'Seanslık programlar',
                    route: Routes.trainingPlans,
                    currentLocation: currentLocation,
                    onTap: () => _navigate(context, Routes.trainingPlans),
                    gradientColors: AppGradients.trainingPlansIcon,
                    isDark: isDark,
                  ),
                  _buildModernMenuItem(
                    context: context,
                    icon: Icons.timer_outlined,
                    title: 'Kronometre',
                    subtitle: 'Süre takibi',
                    route: Routes.stopwatch,
                    currentLocation: currentLocation,
                    onTap: () => _navigate(context, Routes.stopwatch),
                    gradientColors: AppGradients.stopwatchIcon,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionLabel('TAEKWONDO', isDark),
                  const SizedBox(height: 8),
                  _buildModernMenuItem(
                    context: context,
                    icon: Icons.sports_martial_arts,
                    title: 'Taekwondo Skor',
                    subtitle: 'Maç takip ve skor tablosu',
                    route: Routes.taekwondoScoreboard,
                    currentLocation: currentLocation,
                    onTap: () => _navigate(context, Routes.taekwondoScoreboard),
                    gradientColors: AppGradients.taekwondoIcon,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  _buildSectionLabel('BOKS', isDark),
                  const SizedBox(height: 8),
                  _buildModernMenuItem(
                    context: context,
                    icon: Icons.sports_mma,
                    title: 'Box Raund',
                    subtitle: 'Raund süreleri ve dinlenme',
                    route: Routes.boxingRound,
                    currentLocation: currentLocation,
                    onTap: () => _navigate(context, Routes.boxingRound),
                    gradientColors: AppGradients.boxingIcon,
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            //_buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSportyHeader(BuildContext context, bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 16,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.flash_on_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SPORLAB',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Sporcu Performans Takip',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: isDark ? AppColors.darkHint : AppColors.lightHint,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildModernMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required String currentLocation,
    required VoidCallback onTap,
    required List<Color> gradientColors,
    required bool isDark,
  }) {
    final isActive =
        currentLocation == route ||
        (route != '/' && currentLocation.startsWith(route));

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? gradientColors.first.withValues(alpha: 0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              border: isActive
                  ? Border.all(
                      color: gradientColors.first.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isActive
                          ? gradientColors
                          : [
                              isDark ? AppColors.darkCard : AppColors.lightCard,
                              isDark ? AppColors.darkCard : AppColors.lightCard,
                            ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isActive
                        ? Colors.white
                        : (isDark ? AppColors.darkHint : AppColors.lightHint),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isActive
                              ? (isDark ? Colors.white : AppColors.lightText)
                              : (isDark
                                    ? AppColors.darkText
                                    : AppColors.lightText),
                          fontSize: 14,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkHint
                              : AppColors.lightHint,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isActive
                      ? gradientColors.first
                      : (isDark ? AppColors.darkHint : AppColors.lightHint),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeSwitch(BuildContext context, WidgetRef ref, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? [const Color(0xFF9C27B0), const Color(0xFF673AB7)]
                      : [const Color(0xFFFFB74D), const Color(0xFFFF9800)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TEMA',
                    style: TextStyle(
                      color: isDark ? Colors.white : AppColors.lightText,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isDark ? 'Koyu Tema' : 'Açık Tema',
                    style: TextStyle(
                      color: isDark ? AppColors.darkHint : AppColors.lightHint,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: isDark,
              onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
              activeThumbColor: AppColors.workoutHigh,
              activeTrackColor: AppColors.workoutHigh.withValues(alpha: 0.3),
              inactiveThumbColor: const Color(0xFFFFB74D),
              inactiveTrackColor: const Color(
                0xFFFFB74D,
              ).withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context);
    context.go(route);
  }
}
