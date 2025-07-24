import 'package:flutter/material.dart';

class AppTheme {
  // Primary colors from the provided hex codes
  static const Color royalBlueDark = Color(0xFF00296B);
  static const Color darkCornflowerBlue = Color(0xFF003F88);
  static const Color usafaBlue = Color(0xFF00509D);
  static const Color goldenPoppy = Color(0xFFFDC500);
  static const Color goldWebGolden = Color(0xFFFFD500);

  // Additional colors for better theming
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color mediumGray = Color(0xFF9E9E9E);
  static const Color darkGray = Color(0xFF424242);
  static const Color red = Color(0xFFD32F2F);
  static const Color green = Color(0xFF388E3C);

  // Theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: royalBlueDark,
        primary: royalBlueDark,
        secondary: goldenPoppy,
        tertiary: usafaBlue,
        surface: white,
        background: lightGray,
        error: red,
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: royalBlueDark,
        foregroundColor: white,
        elevation: 2,
        titleTextStyle: TextStyle(
          color: white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: royalBlueDark,
          foregroundColor: white,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: royalBlueDark,
          side: const BorderSide(color: royalBlueDark),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: royalBlueDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: goldenPoppy,
        foregroundColor: royalBlueDark,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: royalBlueDark,
        unselectedItemColor: mediumGray,
        type: BottomNavigationBarType.fixed,
      ),
      cardTheme: CardThemeData(
        color: white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: mediumGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: mediumGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: royalBlueDark, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: red),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      scaffoldBackgroundColor: lightGray,
      fontFamily: 'Roboto',
    );
  }

  // Color schemes for different user roles
  static ColorScheme get adminColorScheme {
    return ColorScheme.fromSeed(
      seedColor: red,
      primary: red,
      secondary: goldenPoppy,
      brightness: Brightness.light,
    );
  }

  static ColorScheme get penjualColorScheme {
    return ColorScheme.fromSeed(
      seedColor: green,
      primary: green,
      secondary: goldenPoppy,
      brightness: Brightness.light,
    );
  }

  static ColorScheme get pembeliColorScheme {
    return ColorScheme.fromSeed(
      seedColor: royalBlueDark,
      primary: royalBlueDark,
      secondary: goldenPoppy,
      brightness: Brightness.light,
    );
  }

  // Helper methods for role-based colors
  static Color getRoleColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return red;
      case 'penjual':
        return green;
      case 'pembeli':
        return royalBlueDark;
      default:
        return mediumGray;
    }
  }

  static Color getRoleBackgroundColor(String? role) {
    switch (role?.toLowerCase()) {
      case 'admin':
        return red;
      case 'penjual':
        return green;
      case 'pembeli':
        return royalBlueDark;
      default:
        return mediumGray;
    }
  }

  static AppBarTheme getAppBarTheme(String? role) {
    Color backgroundColor;
    switch (role?.toLowerCase()) {
      case 'admin':
        backgroundColor = red;
        break;
      case 'penjual':
        backgroundColor = green;
        break;
      case 'pembeli':
        backgroundColor = royalBlueDark;
        break;
      default:
        backgroundColor = royalBlueDark;
    }

    return AppBarTheme(
      backgroundColor: backgroundColor,
      foregroundColor: white,
      elevation: 2,
      titleTextStyle: const TextStyle(
        color: white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      iconTheme: const IconThemeData(color: white),
    );
  }

  // Status colors
  static const Color successColor = green;
  static const Color warningColor = goldenPoppy;
  static const Color errorColor = red;
  static const Color infoColor = usafaBlue;

  // Transaction status colors
  static Color getTransactionStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return goldenPoppy;
      case 'paid':
        return usafaBlue;
      case 'confirmed':
        return darkCornflowerBlue;
      case 'preparing':
        return darkCornflowerBlue;
      case 'ready':
        return goldWebGolden;
      case 'completed':
        return green;
      case 'cancelled':
        return red;
      default:
        return mediumGray;
    }
  }

  // For TransactionStatus enum (Import dari models)
  static Color getStatusColorFromEnum(dynamic status) {
    final statusString = status.toString().split('.').last;
    return getTransactionStatusColor(statusString);
  }
}
