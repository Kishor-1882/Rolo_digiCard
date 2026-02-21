import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/organization/organization_controller.dart';
import 'package:rolo_digi_card/models/organization_model.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/views/organization/organization_qr_scanner_view.dart';
import 'package:rolo_digi_card/views/organization/widgets/line_chart_painter.dart';
import 'package:rolo_digi_card/views/profile_page/profile_page.dart';

class OrganizationDashboardView extends GetView<OrganizationController> {
  const OrganizationDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
        final selectedFilter = DateFilterOption.last30Days.obs;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Obx(() {
          final stats = controller.dashboardStats.value;
          final org = controller.organization.value;
          final totalScans = stats?.summary?['totalScans'] ?? 0;

          log("Dashboard Build:${stats?.summary}");
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(org?.name ?? 'Rolo Digi Cards'),
                const SizedBox(height: 24),
                _buildGreeting(),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Key Metrics',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Obx(() => _DateFilterButton(
                      selected: selectedFilter.value,
                      onChanged: (value) {
                       selectedFilter.value = value;

                       final range = value.dateRange;
                        controller.getDashboardStats(
                          startDate: range['startDate'],
                          endDate:   range['endDate'],
               );
                      },
                    )),
                  ],
                ),
                const SizedBox(height: 16),
                _buildMetricsGrid(stats),
                const SizedBox(height: 16),
                _buildFullWidthMetric(
                  title: 'Total Scans',
                  value: totalScans > 1000
                      ? '${(totalScans / 1000).toStringAsFixed(1)}K'
                      : totalScans.toString(),
                  trend: stats != null
                      ? '${totalScans >= 0 ? '+' : ''}${totalScans}% this week'
                      : '0% this week',
                  icon: Icons.qr_code_scanner,
                  color: Colors.purple.shade400,
                  isUp: (stats?.scanTrend ?? 0) >= 0,
                ),
                const SizedBox(height: 24),
                _buildSectionCard(
                  title: 'Organization Activity',
                  icon: Icons.bar_chart,
                  child: _buildActivityChart(stats?.activityTrend),
                ),
                const SizedBox(height: 24),
                _buildSectionCard(
                  title: 'Card Status Distribution',
                  icon: Icons.credit_card,
                  child: _buildStatusDistribution(stats?.cards),
                ),
                const SizedBox(height: 24),
                _buildSectionCard(
                  title: 'Top Performing Cards',
                  icon: Icons.emoji_events_outlined,
                  child: _buildTopPerformingCards(stats?.topPerformingCards),
                ),
                const SizedBox(height: 24),
                _buildSectionCard(
                  title: 'Groups Summary',
                  icon: Icons.folder_open,
                  showViewAll: true,
                  child: _buildGroupsSummary(
                    stats?.groups,
                    stats?.recentGroups,
                  ),
                ),
                const SizedBox(height: 24),
                _buildSectionCard(
                  title: 'Recent Activity',
                  icon: Icons.access_time,
                  child: SizedBox(
                    height: 200,
                    child: Scrollbar(
                      thickness: 4,
                      trackVisibility: false,
                      child: SingleChildScrollView(
                        child: _buildRecentActivity(stats?.recentActivities),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _buildScannedCards(),
                const SizedBox(height: 32),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(String orgName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            // IconButton(
            //   onPressed: () {},
            //   icon: const Icon(Icons.menu, color: AppColors.textPrimary),
            // ),
            // const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primaryPink,
                shape: BoxShape.circle,
              ),
              child: Text(
                orgName.isNotEmpty ? orgName[0].toUpperCase() : 'R',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              orgName,
              style: const TextStyle(
                color: AppColors.primaryPink,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: () {
            Get.to(() => const ProfilePage());
            // Profile action
          },
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.purple.shade400,
              shape: BoxShape.circle,
            ),
            child: Text(
              controller.currentUser.value?.initials ?? 'JD',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else if (hour < 21) {
      return 'Good Evening';
    } else {
      return 'Good Night';
    }
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                '${getGreeting()}, ${controller.currentUser.value?.fullName.split(' ').first ?? 'User'} 👋',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const Text(
          'Organization overview',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid(OrgDashboardStats? stats) {
    final totalViews = stats?.summary?['totalViews'] ?? 0;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _buildMetricCard(
          title: 'Total Users',
          value: stats != null ? stats.totalUsers.toString() : '0',
          trend: stats != null ? '${stats.userTrend}%' : '0%',
          isUp: (stats?.userTrend ?? 0) >= 0,
          icon: Icons.people_outline,
          isGradient: true,
        ),
        _buildMetricCard(
          title: 'Total Cards',
          value: stats != null ? stats.totalCards.toString() : '0',
          trend: stats != null ? '${stats.cardTrend}%' : '0%',
          isUp: (stats?.cardTrend ?? 0) >= 0,
          icon: Icons.credit_card,
        ),
        _buildMetricCard(
          title: 'Active Cards',
          value: stats != null ? stats.activeCards.toString() : '0',
          trend: stats != null ? '${stats.activeTrend}%' : '0%',
          isUp: (stats?.activeTrend ?? 0) >= 0,
          icon: Icons.show_chart,
        ),
        _buildMetricCard(
          title: 'Total Views',
         value: totalViews > 1000
    ? '${(totalViews / 1000).toStringAsFixed(1)}K'
    : totalViews.toString(),
          trend: stats != null ? '${totalViews}%' : '0%',
          isUp: (stats?.viewTrend ?? 0) >= 0,
          icon: Icons.visibility_outlined,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String trend,
    required bool isUp,
    required IconData icon,
    bool isGradient = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isGradient ? null : AppColors.cardBackground,
        gradient: isGradient
            ? const LinearGradient(
                colors: [Color(0xFFE91E8E), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        border: isGradient ? null : Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              Row(
                children: [
                  Icon(
                    isUp ? Icons.north_east : Icons.south_east,
                    color: isUp ? Colors.white70 : Colors.redAccent,
                    size: 14,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    trend,
                    style: TextStyle(
                      color: isUp ? Colors.white70 : Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFullWidthMetric({
    required String title,
    required String value,
    required String trend,
    required IconData icon,
    required Color color,
    required bool isUp,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Icon(
                isUp ? Icons.north_east : Icons.south_east,
                color: isUp ? Colors.greenAccent : Colors.redAccent,
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                trend,
                style: TextStyle(
                  color: isUp ? Colors.greenAccent : Colors.redAccent,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    bool showViewAll = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.primaryPink, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              if (showViewAll)
                InkWell(
                  onTap: () {
                    controller.changeIndex(3);
                  },
                  child: Row(
                    children: [
                      Text(
                        'View All',
                        style: TextStyle(
                          color: Colors.pink.shade300,
                          fontSize: 14,
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: Colors.pink.shade300,
                        size: 18,
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildActivityChart(List<dynamic>? trendData) {
    if (trendData == null || trendData.isEmpty) {
      return const Center(
        child: Text(
          'No activity data',
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 150,
          width: double.infinity,
          child: CustomPaint(painter: LineChartPainter(trendData)),
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartLegendItem('Saves', const Color(0xFF00C950)),
              const SizedBox(width: 12),
              _buildChartLegendItem('Scans', Colors.orange),
              const SizedBox(width: 12),
              _buildChartLegendItem('Shares', Colors.blueAccent),
              const SizedBox(width: 12),
              _buildChartLegendItem('Views', Colors.purpleAccent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChartLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildStatusDistribution(Map<String, dynamic>? cardStats) {
    if (cardStats == null) return Container();

    final int total = cardStats['total'] ?? 0;
    if (total == 0)
      return const Center(
        child: Text('No card data', style: TextStyle(color: Colors.white38)),
      );

    final int assigned = cardStats['assigned'] ?? 0;
    final int unassigned = cardStats['unassigned'] ?? 0;
    final int active = cardStats['active'] ?? 0;
    final int inactive = cardStats['inactive'] ?? 0;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: [
              Expanded(
                flex: assigned,
                child: Container(height: 12, color: const Color(0xFF00C950)),
              ),
              Expanded(
                flex: unassigned,
                child: Container(height: 12, color: const Color(0xFF51A2FF)),
              ),
              Expanded(
                flex: active,
                child: Container(height: 12, color: const Color(0xFF74EF9F)),
              ),
              Expanded(
                flex: inactive,
                child: Container(height: 12, color: const Color(0xFFFB2C36)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 3,
          children: [
            _buildStatusItem(
              'Assigned Cards',
              '$assigned (${((assigned / total) * 100).toInt()}%)',
              const Color(0xFF00C950),
            ),
            _buildStatusItem(
              'Unassigned Cards',
              '$unassigned (${((unassigned / total) * 100).toInt()}%)',
              const Color(0xFF51A2FF),
            ),
            _buildStatusItem(
              'Active Cards',
              '$active',
              const Color(0xFF74EF9F),
            ),
            _buildStatusItem(
              'Inactive Cards',
              '$inactive',
              const Color(0xFFFB2C36),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white54, fontSize: 10),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopPerformingCards(List<dynamic>? topCards) {
    log("Top performing cards: $topCards");
    if (topCards == null || topCards.isEmpty) {
      return const Center(
        child: Text(
          'No performance data',
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    return Column(
      children: topCards.map((card) {
        final index = topCards.indexOf(card) + 1;
        final name = card['name'] ?? 'Untitled Card';
        final scans = card['scanCount'] ?? card['hits'] ?? 0;
        final views = card['viewCount'] ?? 0;

        Color rankColor;
        switch (index) {
          case 1:
            rankColor = Colors.orange;
            break;
          case 2:
            rankColor = Colors.blueGrey;
            break;
          case 3:
            rankColor = Colors.brown;
            break;
          default:
            rankColor = Colors.grey;
        }

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: rankColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '#$index',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.qr_code_scanner,
                          color: Colors.white54,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          scans.toString(),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.visibility_outlined,
                          color: Colors.white54,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          views.toString(),
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildGroupsSummary(
    Map<String, dynamic>? groupStats,
    List<dynamic>? recentGroups,
  ) {
    log("Group stats: $groupStats");
    final total = groupStats?['total'] ?? 0;
    // final shared = groupStats?['shared'] ?? 0;
   final shared = recentGroups?.where((group) => group['isShared'] == true).length ?? 0;


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildSummaryBox(total.toString(), 'Total Groups')),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryBox(
                shared.toString(),
                'Shared Groups',
                icon: Icons.share,
              ),
            ),
          ],
        ),
        if (recentGroups != null && recentGroups.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Text(
            'Recently Added',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ...recentGroups
              .map(
                (g) => _buildGroupItem(
                  g['name'] ?? 'Untitled',
                  '${g['members']?.length ?? 0} members',
                ),
              ),
        ],
      ],
    );
  }

  Widget _buildSummaryBox(String value, String label, {IconData? icon}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.blueAccent, size: 16),
                const SizedBox(width: 4),
              ],
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupItem(String name, String members) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 14)),
          Text(
            members,
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(List<OrgRecentActivity>? activities) {
    if (activities == null || activities.isEmpty) {
      return const Center(
        child: Text(
          'No recent activity',
          style: TextStyle(color: Colors.white38),
        ),
      );
    }

    return Column(
      children: activities.map((activity) {
        final title = activity.action;
        final subtitle = activity.user ?? 'System';
        final time = _formatActivityTime(activity.createdAt);

        Color color;
        IconData icon;

        switch (activity.type) {
          case 'success':
            color = Colors.green;
            icon = Icons.check_circle;
            break;
          case 'error':
            color = Colors.red;
            icon = Icons.error;
            break;
          case 'warning':
            color = Colors.orange;
            icon = Icons.warning;
            break;
          default:
            color = Colors.blue;
            icon = Icons.info;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                time,
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatActivityTime(String? createdAt) {
    if (createdAt == null) return '';
    try {
      final date = DateTime.parse(createdAt);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    } catch (e) {
      return '';
    }
  }

  Widget _buildScannedCards() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.qr_code, color: AppColors.primaryPink, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Scanned Cards',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.qr_code_2,
                  color: Colors.white24,
                  size: 64,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No scanned cards yet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Scan a card to see it appear here',
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE91E8E), Color(0xFF8B5CF6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE91E8E).withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () => Get.to(() => const OrganizationQRScannerView()),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner, color: Colors.white),
                SizedBox(width: 12),
                Text(
                  'Start Scanning',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class _DateFilterButton extends StatelessWidget {
  final DateFilterOption selected;
  final ValueChanged<DateFilterOption> onChanged;

  const _DateFilterButton({
    required this.selected,
    required this.onChanged,
  });

  static const _bgColor      = Color(0xFF1E1E2E);
  static const _borderColor  = Color(0xFF2E2E45);
  static const _accentColor  = Color(0xFF7C5CFC);
  static const _selectedBg   = Color(0xFF2A2A3E);
  static const _textColor    = Color(0xFFE8E8F0);
  static const _mutedColor   = Color(0xFF9090A8);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showMenu(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_today_rounded, color: _accentColor, size: 14),
            const SizedBox(width: 6),
            Text(
              selected.label,
              style: const TextStyle(
                color: _textColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.keyboard_arrow_down_rounded, color: _mutedColor, size: 16),
          ],
        ),
      ),
    );
  }

  void _showMenu(BuildContext context) async {
    // Find the button's position on screen
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    final result = await showMenu<DateFilterOption>(
      context: context,
      position: position,
      color: const Color(0xFF1A1A28),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFF2E2E45)),
      ),
      elevation: 12,
      items: DateFilterOption.values.map((option) {
        final isSelected = option == selected;
        return PopupMenuItem<DateFilterOption>(
          value: option,
          padding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            color: isSelected ? _selectedBg : Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  option.label,
                  style: TextStyle(
                    color: isSelected ? _accentColor : _textColor,
                    fontSize: 14,
                    fontWeight:
                        isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: _accentColor,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      }).toList(),
    );

    if (result != null) onChanged(result);
  }
}

enum DateFilterOption {
  today,
  yesterday,
  thisWeek,
  lastWeek,
  thisMonth,
  lastMonth,
  last30Days,
  thisYear,
  lastYear,
  custom,
}

extension DateFilterOptionLabel on DateFilterOption {
  String get label {
    switch (this) {
      case DateFilterOption.today:      return 'Today';
      case DateFilterOption.yesterday:  return 'Yesterday';
      case DateFilterOption.thisWeek:   return 'This Week';
      case DateFilterOption.lastWeek:   return 'Last Week';
      case DateFilterOption.thisMonth:  return 'This Month';
      case DateFilterOption.lastMonth:  return 'Last Month';
      case DateFilterOption.last30Days: return 'Last 30 Days';
      case DateFilterOption.thisYear:   return 'This Year';
      case DateFilterOption.lastYear:   return 'Last Year';
      case DateFilterOption.custom:     return 'Custom';
    }
  }

   /// Logic mirrors your API: day boundaries are at 18:30 UTC (midnight IST).
  Map<String, String> get dateRange {
    final now = DateTime.now().toUtc();

    // IST midnight = 18:30 UTC previous day
    // "Start of today" in IST means 18:30 UTC of the previous calendar day.
    DateTime todayStart = DateTime.utc(now.year, now.month, now.day - 1, 18, 30, 0, 0);
    // If current UTC time is already past 18:30, today's IST start is today at 18:30 UTC
    if (now.hour > 18 || (now.hour == 18 && now.minute >= 30)) {
      todayStart = DateTime.utc(now.year, now.month, now.day, 18, 30, 0, 0);
    }
    final todayEnd = todayStart.add(const Duration(days: 1)).subtract(const Duration(milliseconds: 1));

    DateTime start;
    DateTime end;

    switch (this) {
      case DateFilterOption.today:
        start = todayStart;
        end   = todayEnd;
        break;

      case DateFilterOption.yesterday:
        start = todayStart.subtract(const Duration(days: 1));
        end   = todayStart.subtract(const Duration(milliseconds: 1));
        break;

      case DateFilterOption.thisWeek:
        // Week starts Monday IST
        final daysFromMonday = now.weekday - 1; // Monday = 1
        start = todayStart.subtract(Duration(days: daysFromMonday));
        end   = todayEnd;
        break;

      case DateFilterOption.lastWeek:
        final daysFromMonday = now.weekday - 1;
        end   = todayStart.subtract(Duration(days: daysFromMonday)).subtract(const Duration(milliseconds: 1));
        start = end.subtract(const Duration(days: 6)).copyWith(hour: 18, minute: 30, second: 0, millisecond: 0);
        break;

      case DateFilterOption.thisMonth:
        // Start of current month in IST = last day of previous month at 18:30 UTC
        start = DateTime.utc(now.year, now.month, 1).subtract(const Duration(hours: 5, minutes: 30));
        end   = todayEnd;
        break;

      case DateFilterOption.lastMonth:
        final firstOfThisMonth = DateTime.utc(now.year, now.month, 1).subtract(const Duration(hours: 5, minutes: 30));
        end   = firstOfThisMonth.subtract(const Duration(milliseconds: 1));
        start = DateTime.utc(now.year, now.month - 1, 1).subtract(const Duration(hours: 5, minutes: 30));
        break;

      case DateFilterOption.last30Days:
        start = todayStart.subtract(const Duration(days: 30));
        end   = todayEnd;
        break;

      case DateFilterOption.thisYear:
        start = DateTime.utc(now.year, 1, 1).subtract(const Duration(hours: 5, minutes: 30));
        end   = todayEnd;
        break;

      case DateFilterOption.lastYear:
        start = DateTime.utc(now.year - 1, 1, 1).subtract(const Duration(hours: 5, minutes: 30));
        end   = DateTime.utc(now.year, 1, 1).subtract(const Duration(hours: 5, minutes: 30, milliseconds: 1));
        break;

      case DateFilterOption.custom:
        // Return empty — caller handles custom date picker
        return {'startDate': '', 'endDate': ''};
    }

    log('Start: $start, End: $end');
    log('Start Iso: ${start.toIso8601String()}, End Iso: ${end.toIso8601String()}');
    return {
      'startDate': start.toIso8601String(),
      'endDate':   end.toIso8601String(),
    };
  }
}