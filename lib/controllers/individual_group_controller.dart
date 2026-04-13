import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:rolo_digi_card/common/snack_bar.dart';
import 'package:rolo_digi_card/models/card_model.dart';
import 'package:rolo_digi_card/models/group_model.dart';
import 'package:rolo_digi_card/services/dio_client.dart';
import 'package:rolo_digi_card/services/end_points.dart';

class IndividualGroupController extends GetxController {
  final Dio _dio = dioClient;

  var isLoading = false.obs;
  var groups = <GroupModel>[].obs;
  var myCards = <CardModel>[].obs;
  
  final searchQuery = ''.obs;

  // Form Controllers
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  var isShared = false.obs;

  var sortBy = 'Sort by Date'.obs;
  var isAscending = false.obs;

  List<GroupModel> get filteredGroups {
    List<GroupModel> result = groups.toList();
    if (searchQuery.value.isNotEmpty) {
      result = result.where((group) => 
        group.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
        (group.description?.toLowerCase().contains(searchQuery.value.toLowerCase()) ?? false)
      ).toList();
    }

    result.sort((a, b) {
      if (sortBy.value == 'Sort by Name') {
        int cmp = a.name.toLowerCase().compareTo(b.name.toLowerCase());
        return isAscending.value ? cmp : -cmp;
      } else {
        // Sort by Date using id for fallback if no timestamp or just use id
        int cmp = a.id.compareTo(b.id);
        if (a.createdAt != null && b.createdAt != null) {
          cmp = a.createdAt!.compareTo(b.createdAt!);
        }
        return isAscending.value ? cmp : -cmp;
      }
    });

    return result;
  }

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

  // Get Individual Groups
  Future<void> getGroups() async {
    log("Fetching Individual Groups...");
    try {
      isLoading.value = true;
      
      final response = await _dio.get(ApiEndpoints.groups);

      if (response.statusCode == 200) {
        // Handle Map response with 'groups' key based on user payload
        final data = response.data;
        List<dynamic> groupsList = [];
        
        if (data is Map<String, dynamic> && data.containsKey('groups')) {
          groupsList = data['groups'];
        } else if (data is List) {
          groupsList = data;
        }

        groups.value = groupsList.map((e) => GroupModel.fromJson(e)).toList();
        log("Individual Groups Fetched: ${groups.length}");
      }
    } on DioException catch (e) {
      log("Get Individual Groups Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Create Group
  Future<void> createGroup() async {
    if (nameController.text.trim().isEmpty) {
      CommonSnackbar.error('Group name is required');
      return;
    }

    try {
      isLoading.value = true;

      final data = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
        'isShared': isShared.value,
      };

      final response = await _dio.post(
        ApiEndpoints.groups,
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        getGroups();
        Get.back(); // Navigate back
        CommonSnackbar.success('Group created successfully');
        clearForm();
      }
    } on DioException catch (e) {
      log("Create Group Error: $e");
      String errorMessage = 'Failed to create group';
      if (e.response != null && e.response?.data is Map) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      CommonSnackbar.error(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  // Edit Group
  Future<void> editGroup(String groupId) async {
    if (nameController.text.trim().isEmpty) {
      CommonSnackbar.error('Group name is required');
      return;
    }

    try {
      isLoading.value = true;

      final data = {
        'name': nameController.text.trim(),
        'description': descriptionController.text.trim(),
      };

      final response = await _dio.put(
        ApiEndpoints.individualGroupDetails(groupId),
        data: data,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
         Get.back();
        CommonSnackbar.success('Group updated successfully');
        getGroups();
       // Navigate back
        clearForm();
      }
    } on DioException catch (e) {
      log("Edit Group Error: $e");
      String errorMessage = 'Failed to update group';
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? 
                       e.response?.data['error'] ?? 
                       errorMessage;
      }
      CommonSnackbar.error(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  // Delete Group
  Future<void> deleteGroup(String groupId) async {
    try {
      isLoading.value = true;

      final response = await _dio.delete(ApiEndpoints.individualGroupDetails(groupId));

      if (response.statusCode == 200) {
        CommonSnackbar.success('Group deleted successfully');
        groups.removeWhere((g) => g.id == groupId);
      }
    } on DioException catch (e) {
      log("Delete Group Error: $e");
      String errorMessage = 'Failed to delete group';
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? 
                       e.response?.data['error'] ?? 
                       errorMessage;
      }
      CommonSnackbar.error(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch My Cards (for Add Cards Dialog)
  Future<void> fetchMyCards() async {
    try {
      log("Fetching My Cards...");
      isLoading.value = true;
      
      final response = await _dio.get(ApiEndpoints.myCards);

      if (response.statusCode == 200) {
        log("My Cards Response: ${response.data}");
        final data = response.data;
        List<dynamic> cardsList = [];
        
        if (data is Map<String, dynamic> && data.containsKey('cards')) {
          cardsList = data['cards'];
        } else if (data is List) {
          cardsList = data;
        }

        myCards.value = cardsList.map((e) => CardModel.fromJson(e)).toList();
        log("My Cards Fetched: ${myCards.length}");
      }
    } on DioException catch (e) {
      log("Fetch My Cards Error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Add Cards to Group
  Future<void> addCardsToGroup(String groupId, List<String> cardIds) async {
    if (cardIds.isEmpty) return;
    
    try {
      isLoading.value = true;

      final response = await _dio.post(
        ApiEndpoints.individualGroupCards(groupId),
        data: {'cardIds': cardIds},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.back();
        CommonSnackbar.success('Cards added successfully');
        await getGroups();
      }
    } on DioException catch (e) {
      log("Add Cards To Group Error: $e");
      String errorMessage = 'Failed to add cards';
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? 
                       e.response?.data['error'] ?? 
                       errorMessage;
      }
      CommonSnackbar.error(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }

  // Remove Card from Group
  Future<void> removeCardFromGroup(String groupId, String cardId) async {
    try {
      final response = await _dio.delete(
        ApiEndpoints.individualGroupRemoveCard(groupId, cardId),
      );

      if (response.statusCode == 200) {
        CommonSnackbar.success('Card removed from group');
        await getGroups();
      }
    } on DioException catch (e) {
      log("Remove Card From Group Error: $e");
      String errorMessage = 'Failed to remove card';
      if (e.response != null && e.response?.data != null) {
        errorMessage = e.response?.data['message'] ?? 
                       e.response?.data['error'] ?? 
                       errorMessage;
      }
      CommonSnackbar.error(errorMessage);
    }
  }

  void clearForm() {
    nameController.clear();
    descriptionController.clear();
    isShared.value = false;
  }
}
