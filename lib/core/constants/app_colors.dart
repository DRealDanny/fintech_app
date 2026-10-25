import 'package:flutter/material.dart';

/// App color palette designed for a modern, sleek fintech aesthetic.
class AppColors {
  AppColors._();

  // Primary Brand Colors
  static const Color primary = Color(0xFF00E599); // Electric Mint / Emerald
  static const Color primaryDark = Color(0xFF059669);
  static const Color primaryLight = Color(0xFF6EE7B7);

  // Accent Colors
  static const Color accentIndigo = Color(0xFF6366F1);
  static const Color accentCyan = Color(0xFF06B6D4);
  static const Color accentAmber = Color(0xFFF59E0B);
  static const Color accentRose = Color(0xFFF43F5E);

  // Backgrounds & Surfaces (Fintech Dark Theme)
  static const Color background = Color(0xFF090D16); // Deep Obsidian
  static const Color surface = Color(0xFF111827); // Dark Card
  static const Color surfaceElevated = Color(0xFF162032);
  static const Color surfaceBorder = Color(0xFF1F293D); // Border line

  // Neutral & Typography
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00E599), Color(0xFF059669)],
    begin: Alignment(-1.0, -1.0),
    end: Alignment(1.0, 1.0),
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0x2200E599), Color(0x05090D16)],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0),
  );
}
