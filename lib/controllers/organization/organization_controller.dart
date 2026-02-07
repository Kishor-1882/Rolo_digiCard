import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:rolo_digi_card/common/snack_bar.dart';
import 'package:rolo_digi_card/controllers/auth_controller.dart';
import 'package:rolo_digi_card/models/organization_model.dart';
import 'package:rolo_digi_card/models/organization_user_model.dart';
import 'package:rolo_digi_card/services/dio_client.dart';
import 'package:rolo_digi_card/services/end_points.dart';

class OrganizationController extends GetxController {
  final Dio _dio = dioClient;

  var isLoading = false.obs;
  var organization = Rxn<OrganizationModel>();
  var currentUser = Rxn<OrganizationUserModel>();
  var dashboardStats = Rxn<OrgDashboardStats>();
  var selectedNavIndex = 0.obs;

  void changeIndex(int index) {
    selectedNavIndex.value = index;
  }

  // Text Controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final domainController =
      TextEditingController(); // Assuming single domain input for creation

  @override
  void onInit() {
    super.onInit();
    final authController = Get.find<AuthController>();
    if (authController.userType.value == 'organization') {
      getOrganization();
      getDashboardStats();
    } else {
      log(
        "Skipping OrganizationController API calls - User is not an organization",
      );
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    domainController.dispose();
    super.onClose();
  }

  // Create Organization
  Future<void> createOrganization() async {
    if (nameController.text.trim().isEmpty) {
      CommonSnackbar.error('Please enter organization name');
      return;
    }

    try {
      isLoading.value = true;
      update();

      final Map<String, dynamic> data = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        // Add domains if required by API, assuming list for now based on model
        'domains': domainController.text.isNotEmpty
            ? [domainController.text.trim()]
            : [],
      };

      log("Create Org Data: ${jsonEncode(data)}");

      final response = await _dio.post(
        ApiEndpoints.createOrganization,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        log("Create Org Response: ${response.data}");

        // Assuming response structure has 'organization' key or is the object itself
        // Adjust based on actual API response for Create
        if (response.data['organization'] != null) {
          organization.value = OrganizationModel.fromJson(
            response.data['organization'],
          );
        }

        CommonSnackbar.success('Organization created successfully');
        // Clear forms or navigate
        nameController.clear();
        descriptionController.clear();
        domainController.clear();
      }
    } on DioException catch (e) {
      isLoading.value = false;
      update();
      String errorMessage = 'Failed to create organization';
      if (e.response != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      log("Create Org Error: $e");
      CommonSnackbar.error(errorMessage);
    } catch (e) {
      isLoading.value = false;
      update();
      log("Create Org Unexpected Error: $e");
      CommonSnackbar.error('An unexpected error occurred');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Get Organization (Me)
  Future<void> getOrganization() async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.get(ApiEndpoints.getOrganization);

      if (response.statusCode == 200) {
        // Based on API.txt: { "user": ..., "organization": ... }
        if (response.data['organization'] != null) {
          organization.value = OrganizationModel.fromJson(
            response.data['organization'],
          );
        }
        if (response.data['user'] != null) {
          currentUser.value = OrganizationUserModel.fromJson(
            response.data['user'],
          );
        }
      }
    } on DioException catch (e) {
      log("Get Org Error: $e");
    } catch (e) {
      log("Get Org Unexpected Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Get Organization Dashboard
  Future<void> getDashboardStats() async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.get(ApiEndpoints.organizationDashboard);

      if (response.statusCode == 200) {
        dashboardStats.value = OrgDashboardStats.fromJson(response.data);
      }
    } on DioException catch (e) {
      log("Get Dashboard Error: $e");
    } catch (e) {
      log("Get Dashboard Unexpected Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Update Settings (Assuming PUT or POST based on endpoint, usually PUT for settings)
  // API.txt shows a response, but we need to know the method.
  // Assuming POST or PUT to '/api/organization/settings' with body.
  // For now implementing structure, might need adjustment if it's just GET.
  // (API.txt shows "Response" for settings, could be GET settings or response to update)
  // If it's GET:
  Future<void> getSettings() async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.get(ApiEndpoints.organizationSettings);

      if (response.statusCode == 200) {
        if (response.data['organization'] != null) {
          // Update organization in state with new settings if returned
          if (organization.value != null) {
            // Logic to update just settings or replace org
            // Since reponse has organization object, we can likely update it
            organization.value = OrganizationModel.fromJson(
              response.data['organization'],
            );
          }
        } else if (response.data['settings'] != null) {
          // If direct settings object...
        }
      }
    } catch (e) {
      log("Get Settings Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Update Settings
  Future<void> updateSettings(OrganizationSettings settings) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.put(
        // Usually PUT for settings update
        ApiEndpoints.organizationSettings,
        data: settings.toJson(),
      );

      if (response.statusCode == 200) {
        if (response.data['organization'] != null) {
          organization.value = OrganizationModel.fromJson(
            response.data['organization'],
          );
        }
        CommonSnackbar.success('Settings updated successfully');
      }
    } on DioException catch (e) {
      log("Update Settings Error: $e");
      CommonSnackbar.error("Failed to update settings");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Deactivate Organization
  Future<void> deactivateOrganization() async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.post(
        ApiEndpoints.deactivateOrganization,
      ); // Assuming POST for action

      if (response.statusCode == 200) {
        if (response.data['organization'] != null) {
          organization.value = OrganizationModel.fromJson(
            response.data['organization'],
          );
        }
        CommonSnackbar.success(
          response.data['message'] ?? 'Organization deactivated',
        );
      }
    } on DioException catch (e) {
      log("Deactivate Error: $e");
      CommonSnackbar.error("Failed to deactivate");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Activate Organization
  Future<void> activateOrganization() async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.post(
        ApiEndpoints.activateOrganization,
      ); // Assuming POST for action

      if (response.statusCode == 200) {
        if (response.data['organization'] != null) {
          organization.value = OrganizationModel.fromJson(
            response.data['organization'],
          );
        }
        CommonSnackbar.success(
          response.data['message'] ?? 'Organization activated',
        );
      }
    } on DioException catch (e) {
      log("Activate Error: $e");
      CommonSnackbar.error("Failed to activate");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Add Custom Domain
  Future<void> addCustomDomain(String domain) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.post(
        ApiEndpoints.addCustomDomain,
        data: {'domain': domain},
      );

      if (response.statusCode == 200) {
        if (response.data['organization'] != null) {
          organization.value = OrganizationModel.fromJson(
            response.data['organization'],
          );
        }
        CommonSnackbar.success('Domain added successfully');
      }
    } on DioException catch (e) {
      log("Add Domain Error: $e");
      String msg = "Failed to add domain";
      if (e.response != null) msg = e.response?.data['message'] ?? msg;
      CommonSnackbar.error(msg);
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Remove Custom Domain
  Future<void> removeCustomDomain(String domain) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.delete(
        ApiEndpoints.removeCustomDomain(domain),
      );

      if (response.statusCode == 200) {
        if (response.data['organization'] != null) {
          organization.value = OrganizationModel.fromJson(
            response.data['organization'],
          );
        }
        CommonSnackbar.success('Domain removed successfully');
      }
    } on DioException catch (e) {
      log("Remove Domain Error: $e");
      CommonSnackbar.error("Failed to remove domain");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Transfer Ownership
  Future<void> transferOwnership(String newOwnerId) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.post(
        ApiEndpoints.transferOwnership,
        data: {'userId': newOwnerId},
      );

      if (response.statusCode == 200) {
        if (response.data['organization'] != null) {
          organization.value = OrganizationModel.fromJson(
            response.data['organization'],
          );
        }
        CommonSnackbar.success('Ownership transferred successfully');
      }
    } on DioException catch (e) {
      log("Transfer Ownership Error: $e");
      CommonSnackbar.error("Failed to transfer ownership");
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
