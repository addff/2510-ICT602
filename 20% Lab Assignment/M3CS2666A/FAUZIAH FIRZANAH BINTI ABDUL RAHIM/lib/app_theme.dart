import 'package:flutter/material.dart';

class UiTMColors {
  static const Color purple = Color(0xFF2C1A4A);
  static const Color yellow = Color(0xFFF8C41B);
}

class AppTheme {
  static ThemeData theme = ThemeData(
    fontFamily: 'Montserrat',
    scaffoldBackgroundColor: Colors.white,

    appBarTheme: const AppBarTheme(
      backgroundColor: UiTMColors.purple,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
    ),

    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFF7F4FA),
      border: OutlineInputBorder(
        borderSide: BorderSide(color: UiTMColors.purple),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: UiTMColors.yellow, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      labelStyle: TextStyle(color: UiTMColors.purple),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: UiTMColors.purple,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
