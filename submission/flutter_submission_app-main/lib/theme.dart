import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._();

  static const Color primary = Color(0xFF4F46E5);
  static const Color secondary = Color(0xFF6366F1);
  static const Color accent = Color(0xFFFBBF24);
  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF0B0F1A);
  static const Color textSecondary = Color(0xFF637083);

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme).apply(
      bodyColor: textPrimary,
      displayColor: textPrimary,
    );
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: surface,
      ),
      scaffoldBackgroundColor: background,
      textTheme: _textTheme(textTheme),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textPrimary,
        centerTitle: false,
      ),
      inputDecorationTheme: _inputTheme(),
      elevatedButtonTheme: _buttonTheme(textTheme),
      cardTheme: _cardTheme(),
      dividerColor: Colors.black12,
    );
  }

  static ThemeData dark() {
    final base = ThemeData.dark(useMaterial3: true);
    final textTheme = GoogleFonts.poppinsTextTheme(base.textTheme).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    );
    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        primary: primary,
        secondary: secondary,
        surface: const Color(0xFF1E1E2A),
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF12121B),
      textTheme: _textTheme(textTheme),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      inputDecorationTheme: _inputTheme(isDark: true),
      elevatedButtonTheme: _buttonTheme(textTheme),
      cardTheme: _cardTheme(isDark: true),
      dividerColor: Colors.white12,
    );
  }

  static TextTheme _textTheme(TextTheme t) => t.copyWith(
        displayMedium: t.displayMedium
            ?.copyWith(fontWeight: FontWeight.w700, fontSize: 28),
        headlineMedium: t.headlineMedium
            ?.copyWith(fontWeight: FontWeight.w700, fontSize: 24),
        titleLarge:
            t.titleLarge?.copyWith(fontWeight: FontWeight.w600, fontSize: 20),
        bodyLarge: t.bodyLarge?.copyWith(fontSize: 16),
        bodyMedium: t.bodyMedium?.copyWith(fontSize: 14),
      );

  static InputDecorationTheme _inputTheme({bool isDark = false}) =>
      InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1E1E2A) : surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      );

  static ElevatedButtonThemeData _buttonTheme(TextTheme textTheme) =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      );

  static CardThemeData _cardTheme({bool isDark = false}) => CardThemeData(
        clipBehavior: Clip.antiAlias,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: isDark ? const Color(0xFF1E1E2A) : surface,
        margin: EdgeInsets.zero,
      );
}
