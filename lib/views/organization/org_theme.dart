import 'package:flutter/material.dart';

class OrgTheme {
  static const Color backgroundColor = Color(0xFF121212);
  static const Color cardBackgroundColor = Color(0xFF1E1E1E); // Slightly lighter
  static const Color primaryColor = Color(0xFFD64FF0); // Pink/Purple from image
  static const Color secondaryColor = Color(0xFF9C27B0);
  static const Color successColor = Color(0xFF4CAF50); // Green
  static const Color warningColor = Color(0xFFFFA726); // Orange/Amber
  static const Color errorColor = Color(0xFFEF5350); // Red
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Colors.grey;
  
  static const TextStyle headerStyle = TextStyle(
    color: textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );
  
  static const TextStyle subHeaderStyle = TextStyle(
    color: textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle cardTitleStyle = TextStyle(
    color: textPrimary,
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle cardLabelStyle = TextStyle(
    color: textSecondary,
    fontSize: 14,
  );

  static BoxDecoration cardDecoration = BoxDecoration(
    color: cardBackgroundColor,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Colors.white.withOpacity(0.05)),
  );
}
