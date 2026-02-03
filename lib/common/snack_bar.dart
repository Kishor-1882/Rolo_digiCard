import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommonSnackbar {
  /// Show a success message
  static void success(String message, {String title = "Success"}) {
    _showSnackbar(message, title, Colors.green);
  }

  /// Show an error message
  static void error(String message, {String title = "Error"}) {
    _showSnackbar(message, title, Colors.red);
  }

  /// Private method to display snackbar
  static void _showSnackbar(String message, String title, Color color) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color.withOpacity(0.9),
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
      borderRadius: 10,
      duration: const Duration(seconds: 3),
      isDismissible: true,
      forwardAnimationCurve: Curves.easeOutBack,
    );
  }
}
