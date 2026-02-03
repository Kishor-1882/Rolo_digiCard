import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/auth_controller.dart';
import 'package:rolo_digi_card/models/user_model.dart';
import 'package:rolo_digi_card/services/dio_client.dart';
import 'package:rolo_digi_card/services/end_points.dart';

class ProfileController extends GetxController{
  final authController = Get.find<AuthController>();
  bool isLoading = false;
  UserModel? user;

  void onInit(){
    super.onInit();
    getProfile();
  }


  Future<void> getProfile() async {
    isLoading = true;
    update();
    try {
      final response = await DioClient().dio.get(
        ApiEndpoints.getUserProfile,
      );
      if (response.statusCode == 200) {
        user= UserModel.fromJson(response.data['user']);
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      throw Exception('Error fetching profile: $e');
    }
    finally{
      isLoading = false;
      update();
    }
  }

}