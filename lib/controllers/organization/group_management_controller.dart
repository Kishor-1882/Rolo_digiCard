import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:rolo_digi_card/common/snack_bar.dart';
import 'package:rolo_digi_card/models/group_model.dart';
import 'package:rolo_digi_card/models/card_model.dart';
import 'package:rolo_digi_card/models/organization_user_model.dart';
import 'package:rolo_digi_card/services/dio_client.dart';
import 'package:rolo_digi_card/services/end_points.dart';

class GroupManagementController extends GetxController {
  final Dio _dio = dioClient;

  var isLoading = false.obs;
  var groups = <GroupModel>[].obs;
  final searchQuery = ''.obs;

  List<GroupModel> get filteredGroups {
    if (searchQuery.value.isEmpty) return groups;
    return groups.where((group) => 
      group.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
      (group.description?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false)
    ).toList();
  }
  var currentGroup = Rxn<GroupModel>();
  var groupUsers = <OrganizationUserModel>[].obs;
  var groupCards = <CardModel>[].obs;

  // Form Controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  var isShared = false.obs;

  @override
  void onInit() {
    super.onInit();
    getGroups();
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  // Helper to extract List from dynamic response (Map or List)
  List<dynamic> _resolveList(dynamic data, String fallbackKey) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      return data[fallbackKey] ?? data['data'] ?? data['docs'] ?? [];
    }
    return [];
  }

  // Get Groups
  Future<void> getGroups() async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.get(ApiEndpoints.organizationGroups);

      if (response.statusCode == 200) {
        log("Groups Raw Data: ${response.data}");
        final List<dynamic> data = _resolveList(response.data, 'groups');
        groups.value = data.map((e) => GroupModel.fromJson(e)).toList();
        log("Parsed Groups: ${groups.length}");
      }
    } on DioException catch (e) {
      log("Get Groups Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Get Single Group
  Future<void> getGroup(String groupId) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.get(ApiEndpoints.getOrganizationGroup(groupId));

      if (response.statusCode == 200) {
        currentGroup.value = GroupModel.fromJson(response.data);
      }
    } on DioException catch (e) {
      log("Get Group Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Create Group
  Future<void> createGroup() async {
    if (nameController.text.trim().isEmpty) {
      CommonSnackbar.error('Please enter group name');
      return;
    }

    try {
      isLoading.value = true;
      update();

      final Map<String, dynamic> data = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'isShared': isShared.value,
      };

      final response = await _dio.post(
        ApiEndpoints.organizationGroups,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
  
        getGroups();
        Get.back(); // Close dialog
        CommonSnackbar.success('Group created successfully');
        // Clear form
        nameController.clear();
        descriptionController.clear();
        isShared.value = false;
      }
    } on DioException catch (e) {
      log("Create Group Error: $e");
      CommonSnackbar.error("Failed to create group");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Update Group
  Future<void> updateGroup(String groupId) async {
     try {
      isLoading.value = true;
      update();

      final Map<String, dynamic> data = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'isShared': isShared.value,
      };

      final response = await _dio.put(
        ApiEndpoints.updateOrganizationGroup(groupId),
        data: data,
      );

      if (response.statusCode == 200) {
        CommonSnackbar.success('Group updated successfully');
        getGroups();
        if (currentGroup.value?.id == groupId) {
          getGroup(groupId); // Refresh details if viewing
        }
      }
    } on DioException catch (e) {
      log("Update Group Error: $e");
      CommonSnackbar.error("Failed to update group");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Delete Group
  Future<void> deleteGroup(String groupId) async {
     try {
      isLoading.value = true;
      update();

      final response = await _dio.delete(ApiEndpoints.deleteOrganizationGroup(groupId));

      if (response.statusCode == 200) {
        CommonSnackbar.success('Group deleted successfully');
        groups.removeWhere((g) => g.id == groupId);
      }
    } on DioException catch (e) {
      log("Delete Group Error: $e");
      CommonSnackbar.error("Failed to delete group");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Get Group Users
  Future<void> getGroupUsers(String groupId) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.get(ApiEndpoints.getGroupUsers(groupId));

      if (response.statusCode == 200) {
        final List<dynamic> data = _resolveList(response.data, 'users');
        groupUsers.value = data.map((e) => OrganizationUserModel.fromJson(e)).toList();
      }
    } on DioException catch (e) {
      log("Get Group Users Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Get Group Cards
  Future<void> getGroupCards(String groupId) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.get(ApiEndpoints.getGroupCards(groupId));

      if (response.statusCode == 200) {
        final List<dynamic> data = _resolveList(response.data, 'cards');
        groupCards.value = data.map((e) => CardModel.fromJson(e)).toList();
      }
    } on DioException catch (e) {
      log("Get Group Cards Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }
  
  // Add Cards to Group
  Future<void> addGroupCards(String groupId, List<String> cardIds) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.post(
        ApiEndpoints.addGroupCards(groupId),
        data: {'cardIds': cardIds},
      );

      if (response.statusCode == 200) {
        CommonSnackbar.success('Cards added to group');
        getGroupCards(groupId);
      }
    } on DioException catch (e) {
      log("Add Group Cards Error: $e");
      CommonSnackbar.error("Failed to add cards to group");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Remove Card from Group
  Future<void> removeGroupCard(String groupId, String cardId) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.delete(ApiEndpoints.removeGroupCard(groupId, cardId));

      if (response.statusCode == 200) {
        CommonSnackbar.success('Card removed from group');
        getGroupCards(groupId);
      }
    } on DioException catch (e) {
      log("Remove Group Card Error: $e");
      CommonSnackbar.error("Failed to remove card from group");
    } finally {
      isLoading.value = false;
      update();
    }
  }
  
  // Bulk Group Status Update
  Future<void> updateBulkGroupStatus(List<String> groupIds, bool isActive) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.patch( // Assuming PUT based on logic, matching others
        ApiEndpoints.bulkGroupStatus,
        data: {
          'groupIds': groupIds,
          'isActive': isActive
        },
      );

      if (response.statusCode == 200) {
        CommonSnackbar.success('Bulk status updated');
        getGroups();
      }
    } on DioException catch (e) {
      log("Bulk Status Error: $e");
      CommonSnackbar.error("Failed to update bulk status");
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
