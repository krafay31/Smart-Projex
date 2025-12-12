import 'package:flutter/material.dart';

class AppColors {
  // Main Brand Colors
  static const Color primary = Color(0xFF0076D6); // Offshore Blue
  static const Color textPrimary = Color.fromRGBO(10, 26, 47, 1); // Navy Blue
  static const Color textPrimaryDark = Color(0xFF1E3A8A); // Purple Blue
    
  
  // Helper Colors
  static const Color textSecondary = Color(0xFF6B7280); // Grey for subtitles/dates
  static const Color surface = Colors.white;
  static const Color background = Color(0xFFF8F9FA);
  
  // Light Variants (for backgrounds/accents)
  static const Color primaryLight = Color.fromARGB(255, 33, 141, 230);
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color primaryBgLight = Color(0xFFE0F0FF); // Very light blue for cards/items
  static const Color primaryBorder = Color(0xFFB3D9FF); // Light blue border
  static const Color primaryBorderLight = Color(0xFFE0F2FE);

  static const Color submitColor = Color(0xFF16A34A); // Green border
  static const Color subtleGreen = Color(0xFFDCFCE7);
  static const Color subtleGrey = Color.fromARGB(255, 233, 233, 233);
  static const Color rejectColor = Color(0xFF92400E); // Red border
  
  static const Color subtleYellow = Color(0xFFFFFBEB);
  static const Color yellow = Color.fromARGB(255, 255, 224, 102);

  // Gradients
  static const List<Color> primaryGradient = [
    Color(0xFF0076D6),
    Color(0xFF0059A3), // Darker shade of Offshore Blue
  ];
}