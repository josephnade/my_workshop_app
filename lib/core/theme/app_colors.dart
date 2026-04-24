import 'package:flutter/material.dart';

/// Uygulamanın tüm renkleri tek yerden yönetilir.
/// Yeni renk eklemek istersen sadece buraya ekle.
abstract class AppColors {
  // — Primary Palette —
  static const primary = Color(0xFF6C63FF);
  static const primaryLight = Color(0xFF9D97FF);
  static const primaryDark = Color(0xFF3D35CC);

  // — Neutral —
  static const background = Color(0xFFF8F9FA);
  static const backgroundDark = Color(0xFF121212);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceDark = Color(0xFF1E1E1E);

  // — Text —
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textPrimaryDark = Color(0xFFF1F1F1);
  static const textSecondaryDark = Color(0xFF9CA3AF);

  // — Semantic —
  static const success = Color(0xFF10B981);
  static const error = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
}
