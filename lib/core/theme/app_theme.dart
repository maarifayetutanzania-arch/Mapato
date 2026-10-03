import 'package:flutter/material.dart';

abstract final class AppColors {
  static const primary = Color(0xFF1E88E5);
  static const secondary = Color(0xFF00796B);
  static const background = Color(0xFFF5F7FA);
  static const white = Color(0xFFFFFFFF);
  static const ink = Color(0xFF17202A);
  static const muted = Color(0xFF667085);
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFED6C02);
  static const error = Color(0xFFD32F2F);
  static const border = Color(0xFFE3E8EF);

  static Color surface(BuildContext context) =>
      Theme.of(context).colorScheme.surface;
  static Color text(BuildContext context) =>
      Theme.of(context).colorScheme.onSurface;
  static Color mutedText(BuildContext context) =>
      Theme.of(context).colorScheme.onSurfaceVariant;
  static Color outline(BuildContext context) =>
      Theme.of(context).colorScheme.outlineVariant;
}

abstract final class AppTheme {
  static ThemeData get light => _build(Brightness.light);
  static ThemeData get dark => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final background = isDark ? const Color(0xFF101820) : AppColors.background;
    final surface = isDark ? const Color(0xFF1B2732) : AppColors.white;
    final outline = isDark ? const Color(0xFF354553) : AppColors.border;
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          surface: surface,
          brightness: brightness,
        ).copyWith(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          error: AppColors.error,
          surface: surface,
          surfaceContainerLow: isDark
              ? const Color(0xFF202E3A)
              : const Color(0xFFF9FAFC),
          outlineVariant: outline,
          onSurface: isDark ? const Color(0xFFF2F5F8) : AppColors.ink,
          onSurfaceVariant: isDark ? const Color(0xFFB2BFCA) : AppColors.muted,
        );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: scheme.onSurface,
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: outline),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: AppColors.primary.withValues(alpha: 0.12),
        labelTextStyle: const WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
      dividerColor: outline,
    );
  }
}
