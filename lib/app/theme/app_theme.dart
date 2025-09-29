import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFF9800);
  static const Color secondaryColor = Color(0xFF009688);
  static const Color errorColor = Color(0xFFD32F2F);

  // 🌞 Light Theme
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ).copyWith(secondary: secondaryColor, error: errorColor);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFFFFBF7), // beda sama dark
      textTheme: Typography.blackCupertino, // teks gelap
      iconTheme: IconThemeData(color: colorScheme.primary),
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        centerTitle: true,
        elevation: 2,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 4,
        color: Colors.white,
        shadowColor: primaryColor.withValues(alpha: 0.2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: TextStyle(
          fontSize: 15,
          color: colorScheme.onSecondary,
        ),
      ),
    );
  }

  // 🌙 Dark Theme
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.dark,
    ).copyWith(secondary: secondaryColor, error: errorColor);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFF121212), // jelas beda
      textTheme: Typography.whiteCupertino, // teks putih
      iconTheme: IconThemeData(color: colorScheme.secondary),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: colorScheme.onPrimary,
        centerTitle: true,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey.shade900,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 3,
        color: const Color(0xFF1E1E1E),
        shadowColor: primaryColor.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        contentTextStyle: TextStyle(
          fontSize: 15,
          color: colorScheme.onSecondary,
        ),
      ),
    );
  }
}
