import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:rolo_digi_card/common/snack_bar.dart';
import 'package:rolo_digi_card/models/card_model.dart';
import 'package:rolo_digi_card/services/dio_client.dart';
import 'package:rolo_digi_card/services/end_points.dart';

import '../../models/dashboard_analytics.dart';

class HomePageController extends GetxController {
  String? shortUrl;
  DashboardAnalytics? dashboardAnalytics;
  CardsResponseModel? cardsResponse;

  var isLoadingCards = false.obs;
  // Form controllers
  final nameController = TextEditingController();
  final designationController = TextEditingController();
  final companyController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final websiteController = TextEditingController();
  final addressController = TextEditingController();
  final industryController = TextEditingController();
  final departmentController = TextEditingController();
  final bioController = TextEditingController();
  final skillController = TextEditingController();
  final linkedinController = TextEditingController();
  final twitterController = TextEditingController();

  // Observable states
  var selectedTheme = 'Light'.obs;
  var isPublicCard = true.obs;
  var isMinimalView = false.obs;
  var showSuccess = false.obs;
  var skills = <String>[].obs;
  var isLoading = false.obs;

  // Dio client instance
  final Dio _dio = dioClient;

  @override
  void onInit(){
    super.onInit();
    getDashboardAnalytics();
    getRecentCards();
  }
  // @override
  // void onClose() {
  //   // Dispose all controllers
  //   nameController.dispose();
  //   designationController.dispose();
  //   companyController.dispose();
  //   phoneController.dispose();
  //   emailController.dispose();
  //   websiteController.dispose();
  //   addressController.dispose();
  //   industryController.dispose();
  //   departmentController.dispose();
  //   bioController.dispose();
  //   skillController.dispose();
  //   linkedinController.dispose();
  //   twitterController.dispose();
  //   super.onClose();
  // }

  // Add skill to the list
  void addSkill() {
    if (skillController.text.isNotEmpty) {
      skills.add(skillController.text);
      skillController.clear();
    }
    update();
  }

  // Remove skill from the list
  void removeSkill(int index) {
    skills.removeAt(index);
  }

  // Toggle theme selection
  void selectTheme(String theme) {
    selectedTheme.value = theme;
  }

  // Toggle public card
  void togglePublicCard(bool value) {
    isPublicCard.value = value;
  }

  // Toggle minimal view
  void toggleMinimalView(bool value) {
    isMinimalView.value = value;
  }

  // Map theme to color values
  Map<String, String> getThemeColors() {
    switch (selectedTheme.value) {
      case 'Dark':
        return {
          'cardStyle': 'dark',
          'primaryColor': '#8B5CF6',
          'backgroundColor': '#FFFFFF',
          'textColor': '#1F2937',
        };
      case 'Glassmorphic':
        return {
          'cardStyle': 'glassmorphic',
          'primaryColor': '#8B5CF6',
          'backgroundColor': '#FFFFFF',
          'textColor': '#1F2937',
        };
      default: // Light
        return {
          'cardStyle': 'professional',
          'primaryColor': '#8B5CF6',
          'backgroundColor': '#FFFFFF',
          'textColor': '#1F2937',
        };
    }
  }

  String? validateOptionalUrl(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // empty is allowed
    }

    final uri = Uri.tryParse(value.trim());
    if (uri == null || !uri.hasAbsolutePath || !(uri.isScheme('http') || uri.isScheme('https'))) {
      return 'Enter a valid URL';
    }

