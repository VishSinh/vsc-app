import 'package:flutter/material.dart';
import 'app_config.dart';

class AppTheme {
  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: AppConfig.primaryColor, brightness: Brightness.dark),
    appBarTheme: AppBarTheme(
      elevation: AppConfig.elevationNone,
      centerTitle: true,
      backgroundColor: AppConfig.transparent,
      foregroundColor: AppConfig.textColorPrimary,
    ),
    cardTheme: CardThemeData(
      elevation: AppConfig.elevationLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.defaultRadius)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 2,
        padding: EdgeInsets.symmetric(horizontal: AppConfig.largePadding, vertical: AppConfig.defaultPadding),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConfig.defaultRadius)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppConfig.defaultRadius)),
      contentPadding: EdgeInsets.symmetric(horizontal: AppConfig.defaultPadding, vertical: AppConfig.smallPadding),
    ),
    dataTableTheme: DataTableThemeData(
      headingTextStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: AppConfig.fontSizeMd),
    ),
  );
}
