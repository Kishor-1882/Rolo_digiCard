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
}
