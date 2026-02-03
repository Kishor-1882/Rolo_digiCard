
// Common Sub-Models

class AnalyticsHealth {
  final int totalUsers;
  final int filteredUsersCount;
  final dynamic activeUsersPercentage; // can be int or string "100.0"
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
      chartData: json['chartData'] ?? [],
      combinedStatus: json['combinedStatus'] ?? [],
      funnel: json['funnel'] ?? [],
    );
  }
}

// Overview / Owner Response
class AnalyticsOverviewModel {
  final AnalyticsHealth health;
  final AnalyticsEngagement engagement;
  final List<dynamic> groupComparison;
  final List<dynamic> zeroActivityGroups;

  AnalyticsOverviewModel({
    required this.health,
    required this.engagement,
    required this.groupComparison,
    required this.zeroActivityGroups,
  });

  factory AnalyticsOverviewModel.fromJson(Map<String, dynamic> json) {
    return AnalyticsOverviewModel(
      health: AnalyticsHealth.fromJson(json['health'] ?? {}),
      engagement: AnalyticsEngagement.fromJson(json['engagement'] ?? {}),
      groupComparison: json['groupComparison'] ?? [],
      zeroActivityGroups: json['zeroActivityGroups'] ?? [],
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
}

// User / Cards Response (They share structure mainly)
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