    return null; // valid URL
  }

  bool isValidUrl(String value) {
    final uri = Uri.tryParse(value.trim());
    return uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
  }


  // Validate form data
  bool validateForm() {
    if (nameController.text.trim().isEmpty) {
      CommonSnackbar.error('Please enter your name');
      return false;
    }

    if (emailController.text.trim().isEmpty) {
      CommonSnackbar.error('Please enter your email');
      return false;
    }

    if (!GetUtils.isEmail(emailController.text.trim())) {
      CommonSnackbar.error('Please enter a valid email');
      return false;
    }

    if (phoneController.text.trim().isEmpty) {
      CommonSnackbar.error('Please enter your phone number');
      return false;
    }

    if (designationController.text.trim().isEmpty) {
      CommonSnackbar.error('Please enter your designation');
      return false;
    }

    if (companyController.text.trim().isEmpty) {
      CommonSnackbar.error('Please enter your company');
      return false;
    }

    if (linkedinController.text.trim().isNotEmpty &&
        !isValidUrl(linkedinController.text.trim())) {
      CommonSnackbar.error('Please enter a valid LinkedIn URL');
      return false;
    }

    if (twitterController.text.trim().isNotEmpty &&
        !isValidUrl(twitterController.text.trim())) {
      CommonSnackbar.error('Please enter a valid Twitter URL');
      return false;
    }

     if (websiteController.text.trim().isNotEmpty &&
        !isValidUrl(websiteController.text.trim())) {
      CommonSnackbar.error('Please enter a valid Website URL');
      return false;
    }



    return true;
  }

  Future<void> getDashboardAnalytics() async {
    try {
      final  response = await dioClient.get(ApiEndpoints.dashboardCardCount);

      if (response.statusCode == 200) {
        dashboardAnalytics= DashboardAnalytics.fromJson(response.data);
      } else {
        throw Exception('Failed to load dashboard analytics');
      }
    } catch (e) {
      // Handle other general errors
      log('Unexpected error in getDashboardAnalytics: $e');
      throw Exception('An unexpected error occurred');
    }
    update();
  }

  // Create card API call using Dio
  Future<void> createCard() async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;
      update();

      final themeColors = getThemeColors();

      // Prepare the request body matching your API structure
      final Map<String, dynamic> cardData = {
        'name': nameController.text.trim(),
        'title': designationController.text.trim(),
        'company': companyController.text.trim(),
        'industry':industryController.text.trim(),
        'contact': {
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'mobileNumber': phoneController.text.trim(),
          'personalEmail': emailController.text.trim(),
          'personalPhone': phoneController.text.trim(),
          'hidePersonalEmail': false,
          'hidePersonalPhone': false,
        },
        'bio': bioController.text.trim(),
        'website': websiteController.text.trim(),
        'linkedinUrl': linkedinController.text.trim(),
        'tags': skills.value,
        'theme': {
          'cardStyle': themeColors['cardStyle'],
          'primaryColor': themeColors['primaryColor'],
          'backgroundColor': themeColors['backgroundColor'],
          'textColor': themeColors['textColor'],
        },
        'isPublic': isPublicCard.value,
      };

      if (skills.isNotEmpty) {
        cardData['tags'] = skills.toList();
      }

      log("Create Card:${jsonEncode(cardData)}");

      // Make API request using Dio
      final response = await _dio.post(
        ApiEndpoints.createCard,
        data: cardData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        // adjust key based on actual response structure
        shortUrl = data['card']['shortUrl'];
        log("Short URL stored: ${data['card']['shortUrl']}");

        // Show success
        showSuccess.value = true;
        isLoading.value = false;
        update();
        CommonSnackbar.success('Card created successfully!');
        resetForm();
        getRecentCards();
      }
    } on DioException catch (e,t) {
      isLoading.value = true;
      update();
      String errorMessage = 'Failed to create card';
      log("Error in $e $t ${e.response}");
      if (e.response != null) {
        // Server responded with an error
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server took too long to respond.';
      } else if (e.type == DioExceptionType.unknown) {
        errorMessage = 'Network error. Please check your connection.';
      }
      CommonSnackbar.error(errorMessage);
    } catch (e) {
      isLoading.value = true;
      update();
      CommonSnackbar.error('An unexpected error occurred: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateCard(String cardId) async {
    if (!validateForm()) return;

    try {
      isLoading.value = true;
      update();

      final themeColors = getThemeColors();

      // Prepare the request body matching your API structure
      final Map<String, dynamic> cardData = {
        'name': nameController.text.trim(),
        'title': designationController.text.trim(),
        'company': companyController.text.trim(),
        'industry': industryController.text.trim(),
        'contact': {
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'mobileNumber': phoneController.text.trim(),
          'personalEmail': emailController.text.trim(),
          'personalPhone': phoneController.text.trim(),
          'hidePersonalEmail': false,
          'hidePersonalPhone': false,
        },
        'bio': bioController.text.trim(),
        'website': websiteController.text.trim(),
        'linkedinUrl': linkedinController.text.trim(),
        'tags': skills.value,
        'theme': {
          'cardStyle': themeColors['cardStyle'],
          'primaryColor': themeColors['primaryColor'],
          'backgroundColor': themeColors['backgroundColor'],
          'textColor': themeColors['textColor'],
        },
        'isPublic': isPublicCard.value,
      };

      if (skills.isNotEmpty) {
        cardData['tags'] = skills.toList();
      }

      log("Update Card: ${jsonEncode(cardData)}");

      // Make API request using Dio
      final response = await _dio.put(
        ApiEndpoints.updateCard(cardId), // PUT /api/cards/:cardId
        data: cardData,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        shortUrl = data['card']['shortUrl'];
        // Show success
        showSuccess.value = true;
        isLoading.value = false;
        update();
        CommonSnackbar.success('Card updated successfully!');
        resetForm();
        getRecentCards(); // Refresh the cards list
      }
    } on DioException catch (e) {
      log("ERROR:${e.response}");
      isLoading.value = false;
      update();
      String errorMessage = 'Failed to update card';

      if (e.response != null) {
        // Server responded with an error
        errorMessage = e.response?.data['message'] ?? errorMessage;
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Please check your internet connection.';
      } else if (e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'Server took too long to respond.';
      } else if (e.type == DioExceptionType.unknown) {
        errorMessage = 'Network error. Please check your connection.';
      }
      CommonSnackbar.error(errorMessage);
    } catch (e) {
      isLoading.value = false;
      update();
      CommonSnackbar.error('An unexpected error occurred: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }


  Future<void> getRecentCards({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      isLoadingCards.value= true;
      final response = await DioClient().dio.get(
        ApiEndpoints.myCard,
      );
      if (response.statusCode == 200) {
         cardsResponse = CardsResponseModel.fromJson(response.data);
         cardsResponse?.cards.sort((a, b) => b.createdAt.compareTo(a.createdAt));
         isLoadingCards.value= false;
      } else {
        isLoadingCards.value= false;
      }
      update();
    } catch (e) {
      isLoadingCards.value= false;
      log("Error in CardResponse:$e");
      update();
    }
  }

  Future<void> deleteCard(BuildContext context, String cardId) async {
      isLoading.value = true;
      update();
    try {
      final response = await dioClient.delete(
        ApiEndpoints.deleteCard(cardId),
      );
      isLoading.value = false;
      update();
      if (response.statusCode == 200 || response.statusCode == 204) {
        CommonSnackbar.success('Card Delete Successfully');
        getRecentCards();
      } else {
        // Unexpected status code
      }
      }  catch (e) {
        isLoading.value = false;
        update();

    }
  }



  // Reset form
  void resetForm() {
    log("Clear");
    nameController.clear();
    designationController.clear();
    companyController.clear();
    phoneController.clear();
    emailController.clear();
    websiteController.clear();
    addressController.clear();
    industryController.clear();
    departmentController.clear();
    bioController.clear();
    linkedinController.clear();
    twitterController.clear();
    skills.clear();
    selectedTheme.value = 'Light';
    isPublicCard.value = true;
    isMinimalView.value = false;
  }

  // Navigate to home
  void goToHome() {
    Get.offAllNamed('/home'); // Adjust route name as needed
  }

  // Navigate to view card
  void viewCard(String cardId) {
    Get.toNamed('/card-detail', arguments: {'cardId': cardId}); // Adjust route name as needed
  }

  // Add these getter methods in your controller class

  int get totalCards => cardsResponse?.cards.length ?? 0;

  int get totalViews {
    if (cardsResponse?.cards == null) return 0;
    return cardsResponse!.cards.fold(0, (sum, card) => sum + card.viewCount);
  }

  int get totalSaves {
    if (cardsResponse?.cards == null) return 0;
    return cardsResponse!.cards.fold(0, (sum, card) => sum + card.saveCount);
  }

  int get totalScans {
    if (cardsResponse?.cards == null) return 0;
    return cardsResponse!.cards.fold(0, (sum, card) => sum + card.scanCount);
  }
}