import 'package:flutter/material.dart';

class AppColors {
  // Ana Renkler - Kairos teması
  static const Color primary = Color(0xFFE84C3D); // Enerjik kırmızı
  static const Color secondary = Color(0xFFF39C12); // Turuncu - motivasyon
  static const Color accent = Color(0xFF2ECC71); // Yeşil - başarı/ilerleme

  // Gradient Renkleri
  static const Color gradientStart = Color(0xFFE84C3D);
  static const Color gradientEnd = Color(0xFFF39C12);

  // Koyu Tema Renkleri
  static const Color darkBackground = Color(0xFF1A1A1A);
  static const Color darkSurface = Color(0xFF2D2D2D);
  static const Color darkCard = Color(0xFF3D3D3D);
  static const Color darkText = Color(0xFFE0E0E0);
  static const Color darkHint = Color(0xFF888888);
  static const Color darkDivider = Color(0xFF404040);

  // Açık Tema Renkleri
  static const Color lightBackground = Color(0xFFF8F9FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFF0F0F0);
  static const Color lightText = Color(0xFF1A1A1A);
  static const Color lightHint = Color(0xFF888888);
  static const Color lightDivider = Color(0xFFE0E0E0);

  // Status Renkleri
  static const Color success = Color(0xFF2ECC71);
  static const Color warning = Color(0xFFF39C12);
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);

  // Antrenman Özel Renkleri
  static const Color workoutHigh = Color(0xFFE84C3D);
  static const Color workoutMedium = Color(0xFFF39C12);
  static const Color workoutLow = Color(0xFF2ECC71);
  static const Color workoutRest = Color(0xFF3498DB);

  // Nötr Renkler
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  // Opaklık ile Renk Kullanımı
  static Color primaryWithOpacity(double opacity) =>
      primary.withValues(alpha: opacity);
  static Color secondaryWithOpacity(double opacity) =>
      secondary.withValues(alpha: opacity);
  static Color accentWithOpacity(double opacity) =>
      accent.withValues(alpha: opacity);
}
