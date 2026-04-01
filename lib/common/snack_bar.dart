import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonSnackbar {
  /// Show a success message
  static void success(String message, {String title = "Success", TextButton? mainButton}) {
    _showSnackbar(message, title, Colors.green, mainButton);
  }

  /// Show an error message
  static void error(String message, {String title = "Error", TextButton? mainButton}) {
    _showSnackbar(message, title, Colors.red, mainButton);
  }

  /// Private method to display snackbar
  static void _showSnackbar(String message, String title, Color color, TextButton? mainButton) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      duration: const Duration(seconds: 4),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
      mainButton: mainButton,
    );
  }
}
