// lib/core/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kairos/core/router/app_router.dart';
import 'package:kairos/core/theme/app_colors.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocation = GoRouterState.of(context).matchedLocation;

    return Drawer(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.darkBackground, Color(0xFF0D0D0D)],
          ),
        ),
        child: Column(
          children: [
            _buildSportyHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                children: [
                  _buildStatsCard(),
                  const SizedBox(height: 16),
                  _buildModernMenuItem(
                    context: context,
                    icon: Icons.dashboard_rounded,
                    title: 'Ana Panel',
                    subtitle: 'Genel bakış',
                    route: Routes.dashboard,
                    currentLocation: currentLocation,
                    onTap: () => _navigate(context, Routes.dashboard),
                    gradientColors: [
                      AppColors.workoutHigh,
                      AppColors.workoutMedium,
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSectionLabel('ANTRENMAN'),
                  const SizedBox(height: 8),
                  _buildModernMenuItem(
                    context: context,
                    icon: Icons.calendar_month,
                    title: 'Antrenman Takvimi',
                    subtitle: '',
                    route: Routes.trainingSchedule,
                    currentLocation: currentLocation,
                    onTap: () => _navigate(context, Routes.trainingSchedule),
                    gradientColors: [
                      AppColors.workoutHigh,
                      AppColors.workoutMedium,
                    ],
                  ),
                  _buildModernMenuItem(
                    context: context,
                    icon: Icons.fitness_center_rounded,
                    title: 'Antrenmanlar\u0131m',
                    subtitle: 'Haftal\u0131k program',
                    route: Routes.trainingPlans,
                    currentLocation: currentLocation,
                    onTap: () => _navigate(context, Routes.trainingPlans),
                    gradientColors: [
                      AppColors.workoutHigh,
                      AppColors.workoutMedium,
                    ],
                  ),
                  _buildModernMenuItem(
                    context: context,
                    icon: Icons.timer_outlined,
                    title: 'Kronometre',
                    subtitle: 'S\u00fcre takibi',
                    route: Routes.stopwatch,
                    currentLocation: currentLocation,
                    onTap: () => _navigate(context, Routes.stopwatch),
                    gradientColors: [
                      AppColors.workoutRest,
                      const Color(0xFF2980B9),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildSectionLabel('TAEKWONDO'),
                ],
              ),
            ),
            //_buildBottomActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSportyHeader(BuildContext context) {
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
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white24,
                  child: Icon(
                    Icons.sports_gymnastics,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sporcu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Premium \u00dcye',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Stack(
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: Colors.amber,
                  size: 20,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '"Durdurulamayan bir g\u00fcc varsa, o da kararl\u0131l\u0131kt\u0131r."',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkDivider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.local_fire_department,
            '12',
            'G\u00fcn',
            AppColors.primary,
          ),
          _buildStatDivider(),
          _buildStatItem(
            Icons.timer_outlined,
            '48',
            'Saat',
            AppColors.secondary,
          ),
          _buildStatDivider(),
          _buildStatItem(
            Icons.emoji_events_outlined,
            '5',
            'Ba\u015far\u0131',
            AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: TextStyle(color: AppColors.darkHint, fontSize: 11)),
      ],
    );
  }

  Widget _buildStatDivider() {
    return Container(width: 1, height: 40, color: AppColors.darkDivider);
  }

  Widget _buildSectionLabel(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.darkHint,
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
                          : [AppColors.darkCard, AppColors.darkCard],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: isActive ? Colors.white : AppColors.darkHint,
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
                          color: isActive ? Colors.white : AppColors.darkText,
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
                          color: AppColors.darkHint,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isActive ? gradientColors.first : AppColors.darkHint,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigate(BuildContext context, String route) {
    Navigator.pop(context);
    context.go(route);
  }
}
