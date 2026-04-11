import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:rolo_digi_card/common/snack_bar.dart';
import 'package:rolo_digi_card/services/dio_client.dart';
import 'package:rolo_digi_card/services/end_points.dart';

class OrganizationSettingsController extends GetxController {
  final Dio _dio = dioClient;

  var isLoading = false.obs;

  // General Settings State
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final domainController = TextEditingController();
  var logoBase64 = ''.obs;
  var logoUrl = ''.obs;

  // Advanced Security State
  var adminSettingsPermission = false.obs;
  var isDeactivated = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    domainController.dispose();
    super.onClose();
  }

  Future<void> fetchSettings() async {
    try {
      isLoading.value = true;
      final response = await _dio.get(ApiEndpoints.organizationSettings);

      if (response.statusCode == 200) {
        final data = response.data;
        nameController.text = data['name'] ?? '';
        descriptionController.text = data['description'] ?? '';

        if (data['domains'] != null && data['domains'].isNotEmpty) {
          domainController.text = data['domains'].first;
        }

        if (data['logo'] != null &&
            data['logo'].toString().startsWith('data:image')) {
          logoBase64.value = data['logo'];
        } else {
          logoUrl.value = data['logo'] ?? '';
        }

        if (data['settings'] != null) {
          adminSettingsPermission.value =
              data['settings']['adminSettingsPermission'] ?? false;
        }

        isDeactivated.value =
            data['status'] == 'deactivated' || data['isActive'] == false;
      }
    } on DioException catch (e) {
      log("Fetch Settings Error: $e");
      CommonSnackbar.error("Failed to fetch settings");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickLogo() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final bytes = await image.readAsBytes();
      final String base64Image = "data:image/png;base64,${base64Encode(bytes)}";
      logoBase64.value = base64Image;
    }
  }

  void removeLogo() {
    logoBase64.value = '';
    logoUrl.value = '';
  }

  Future<void> updateSettings() async {
    try {
      isLoading.value = true;
      final payload = {
        "name": nameController.text.trim(),
        "description": descriptionController.text.trim(),
        "domain": domainController.text.trim(),
      };

      if (logoBase64.value.isNotEmpty) {
        payload["logo"] = logoBase64.value;
      }

      log("Update Settings Payload: ${jsonEncode(payload)}");

      final response = await _dio.put(
        ApiEndpoints.organizationSettings,
        data: payload,
      );

      if (response.statusCode == 200) {
        CommonSnackbar.success("Organization settings updated successfully");
      }
    } on DioException catch (e) {
      log("Update Settings Error: $e");
      CommonSnackbar.error(
          e.response?.data?['message'] ?? "Failed to update settings");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      isLoading.value = true;
      final payload = {
        "oldPassword": currentPassword,
        "newPassword": newPassword,
      };

      log("Change Password Payload: ${jsonEncode(payload)}");

      final response = await _dio.put(
        ApiEndpoints.changePassword,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        CommonSnackbar.success("Password changed successfully");
        Get.back(); // close dialog
      }
    } on DioException catch (e) {
      log("Change Password Error: $e");
      CommonSnackbar.error(
          e.response?.data?['message'] ?? "Failed to change password");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleAdminAccess(bool value) async {
    try {
      adminSettingsPermission.value = value;

      final response = await _dio.patch(
        ApiEndpoints.adminPermission,
        data: {
          "allowed": value,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Invalid status code ${response.statusCode}");
      }
      CommonSnackbar.success("Admin access updated");
    } on DioException catch (e) {
      log("Toggle Admin Permission Error: $e");
      adminSettingsPermission.value = !value;
      CommonSnackbar.error("Failed to update permission");
    } catch (e) {
      adminSettingsPermission.value = !value;
      CommonSnackbar.error("Failed to update permission");
    }
  }

  // Advanced Security State
  var orgMembers = <dynamic>[].obs;

  Future<void> fetchOrganizationMembers() async {
    try {
      final response = await _dio.get(ApiEndpoints.organizationUsers);
      if (response.statusCode == 200) {
        log("Organization Members: ${response.data}");
        orgMembers.value = response.data ?? response.data ?? [];
      }
    } catch (e) {
      log("Fetch Organization Members Error: $e");
    }
  }

  Future<void> transferOwnership(
      {String? toUserId, String? toEmail, required String note}) async {
    try {
      isLoading.value = true;
      final payload = {"note": note};
      if (toUserId != null && toUserId.isNotEmpty)
        payload["toUserId"] = toUserId;
      if (toEmail != null && toEmail.isNotEmpty) payload["toEmail"] = toEmail;

      log("Transfer Ownership Payload: ${jsonEncode(payload)}");

      final response = await _dio.post(
        ApiEndpoints.transferOwnership,
        data: payload,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        CommonSnackbar.success("Ownership transferred successfully");
        Get.back(); // Close dialog
      }
    } on DioException catch (e) {
      log("Transfer Ownership Error: $e");
      CommonSnackbar.error(
          e.response?.data?['message'] ?? "Failed to transfer ownership");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deactivateOrganization() async {
    try {
      isLoading.value = true;
      log("Deactivate Organization");
      final response =
          await _dio.post(ApiEndpoints.deactivateOrganization, data: {});
      if (response.statusCode == 200 || response.statusCode == 201) {
        isDeactivated.value = true;
        CommonSnackbar.success("Organization deactivated successfully");
      }
    } on DioException catch (e) {
      log("Deactivate Error: $e");
      CommonSnackbar.error(
          e.response?.data?['message'] ?? "Failed to deactivate organization");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> activateOrganization() async {
    try {
      isLoading.value = true;
      log("Activate Organization");
      final response =
          await _dio.post(ApiEndpoints.activateOrganization, data: {});
      if (response.statusCode == 200 || response.statusCode == 201) {
        isDeactivated.value = false;
        CommonSnackbar.success("Organization activated successfully");
      }
    } on DioException catch (e) {
      log("Activate Error: $e");
      CommonSnackbar.error(
          e.response?.data?['message'] ?? "Failed to activate organization");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteOrganization() async {
    try {
      isLoading.value = true;
      log("Delete Organization");
      final response = await _dio.delete(ApiEndpoints.createOrganization);
      if (response.statusCode == 200 || response.statusCode == 201) {
        CommonSnackbar.success("Organization deleted successfully");
        // Navigation or post-delete logic could go here
      }
    } on DioException catch (e) {
      log("Delete Error: $e");
      CommonSnackbar.error(
          e.response?.data?['message'] ?? "Failed to delete organization");
    } finally {
      isLoading.value = false;
    }
  }
}
