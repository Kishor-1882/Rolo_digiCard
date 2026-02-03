import 'dart:developer';

import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:rolo_digi_card/models/analytics_model.dart';
import 'package:rolo_digi_card/services/dio_client.dart';
import 'package:rolo_digi_card/services/end_points.dart';

class AnalyticsController extends GetxController {
  final Dio _dio = dioClient;

  var isLoading = false.obs;

  // Rx Variables for different analytics sections
  var overviewData = Rxn<AnalyticsOverviewModel>();
  var adminData = Rxn<AnalyticsAdminModel>();
  var userData = Rxn<AnalyticsUserCardsModel>();
  var cardsData = Rxn<AnalyticsUserCardsModel>();
  var geographyData = Rxn<dynamic>(); // Dynamic as structure varies or is simple list/map

  @override
  void onInit() {
    super.onInit();
  }

  // Get Analytics Overview
  Future<void> getOverview() async {
    try {
      isLoading.value = true;
      update();

      final response = await _dio.get(ApiEndpoints.analyticsOverview);

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
        geographyData.value = response.data;
      }
    } on DioException catch (e) {
      log("Get Geography Analytics Error: $e");
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
