import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:rolo_digi_card/controllers/auth_controller.dart';
import 'package:rolo_digi_card/services/end_points.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DioClient {
  final Dio _dio;
  static String? _cachedAccessToken;
  static bool _isRefreshing = false;
  static final List<Function()> _retryQueue = [];

  DioClient._internal(this._dio) {
    _initializeDio();
  }

  factory DioClient() {
    return DioClient._internal(Dio());
  }

  static void setToken(String token) {
    _cachedAccessToken = token;
  }

   Future<void> clearTokens() async {
    _cachedAccessToken = null;
    const storage = FlutterSecureStorage();
    await storage.delete(key: 'accessToken');
    await storage.delete(key: 'refreshToken');
  }

  void _initializeDio() {
    _dio.options = BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  // ---------------- REQUEST ----------------
  Future<void> _onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  // ---------------- ERROR ----------------
  Future<void> _onError(
      DioException error, ErrorInterceptorHandler handler) async {
    if (error.response?.statusCode == 4001) {
      final requestOptions = error.requestOptions;

      // Queue the failed request
      _retryQueue.add(() async {
        final response = await _dio.fetch(requestOptions);
        handler.resolve(response);
      });

      if (_isRefreshing) return;

      _isRefreshing = true;

      final success = await _refreshToken();

      _isRefreshing = false;

      if (success) {
        for (final retry in _retryQueue) {
          retry();
        }
        _retryQueue.clear();
      } else {
        _retryQueue.clear();
        await clearTokens();
        Get.offAllNamed("/login");
      }
      return;
    }

    handler.next(error);
  }

  // ---------------- TOKEN ----------------
  Future<String?> _getAccessToken() async {
    if (_cachedAccessToken != null) return _cachedAccessToken;

    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'accessToken');
    _cachedAccessToken = token;
    return token;
  }

  // ---------------- REFRESH ----------------
  Future<bool> _refreshToken() async {
    try {
      const storage = FlutterSecureStorage();
      final refreshToken = await storage.read(key: 'refreshToken');

      if (refreshToken == null) return false;

      final response = await Dio().post(
        '${ApiEndpoints.baseUrl}/api/auth/refresh-token',
        data: {
          "refreshToken": refreshToken,
        },
      );

      final newAccessToken = response.data["tokens"]["accessToken"];
      final newRefreshToken = response.data["tokens"]["refreshToken"];

      await storage.write(key: 'accessToken', value: newAccessToken);
      await storage.write(key: 'refreshToken', value: newRefreshToken);

      _cachedAccessToken = newAccessToken;
      return true;
    } catch (_) {
      return false;
    }
  }

  Dio get dio => _dio;
}

// Usage
final dioClient = DioClient().dio;