import 'dart:developer';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
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
  var savedContacts = <OrganizationUserModel>[].obs; // Using org users as contacts for now

  List<CardModel> get filteredCards {
    if (searchQuery.value.isEmpty) return savedCards;
    return savedCards.where((card) => 
      card.name.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
      card.title.toLowerCase().contains(searchQuery.value.toLowerCase())
    ).toList();
  }

  List<OrganizationUserModel> get filteredContacts {
    if (searchQuery.value.isEmpty) return savedContacts;
    return savedContacts.where((contact) => 
      contact.fullName.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
      contact.email.toLowerCase().contains(searchQuery.value.toLowerCase())
    ).toList();
  }

  @override
  void onInit() {
    super.onInit();
    getSavedCards();
    getSavedContacts();
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  Future<void> getSavedCards() async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.get(ApiEndpoints.savedCard);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
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

      // For contacts in "Saved", we might want organization users or a specific endpoint.
      // API.txt shows /api/organization/users.
      final response = await _dio.get(ApiEndpoints.organizationUsers);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        savedContacts.value = data.map((e) => OrganizationUserModel.fromJson(e)).toList();
      }
    } on DioException catch (e) {
      log("Get Saved Contacts Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
