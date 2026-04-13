import 'dart:developer';

import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:rolo_digi_card/controllers/auth_controller.dart';
import 'package:rolo_digi_card/models/analytics_model.dart';
import 'package:rolo_digi_card/services/dio_client.dart';
import 'package:rolo_digi_card/services/end_points.dart';
import 'package:rolo_digi_card/views/organization/widgets/date_filter_dropdown.dart';

class AnalyticsController extends GetxController {
  final Dio _dio = dioClient;

  var isLoading = false.obs;

  // Rx Variables for different analytics sections
  var overviewData = Rxn<AnalyticsOverviewModel>();
  var adminData = Rxn<AnalyticsAdminModel>();
  var userData = Rxn<AnalyticsUserCardsModel>();
  var cardsData = Rxn<AnalyticsUserCardsModel>();
  var geographyData = <GeographyModel>[].obs;

  final selectedFilter = DateFilterOption.last30Days.obs;
  var selectedTabIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    final authController = Get.find<AuthController>();
    if (authController.userType.value == 'organization') {
      getOwnerAnalytics(days: selectedFilter.value.days);
      getAdminAnalytics(days: selectedFilter.value.days);
      // Optional: keep other specialized analytics if needed for other tabs/views
      // getUserAnalytics();
      // getCardsAnalytics();
      // getGeographyAnalytics();
    } else {
      log(
        "Skipping AnalyticsController API calls - User is not an organization",
      );
    }
  }

  // Get Analytics Overview
  Future<void> getOverview() async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.get(ApiEndpoints.analyticsOverview);
      // log('Get Overview response: ${response.data}');

      if (response.statusCode == 200) {
        overviewData.value = AnalyticsOverviewModel.fromJson(response.data);
      }
    } on DioException catch (e) {
      log("Get Overview Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Get Owner Analytics (Similar structure to Overview in API text)
  Future<void> getOwnerAnalytics({int days = 30}) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.get(ApiEndpoints.analyticsOwner(days));

      if (response.statusCode == 200) {
        // Reuse OverviewModel as structure matches "health", "engagement", etc.
        overviewData.value = AnalyticsOverviewModel.fromJson(response.data);
      }
    } on DioException catch (e) {
      log("Get Owner Analytics Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Get Admin Analytics
  Future<void> getAdminAnalytics({int days = 30}) async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.get(ApiEndpoints.analyticsAdmin(days));

      if (response.statusCode == 200) {
        adminData.value = AnalyticsAdminModel.fromJson(response.data);
      }
    } on DioException catch (e) {
      log("Get Admin Analytics Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Get User Analytics
  Future<void> getUserAnalytics() async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.get(ApiEndpoints.analyticsUser);

      if (response.statusCode == 200) {
        log("Get User Analytics response: ${response.data}");
        userData.value = AnalyticsUserCardsModel.fromJson(response.data);
      }
    } on DioException catch (e) {
      log("Get User Analytics Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Get Cards Analytics
  Future<void> getCardsAnalytics() async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.get(ApiEndpoints.analyticsCards);

      if (response.statusCode == 200) {
        cardsData.value = AnalyticsUserCardsModel.fromJson(response.data);
      }
    } on DioException catch (e) {
      log("Get Cards Analytics Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }

  // Get Geography Analytics
  Future<void> getGeographyAnalytics() async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.get(ApiEndpoints.analyticsGeography);

      if (response.statusCode == 200) {
        final List<dynamic> list = response.data is List ? response.data : [];
        geographyData.value = list
            .map((e) => GeographyModel.fromJson(e))
            .toList();
      }
    } on DioException catch (e) {
      log("Get Geography Analytics Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
