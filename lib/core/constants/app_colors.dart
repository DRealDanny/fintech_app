import 'package:flutter/material.dart';

/// App color palette designed for a sleek, modern Black & White luxury fintech aesthetic
/// with high-visibility green and red accents for financial indicators.
class AppColors {
  AppColors._();

  // Mode-Independent Constants
  static const Color pureBlack = Color(0xFF000000);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color positiveGreen = Color(0xFF00E676);
  static const Color negativeRed = Color(0xFFFF3B30);
  static const Color accentAmber = Color(0xFFFFB300);
  static const Color accentCyan = Color(0xFF00E676);
  static const Color accentRose = Color(0xFFFF3B30);
  static const Color accentIndigo = Color(0xFF71717A);

  // Dark Palette Constants (Default)
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF101010);
  static const Color surfaceElevated = Color(0xFF181818);
  static const Color surfaceBorder = Color(0xFF262626);
  static const Color surfaceBorderLight = Color(0xFF383838);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA1A1AA);
  static const Color textMuted = Color(0xFF71717A);
  static const Color primary = Color(0xFFFFFFFF);
  static const Color primaryDark = Color(0xFFE4E4E7);
  static const Color primaryLight = Color(0xFFFFFFFF);

  // Light Palette Constants
  static const Color lightBackground = Color(0xFFF7F7F8);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceElevated = Color(0xFFEFEFF2);
  static const Color lightSurfaceBorder = Color(0xFFE5E5EA);
  static const Color lightSurfaceBorderLight = Color(0xFFD1D1D6);
  static const Color lightTextPrimary = Color(0xFF09090B);
  static const Color lightTextSecondary = Color(0xFF6E6E73);
  static const Color lightTextMuted = Color(0xFF8E8E93);
  static const Color lightPrimary = Color(0xFF09090B);

  // Context-aware dynamic helpers
  static bool isDarkMode(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color bg(BuildContext context) =>
      isDarkMode(context) ? background : lightBackground;

  static Color surf(BuildContext context) =>
      isDarkMode(context) ? surface : lightSurface;

  static Color surfElevated(BuildContext context) =>
      isDarkMode(context) ? surfaceElevated : lightSurfaceElevated;

  static Color border(BuildContext context) =>
      isDarkMode(context) ? surfaceBorder : lightSurfaceBorder;

  static Color text(BuildContext context) =>
      isDarkMode(context) ? textPrimary : lightTextPrimary;

  static Color textSub(BuildContext context) =>
      isDarkMode(context) ? textSecondary : lightTextSecondary;

  static Color btn(BuildContext context) =>
      isDarkMode(context) ? primary : lightPrimary;

  static Color onBtn(BuildContext context) =>
      isDarkMode(context) ? pureBlack : pureWhite;

  static LinearGradient cardGrad(BuildContext context) =>
      isDarkMode(context) ? darkCardGradient : lightCardGradient;

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFE4E4E7)],
    begin: Alignment(-1.0, -1.0),
    end: Alignment(1.0, 1.0),
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF161616), Color(0xFF0A0A0A)],
    begin: Alignment(-1.0, -1.0),
    end: Alignment(1.0, 1.0),
  );

  static const LinearGradient lightCardGradient = LinearGradient(
    colors: [Color(0xFFFFFFFF), Color(0xFFF2F2F7)],
    begin: Alignment(-1.0, -1.0),
    end: Alignment(1.0, 1.0),
  );

  static const LinearGradient cardGlowGradient = LinearGradient(
    colors: [Color(0x1AFFFFFF), Color(0x02000000)],
    begin: Alignment(0.0, -1.0),
    end: Alignment(0.0, 1.0),
  );
}
