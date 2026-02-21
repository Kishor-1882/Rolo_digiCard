import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:rolo_digi_card/controllers/auth_controller.dart';
import 'package:rolo_digi_card/common/snack_bar.dart';
import 'package:rolo_digi_card/controllers/organization/organization_controller.dart';
import 'package:rolo_digi_card/models/check_card_model.dart';
import 'package:rolo_digi_card/models/group_model.dart';
import 'package:rolo_digi_card/models/card_model.dart';
import 'package:rolo_digi_card/models/organization_user_model.dart';
import 'package:rolo_digi_card/services/dio_client.dart';
import 'package:rolo_digi_card/services/end_points.dart';

class GroupManagementController extends GetxController {
  final organizationController = Get.find<OrganizationController>();
  final Dio _dio = dioClient;

  var isLoading = false.obs;
  var groups = <GroupModel>[].obs;
  final searchQuery = ''.obs;
  final RxString errorMessage = ''.obs;
  final Rx<GroupModel?> selectedGroup = Rx<GroupModel?>(null);
  var cardsList = <CheckCardModel>[].obs;

  List<GroupModel> get filteredGroups {
    if (searchQuery.value.isEmpty) return groups;
    return groups
        .where(
          (group) =>
              group.name.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ||
              (group.description?.toLowerCase().contains(
                    searchQuery.value.toLowerCase(),
                  ) ??
                  false),
        )
        .toList();
  }

  var currentGroup = Rxn<GroupModel>();
  var groupUsers = <OrganizationUserModel>[].obs;
  var groupCards = <CardModel>[].obs;

  // Form Controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  var isShared = false.obs;

  // Group Type
  var groupType = 'user'.obs;

  @override
  void onInit() {
    super.onInit();
    final authController = Get.find<AuthController>();
    if (authController.userType.value == 'organization') {
      getGroups();
      fetchOrganizationCards();
    } else {
      log(
        "Skipping GroupManagementController API calls - User is not an organization",
      );
    }
  }

  void setGroupType(String type) {
    groupType.value = type;
    getGroups();
  }

  @override
  void onClose() {
    // nameController.dispose();
    // descriptionController.dispose();
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
    log("kanchi");
    try {
      isLoading.value = true;
      update();

      final response = await _dio.get(ApiEndpoints.organizationGroups(groupType.value));

      if (response.statusCode == 200) {
        // log("Groups Raw Data: ${response.data}");
        final List<dynamic> data = _resolveList(response.data, 'groups');
        groups.value = data.map((e) => GroupModel.fromJson(e)).toList();
        log("Parsed Groups (${groupType.value}): ${groups.length}");
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

      final response = await _dio.get(
        ApiEndpoints.getOrganizationGroup(groupId),
      );

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
        'groupType': groupType.value,
        'isShared': isShared.value,
      };

      final response = await _dio.post(
        ApiEndpoints.organizationGroups(groupType.value),
        data: data,
      );
      log("Create Group Response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        getGroups();
        organizationController.getDashboardStats();
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

      final response = await _dio.delete(
        ApiEndpoints.deleteOrganizationGroup(groupId),
      );

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
        groupUsers.value = data
            .map((e) => OrganizationUserModel.fromJson(e))
            .toList();
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

      final response = await _dio.delete(
        ApiEndpoints.removeGroupCard(groupId, cardId),
      );

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
  Future<void> updateBulkGroupStatus(
    List<String> groupIds,
    bool isActive,
  ) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.patch(
        // Assuming PUT based on logic, matching others
        ApiEndpoints.bulkGroupStatus,
        data: {'groupIds': groupIds, 'isActive': isActive},
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
  // Add Users to Group
  Future<void> addMembersToGroup(String groupId, List<String> userIds) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.post(
        ApiEndpoints.addGroupUsers(groupId),
        data: {'userIds': userIds},
      );

      if (response.statusCode == 200) {
        Get.back();
        CommonSnackbar.success('Members added to group');
        getGroupUsers(groupId);
        getGroups();
      }
    } on DioException catch (e) {
      log("Add Group Members Error: $e");
      CommonSnackbar.error("Failed to add members to group");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Remove User from Group
  Future<void> removeMemberFromGroup(String groupId, String userId) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.delete(
        ApiEndpoints.removeGroupUser(groupId, userId),
      );

      if (response.statusCode == 200) {
        CommonSnackbar.success('Member removed from group');
        getGroupUsers(groupId);
        getGroups();
      }
    } on DioException catch (e) {
      log("Remove Group Member Error: $e");
      CommonSnackbar.error("Failed to remove member from group");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> getGroupById(String groupId) async {
    log("Dummy S");
  try {
    isLoading.value = true;
    errorMessage.value = '';

    final response = await dioClient.get(
      '/api/organization/groups/$groupId',
    );

log("Response Status: ${response.statusCode}");
    if (response.statusCode == 200) {
    log("Dummy K");
    try{
      final groupData = GroupModel.fromJson(response.data);
      selectedGroup.value = groupData;
      log("Dummy :#${selectedGroup.value?.name}");
    }
    catch(e,t){
      log("Error parsing group details: $e $t");
      errorMessage.value = 'Failed to parse group details';
    }
    } else {
      errorMessage.value = 'Failed to fetch group details';
    }
  } on DioException catch (e) {
    log("Error fetching group details: $e");
    Get.snackbar(
      'Error',
      errorMessage.value,
      snackPosition: SnackPosition.BOTTOM,
    );
    return null;
  } catch (e) {
    errorMessage.value = 'An unexpected error occurred: $e';
    return null;
  } finally {
    isLoading.value = false;
  }
}

Future<void> fetchOrganizationCards() async {
  try {
    isLoading.value = true;
    final response = await dioClient.get('/api/organization/cards');
    if (response.statusCode == 200) {
       final data = response.data;

      List<dynamic> cardsData;

      if (data is List) {
        // API returns direct list
        cardsData = data;
      } else if (data is Map<String, dynamic>) {
        // API returns wrapped object
        cardsData =
            data['cards'] ?? data['data'] ?? data['docs'] ?? [];
      } else {
        cardsData = [];
      }

      cardsList.value =
          cardsData.map((e) => CheckCardModel.fromJson(e)).toList();

      log("Fetch Cards: ${cardsList.length}");
    }
  } on DioException catch (e) {
    log('fetchOrganizationCards error: $e');
  } finally {
    isLoading.value = false;
  }
}

Future<List<dynamic>> fetchCardGroups() async {
  try {
    final response = await dioClient.get(
      '/api/organization/groups',
      queryParameters: {'groupType': 'card'},
    );
    // Dio returns Response<dynamic>; actual body is in response.data
    final body = response.data as Map<String, dynamic>;
    return body['groups'] as List<dynamic>? ?? [];
  } catch (e) {
    log('fetchCardGroups error: $e');
    rethrow;
  }
}

Future<void> linkCardGroups(String groupId, List<String> linkedGroupIds) async {
  try {
    // Dio uses 'data:' not 'body:'
    await dioClient.post(
      '/api/organization/groups/$groupId/link',
      data: {'linkedGroupIds': linkedGroupIds},
    );
  } catch (e) {
    log('linkCardGroups error: $e');
    rethrow;
  }
}

}
