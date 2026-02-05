import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/common/snack_bar.dart';
import 'package:rolo_digi_card/services/dio_client.dart';
import 'package:rolo_digi_card/services/end_points.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginController extends GetxController {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  bool isLoginMode = true;
  //login
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  //register
  final registerEmailController = TextEditingController();
  final registerPasswordController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final nameController = TextEditingController();
  final isLoading = false.obs;
  final isLoggedIn = false.obs;


  Map<String, String> splitFullName(String fullName) {
    if (fullName.trim().isEmpty) {
      return {
        'firstName': '',
        'lastName': '',
      };
    }

    final parts = fullName.trim().split(RegExp(r'\s+'));

    final firstName = parts.first;
    final lastName = parts.length > 1
        ? parts.sublist(1).join(' ')
        : '';

    return {
      'firstName': firstName,
      'lastName': lastName,
    };
  }


  Future<void> login() async {
    log("Email:${emailController.text} Password ${passwordController.text}");
    if(emailController.text.isEmpty || passwordController.text.isEmpty){
      CommonSnackbar.error('Please fill all the form');
      return ;
    }

    log("Emailing");


    try {
      isLoading.value = true;
      update();
      log("Emailing 1");
      final response = await dioClient.post(
        ApiEndpoints.login,
        data: {
          "email": emailController.text.trim(),
          "password": passwordController.text.trim(),
        },
      );

      log("Emailing 2");
      if (response.statusCode == 200) {
        log("Emailing 3");
        final accessToken = response.data["tokens"]["accessToken"];
        final refreshToken = response.data["tokens"]["refreshToken"];
        final userType = response.data["user"]["userType"];

        await storage.write(key: 'accessToken', value: accessToken);
        await storage.write(key: 'refreshToken', value: refreshToken);
        await storage.write(key: 'userType', value: userType);

        DioClient.setToken(accessToken);

        isLoggedIn.value = true;
        Get.offAllNamed("/sidebar");
        update();
      } else {
        log("Emailing 4");
        CommonSnackbar.error('Invalid Credentials');
        isLoading.value = false;
        update();
      }
    } catch (e, t) {
      log("Emailing 5: $e");
      String errorMessage = 'Login failed';
      if (e is DioException && e.response != null) {
        log("Login Error Response: ${e.response?.data}");
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      CommonSnackbar.error(errorMessage);
      isLoading.value = false;
      update();
    } finally {
      log("Emailing 6");
      isLoading.value = false;
      update();
      emailController.clear();
      passwordController.clear();
    }
  }

  Future<void> register() async {
    try {
      if (emailController.text.trim().isEmpty ||
          passwordController.text.trim().isEmpty ||
          firstNameController.text.trim().isEmpty ||
          lastNameController.text.trim().isEmpty) {
        CommonSnackbar.error('All fields are mandatory');
        return;
      }
      if (passwordController.text.trim().length < 8) {
        CommonSnackbar.error('Password must be at least 8 characters');
        return;
      }

      isLoading.value = true;
      update();
      // final name = splitFullName(nameController.text.trim());
      final data= {
        "email": emailController.text.trim(),
        "password": passwordController.text.trim(),
        "firstName": firstNameController.text.trim(),
        "lastName": lastNameController.text.trim(),
      };
      log("Data:${jsonEncode(data)}");
      final response = await DioClient().dio.post(
        ApiEndpoints.register,
        data: data,
      );

      if (response.statusCode == 200) {
        CommonSnackbar.success('Account created. Please login.');
      }
      isLoading.value = false;
      isLoginMode = true;
      update();
    } catch (e) {
      log("Error in Reg:$e");
      isLoading.value = false;
      update();
      CommonSnackbar.error('Registration failed');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("accessToken");
    isLoggedIn.value = false;
    final token = await storage.read(key: 'accessToken');
    log("TOken:$token");
    Get.offAllNamed("/login");
  }

}
