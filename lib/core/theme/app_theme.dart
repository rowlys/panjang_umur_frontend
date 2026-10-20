import 'package:flutter/material.dart';

class AppTheme {
  static const Color _walnut = Color(0xFF6D4C41);
  static const Color _darkWood = Color(0xFF5D4037);
  static const Color _lightWood = Color(0xFF8D6E63);
  static const Color _parchment = Color(0xFFF5ECD9);
  static const Color _cream = Color(0xFFFFF8EC);
  static const Color _ink = Color(0xFF4E342E);

  static const Color success = Color(0xFF5B7B3A);
  static const Color warning = Color(0xFFC08A2E);

  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: _walnut,
    brightness: Brightness.light,
  ).copyWith(
    primary: _walnut,
    onPrimary: _cream,
    primaryContainer: const Color(0xFFE6CBB0),
    onPrimaryContainer: const Color(0xFF3E2723),
    secondary: const Color(0xFF6B7F3A),
    onSecondary: _cream,
    secondaryContainer: const Color(0xFFDCE3C0),
    onSecondaryContainer: const Color(0xFF2F3A14),
    surface: _parchment,
    onSurface: _ink,
    onSurfaceVariant: const Color(0xFF6D5A4F),
    surfaceContainerLowest: const Color(0xFFFBF5EA),
    surfaceContainerLow: const Color(0xFFF2E7D2),
    surfaceContainer: const Color(0xFFEEE2CA),
    surfaceContainerHigh: const Color(0xFFEBDDC3),
    surfaceContainerHighest: const Color(0xFFE8D9BC),
    outline: const Color(0xFFA1887F),
    outlineVariant: const Color(0xFFD7C4A8),
    error: const Color(0xFFA0412D),
    onError: _cream,
    errorContainer: const Color(0xFFF4D6CC),
    onErrorContainer: const Color(0xFF4A1408),
    inverseSurface: const Color(0xFF3E2723),
    onInverseSurface: _parchment,
    inversePrimary: const Color(0xFFE6CBB0),
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      scaffoldBackgroundColor: _parchment,

      appBarTheme: const AppBarTheme(
        backgroundColor: _darkWood,
        foregroundColor: _cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _cream,
          letterSpacing: -0.5,
        ),
      ),

      tabBarTheme: TabBarThemeData(
        labelColor: _cream,
        unselectedLabelColor: _cream.withValues(alpha: 0.7),
        indicatorColor: _lightColorScheme.primaryContainer,
        dividerColor: Colors.transparent,
      ),

      cardTheme: CardThemeData(
        elevation: 0,
        color: _lightColorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: _lightColorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
      ),

      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: _darkWood,
        indicatorColor: _lightWood,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _cream, size: 26);
          }
          return IconThemeData(color: _cream.withValues(alpha: 0.7), size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: _cream,
            );
          }
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: _cream.withValues(alpha: 0.7),
          );
        }),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: _lightColorScheme.inverseSurface,
        contentTextStyle: TextStyle(
          color: _lightColorScheme.onInverseSurface,
          fontSize: 14,
        ),
        actionTextColor: _lightColorScheme.inversePrimary,
        behavior: SnackBarBehavior.floating,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
