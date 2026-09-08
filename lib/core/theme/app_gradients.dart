import 'package:flutter/material.dart';

class AppGradients {
  // Dashboard - Mavi-Mor gradient (Güvenilirlik, profesyonellik)
  static const LinearGradient dashboard = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
  );

  static const LinearGradient dashboardDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4a5568), Color(0xFF2d3748)],
  );

  // Training Schedule - Kırmızı-Turuncu gradient (Enerji, motivasyon)
  static const LinearGradient trainingSchedule = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE84C3D), Color(0xFFF39C12)],
  );

  static const LinearGradient trainingScheduleDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF4500), Color(0xFFFF8C00)],
  );

  // Training Plans - Yeşil-Teal gradient (Büyüme, ilerleme)
  static const LinearGradient trainingPlans = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF11998e), Color(0xFF38ef7d)],
  );

  static const LinearGradient trainingPlansDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0d6b5e), Color(0xFF1a936f)],
  );

  // Stopwatch - Mor-Pembe gradient (Hassasiyet, odak)
  static const LinearGradient stopwatch = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF8360c3), Color(0xFF2ebf91)],
  );

  static const LinearGradient stopwatchDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF5e4b9a), Color(0xFF1a8a6e)],
  );

  // Taekwondo Scoreboard - Mavi-Kırmızı gradient (Chung-Hong renkleri)
  static const LinearGradient taekwondo = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1565C0), Color(0xFFC62828)],
  );

  static const LinearGradient taekwondoDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0D47A1), Color(0xFFB71C1C)],
  );

  // Boxing Round - Kırmızı-Siyah gradient (Güç, agresif)
  static const LinearGradient boxing = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE84C3D), Color(0xFF1A1A1A)],
  );

  static const LinearGradient boxingDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFC62828), Color(0xFF000000)],
  );

  // Drawer item gradients
  static const List<Color> dashboardIcon = [Color(0xFF667eea), Color(0xFF764ba2)];
  static const List<Color> trainingScheduleIcon = [Color(0xFFE84C3D), Color(0xFFF39C12)];
  static const List<Color> trainingPlansIcon = [Color(0xFF11998e), Color(0xFF38ef7d)];
  static const List<Color> stopwatchIcon = [Color(0xFF8360c3), Color(0xFF2ebf91)];
  static const List<Color> taekwondoIcon = [Color(0xFF1565C0), Color(0xFFC62828)];
  static const List<Color> boxingIcon = [Color(0xFFE84C3D), Color(0xFF1A1A1A)];
}
