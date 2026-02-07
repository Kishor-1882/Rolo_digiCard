import 'dart:developer';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:rolo_digi_card/controllers/auth_controller.dart';
import 'package:rolo_digi_card/models/card_model.dart';
import 'package:rolo_digi_card/models/organization_user_model.dart';
import 'package:rolo_digi_card/services/dio_client.dart';
import 'package:rolo_digi_card/services/end_points.dart';

class SavedItemsController extends GetxController {
  final Dio _dio = dioClient;

  final selectedCategory = 'All'.obs;
  final searchQuery = ''.obs;
  final isLoading = false.obs;

  var savedCards = <CardModel>[].obs;
  var savedContacts = <OrganizationUserModel>[].obs;

  List<CardModel> get filteredCards {
    if (searchQuery.value.isEmpty) return savedCards;
    return savedCards
        .where(
          (card) =>
              card.name.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ||
              card.title.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ),
        )
        .toList();
  }

  List<OrganizationUserModel> get filteredContacts {
    if (searchQuery.value.isEmpty) return savedContacts;
    return savedContacts
        .where(
          (contact) =>
              contact.fullName.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ) ||
              contact.email.toLowerCase().contains(
                searchQuery.value.toLowerCase(),
              ),
        )
        .toList();
  }

  @override
  void onInit() {
    super.onInit();
    final authController = Get.find<AuthController>();
    if (authController.userType.value == 'organization') {
      getSavedCards();
      getSavedContacts();
    } else {
      log(
        "Skipping SavedItemsController API calls - User is not an organization",
      );
    }
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Helper to extract List from dynamic response (Map or List)
  List<dynamic> _resolveList(dynamic data, String fallbackKey) {
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      return data[fallbackKey] ??
          data['data'] ??
          data['docs'] ??
          data['cards'] ??
          data['users'] ??
          [];
    }
    return [];
  }

  Future<void> getSavedCards() async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.get(ApiEndpoints.savedCard);

      if (response.statusCode == 200) {
        final List<dynamic> data = _resolveList(response.data, 'cards');
        savedCards.value = data.map((e) => CardModel.fromJson(e)).toList();
      }
    } on DioException catch (e) {
      log("Get Saved Cards Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> getSavedContacts() async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.get(ApiEndpoints.organizationUsers);

      if (response.statusCode == 200) {
        final List<dynamic> data = _resolveList(response.data, 'users');
        savedContacts.value = data
            .map((e) => OrganizationUserModel.fromJson(e))
            .toList();
      }
    } on DioException catch (e) {
      log("Get Saved Contacts Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
