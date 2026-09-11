// lib/core/widgets/app_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lingo_easy/lingo_easy.dart';
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
                  const SizedBox(height: 8),
                  _buildLanguageSelector(context, isDark),
                  const SizedBox(height: 16),
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

  Widget _buildLanguageSelector(BuildContext context, bool isDark) {
    final currentLocale = context.currentLocale;
    final isTr = currentLocale == 'tr';

    // Active language accent color
    const trColor = Color(0xFFE63946); // kırmızı — TR
    const enColor = Color(0xFF4361EE); // mavi — EN
    final activeColor = isTr ? trColor : enColor;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF141428), const Color(0xFF0E0E1E)]
                : [const Color(0xFFF5F5FF), const Color(0xFFECECF8)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: activeColor.withValues(alpha: isDark ? 0.35 : 0.2),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: activeColor.withValues(alpha: isDark ? 0.18 : 0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Header row ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: activeColor.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Globe icon with active-color glow
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: isTr
                            ? [const Color(0xFFE63946), const Color(0xFFC1121F)]
                            : [
                                const Color(0xFF4361EE),
                                const Color(0xFF3A0CA3),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: activeColor.withValues(alpha: 0.45),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.translate_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Label + active locale chip
                  Expanded(
                    child: Row(
                      children: [
                        Text(
                          'DİL',
                          style: TextStyle(
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF1A1A2E),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: activeColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            currentLocale.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Current flag large
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Text(
                      isTr ? '🇹🇷' : '🇬🇧',
                      key: ValueKey(currentLocale),
                      style: const TextStyle(fontSize: 22),
                    ),
                  ),
                ],
              ),
            ),

            // ── Toggle strip ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final halfW = (constraints.maxWidth - 6) / 2;
                  return Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.35)
                          : Colors.white.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.06)
                            : Colors.black.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Sliding pill indicator
                        AnimatedPositioned(
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutBack,
                          left: isTr ? 3 : halfW + 3,
                          top: 3,
                          bottom: 3,
                          width: halfW,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: isTr
                                    ? [
                                        const Color(0xFFE63946),
                                        const Color(0xFFC1121F),
                                      ]
                                    : [
                                        const Color(0xFF4361EE),
                                        const Color(0xFF3A0CA3),
                                      ],
                              ),
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: [
                                BoxShadow(
                                  color: activeColor.withValues(alpha: 0.5),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Two language buttons overlay
                        Row(
                          children: [
                            _buildLangTab(
                              context: context,
                              flag: '🇹🇷',
                              code: 'TR',
                              name: 'Türkçe',
                              locale: 'tr',
                              isSelected: isTr,
                              isDark: isDark,
                            ),
                            _buildLangTab(
                              context: context,
                              flag: '🇬🇧',
                              code: 'EN',
                              name: 'English',
                              locale: 'en',
                              isSelected: !isTr,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangTab({
    required BuildContext context,
    required String flag,
    required String code,
    required String name,
    required String locale,
    required bool isSelected,
    required bool isDark,
  }) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!isSelected) {
            context.setLocale(locale);
            Navigator.pop(context);
          }
        },
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(flag, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.4)
                                : Colors.black.withValues(alpha: 0.35)),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    name,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.75)
                          : (isDark
                                ? Colors.white.withValues(alpha: 0.25)
                                : Colors.black.withValues(alpha: 0.25)),
                      fontSize: 8,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ],
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
