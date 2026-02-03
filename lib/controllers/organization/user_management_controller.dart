import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:rolo_digi_card/common/snack_bar.dart';
import 'package:rolo_digi_card/models/organization_user_model.dart';
import 'package:rolo_digi_card/services/dio_client.dart';
import 'package:rolo_digi_card/services/end_points.dart';

class UserManagementController extends GetxController {
  final Dio _dio = dioClient;

  var isLoading = false.obs;
  var users = <OrganizationUserModel>[].obs;

  // Invite Form Controllers
  final inviteEmailController = TextEditingController();
  final inviteFirstNameController = TextEditingController();
  final inviteLastNameController = TextEditingController();
  final inviteRoleController = TextEditingController(text: 'user');
  // Permissions selection could be a list of strings managed separately

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onClose() {
    inviteEmailController.dispose();
    inviteFirstNameController.dispose();
    inviteLastNameController.dispose();
    inviteRoleController.dispose();
    super.onClose();
  }

  // Get Organization Users
  Future<void> getOrganizationUsers() async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.get(ApiEndpoints.organizationUsers);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        users.value = data.map((e) => OrganizationUserModel.fromJson(e)).toList();
      }
    } on DioException catch (e) {
      log("Get Users Error: $e");
    } catch (e) {
      log("Get Users Unexpected Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Get User Details
  Future<OrganizationUserModel?> getUserDetails(String userId) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.get(ApiEndpoints.getOrgUser(userId));

      if (response.statusCode == 200) {
        return OrganizationUserModel.fromJson(response.data);
      }
    } on DioException catch (e) {
      log("Get User Details Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
    return null;
  }

  // Invite User
  Future<void> inviteUser(List<String> permissions) async {
     if (inviteEmailController.text.trim().isEmpty) {
      CommonSnackbar.error('Please enter email');
      return;
    }

    try {
      isLoading.value = true;
      update();

      final Map<String, dynamic> data = {
        'email': inviteEmailController.text.trim(),
        'firstName': inviteFirstNameController.text.trim(),
        'lastName': inviteLastNameController.text.trim(),
        'role': inviteRoleController.text.trim(),
        'permissions': permissions,
      };

      final response = await _dio.post(
        ApiEndpoints.inviteUser,
        data: data,
      );

      if (response.statusCode == 200) {
        CommonSnackbar.success('User invited successfully');
        // Optionally refresh list or add locally
        getOrganizationUsers();
        
        // Clear form
        inviteEmailController.clear();
        inviteFirstNameController.clear();
        inviteLastNameController.clear();
        inviteRoleController.text = 'user';
      }
    } on DioException catch (e) {
      log("Invite User Error: $e");
      String errorMessage = 'Failed to invite user';
      if (e.response != null) {
         errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      CommonSnackbar.error(errorMessage);
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Resend Invite
  Future<void> resendInvite(String userId) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.post(ApiEndpoints.resendInvite(userId));

      if (response.statusCode == 200) {
        CommonSnackbar.success('Invite resent successfully');
      }
    } on DioException catch (e) {
      log("Resend Invite Error: $e");
      CommonSnackbar.error("Failed to resend invite");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Update User Status (Activate/Deactivate)
  Future<void> updateUserStatus(String userId, bool isActive) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.patch(
        ApiEndpoints.updateUserStatus(userId),
        data: {'isActive': isActive},
      );

      if (response.statusCode == 200) {
        CommonSnackbar.success('User status updated');
        // Update local list
        final index = users.indexWhere((u) => u.id == userId);
        if (index != -1) {
          // Ideally we re-fetch or clone and update, but re-fetching is safer
          getOrganizationUsers();
        }
      }
    } on DioException catch (e) {
      log("Update Status Error: $e");
      CommonSnackbar.error("Failed to update status");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Update Permissions
  Future<void> updateUserPermissions(String userId, List<String> permissions) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.patch(
        ApiEndpoints.updateUserPermissions(userId),
        data: {'permissions': permissions},
      );

      if (response.statusCode == 200) {
        CommonSnackbar.success('Permissions updated');
        getOrganizationUsers();
      }
    } on DioException catch (e) {
      log("Update Permissions Error: $e");
      CommonSnackbar.error("Failed to update permissions");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Update Role (and permissions potentially)
  Future<void> updateUserRole(String userId, String role, List<String> permissions) async {
    try {
      isLoading.value = true;
      update();

      // Based on API.txt line 128, updating role seems to go to same endpoint as permissions but with role in body
      // Wait, endpoint is /permissions in line 128 but body has role.
      // So I might assume updateUserPermissions logic handles role too if passed.
      // Or I can use my `updateUserRole` method signature but point to relevant logic.
      // For now I'm using the endpoint I defined `updateUserPermissions` for both as per API.txt pattern.
      
      final Map<String, dynamic> data = {
        'role': role,
        'permissions': permissions,
      };

      final response = await _dio.patch(
        ApiEndpoints.updateUserPermissions(userId), // Using the permissions endpoint string
        data: data,
      );

      if (response.statusCode == 200) {
        CommonSnackbar.success('Role updated');
        getOrganizationUsers();
      }
    } on DioException catch (e) {
      log("Update Role Error: $e");
      CommonSnackbar.error("Failed to update role");
    } finally {
      isLoading.value = false;
      update();
    }
  }
  
  // Delete User
  Future<void> deleteUser(String userId) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.delete(ApiEndpoints.deleteUser(userId));

      if (response.statusCode == 200) {
        CommonSnackbar.success('User deleted successfully');
        users.removeWhere((u) => u.id == userId);
      }
    } on DioException catch (e) {
      log("Delete User Error: $e");
      CommonSnackbar.error("Failed to delete user");
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
