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
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Obx(() {
          final stats = controller.dashboardStats.value;
          final org = controller.organization.value;

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
                const Text(
                  'Key Metrics',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildMetricsGrid(stats),
                const SizedBox(height: 16),
                _buildFullWidthMetric(
                  title: 'Total Scans',
                  value: stats != null ? stats.totalScans.toString() : '0',
                  trend: stats != null
                      ? '${stats.scanTrend >= 0 ? '+' : ''}${stats.scanTrend}% this week'
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
          value: stats != null
              ? (stats.totalViews > 1000
                    ? '${(stats.totalViews / 1000).toStringAsFixed(1)}K'
                    : stats.totalViews.toString())
              : '0',
          trend: stats != null ? '${stats.viewTrend}%' : '0%',
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
    final total = groupStats?['total'] ?? 0;
    final shared = groupStats?['shared'] ?? 0;

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
              .take(2)
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
