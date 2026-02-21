import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:rolo_digi_card/common/snack_bar.dart';
import 'package:rolo_digi_card/models/org_model.dart';
import 'package:rolo_digi_card/services/dio_client.dart';
import 'package:rolo_digi_card/services/end_points.dart';

class OrgUserManagementController extends GetxController {
  final Dio _dio = dioClient;

  final users = <OrgUser>[].obs;
  final filteredUsers = <OrgUser>[].obs;
  final isLoading = false.obs;
  final searchQuery = ''.obs;
  final statusFilter = 'All'.obs;

  final RxList<OrgCard> userCards = <OrgCard>[].obs;
  final RxBool isCardsLoading = false.obs;
  final RxBool isCardActionLoading = false.obs;


  // ── Computed stats ────────────────────────────────────────────────────────
  int get totalUsers => users.length;
  int get activeUsers => users.where((u) => u.isActive && !u.isBlocked).length;
  int get inactiveUsers => users.where((u) => !u.isActive && !u.isBlocked).length;
  int get blockedUsers => users.where((u) => u.isBlocked).length;

    final RxList<OrgUser> allUsers = <OrgUser>[].obs;
  final RxBool isUsersLoading = false.obs;
  final RxBool isAssigning = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUsers();
    ever(searchQuery, (_) => _applyFilters());
    ever(statusFilter, (_) => _applyFilters());
  }

  // ── Filter / Search ───────────────────────────────────────────────────────
  void _applyFilters() {
    var result = users.toList();

    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      result = result.where((u) {
        return u.fullName.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q) ||
            u.organizationRole.toLowerCase().contains(q);
      }).toList();
    }

    final filter = statusFilter.value;
    if (filter == 'Active') {
      result = result.where((u) => u.isActive && !u.isBlocked).toList();
    } else if (filter == 'Inactive') {
      result = result.where((u) => !u.isActive && !u.isBlocked).toList();
    } else if (filter == 'Blocked') {
      result = result.where((u) => u.isBlocked).toList();
    }

    filteredUsers.assignAll(result);
  }

  // ── 1. List All Users ─────────────────────────────────────────────────────
  // GET /api/organization/users
  Future<void> fetchUsers() async {
    try {
      isLoading.value = true;
      final response = await _dio.get(ApiEndpoints.organizationUsers);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['users'] ?? response.data['data'] ?? []);
        final list = data.map((e) => OrgUser.fromJson(e as Map<String, dynamic>)).toList();
        users.assignAll(list);
        _applyFilters();
      }
    } on DioException catch (e) {
      log('Fetch users error: $e');
      CommonSnackbar.error(_extractMessage(e, 'Failed to load users'));
    } finally {
      isLoading.value = false;
    }
  }

  // ── 2. Get Single User ────────────────────────────────────────────────────
  // GET /api/organization/users/:id
  Future<OrgUser?> getUser(String userId) async {
    try {
      final response = await _dio.get('${ApiEndpoints.organizationUsers}/$userId');
      if (response.statusCode == 200) {
        final data = response.data is Map
            ? response.data['user'] ?? response.data
            : response.data;
        return OrgUser.fromJson(data as Map<String, dynamic>);
      }
    } on DioException catch (e) {
      log('Get user error: $e');
      CommonSnackbar.error(_extractMessage(e, 'Failed to load user'));
    }
    return null;
  }

  // ── 3. Update User Status (Activate / Deactivate) ─────────────────────────
  // PATCH /api/organization/users/:id/status
  Future<void> updateUserStatus(String userId, {required bool isActive}) async {
    try {
      isLoading.value = true;
      final response = await _dio.patch(
        '${ApiEndpoints.organizationUsers}/$userId/status',
        data: {'isActive': isActive},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _updateUserLocally(userId, isActive: isActive);
        CommonSnackbar.success(
          isActive ? 'User activated successfully' : 'User deactivated successfully',
        );
      }
    } on DioException catch (e) {
      log('Update status error: $e');
      CommonSnackbar.error(_extractMessage(e, 'Failed to update user status'));
    } finally {
      isLoading.value = false;
    }
  }

  // ── 4. Update Permissions ─────────────────────────────────────────────────
  // PATCH /api/organization/users/:id/permissions
  Future<bool> updatePermissions(String userId, List<String> permissions) async {
    try {
      isLoading.value = true;
      final response = await _dio.patch(
        '${ApiEndpoints.organizationUsers}/$userId/permissions',
        data: {'permissions': permissions},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _updateUserLocally(userId, permissions: permissions);
        Get.back();
        CommonSnackbar.success('Permissions updated successfully');
        return true;
      }
    } on DioException catch (e) {
      log('Update permissions error: $e');
      CommonSnackbar.error(_extractMessage(e, 'Failed to update permissions'));
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  // ── 5. Update Role ────────────────────────────────────────────────────────
  // PATCH /api/organization/users/:id/permissions (same endpoint, different body)
  Future<bool> updateRole(String userId, String role, List<String> permissions) async {
    try {
      isLoading.value = true;
      final response = await _dio.patch(
        '${ApiEndpoints.organizationUsers}/$userId/permissions',
        data: {'role': role, 'permissions': permissions},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        _updateUserLocally(userId, organizationRole: role, permissions: permissions);
         Get.back(); // Close the edit dialog
        CommonSnackbar.success('Role updated successfully');
       
        return true;
      }
    } on DioException catch (e) {
      log('Update role error: $e');
      CommonSnackbar.error(_extractMessage(e, 'Failed to update role'));
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  // ── 6. Remove User ────────────────────────────────────────────────────────
  // DELETE /api/organization/users/:id
  Future<bool> removeUser(String userId) async {
    try {
      isLoading.value = true;
      final response = await _dio.delete('${ApiEndpoints.organizationUsers}/$userId');
      if (response.statusCode == 200 || response.statusCode == 204) {
        users.removeWhere((u) => u.id == userId);
        _applyFilters();
        Get.back();
        CommonSnackbar.success('User removed successfully');
        return true;
      }
    } on DioException catch (e) {
      log('Remove user error: $e');
      CommonSnackbar.error(_extractMessage(e, 'Failed to remove user'));
    } finally {
      isLoading.value = false;
    }
    return false;
  }

  // ── 7. Resend Invitation ──────────────────────────────────────────────────
  // POST /api/organization/users/:id/invite/resend
  Future<void> resendInvitation(String userId) async {
    try {
      isLoading.value = true;
      final response = await _dio.post(
        '${ApiEndpoints.organizationUsers}/$userId/invite/resend',
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        CommonSnackbar.success('Invitation resent successfully');
      }
    } on DioException catch (e) {
      log('Resend invite error: $e');
      Get.back();
      CommonSnackbar.error(_extractMessage(e, 'Failed to resend invitation'));
    } finally {
      isLoading.value = false;
    }
  }

    Future<void> fetchUserCards(String userId) async {
    try {
      isCardsLoading.value = true;
      final response = await _dio.get(
        ApiEndpoints.organizationCards,          // '/organization/cards'
        queryParameters: {'userId': userId},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['cards'] ?? response.data['data'] ?? []);
        userCards.assignAll(
          data.map((e) => OrgCard.fromJson(e as Map<String, dynamic>)).toList(),
        );
      }
    } on DioException catch (e) {
      log('Fetch user cards error: $e');
      CommonSnackbar.error(_extractMessage(e, 'Failed to load cards'));
    } finally {
      isCardsLoading.value = false;
    }
  }

   Future<void> fetchAllUsers() async {
    try {
      isUsersLoading.value = true;
      final response = await _dio.get(ApiEndpoints.organizationUsers);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data is List
            ? response.data
            : (response.data['users'] ?? response.data['data'] ?? []);
        allUsers.assignAll(
          data.map((e) => OrgUser.fromJson(e as Map<String, dynamic>)).toList(),
        );
      }
    } on DioException catch (e) {
      log('Fetch users error: $e');
    } finally {
      isUsersLoading.value = false;
    }
  }

    Future<bool> assignCardToUser(String cardId, String userId) async {
    try {
      log("Card ID:$cardId, User ID:$userId");  
      isAssigning.value = true;
      final response = await _dio.patch(
        '${ApiEndpoints.organizationCards}/$cardId/reassign',   // PATCH /organization/cards/{cardId}
        data: {'userId': userId},
      );
      return response.statusCode == 200;
    } on DioException catch (e) {
      log('Assign card error: $e');
      CommonSnackbar.error(_extractMessage(e, 'Failed to assign card'));
      return false;
    } finally {
      isAssigning.value = false;
    }
  }

  Future<void> toggleCardActive(OrgCard card, {required VoidCallback onSuccess}) async {
  try {
    isCardActionLoading.value = true;
    final response = await _dio.patch(
      '${ApiEndpoints.organizationCards}/${card.id}/status',
      data: {'isActive': !card.isActive},
    );
    if (response.statusCode == 200) {
      CommonSnackbar.success(card.isActive ? 'Card deactivated' : 'Card activated');
      onSuccess();
    }
  } on DioException catch (e) {
    log("Toggle card active error: $e");
    CommonSnackbar.error(_extractMessage(e, 'Failed to update card'));
  } finally {
    isCardActionLoading.value = false;
  }
}

Future<void> deleteCard(String cardId, {required VoidCallback onSuccess}) async {
  try {
    isCardActionLoading.value = true;
    final response = await _dio.delete('${ApiEndpoints.organizationCards}/$cardId');
    if (response.statusCode == 200) {
      onSuccess();
       CommonSnackbar.success('Card deleted');
    }
  } on DioException catch (e) {
        log("Delete card error: $e");
    CommonSnackbar.error(_extractMessage(e, 'Failed to delete card'));
  } finally {
    isCardActionLoading.value = false;
  }
}


  // ── Local helpers ─────────────────────────────────────────────────────────
  void _updateUserLocally(
    String userId, {
    bool? isActive,
    bool? isBlocked,
    List<String>? permissions,
    String? organizationRole,
  }) {
    final index = users.indexWhere((u) => u.id == userId);
    if (index != -1) {
      users[index] = users[index].copyWith(
        isActive: isActive,
        isBlocked: isBlocked,
        permissions: permissions,
        organizationRole: organizationRole,
      );
      _applyFilters();
    }
  }

  String _extractMessage(DioException e, String fallback) {
    if (e.response?.data is Map && e.response!.data['message'] != null) {
      return e.response!.data['message'].toString();
    }
    return fallback;
  }

  // Returns a locally-cached user by id (used by detail page before async load)
  OrgUser? getCachedUser(String userId) {
    try {
      return users.firstWhere((u) => u.id == userId);
    } catch (_) {
      return null;
    }
  }
}


class OrgUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String platformRole;
  final String userType;
  final String organizationName;
  final String organizationLogo;
  final String userState;
  final bool isActive;
  final bool isBlocked;
  final bool isEmailVerified;
  final List<String> permissions;
  final String organizationId;
  final String organizationRole;
  final String createdAt;
  final String updatedAt;
  final String? lastLogin;
  final int cardCount;

  OrgUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.platformRole,
    required this.userType,
    required this.organizationName,
    required this.organizationLogo,
    required this.userState,
    required this.isActive,
    required this.isBlocked,
    required this.isEmailVerified,
    required this.permissions,
    required this.organizationId,
    required this.organizationRole,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
    required this.cardCount,
  });

  String get fullName => '$firstName $lastName'.trim();

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  String get displayRole {
    if (organizationRole == 'owner') return 'Owner';
    if (organizationRole == 'admin') return 'Administrator';
    return 'Member';
  }

  String get statusLabel {
    if (isBlocked) return 'Blocked';
    if (isActive) return 'Active';
    return 'Inactive';
  }

  factory OrgUser.fromJson(Map<String, dynamic> json) {
    return OrgUser(
      id: json['_id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      platformRole: json['platformRole']?.toString() ?? 'user',
      userType: json['userType']?.toString() ?? '',
      organizationName: json['organizationName']?.toString() ?? '',
      organizationLogo: json['organizationLogo']?.toString() ?? '',
      userState: json['userState']?.toString() ?? 'active',
      isActive: json['isActive'] == true,
      isBlocked: json['isBlocked'] == true,
      isEmailVerified: json['isEmailVerified'] == true,
      permissions: List<String>.from(json['permissions'] ?? []),
      organizationId: json['organizationId']?.toString() ?? '',
      organizationRole: json['organizationRole']?.toString() ?? 'user',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      lastLogin: json['lastLogin']?.toString(),
      cardCount: json['cardCount'] is int ? json['cardCount'] : 0,
    );
  }

  OrgUser copyWith({
    bool? isActive,
    bool? isBlocked,
    List<String>? permissions,
    String? organizationRole,
  }) {
    return OrgUser(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      platformRole: platformRole,
      userType: userType,
      organizationName: organizationName,
      organizationLogo: organizationLogo,
      userState: userState,
      isActive: isActive ?? this.isActive,
      isBlocked: isBlocked ?? this.isBlocked,
      isEmailVerified: isEmailVerified,
      permissions: permissions ?? this.permissions,
      organizationId: organizationId,
      organizationRole: organizationRole ?? this.organizationRole,
      createdAt: createdAt,
      updatedAt: updatedAt,
      lastLogin: lastLogin,
      cardCount: cardCount,
    );
  }
}