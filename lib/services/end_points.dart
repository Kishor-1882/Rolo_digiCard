class ApiEndpoints {
  //baseUrl
  static const String baseUrl = "https://digi-bend.roloscan.com";

  // Auth
  static const String register = "/api/auth/register";
  static const String login = "/api/auth/login";

  // Profile
  static const String getUserProfile = "/api/auth/profile";
  static const String updateUser = "/api/profile/updateUser";
  static const String uploadAvatar = "/api/profile/upload-avatar";
  static const String removeAvatar = "/api/profile/remove-avatar";

  // Card
  static const String dashboardCardCount = "/api/analytics/dashboard";
  static const String createCard = "/api/cards";
  static const String myCard = "/api/cards/my-cards";
  static const String savedCard = "/api/cards/saved";
  static String toggleSavedCardFavorite(String cardId) => "/api/cards/saved/$cardId/favorite";
  static String deleteSavedCard(String cardId) => "/api/cards/saved/$cardId";
  static String saveCard(String cardId) => "/api/cards/save/$cardId";
  static const String cardDetail = "/api/cards/card-detail";
  static  String viewPublicCard(String cardId) => "/api/cards/public/$cardId";
  static  String updateCard(String cardId) => "/api/cards/$cardId";
  static  String deleteCard(String cardId) => "/api/cards/$cardId";

  // QR
  static const String downloadQrCardId = "/api/qr/download/cardId";
  static const String downloadQrUserId = "/api/qr/download/userId";
  static const String qrApiUrl = "/api/qr/api/url";

  // Social Links
  static const String createLink = "/api/social/create-link";
  static const String socialComputerList = "/api/social/social-computer-list";
  static const String userSocialList = "/api/social/user-social-list";
  static const String deleteSocialLink = "/api/social/delete-link";

  // Organization
  static const String createOrganization = "/api/organization";
  static const String getOrganization = "/api/organization/me";
  static const String organizationDashboard = "/api/organization/dashboard";
  static const String organizationSettings = "/api/organization/settings";
  static const String deactivateOrganization = "/api/organization/deactivate";
  static const String activateOrganization = "/api/organization/activate";

  // User Management
  static const String organizationUsers = "/api/organization/users";
  static String getOrgUser(String userId) => "/api/organization/users/$userId"; 
  static const String inviteUser = "/api/organization/users/invite";
  static String resendInvite(String userId) => "/api/organization/users/$userId/invite/resend";
  static String deleteUser(String userId) => "/api/organization/users/$userId";
  static String updateUserStatus(String userId) => "/api/organization/users/$userId/status";
  static String updateUserPermissions(String userId) => "/api/organization/users/$userId/permissions";
  static String updateUserRole(String userId) => "/api/organization/users/$userId/role"; // Assuming separate endpoint or same perms endpoint?
  // Text file shows two "permissions" endpoints, one with role. Likely updating user role is merged with permissions or specialized.
  // The structure at line 128 of user_management.txt seems to update role AND permissions. I will make a generic update method or rely on the permissions endpoint if it handles both.
  // Actually, looking at 119 vs 128:
  // 119: permissions only
  // 128: role + permissions. Both have URL .../permissions. So one endpoint handles both likely.

  // Card Management (Organization)
  static const String organizationCards = "/api/organization/cards";
  static const String organizationCardsStats = "/api/organization/cards/stats";
  static String getOrgCard(String cardId) => "/api/organization/cards/$cardId";
  static String updateOrgCard(String cardId) => "/api/organization/cards/$cardId";
  static String updateOrgCardStatus(String cardId) => "/api/organization/cards/$cardId/status";
  static String reassignOrgCard(String cardId) => "/api/organization/cards/$cardId/reassign";
  static String deleteOrgCard(String cardId) => "/api/organization/cards/$cardId";

  // Group Management
  static const String organizationGroups = "/api/organization/groups";
  static String getOrganizationGroup(String groupId) => "/api/organization/groups/$groupId";
  static String updateOrganizationGroup(String groupId) => "/api/organization/groups/$groupId";
  static String deleteOrganizationGroup(String groupId) => "/api/organization/groups/$groupId";
  static String getGroupUsers(String groupId) => "/api/organization/groups/$groupId/users";
  static String getGroupCards(String groupId) => "/api/organization/groups/$groupId/cards";
  static String addGroupCards(String groupId) => "/api/organization/groups/$groupId/cards"; // POST based on text file logic, wait check usage
  // The endpoint listed is .../cards but with body, likely POST to add
  static String removeGroupCard(String groupId, String cardId) => "/api/organization/groups/$groupId/cards/$cardId";
  static const String bulkGroupStatus = "/api/organization/groups/bulk-status";
  
  // Note: Add/Remove Users from group endpoints were not explicitly detailed with Bodies in group_management.txt
  // but looking at `user_management.txt` line 37-38 (group:add-user, group:remove-user) permissions exist.
  // Generally it follows REST: POST /groups/:id/users for add, DELETE /groups/:id/users/:userId for remove.
  // I will add them speculatively matching the cards pattern if needed, or wait. 
  // However, I see `getGroupUsers`. I'll add `addGroupUser` and `removeGroupUser` logic in controller using standard REST conventions if needed, 
  // or maybe the logic is handled via user management "assign to group". 
  // Actually, checking `group_management.txt` again... 
  // It lists `.../users` (line 15) but no body/response shown for ADDing/removing users, just GET probably.
  // But wait, it shows `.../cards` with body to add cards. 
  // Since `group_management.txt` is the source of truth, I'll stick to what's there.
  // Line 15: `.../groups/.../users`. Probably GET.
  // There is NO explicit "Add User to Group" API documented in `group_management.txt`.
  // I will only include what I see or strongly infer.

  // Analytics (Organization)
  static const String analyticsOverview = "/api/organization/analytics/overview";
  static String analyticsOwner(int days) => "/api/organization/analytics/owner?days=$days";
  static String analyticsAdmin(int days) => "/api/organization/analytics/admin?days=$days";
  static const String analyticsUser = "/api/organization/analytics/user";
  static const String analyticsCards = "/api/organization/analytics/cards";
  static const String analyticsGeography = "/api/organization/analytics/geography";
}
