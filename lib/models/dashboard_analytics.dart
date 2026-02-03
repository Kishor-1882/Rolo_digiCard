class DashboardAnalytics {
  final List<dynamic> recentViews; // Assuming these are brief objects/IDs
  final List<dynamic> recentScans;
  final List<dynamic> recentSaves;
  final int totalViews;
  final int totalScans;
  final int totalSaves;
  final List<TopCard> topCards;
  final List<ViewsByDay> viewsByDay;
  final DeviceBreakdown deviceBreakdown;
  final List<LocationBreakdown> locationBreakdown;

  DashboardAnalytics({
    required this.recentViews,
    required this.recentScans,
    required this.recentSaves,
    required this.totalViews,
    required this.totalScans,
    required this.totalSaves,
    required this.topCards,
    required this.viewsByDay,
    required this.deviceBreakdown,
    required this.locationBreakdown,
  });

  factory DashboardAnalytics.fromJson(Map<String, dynamic> json) {
    return DashboardAnalytics(
      recentViews: json['recentViews'] as List<dynamic>? ?? [],
      recentScans: json['recentScans'] as List<dynamic>? ?? [],
      recentSaves: json['recentSaves'] as List<dynamic>? ?? [],
      totalViews: json['totalViews'] as int? ?? 0,
      totalScans: json['totalScans'] as int? ?? 0,
      totalSaves: json['totalSaves'] as int? ?? 0,
      topCards: (json['topCards'] as List<dynamic>?)
          ?.map((e) => TopCard.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      viewsByDay: (json['viewsByDay'] as List<dynamic>?)
          ?.map((e) => ViewsByDay.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      deviceBreakdown: DeviceBreakdown.fromJson(
          json['deviceBreakdown'] as Map<String, dynamic>? ?? {}),
      locationBreakdown: (json['locationBreakdown'] as List<dynamic>?)
          ?.map(
              (e) => LocationBreakdown.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
    );
  }
}

class TopCard {
  final String cardId;
  final String name;
  final int views;
  final int saves;

  TopCard({
    required this.cardId,
    required this.name,
    required this.views,
    required this.saves,
  });

  factory TopCard.fromJson(Map<String, dynamic> json) {
    return TopCard(
      cardId: json['cardId'] as String? ?? '',
      name: json['name'] as String? ?? 'N/A',
      views: json['views'] as int? ?? 0,
      saves: json['saves'] as int? ?? 0,
    );
  }
}

class ViewsByDay {
  final String date;
  final int count;

  ViewsByDay({required this.date, required this.count});

  factory ViewsByDay.fromJson(Map<String, dynamic> json) {
    return ViewsByDay(
      date: json['date'] as String? ?? '',
      count: json['count'] as int? ?? 0,
    );
  }
}

class DeviceBreakdown {
  final int mobile;
  final int tablet;
  final int desktop;

  DeviceBreakdown({
    required this.mobile,
    required this.tablet,
    required this.desktop,
  });

  factory DeviceBreakdown.fromJson(Map<String, dynamic> json) {
    return DeviceBreakdown(
      mobile: json['mobile'] as int? ?? 0,
      tablet: json['tablet'] as int? ?? 0,
      desktop: json['desktop'] as int? ?? 0,
    );
  }
}

class LocationBreakdown {
  final String country;
  final int count;

  LocationBreakdown({required this.country, required this.count});

  factory LocationBreakdown.fromJson(Map<String, dynamic> json) {
    return LocationBreakdown(
      country: json['country'] as String? ?? 'Unknown',
      count: json['count'] as int? ?? 0,
    );
  }
}