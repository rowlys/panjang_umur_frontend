import 'package:flutter/material.dart';

class AppTheme {
  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2E7D32),
    brightness: Brightness.light,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      scaffoldBackgroundColor: const Color(0xFFFBFDF8),
      
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: _lightColorScheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _lightColorScheme.onSurface,
          letterSpacing: -0.5,
        ),
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
        backgroundColor: Colors.transparent,
        indicatorColor: _lightColorScheme.secondaryContainer,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: _lightColorScheme.onSecondaryContainer, size: 26);
          }
          return IconThemeData(color: _lightColorScheme.onSurfaceVariant, size: 24);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.w700, 
              color: _lightColorScheme.onSurface,
            );
          }
          return TextStyle(
            fontSize: 12, 
            fontWeight: FontWeight.w500, 
            color: _lightColorScheme.onSurfaceVariant,
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