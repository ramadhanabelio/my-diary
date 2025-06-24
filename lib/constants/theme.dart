import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryPink = Color(0xFFFF4FA2);
  static const Color secondaryPurple = Color(0xFF9B5DE5);
  static const Color softOrange = Color(0xFFFF9A76);
  static const Color softPink = Color(0xFFFF7EB9);
  static const Color almostWhitePink = Color.fromARGB(255, 255, 250, 252);
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color lightGrey = Color(0xFFDADADA);

  static var scaffoldBackground = almostWhitePink;
}

class AppGradients {
  static const LinearGradient mainGradient = LinearGradient(
    colors: [AppColors.softPink, AppColors.softOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: AppColors.scaffoldBackground,
    primaryColor: AppColors.primaryPink,
    colorScheme: ColorScheme.fromSwatch().copyWith(
      primary: AppColors.primaryPink,
      secondary: AppColors.secondaryPurple,
    ),
    textTheme: const TextTheme(
      bodyMedium: TextStyle(
        color: AppColors.black,
        fontFamily: 'PlusJakartaSans',
      ),
    ),
    fontFamily: 'PlusJakartaSans',
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryPink,
        foregroundColor: AppColors.white,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontFamily: 'PlusJakartaSans',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primaryPink,
        backgroundColor: AppColors.white,
        side: const BorderSide(color: AppColors.primaryPink),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide(color: AppColors.lightGrey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: BorderSide(color: AppColors.lightGrey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(50),
        borderSide: const BorderSide(color: AppColors.primaryPink, width: 2),
      ),
      labelStyle: const TextStyle(
        color: AppColors.primaryPink,
        fontFamily: 'PlusJakartaSans',
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
    ),
  );
}
