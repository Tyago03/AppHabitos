import 'package:flutter/material.dart';

/// Identidade visual inspirada em agendas de papel, plantas e rotina leve.
abstract final class HabitPalette {
  static const paper = Color(0xFFFAF7F2);
  static const white = Color(0xFFFFFDF9);
  static const ink = Color(0xFF303A32);
  static const muted = Color(0xFF778076);
  static const line = Color(0xFFE9E3D9);
  static const terracotta = Color(0xFFBA705D);
  static const peach = Color(0xFFF6E7E0);
  static const sage = Color(0xFF78947C);
  static const sageWash = Color(0xFFE8EEE5);
  static const honey = Color(0xFFE5B775);
}

abstract final class HabitTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: HabitPalette.terracotta,
      brightness: Brightness.light,
    ).copyWith(
      primary: HabitPalette.terracotta,
      onPrimary: Colors.white,
      secondary: HabitPalette.sage,
      onSecondary: Colors.white,
      surface: HabitPalette.white,
      onSurface: HabitPalette.ink,
      outline: HabitPalette.line,
    );

    const outline = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
      borderSide: BorderSide(color: HabitPalette.line),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      scaffoldBackgroundColor: HabitPalette.paper,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: HabitPalette.paper,
        foregroundColor: HabitPalette.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.zero,
        elevation: 0,
        color: HabitPalette.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: HabitPalette.line),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: HabitPalette.white,
        border: outline,
        enabledBorder: outline,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: HabitPalette.terracotta, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: HabitPalette.terracotta,
        foregroundColor: Colors.white,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: HabitPalette.white,
        indicatorColor: HabitPalette.peach,
        elevation: 0,
      ),
      dividerColor: HabitPalette.line,
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: HabitPalette.ink,
          height: 1.13,
        ),
        headlineSmall: TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.w700,
          color: HabitPalette.ink,
        ),
        titleLarge: TextStyle(
          fontSize: 19,
          fontWeight: FontWeight.w700,
          color: HabitPalette.ink,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: HabitPalette.ink,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: HabitPalette.ink,
          height: 1.4,
        ),
      ),
    );
  }
}
