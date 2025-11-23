import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: AppColors.blueRegular,
      scaffoldBackgroundColor: const Color(0xFFF5F7FA), // М'який сіро-блакитний фон
      colorScheme: ColorScheme.light(
        primary: AppColors.blueRegular,
        secondary: AppColors.greenRegular,
        surface: Colors.white,
        background: const Color(0xFFF5F7FA), // М'який сіро-блакитний фон
        error: AppColors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF212121), // Темніший чорний для кращого контрасту
        onBackground: const Color(0xFF212121), // Темніший чорний для кращого контрасту
        onError: Colors.white,
        surfaceVariant: const Color(0xFFF0F4F8), // Світліший варіант для поверхонь
        onSurfaceVariant: const Color(0xFF424242), // Темніший сірий для другорядного тексту
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.blueRegular,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.blueRegular,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: AppColors.red,
            width: 1.5,
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.bold),
        displayMedium: TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.bold),
        displaySmall: TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.bold),
        headlineLarge: TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.w600),
        headlineMedium: TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.w600),
        titleLarge: TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.w500),
        titleSmall: TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.w500),
        bodyLarge: TextStyle(color: Color(0xFF212121)),
        bodyMedium: TextStyle(color: Color(0xFF212121)),
        bodySmall: TextStyle(color: Color(0xFF424242)),
        labelLarge: TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.w500),
        labelMedium: TextStyle(color: Color(0xFF424242)),
        labelSmall: TextStyle(color: Color(0xFF424242)),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
        space: 1,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenRegular, // Зелений колір для кнопок
          foregroundColor: Colors.white,
          elevation: 3,
          shadowColor: AppColors.greenRegular.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.greenRegular, // Зелений колір для outlined кнопок
          side: BorderSide(
            color: AppColors.greenRegular,
            width: 2,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.greenRegular, // Зелений колір для text кнопок
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          color: Color(0xFF212121),
          fontSize: 14,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: AppColors.blueLighter,
      scaffoldBackgroundColor: AppColors.blueDarkest,
      colorScheme: ColorScheme.dark(
        primary: AppColors.blueLighter,
        secondary: AppColors.greenLighter,
        surface: AppColors.blueDarker,
        background: AppColors.blueDarkest,
        error: AppColors.red,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.blueDarker,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.blueDarker,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.blueDarker,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

