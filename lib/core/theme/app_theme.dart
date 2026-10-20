import 'package:flutter/material.dart';

class AppTheme {
  static const Color _woodEdge = Color(0xFF965718);
  static const Color _wood = Color(0xFFA86827);
  static const Color _rope = Color(0xFFEED1A0);
  static const Color _page = Color(0xFFF6E9D2);
  static const Color _cream = Color(0xFFFFF8EC);
  static const Color _ink = Color(0xFF4A2E14);
  static const Color _shadowTone = Color(0xFFAA6929);

  static const Color success = Color(0xFF5B7B3A);
  static const Color warning = Color(0xFFC08A2E);

  static final HandDrawn _handDrawn = HandDrawn(
    ink: _ink,
    paper: const Color(0xFFFFF6E0),
    shadow: _shadowTone.withValues(alpha: 0.5),
    bountyNote: const Color(0xFFFFDB5A),
    dailyNote: const Color(0xFFFBA73A),
    weeklyNote: const Color(0xFFE5EA7F),
  );

  static final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
    seedColor: _woodEdge,
    brightness: Brightness.light,
  ).copyWith(
    primary: _woodEdge,
    onPrimary: _cream,
    primaryContainer: _rope,
    onPrimaryContainer: _ink,
    secondary: _wood,
    onSecondary: _cream,
    secondaryContainer: const Color(0xFFE6C8A3),
    onSecondaryContainer: _ink,
    surface: _page,
    onSurface: _ink,
    onSurfaceVariant: const Color(0xFF70573E),
    surfaceContainerLowest: const Color(0xFFFBF2E2),
    surfaceContainerLow: const Color(0xFFF3E3CA),
    surfaceContainer: const Color(0xFFF0DEC2),
    surfaceContainerHigh: const Color(0xFFEED8BA),
    surfaceContainerHighest: const Color(0xFFEAD2B1),
    outline: _wood,
    outlineVariant: const Color(0xFFE1BF96),
    error: const Color(0xFFA0412D),
    onError: _cream,
    errorContainer: const Color(0xFFF4D6CC),
    onErrorContainer: const Color(0xFF4A1408),
    inverseSurface: _ink,
    onInverseSurface: _page,
    inversePrimary: _rope,
    shadow: _shadowTone,
  );

  static const TextStyle _buttonLabel = TextStyle(fontFamily: HandDrawn.fontFamily, fontSize: 18);
  static final OutlinedBorder _buttonShape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(6));

  static WidgetStateProperty<BorderSide> _outline(Color color) => WidgetStateProperty.resolveWith(
        (states) => BorderSide(
          color: states.contains(WidgetState.disabled) ? color.withValues(alpha: 0.3) : color,
          width: 2,
        ),
      );

  static final WidgetStateProperty<double> _raised = WidgetStateProperty.resolveWith(
    (states) => states.contains(WidgetState.pressed) || states.contains(WidgetState.disabled) ? 0 : 2,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: _lightColorScheme,
      scaffoldBackgroundColor: _page,
      extensions: [_handDrawn],
      splashColor: _woodEdge.withValues(alpha: 0.12),
      highlightColor: _woodEdge.withValues(alpha: 0.10),
      hoverColor: _woodEdge.withValues(alpha: 0.06),
      focusColor: _woodEdge.withValues(alpha: 0.12),

      appBarTheme: const AppBarTheme(
        backgroundColor: _woodEdge,
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
        height: 64,
        elevation: 0,
        backgroundColor: _lightColorScheme.surfaceContainerHighest,
        indicatorColor: _woodEdge,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: _lightColorScheme.surfaceContainerHighest);
          }
          return IconThemeData(color: _lightColorScheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: _lightColorScheme.surfaceContainerHighest,
          ),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _woodEdge,
          foregroundColor: _cream,
          shadowColor: _shadowTone,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: _buttonLabel,
          shape: _buttonShape,
        ).copyWith(side: _outline(_ink), elevation: _raised),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: _handDrawn.paper,
          foregroundColor: _woodEdge,
          shadowColor: _shadowTone,
          textStyle: _buttonLabel,
          shape: _buttonShape,
        ).copyWith(side: _outline(_woodEdge), elevation: _raised),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _woodEdge,
          textStyle: _buttonLabel,
          shape: _buttonShape,
        ),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _rope,
        foregroundColor: _ink,
        elevation: 2,
        focusElevation: 2,
        hoverElevation: 3,
        highlightElevation: 0,
        extendedTextStyle: _buttonLabel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: const BorderSide(color: _woodEdge, width: 2),
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

class HandDrawn extends ThemeExtension<HandDrawn> {
  static const String fontFamily = 'PatrickHand';

  final Color ink;
  final Color paper;
  final Color shadow;
  final Color bountyNote;
  final Color dailyNote;
  final Color weeklyNote;

  const HandDrawn({
    required this.ink,
    required this.paper,
    required this.shadow,
    required this.bountyNote,
    required this.dailyNote,
    required this.weeklyNote,
  });

  static HandDrawn of(BuildContext context) => Theme.of(context).extension<HandDrawn>()!;

  TextStyle hand(double size) => TextStyle(fontFamily: fontFamily, fontSize: size, color: ink);

  List<BoxShadow> get dropShadow => [BoxShadow(color: shadow, blurRadius: 2, offset: const Offset(1, 2))];

  @override
  HandDrawn copyWith({
    Color? ink,
    Color? paper,
    Color? shadow,
    Color? bountyNote,
    Color? dailyNote,
    Color? weeklyNote,
  }) {
    return HandDrawn(
      ink: ink ?? this.ink,
      paper: paper ?? this.paper,
      shadow: shadow ?? this.shadow,
      bountyNote: bountyNote ?? this.bountyNote,
      dailyNote: dailyNote ?? this.dailyNote,
      weeklyNote: weeklyNote ?? this.weeklyNote,
    );
  }

  @override
  HandDrawn lerp(HandDrawn? other, double t) {
    if (other == null) return this;
    return HandDrawn(
      ink: Color.lerp(ink, other.ink, t)!,
      paper: Color.lerp(paper, other.paper, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      bountyNote: Color.lerp(bountyNote, other.bountyNote, t)!,
      dailyNote: Color.lerp(dailyNote, other.dailyNote, t)!,
      weeklyNote: Color.lerp(weeklyNote, other.weeklyNote, t)!,
    );
  }
}
