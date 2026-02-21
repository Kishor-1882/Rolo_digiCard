import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:rolo_digi_card/common/snack_bar.dart';
import 'package:rolo_digi_card/services/dio_client.dart';
import 'package:rolo_digi_card/services/end_points.dart';

/// Permission category with label and list of {label, apiKey}.
class PermissionCategory {
  final String title;
  final List<PermissionItem> items;

  const PermissionCategory({required this.title, required this.items});
}

class PermissionItem {
  final String label;
  final String apiKey;

  const PermissionItem({required this.label, required this.apiKey});
}

/// All permission categories and items matching the Invite Team User UI.
/// API keys match the backend (e.g. card:read, user:create).
final List<PermissionCategory> kInvitePermissionCategories = [
  PermissionCategory(
    title: 'Analytics',
    items: [
      const PermissionItem(label: 'View analytics', apiKey: 'analytics:read'),
    ],
  ),
  PermissionCategory(
    title: 'Settings',
    items: [
      const PermissionItem(label: 'View settings', apiKey: 'settings:read'),
      const PermissionItem(label: 'Update settings', apiKey: 'settings:update'),
    ],
  ),
  PermissionCategory(
    title: 'User Management',
    items: [
      const PermissionItem(label: 'Create users', apiKey: 'user:create'),
      const PermissionItem(label: 'View users', apiKey: 'user:read'),
      const PermissionItem(label: 'Activate / Deactivate users', apiKey: 'user:activate'),
      const PermissionItem(label: 'Edit Permission', apiKey: 'user:permission'),
      const PermissionItem(label: 'Delete users', apiKey: 'user:delete'),
      const PermissionItem(label: 'Change user role', apiKey: 'user:role'),
    ],
  ),
  PermissionCategory(
    title: 'Card Management',
    items: [
      const PermissionItem(label: 'Create cards', apiKey: 'card:create'),
      const PermissionItem(label: 'View cards', apiKey: 'card:read'),
      const PermissionItem(label: 'Edit cards', apiKey: 'card:update'),
      const PermissionItem(label: 'Activate / Deactivate cards', apiKey: 'card:activate'),
      const PermissionItem(label: 'Assign cards to users', apiKey: 'card:assign'),
      const PermissionItem(label: 'Delete cards', apiKey: 'card:delete'),
    ],
  ),
  PermissionCategory(
    title: 'Group Management',
    items: [
      const PermissionItem(label: 'Create groups', apiKey: 'group:create'),
      const PermissionItem(label: 'View groups', apiKey: 'group:read'),
      const PermissionItem(label: 'Edit group details', apiKey: 'group:update'),
      const PermissionItem(label: 'Activate / Deactivate groups', apiKey: 'group:activate'),
      const PermissionItem(label: 'Add users to group', apiKey: 'group:add-user'),
      const PermissionItem(label: 'Remove users from group', apiKey: 'group:remove-user'),
      const PermissionItem(label: 'Add cards to group', apiKey: 'group:add-card'),
      const PermissionItem(label: 'Remove cards from group', apiKey: 'group:remove-card'),
      const PermissionItem(label: 'Delete groups', apiKey: 'group:delete'),
    ],
  ),
];

class InviteUserController extends GetxController {
  final Dio _dio = dioClient;

  final stepIndex = 0.obs;
  final emailController = TextEditingController();
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();

  /// 'user' or 'admin'. API expects 'user' | 'admin' (or similar).
  final role = 'user'.obs;

  /// Selected permission API keys (e.g. card:read, user:create).
  final selectedPermissions = <String>{}.obs;

  final isLoading = false.obs;
  final isEmailValid = false.obs;

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(_validateEmail);
  }

  @override
  void onClose() {
    emailController.removeListener(_validateEmail);
    emailController.dispose();
    firstNameController.dispose();
    lastNameController.dispose();
    super.onClose();
  }

  void _validateEmail() {
    isEmailValid.value = _emailRegex.hasMatch(emailController.text.trim());
  }

  int get selectedPermissionsCount => selectedPermissions.length;

  void setRole(String value) {
    role.value = value;
  }

  void togglePermission(String apiKey) {
    if (selectedPermissions.contains(apiKey)) {
      selectedPermissions.remove(apiKey);
    } else {
      selectedPermissions.add(apiKey);
    }
  }

  bool isPermissionSelected(String apiKey) => selectedPermissions.contains(apiKey);

  void selectAllInCategory(PermissionCategory category) {
    for (final item in category.items) {
      selectedPermissions.add(item.apiKey);
    }
  }

  void deselectAllInCategory(PermissionCategory category) {
    for (final item in category.items) {
      selectedPermissions.remove(item.apiKey);
    }
  }

  int selectedCountInCategory(PermissionCategory category) {
    return category.items.where((e) => selectedPermissions.contains(e.apiKey)).length;
  }

  void goToStep(int index) {
    stepIndex.value = index.clamp(0, 1);
  }

  void nextStep() {
    if (stepIndex.value < 1) goToStep(1);
  }

  void previousStep() {
    if (stepIndex.value > 0) goToStep(0);
  }

  /// If role is Administrator, select all permissions (Full Access).
  void applyFullAccessForAdmin() {
    for (final cat in kInvitePermissionCategories) {
      for (final item in cat.items) {
        selectedPermissions.add(item.apiKey);
      }
    }
  }

  Future<void> sendInvitation({VoidCallback? onSuccess}) async {
    final email = emailController.text.trim();
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    if (email.isEmpty) {
      CommonSnackbar.error('Please enter email');
      return;
    }
    if (!_emailRegex.hasMatch(email)) {
      CommonSnackbar.error('Please enter a valid email');
      return;
    }
    if (firstName.isEmpty) {
      CommonSnackbar.error('Please enter first name');
      return;
    }
    if (lastName.isEmpty) {
      CommonSnackbar.error('Please enter last name');
      return;
    }

    try {
      isLoading.value = true;
      final body = {
        'email': email,
        'firstName': firstName,
        'lastName': lastName,
        'role': role.value,
        'permissions': selectedPermissions.toList(),
      };
      final response = await _dio.post(
        ApiEndpoints.inviteUser,
        data: body,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        CommonSnackbar.success(
          response.data['message']?.toString() ?? 'User invited successfully',
        );
        onSuccess?.call();
        
      }
    } on DioException catch (e) {
      log('Invite user error: $e');
      String message = 'Failed to send invitation';
      if (e.response?.data != null) {
        final data = e.response!.data;
        if (data is Map && data['message'] != null) {
          message = data['message'].toString();
        }
      }
      CommonSnackbar.error(message);
    } finally {
      isLoading.value = false;
    }
  }

  void reset() {
    stepIndex.value = 0;
    emailController.clear();
    firstNameController.clear();
    lastNameController.clear();
    role.value = 'user';
    selectedPermissions.clear();
    isEmailValid.value = false;
  }
}
