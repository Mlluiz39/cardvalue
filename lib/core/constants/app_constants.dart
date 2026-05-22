import 'package:flutter/material.dart';

class AppColors {
  // Semantic colors
  static const Color income = Color(0xFF2E7D32);
  static const Color incomeLight = Color(0xFFE8F5E9);
  static const Color expense = Color(0xFFC62828);
  static const Color expenseLight = Color(0xFFFFEBEE);
  static const Color warning = Color(0xFFEF6C00);
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color info = Color(0xFF1565C0);
  static const Color infoLight = Color(0xFFE3F2FD);
  static const Color success = Color(0xFF2E7D32);
  static const Color successLight = Color(0xFFE8F5E9);

  // Category colors
  static const Map<String, Color> categoryColors = {
    'food': Color(0xFFFF9800),
    'transport': Color(0xFF2196F3),
    'housing': Color(0xFF795548),
    'health': Color(0xFFE53935),
    'education': Color(0xFF9C27B0),
    'entertainment': Color(0xFFE91E63),
    'clothing': Color(0xFF009688),
    'salary': Color(0xFF4CAF50),
    'freelance': Color(0xFF8BC34A),
    'other': Color(0xFF9E9E9E),
  };

  static Color getCategoryColor(String categoryId) {
    return categoryColors[categoryId] ?? Colors.grey;
  }

  // Chart palette
  static const List<Color> chartPalette = [
    Color(0xFF3F51B5), // indigo
    Color(0xFF00BCD4), // cyan
    Color(0xFFFFC107), // amber
    Color(0xFFE53935), // red
    Color(0xFF4CAF50), // green
    Color(0xFF9C27B0), // violet
    Color(0xFFFF9800), // orange
    Color(0xFF009688), // teal
    Color(0xFFE91E63), // pink
    Color(0xFF607D8B), // slate
  ];
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;

  static const EdgeInsets screenPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(horizontal: lg, vertical: sm);
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;

  static BorderRadius get borderRadiusSm => BorderRadius.circular(sm);
  static BorderRadius get borderRadiusMd => BorderRadius.circular(md);
  static BorderRadius get borderRadiusLg => BorderRadius.circular(lg);
}

class AppConstants {
  static const String appName = 'CardValue';
  static const String appVersion = '1.0.0';
  static const String defaultLocale = 'pt-BR';
  static const String defaultCurrency = 'BRL';
}
