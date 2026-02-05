import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:rolo_digi_card/common/snack_bar.dart';
import 'package:rolo_digi_card/models/card_model.dart';
import 'package:rolo_digi_card/services/dio_client.dart';
import 'package:rolo_digi_card/services/end_points.dart';

class CardManagementController extends GetxController {
  final Dio _dio = dioClient;

  var isLoading = false.obs;
  var orgCards = <CardModel>[].obs;
  var cardStats = <String, dynamic>{}.obs; // To store simple stats object
  final searchQuery = ''.obs;
  final statusFilter = 'All...'.obs;

  List<CardModel> get filteredCards {
    return orgCards.where((card) {
      // Search filter
      final matchesSearch = card.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          card.id.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          card.title.toLowerCase().contains(searchQuery.value.toLowerCase());

      // Status filter
      bool matchesStatus = true;
      if (statusFilter.value != 'All...') {
        final status = card.isActive ? 'Active' : (card.isBlocked ? 'Blocked' : 'Inactive');
        matchesStatus = status == statusFilter.value;
      }

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // Form Controllers (For minimal creating/updating, can be expanded)
  final nameController = TextEditingController();
  final titleController = TextEditingController();
  final emailController = TextEditingController(); // Contact email

  @override
  void onInit() {
    super.onInit();
    getOrganizationCards();
    getCardStats();
  }

  @override
  void onClose() {
    nameController.dispose();
    titleController.dispose();
    emailController.dispose();
    super.onClose();
  }

  // Get Organization Cards
  Future<void> getOrganizationCards() async {
    log("Fetching Organization Cards...");
    try {
      isLoading.value = true;
      update();

      final response = await _dio.get(ApiEndpoints.organizationCards);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        orgCards.value = data.map((e) => CardModel.fromJson(e)).toList();
        log("Org Cards Fetched: ${orgCards.length}");
      }
    } on DioException catch (e) {
      log("Get Org Cards Error: $e");
    } catch (e) {
      log("Get Org Cards Unexpected Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Get Organization Card Details
  Future<CardModel?> getOrgCardDetails(String cardId) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.get(ApiEndpoints.getOrgCard(cardId));

      if (response.statusCode == 200) {
        return CardModel.fromJson(response.data);
      }
    } on DioException catch (e) {
      log("Get Org Card Details Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
    return null;
  }

  // Get Card Stats
  Future<void> getCardStats() async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.get(ApiEndpoints.organizationCardsStats);

      if (response.statusCode == 200) {
        cardStats.value = response.data;
      }
    } on DioException catch (e) {
      log("Get Cards Stats Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Create Card (Simplified for now, expecting a full map if form is complex)
  // Or usage of existing HomePageController logic adjusted for Org API
  // Here I'll assume we pass the full map similar to HomePageController
  Future<void> createOrgCard(Map<String, dynamic> cardData) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.post(
        ApiEndpoints.organizationCards,
        data: cardData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        CommonSnackbar.success('Card created successfully');
        getOrganizationCards(); // Refresh list
      }
    } on DioException catch (e) {
      log("Create Org Card Error: $e");
      String errorMessage = 'Failed to create card';
      if (e.response != null) {
        errorMessage = e.response?.data['message'] ?? errorMessage;
      }
      CommonSnackbar.error(errorMessage);
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Update Org Card
  Future<void> updateOrgCard(String cardId, Map<String, dynamic> cardData) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.patch(
        ApiEndpoints.updateOrgCard(cardId),
        data: cardData,
      );

      if (response.statusCode == 200) {
        CommonSnackbar.success('Card updated successfully');
        getOrganizationCards();
      }
    } on DioException catch (e) {
      log("Update Org Card Error: $e");
      CommonSnackbar.error("Failed to update card");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Update Status
  Future<void> updateCardStatus(String cardId, bool isActive) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.patch(
        ApiEndpoints.updateOrgCardStatus(cardId),
        data: {'isActive': isActive},
      );

      if (response.statusCode == 200) {
        CommonSnackbar.success('Card status updated');
        // Update local list without refresh if possible, or just refresh
        final index = orgCards.indexWhere((c) => c.id == cardId);
        if (index != -1) {
          getOrganizationCards(); // Refresh to be safe and simple
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

  // Reassign Card
  Future<void> reassignCard(String cardId, String userId) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.patch( // Assuming PUT or POST, API.txt doesn't explicitly specify but reassign is usually an action or update
        ApiEndpoints.reassignOrgCard(cardId),
        data: {'userId': userId},
      );

      if (response.statusCode == 200) {
        CommonSnackbar.success('Card reassigned successfully');
        getOrganizationCards();
      }
    } on DioException catch (e) {
      log("Reassign Error: $e");
      CommonSnackbar.error("Failed to reassign card");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Delete Card
  Future<void> deleteOrgCard(String cardId) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.delete(ApiEndpoints.deleteOrgCard(cardId));

      if (response.statusCode == 200) {
        CommonSnackbar.success('Card deleted successfully');
        orgCards.removeWhere((c) => c.id == cardId);
      }
    } on DioException catch (e) {
      log("Delete Card Error: $e");
      CommonSnackbar.error("Failed to delete card");
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
