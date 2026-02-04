import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/services/dio_client.dart';
import 'package:shared_preferences/shared_preferences.dart';



class AuthController extends GetxController {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  var isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> checkLoginStatus() async {

     Get.offAllNamed("/sidebar");
    return;

    final token = await storage.read(key: 'accessToken');
    log("Token:$token");
    if (token != null && token.isNotEmpty) {
      log("Goinf");
      isLoggedIn.value = true;
      Get.offAllNamed("/sidebar");
    } else {
      isLoggedIn.value = false;
      Get.offAllNamed("/login");
    }
  }


  Future<bool> logout() async {
    try {
      final token = await storage.read(key: 'accessToken');

      if (token == null || token.isEmpty) {
        throw Exception('No token found');
      }

      final response = await dioClient.post(
        'https://digi-bend.roloscan.com/api/auth/logout',
      );

      if (response.statusCode == 200) {
        // Clear stored token
        await storage.delete(key: 'accessToken');

        // Clear SharedPreferences if needed
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Update login status
        isLoggedIn.value = false;

        log("Logout successful");
        final token = await storage.read(key: 'accessToken');
        log("Token:$token");
        return true;
      } else {
        throw Exception('Logout failed');
      }
    } catch (e) {
      log("Logout error: $e");

      // Even if API fails, clear local data
      await storage.delete(key: 'accessToken');
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      isLoggedIn.value = false;

      return false;
    }
  }
}

