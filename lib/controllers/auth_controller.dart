import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/models/user_model.dart';
import 'package:rolo_digi_card/services/dio_client.dart';
import 'package:rolo_digi_card/services/end_points.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  var isLoggedIn = false.obs;
  var userType = 'individual'.obs;
  var user = Rxn<UserModel>();
  var permissions = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  /// Returns true if user has the given permission. If permissions list is empty (e.g. individual user), returns true.
  bool hasPermission(String permission) {
    if (permissions.isEmpty) return true;
    return permissions.contains(permission);
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await dioClient.get(ApiEndpoints.getUserProfile);
      if (response.statusCode == 200 && response.data['user'] != null) {
        user.value = UserModel.fromJson(response.data['user']);
        permissions.value = user.value?.permissions ?? [];
        if (user.value?.userType != null) {
          userType.value = user.value!.userType!;
        }
      }
    } catch (e) {
      log('Fetch profile error: $e');
    }
  }

  Future<void> checkLoginStatus() async {
    final token = await storage.read(key: 'accessToken');
    final type = await storage.read(key: 'userType');
    log("Token check: $token, UserType: $type");

    if (type != null) {
      userType.value = type;
    }

    if (token != null && token.isNotEmpty) {
      DioClient.setToken(token);
      await fetchUserProfile();
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
        await storage.delete(key: 'refreshToken');

        user.value = null;
        permissions.clear();

        // Clear SharedPreferences if needed
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Update login status
        isLoggedIn.value = false;

        log("Logout successful");
        final token = await storage.read(key: 'accessToken');
        log("Token:$token");
          final Rtoken = await storage.read(key: 'refreshToken');
        log("Refresh Token:$Rtoken");

        return true;
      } else {
        throw Exception('Logout failed');
      }
    } catch (e) {
      log("Logout error: $e");

      // Even if API fails, clear local data
      await storage.delete(key: 'accessToken');
      user.value = null;
      permissions.clear();
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      isLoggedIn.value = false;

      return false;
    }
  }
}
