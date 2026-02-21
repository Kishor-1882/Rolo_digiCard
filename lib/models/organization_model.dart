import 'dart:developer';

class OrganizationSettings {
  final String defaultTheme;
  final String layout;
  final bool adminSettingsPermission;
  final String whoCanCreateCards;
  final bool adminCardReassignmentPermission;
  final String whoCanCreateGroups;
  final bool allowPublicAccess;
  final String defaultCardVisibility;

  OrganizationSettings({
    this.defaultTheme = 'professional',
    this.layout = 'v1',
    this.adminSettingsPermission = true,
    this.whoCanCreateCards = 'all',
    this.adminCardReassignmentPermission = false,
    this.whoCanCreateGroups = 'admin',
    this.allowPublicAccess = true,
    this.defaultCardVisibility = 'organization',
  });

  factory OrganizationSettings.fromJson(Map<String, dynamic> json) {
    return OrganizationSettings(
      defaultTheme: json['defaultTheme'] ?? 'professional',
      layout: json['layout'] ?? 'v1',
      adminSettingsPermission: json['adminSettingsPermission'] ?? true,
      whoCanCreateCards: json['whoCanCreateCards'] ?? 'all',
      adminCardReassignmentPermission: json['adminCardReassignmentPermission'] ?? false,
      whoCanCreateGroups: json['whoCanCreateGroups'] ?? 'admin',
      allowPublicAccess: json['allowPublicAccess'] ?? true,
      defaultCardVisibility: json['defaultCardVisibility'] ?? 'organization',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'defaultTheme': defaultTheme,
      'layout': layout,
      'adminSettingsPermission': adminSettingsPermission,
      'whoCanCreateCards': whoCanCreateCards,
      'adminCardReassignmentPermission': adminCardReassignmentPermission,
      'whoCanCreateGroups': whoCanCreateGroups,
      'allowPublicAccess': allowPublicAccess,
      'defaultCardVisibility': defaultCardVisibility,
    };
  }
}

class OrganizationModel {
  final String id;
  final String name;
  final List<String> domains;
  final String? logo;
  final String? description;
  final bool isActive;
  final OrganizationSettings settings;
  final String? createdAt;
  final String? updatedAt;

  OrganizationModel({
    required this.id,
    required this.name,
    required this.domains,
    this.logo,
    this.description,
    this.isActive = true,
    required this.settings,
    this.createdAt,
    this.updatedAt,
  });

  factory OrganizationModel.fromJson(Map<String, dynamic> json) {
    return OrganizationModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      domains: json['domains'] != null ? List<String>.from(json['domains']) : [],
      logo: json['logo'],
      description: json['description'],
      isActive: json['isActive'] ?? true,
      settings: json['settings'] != null
          ? OrganizationSettings.fromJson(json['settings'])
          : OrganizationSettings(),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'domains': domains,
      'logo': logo,
      'description': description,
      'isActive': isActive,
      'settings': settings.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

// --- Dashboard Models ---

class OrgDashboardStats {
  final Map<String, dynamic>? users;
  final Map<String, dynamic>? cards;
  final Map<String, dynamic>? groups;
  final Map<String, dynamic>? summary;
  final List<dynamic>? topCards;
  final List<dynamic>? topPerformingCards;
  final List<dynamic>? activityTrend;
  final List<OrgRecentActivity>? recentActivities;
  final List<dynamic>? recentGroups;

  // KPIs for UI
  int get totalUsers => users?['total'] ?? users?['totalUsers'] ?? 0;
  num get userTrend => users?['trend'] ?? users?['percentage'] ?? 0;
  
  int get totalCards => cards?['total'] ?? cards?['totalCards'] ?? 0;
  num get cardTrend => cards?['trend'] ?? 0;
  
  int get activeCards => cards?['active'] ?? cards?['activeCards'] ?? 0;
  num get activeTrend => cards?['activeTrend'] ?? 0;
  
  int get totalViews => summary?['totalViews'] ?? summary?['views'] ?? 0;
  num get viewTrend => summary?['viewTrend'] ?? 0;
  
  int get totalScans => summary?['totalScans'] ?? summary?['hits'] ?? 0;
  num get scanTrend => summary?['scanTrend'] ?? summary?['hitTrend'] ?? 0;

  OrgDashboardStats({
    this.users,
    this.cards,
    this.groups,
    this.summary,
    this.topCards,
    this.topPerformingCards,
    this.activityTrend,
    this.recentActivities,
    this.recentGroups,
  });

  factory OrgDashboardStats.fromJson(Map<String, dynamic> json) {
    log("Parsing dashboard stats: $json");
    return OrgDashboardStats(
      users: json['users'],
      cards: json['cards'],
      groups: json['groups'],
      summary: json['summary'],
      topCards: json['topCards'],
      topPerformingCards: json['topPerformingCards'],
      activityTrend: json['activityTrend'],
      recentActivities: json['recentActivities'] != null
          ? (json['recentActivities'] as List)
              .map((e) => OrgRecentActivity.fromJson(e))
              .toList()
          : [],
      recentGroups: json['recentGroups'],
    );
  }
}

class OrgRecentActivity {
  final String id;
  final String? user;
  final String action;
  final String? type; // success, error, info, warning
  final String? createdAt;

  OrgRecentActivity({
    required this.id,
    this.user,
    required this.action,
    this.type,
    this.createdAt,
  });

  factory OrgRecentActivity.fromJson(Map<String, dynamic> json) {
    return OrgRecentActivity(
      id: json['_id'] ?? '',
      user: json['user'],
      action: json['action'] ?? '',
      type: json['type'],
      createdAt: json['createdAt'],
    );
  }
}
