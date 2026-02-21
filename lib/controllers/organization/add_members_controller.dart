// controllers/add_member_controller.dart
import 'dart:developer';

import 'package:get/get.dart';
import 'package:dio/dio.dart';
import 'package:rolo_digi_card/models/group_model.dart';
import 'package:rolo_digi_card/services/dio_client.dart';
import 'package:rolo_digi_card/services/end_points.dart';

class AddMemberController extends GetxController {
  // Inject your Dio client

  // Observable list of team members
  final RxList<TeamMember> teamMembers = <TeamMember>[].obs;
  final Rx<GroupModel?> selectedGroup = Rx<GroupModel?>(null);

  // Loading state
  final RxBool isLoading = false.obs;
  
  // Error message
  final RxString errorMessage = ''.obs;

  // Base URL

  @override
  void onInit() {
    super.onInit();
    fetchTeamMembers();
  }

  /// Fetch all team members
  Future<void> fetchTeamMembers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await dioClient.get(ApiEndpoints.organizationUsers);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        teamMembers.value = data.map((json) => TeamMember.fromJson(json)).toList();
      } else {
        errorMessage.value = 'Failed to fetch team members';
      }
    } catch (e,t) {
      log("Error fetching team members: $e $t");
      errorMessage.value = 'An unexpected error occurred: $e';
    } finally {
      isLoading.value = false;
    }
  }

  /// Get group details by ID
Future<void> getGroupById(String groupId) async {
  try {
    isLoading.value = true;
    errorMessage.value = '';

    final response = await dioClient.get(
      '/api/organization/groups/$groupId',
    );

    if (response.statusCode == 200) {
      final groupData = GroupModel.fromJson(response.data);
      selectedGroup.value = groupData;
    } else {
      errorMessage.value = 'Failed to fetch group details';
    }
  } on DioException catch (e) {
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

  /// Add selected members to a group
Future<bool> addMembersToGroup({
  required String groupId,
  required List<String> userIds,
  required List<String> cardGroupIds,
}) async {
  try {
    isLoading.value = true;
    errorMessage.value = '';

    final Map<String, dynamic> requestData = {
      'userIds': userIds,
      'cardGroupIds': cardGroupIds,
    };

    log("Adding members to group with data: $requestData Group ID: $groupId"); // Debug log

    final response = await dioClient.post(
      ApiEndpoints.addOrgUser(groupId),
      data: requestData,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      log("Members added successfully: ${response.data}"); // Log success details
      Get.back();
      Get.snackbar(
        'Success',
        'Members added to group successfully',
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } else {
      log("Failed to add members. Status code: ${response.statusCode}, Response: ${response.data}"); // Log failure details
      errorMessage.value = 'Failed to add members to group';
      return false;
    }
  } on DioException catch (e) {
  log("DioException occurred: ${e.response?.data ?? e.message}"); // Log detailed error
    Get.snackbar(
      'Error',
      errorMessage.value,
      snackPosition: SnackPosition.BOTTOM,
    );
    return false;
  } catch (e) {
    errorMessage.value = 'An unexpected error occurred: $e';
    return false;
  } finally {
    isLoading.value = false;
  }
}

  /// Refresh team members
  Future<void> refresh() async {
    await fetchTeamMembers();
  }
}



// models/team_member_model.dart
class TeamMember {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String location;
  final String city;
  final String state;
  final String country;
  final bool isEmailVerified;
  final String emailVerificationToken;
  final DateTime? emailVerificationExpires;
  final String platformRole;
  final String userType;
  final String organizationName;
  final String organizationLogo;
  final String userState;
  final bool isActive;
  final bool isBlocked;
  final bool twoFactorEnabled;
  final List<dynamic> permissions;
  final String organizationId;
  final String organizationRole;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastLogin;
  final int cardCount;

  TeamMember({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.location,
    required this.city,
    required this.state,
    required this.country,
    required this.isEmailVerified,
    required this.emailVerificationToken,
    required this.emailVerificationExpires,
    required this.platformRole,
    required this.userType,
    required this.organizationName,
    required this.organizationLogo,
    required this.userState,
    required this.isActive,
    required this.isBlocked,
    required this.twoFactorEnabled,
    required this.permissions,
    required this.organizationId,
    required this.organizationRole,
    required this.createdAt,
    required this.updatedAt,
    this.lastLogin,
    required this.cardCount,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      location: json['location'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      isEmailVerified: json['isEmailVerified'] ?? false,
      emailVerificationToken: json['emailVerificationToken'] ?? '',
      emailVerificationExpires: json['emailVerificationExpires'] != null ? DateTime.parse(json['emailVerificationExpires']) : null,
      platformRole: json['platformRole'] ?? '',
      userType: json['userType'] ?? '',
      organizationName: json['organizationName'] ?? '',
      organizationLogo: json['organizationLogo'] ?? '',
      userState: json['userState'] ?? '',
      isActive: json['isActive'] ?? false,
      isBlocked: json['isBlocked'] ?? false,
      twoFactorEnabled: json['twoFactorEnabled'] ?? false,
      permissions: json['permissions'] ?? [],
      organizationId: json['organizationId'] ?? '',
      organizationRole: json['organizationRole'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
      cardCount: json['cardCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'location': location,
      'city': city,
      'state': state,
      'country': country,
      'isEmailVerified': isEmailVerified,
      'emailVerificationToken': emailVerificationToken,
      'emailVerificationExpires': emailVerificationExpires?.toIso8601String(),
      'platformRole': platformRole,
      'userType': userType,
      'organizationName': organizationName,
      'organizationLogo': organizationLogo,
      'userState': userState,
      'isActive': isActive,
      'isBlocked': isBlocked,
      'twoFactorEnabled': twoFactorEnabled,
      'permissions': permissions,
      'organizationId': organizationId,
      'organizationRole': organizationRole,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
      'cardCount': cardCount,
    };
  }

  String get fullName => '$firstName $lastName';
}