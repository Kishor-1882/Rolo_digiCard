// Common Sub-Models

class GeographyModel {
  final String? countryCode;
  final String? countryName;
  final int count;
  final dynamic percentage;

  GeographyModel({
    this.countryCode,
    this.countryName,
    required this.count,
    this.percentage,
  });

  factory GeographyModel.fromJson(Map<String, dynamic> json) {
    return GeographyModel(
      countryCode: json['countryCode'] ?? json['code'],
      countryName: json['countryName'] ?? json['name'],
      count: json['count'] ?? 0,
      percentage: json['percentage'] ?? 0,
    );
  }
}

class AnalyticsHealth {
  final int totalUsers;
  final int filteredUsersCount;
  final dynamic activeUsersPercentage;
  final int totalCards;
  final int filteredCardsCount;
  final dynamic activeCardsPercentage;
  final int totalShares;
  final int totalViews;
  final int? assignedCards;
  final int? unassignedCards;

  AnalyticsHealth({
    required this.totalUsers,
    required this.filteredUsersCount,
    this.activeUsersPercentage,
    required this.totalCards,
    required this.filteredCardsCount,
    this.activeCardsPercentage,
    required this.totalShares,
    required this.totalViews,
    this.assignedCards,
    this.unassignedCards,
  });

  factory AnalyticsHealth.fromJson(Map<String, dynamic> json) {
    return AnalyticsHealth(
      totalUsers: json['totalUsers'] ?? 0,
      filteredUsersCount: json['filteredUsersCount'] ?? 0,
      activeUsersPercentage: json['activeUsersPercentage'],
      totalCards: json['totalCards'] ?? 0,
      filteredCardsCount: json['filteredCardsCount'] ?? 0,
      activeCardsPercentage: json['activeCardsPercentage'],
      totalShares: json['totalShares'] ?? 0,
      totalViews: json['totalViews'] ?? 0,
      assignedCards: json['assignedCards'],
      unassignedCards: json['unassignedCards'],
    );
  }
}

class AnalyticsEngagement {
  final List<dynamic> chartData;
  final List<dynamic> combinedStatus;
  final List<dynamic> funnel;

  AnalyticsEngagement({
    required this.chartData,
    required this.combinedStatus,
    required this.funnel,
  });

  factory AnalyticsEngagement.fromJson(Map<String, dynamic> json) {
    return AnalyticsEngagement(
      chartData: json['chartData'] ?? json['activityTrend'] ?? [],
      combinedStatus: json['combinedStatus'] ?? [],
      funnel: json['funnel'] ?? [],
    );
  }
}

class GroupAnalyticsModel {
  final List<dynamic> distribution;
  final List<dynamic> status;
  final List<dynamic> topUserGroups;
  final int totalUserGroups;
  final int totalCardGroups;

  GroupAnalyticsModel({
    required this.distribution,
    required this.status,
    required this.topUserGroups,
    required this.totalUserGroups,
    required this.totalCardGroups,
  });

  factory GroupAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return GroupAnalyticsModel(
      distribution: json['distribution'] ?? [],
      status: json['status'] ?? [],
      topUserGroups: json['topUserGroups'] ?? [],
      totalUserGroups: json['totalUserGroups'] ?? 0,
      totalCardGroups: json['totalCardGroups'] ?? 0,
    );
  }
}

class CardGroupAnalyticsModel {
  final List<dynamic> cardsPerGroup;
  final List<dynamic> topActiveCardGroups;
  final List<dynamic> cardGroupsPerUserGroup;

  CardGroupAnalyticsModel({
    required this.cardsPerGroup,
    required this.topActiveCardGroups,
    required this.cardGroupsPerUserGroup,
  });

  factory CardGroupAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return CardGroupAnalyticsModel(
      cardsPerGroup: json['cardsPerGroup'] ?? [],
      topActiveCardGroups: json['topActiveCardGroups'] ?? [],
      cardGroupsPerUserGroup: json['cardGroupsPerUserGroup'] ?? [],
    );
  }
}

// Overview / Owner Response
class AnalyticsOverviewModel {
  final AnalyticsHealth health;
  final AnalyticsEngagement engagement;
  final GroupAnalyticsModel groupAnalytics;
  final CardGroupAnalyticsModel cardGroupAnalytics;
  final List<dynamic> groupComparison;
  final List<dynamic> zeroActivityGroups;
  final List<GeographyModel> geography;

  AnalyticsOverviewModel({
    required this.health,
    required this.engagement,
    required this.groupAnalytics,
    required this.cardGroupAnalytics,
    required this.groupComparison,
    required this.zeroActivityGroups,
    required this.geography,
  });

  factory AnalyticsOverviewModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsOverviewModel(
      health: AnalyticsHealth.fromJson(json['health'] ?? {}),
      engagement: AnalyticsEngagement.fromJson(json['engagement'] ?? {}),
      groupAnalytics: GroupAnalyticsModel.fromJson(json['groupAnalytics'] ?? {}),
      cardGroupAnalytics: CardGroupAnalyticsModel.fromJson(json['cardGroupAnalytics'] ?? {}),
      groupComparison: json['groupComparison'] ?? [],
      zeroActivityGroups: json['zeroActivityGroups'] ?? [],
      geography: (json['geography'] as List? ?? [])
          .map((e) => GeographyModel.fromJson(e))
          .toList(),
    );
  }
}

// Admin Response
class AnalyticsAdminModel {
  final Map<String, dynamic> summary;
  final Map<String, dynamic> inventory;
  final Map<String, dynamic> groups;
  final List<dynamic> userPerformance;
  final List<dynamic> topPerformingCards;

  AnalyticsAdminModel({
    required this.summary,
    required this.inventory,
    required this.groups,
    required this.userPerformance,
    required this.topPerformingCards,
  });

  factory AnalyticsAdminModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsAdminModel(
      summary: json['summary'] ?? {},
      inventory: json['inventory'] ?? {},
      groups: json['groups'] ?? {},
      userPerformance: json['userPerformance'] ?? [],
      topPerformingCards: json['topPerformingCards'] ?? [],
    );
  }

  // Helper for UI if needed
  List<dynamic> get funnel => [];
}

// User / Cards Response
class AnalyticsUserCardsModel {
  final Map<String, dynamic> kpi;
  final List<dynamic> cardPerformance;
  final Map<String, dynamic> activitySummary;
  final Map<String, dynamic> groupContext;
  final Map<String, dynamic> benchmark;

  AnalyticsUserCardsModel({
    required this.kpi,
    required this.cardPerformance,
    required this.activitySummary,
    required this.groupContext,
    required this.benchmark,
  });

  factory AnalyticsUserCardsModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsUserCardsModel(
      kpi: json['kpi'] ?? {},
      cardPerformance: json['cardPerformance'] ?? [],
      activitySummary: json['activitySummary'] ?? {},
      groupContext: json['groupContext'] ?? {},
      benchmark: json['benchmark'] ?? {},
    );
  }
}
