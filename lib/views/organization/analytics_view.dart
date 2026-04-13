import 'dart:developer';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/common/header.dart';
import 'package:rolo_digi_card/controllers/auth_controller.dart';
import 'package:rolo_digi_card/controllers/organization/analytics_controller.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/views/organization/admin_analytics_view.dart';
import 'package:rolo_digi_card/views/organization/widgets/date_filter_dropdown.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final authController = Get.find<AuthController>();
      final user = authController.user.value;
      final role = user?.organizationRole?.toLowerCase() ?? '';

      // Redirect to dedicated Admin view if applicable
      if (role == 'admin') {
        return const AdminAnalyticsView();
      }

      // Default Owner UI (Preserved from the restored version)
      return Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: SafeArea(
          child: Obx(() {
            final isLoading = controller.isLoading.value;
            final overview = controller.overviewData.value;

            if (isLoading && overview == null) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryPink),
              );
            }

            if (overview == null) {
              return const Center(
                child: Text(
                  'No analytics data available',
                  style: TextStyle(color: Colors.white54),
                ),
              );
            }

            return Stack(
              children: [
                Column(
                  children: [
                    AppHeader(),
                    const SizedBox(height: 10),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            _buildHeader(context),
                            const SizedBox(height: 24),
                      
                            // 0. KPI Stats
                            _buildKPIStats(overview.health, overview.groupAnalytics, overview.engagement),
                            const SizedBox(height: 24),

                            // Tab Switcher
                            _buildTabSwitcher(),
                            const SizedBox(height: 24),

                            Obx(() => controller.selectedTabIndex.value == 0 
                              ? Column(
                                  children: [
                                    // 4. Group Distribution Analytics (Pie Chart)
                                    _buildSectionCard(
                                      title: 'Group Distribution Analytics',
                                      subtitle: 'Card Groups vs User Groups',
                                      child: _buildGroupDistributionPie(overview.groupAnalytics.distribution),
                                    ),
                                    const SizedBox(height: 24),
                              
                                    // 5. Active vs Inactive User Groups (Donut Chart)
                                    _buildSectionCard(
                                      title: 'Active vs Inactive User Groups',
                                      subtitle: 'User Group Status Overview',
                                      child: _buildUserGroupStatusDonut(overview.groupAnalytics.status),
                                    ),

                                    const SizedBox(height: 24),

                                    // 6. Members per User Group (Bar Chart)
                                    _buildSectionCard(
                                      title: 'Members per User Group',
                                      subtitle: 'Member count distribution across user groups',
                                      icon: Icons.groups_outlined,
                                      child: _buildMembersPerGroupChart(overview.groupAnalytics.topUserGroups),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    // Card Groups Specific Analytics (Mockup 2 Style)
                                    _buildSectionCard(
                                      title: 'Top Performing Groups',
                                      icon: Icons.emoji_events_outlined, // Trophy icon like mockup
                                      child: _buildTopPerformingGroupsList(overview.cardGroupAnalytics.topActiveCardGroups),
                                    ),
                                    const SizedBox(height: 24),

                                    _buildSectionCard(
                                      title: 'Cards per Card Group',
                                      subtitle: 'Distribution of cards across card groups',
                                      child: _buildCardsPerGroupBarChart(overview.cardGroupAnalytics.cardsPerGroup),
                                    ),
                                  ],
                                )

                            ),
                            
                            const SizedBox(height: 24),
                            
                            const Text(
                              "General Engagement",
                              style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 16),

                            // 1. Card Activity (Bar Chart)
                            _buildSectionCard(
                              title: 'Card Activity',
                              icon: Icons.bar_chart,
                              child: _buildCardActivityChart(overview.engagement.chartData),
                            ),
                            const SizedBox(height: 24),
                      
                            // 2. Cards Status Distribution (Donut Chart)
                            _buildSectionCard(
                              title: 'Cards Status Distribution',
                              icon: Icons.donut_large,
                              child: _buildStatusDonutChart(overview.engagement.combinedStatus),
                            ),
                            const SizedBox(height: 24),
                      
                            // 3. Funnel Analysis
                            _buildSectionCard(
                              title: 'Funnel Analysis',
                              subtitle: 'Conversion journey through stages',
                              icon: Icons.filter_list,
                              child: _buildFunnelAnalysis(overview.engagement.funnel),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                if (isLoading)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(color: AppColors.primaryPink),
                    ),
                  ),
              ],
            );
          }),
        ),
      );
    });
  }

  Widget _buildKPIStats(dynamic health, dynamic groupAnalytics, dynamic engagement) {
    // Extract dynamic funnel values with fallbacks
    final funnel = engagement.funnel as List<dynamic>? ?? [];
    
    String getFunnelValue(String id, String fallback) {
      final item = funnel.firstWhere((e) => e['id'] == id, orElse: () => null);
      if (item != null) return item['value']?.toString() ?? '0';
      return fallback;
    }

    final totalShares = getFunnelValue('shared', health.totalShares.toString());
    final totalViews = getFunnelValue('viewed', health.totalViews.toString());
    final totalSaves = getFunnelValue('saved', '0'); // Optional extra metric if needed

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildKPICard('Total Users', health.totalUsers.toString(), Icons.people_outline, const Color(0xFF6366f1)),
          _buildKPICard('Total Cards', health.totalCards.toString(), Icons.credit_card, const Color(0xFF8b5cf6)),
          _buildKPICard('Total Shares', totalShares, Icons.share_outlined, const Color(0xFF10b981)),
          _buildKPICard('Total Views', totalViews, Icons.visibility_outlined, const Color(0xFFa855f7)),
          _buildKPICard('Total User Groups', groupAnalytics.totalUserGroups.toString(), Icons.group_work_outlined, const Color(0xFFf59e0b)),
        ],
      ),
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
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
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 12, fontWeight: FontWeight.w500),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Obx(() => Row(
        children: [
          _buildTabItem(0, 'User Groups', Icons.people_outline),
          _buildTabItem(1, 'Card Groups', Icons.credit_card_outlined),
        ],
      )),
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon) {
    final isSelected = controller.selectedTabIndex.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectedTabIndex.value = index,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? AppColors.primaryPink : Colors.white54, size: 18),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white54,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Analytics',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Insights & performance metrics',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
        Obx(() => DateFilterDropdown(
          selected: controller.selectedFilter.value,
          onChanged: (value) {
            controller.selectedFilter.value = value;
            controller.getOwnerAnalytics(days: value.days);
          },
        )),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    String? subtitle,
    IconData? icon,
    required Widget child,
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
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white70, size: 20),
                const SizedBox(width: 10),
              ],
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  // --- 1. Card Activity Bar Chart ---
  Widget _buildCardActivityChart(List<dynamic> chartData) {
    if (chartData.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text('No activity data', style: TextStyle(color: Colors.white38))),
      );
    }

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            height: 200,
            width: chartData.length * 60.0 > 300 ? chartData.length * 60.0 : 340,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.center,
                maxY: chartData.fold<double>(1, (max, e) {
                  double val = [((e['created'] ?? 0) as num).toDouble(), ((e['scanned'] ?? 0) as num).toDouble()].reduce((a, b) => a > b ? a : b);
                  return val > max ? val : max;
                }) + 1,
                barGroups: chartData.asMap().entries.map((entry) {
                  final data = entry.value;
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: ((data['created'] ?? 0) as num).toDouble(),
                        color: const Color(0xFF6366f1),
                        width: 16,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: ((data['scanned'] ?? 0) as num).toDouble(),
                        color: const Color(0xFF10b981),
                        width: 16,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                    barsSpace: 4,
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  show: true,
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int idx = value.toInt();
                        if (idx >= 0 && idx < chartData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              chartData[idx]['period']?.toString() ?? '',
                              style: const TextStyle(color: Colors.white38, fontSize: 10),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white10, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Created', const Color(0xFF6366f1)),
            const SizedBox(width: 24),
            _buildLegendItem('Scanned', const Color(0xFF10b981)),
          ],
        ),
      ],
    );
  }

  // --- 2. Card Status Donut Chart ---
  Widget _buildStatusDonutChart(List<dynamic> combinedStatus) {
    if (combinedStatus.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 40,
              sections: combinedStatus.map((status) {
                return PieChartSectionData(
                  value: ((status['value'] ?? 0) as num).toDouble(),
                  color: _getStatusColor(status['name']),
                  radius: 12,
                  showTitle: false,
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: combinedStatus.map((status) {
            return _buildLegendItem(status['name'], _getStatusColor(status['name']));
          }).toList(),
        ),
      ],
    );
  }

  // --- 3. Funnel Analysis ---
  Widget _buildFunnelAnalysis(List<dynamic> funnel) {
    if (funnel.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: funnel.asMap().entries.map((entry) {
          final idx = entry.key;
          final item = entry.value;
          final color = _getFunnelColor(item['id'] ?? '');

          return Row(
            children: [
              Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                    alignment: Alignment.center,
                    child: Text(
                      item['value'].toString(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item['label'] ?? '',
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              if (idx < funnel.length - 1)
                Container(
                  width: 40,
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color, _getFunnelColor(funnel[idx + 1]['id'] ?? '')],
                    ),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // --- 4. Group Distribution Pie Chart ---
  Widget _buildGroupDistributionPie(List<dynamic> distribution) {
    if (distribution.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 0,
              sections: distribution.map((item) {
                // Use mockup-specific colors if names match
                Color color = _hexToColor(item['color'] ?? '#6366f1');
                if (item['name'] == 'Card Groups') color = const Color(0xFF6366f1);
                if (item['name'] == 'User Groups') color = const Color(0xFF10b981);

                return PieChartSectionData(
                  value: ((item['value'] ?? 1) as num).toDouble(),
                  color: color,
                  radius: 80,
                  showTitle: false,
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: distribution.map((item) {
            Color color = _hexToColor(item['color'] ?? '#6366f1');
            if (item['name'] == 'Card Groups') color = const Color(0xFF6366f1);
            if (item['name'] == 'User Groups') color = const Color(0xFF10b981);
            
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: _buildLegendItem(item['name'], color),
            );
          }).toList(),
        ),
      ],
    );
  }

  // --- 5. User Group Status Donut Chart ---
  Widget _buildUserGroupStatusDonut(List<dynamic> status) {
    log("User Group Status Data: $status");
    if (status.isEmpty) return const SizedBox.shrink();

    final totalValue = status.fold<double>(0, (sum, item) => sum + ((item['value'] ?? 0) as num).toDouble());

    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 60, // Thinner ring as per mockup
              sections: totalValue == 0 
                ? [PieChartSectionData(value: 1, color: Colors.white12, radius: 15, showTitle: false)]
                : status.map((item) {
                    return PieChartSectionData(
                      value: ((item['value'] ?? 0) as num).toDouble(),
                      color: _getUserGroupStatusColor(item['name']),
                      radius: 18,
                      showTitle: false,
                    );
                  }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 16,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: status.map((item) {
            return _buildLegendItem(item['name'], _getUserGroupStatusColor(item['name']));
          }).toList(),
        ),
      ],
    );
  }

  // --- 6. Members per Group Bar Chart ---
  Widget _buildMembersPerGroupChart(List<dynamic> groupData) {
    log("Members Per Group Data: $groupData");
    if (groupData.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text('No group data', style: TextStyle(color: Colors.white38))),
      );
    }

    return Column(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            height: 220,
            width: groupData.length * 70.0 > 300 ? groupData.length * 70.0 : 340,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: groupData.fold<double>(1, (max, e) {
                  double val = ((e['members'] ?? e['value'] ?? e['count'] ?? e['memberCount'] ?? e['usersCount'] ?? 0) as num).toDouble();
                  return val > max ? val : max;
                }) + 1,
                barGroups: groupData.asMap().entries.map((entry) {
                  return BarChartGroupData(
                    x: entry.key,
                    barRods: [
                      BarChartRodData(
                        toY: ((entry.value['members'] ?? entry.value['value'] ?? entry.value['count'] ?? entry.value['memberCount'] ?? entry.value['usersCount'] ?? 0) as num).toDouble(),
                        color: const Color(0xFF8b5cf6),
                        width: 16,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 60,
                      getTitlesWidget: (value, meta) {
                        int idx = value.toInt();
                        if (idx >= 0 && idx < groupData.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12.0),
                            child: Transform.rotate(
                              angle: -0.5,
                              child: SizedBox(
                                width: 60,
                                child: Text(
                                  groupData[idx]['name'] ?? '',
                                  style: const TextStyle(color: Colors.white38, fontSize: 9),
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(color: Colors.white38, fontSize: 10),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white10, strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- 8. Cards Per Group Bar Chart (Refined as per Mockup 2) ---
  Widget _buildCardsPerGroupBarChart(List<dynamic> groupData) {
    log("Kanchi Group Data:$groupData");
    if (groupData.isEmpty) {
      return const SizedBox(
        height: 150,
        child: Center(child: Text('No group distribution data', style: TextStyle(color: Colors.white38))),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 240,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: groupData.fold<double>(0, (max, e) => (e['totalCards'] ?? 0) > max ? (e['totalCards'] as num).toDouble() : max) + 1,
              barGroups: groupData.asMap().entries.map((entry) {
                return BarChartGroupData(
                  x: entry.key,
                  barRods: [
                    BarChartRodData(
                      toY: ((entry.value['totalCards'] ?? 0) as num).toDouble(),
                      color: const Color(0xFF8166FF), // Purple color from mockup
                      width: 22,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                    ),
                  ],
                );
              }).toList(),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      int idx = value.toInt();
                      if (idx >= 0 && idx < groupData.length) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Transform.rotate(
                            angle: -0.8,
                            child: Text(
                              groupData[idx]['groupName'] ?? '',
                              style: const TextStyle(color: Colors.white38, fontSize: 10),
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: const TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ),
                ),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) => const FlLine(color: Colors.white10, strokeWidth: 1, dashArray: [5, 5]),
              ),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
      ],
    );
  }

  // --- 9. Top Performing Groups List (Mockup 2 Style) ---
  Widget _buildTopPerformingGroupsList(List<dynamic> groups) {
    if (groups.isEmpty) {
      return const SizedBox(
        height: 100,
        child: Center(child: Text('No performance data', style: TextStyle(color: Colors.white38))),
      );
    }

    return Column(
      children: groups.asMap().entries.map((entry) {
        final idx = entry.key;
        final group = entry.value;
        final isFirst = idx == 0;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFirst ? Colors.yellow.withOpacity(0.3) : Colors.white10,
              width: isFirst ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              // Rank Circle
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isFirst ? Colors.white : Colors.white10,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  (idx + 1).toString(),
                  style: TextStyle(
                    color: isFirst ? Colors.black : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Group Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group['name'] ?? '',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Active',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Card Count
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    (group['cardCount'] ?? group['count'] ?? 0).toString(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const Text(
                    'CARDS',
                    style: TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // --- Helper Widgets & Methods ---



  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Color _getStatusColor(String? name) {

    switch (name) {
      case 'Active & Assigned': return const Color(0xFF10b981);
      case 'Active & Unassigned': return const Color(0xFFf59e0b);
      case 'Inactive & Assigned': return const Color(0xFF94a3b8);
      case 'Inactive & Unassigned': return const Color(0xFFef4444);
      default: return Colors.grey;
    }
  }

  Color _getUserGroupStatusColor(String? name) {
    switch (name) {
      case 'Active Public': return const Color(0xFF10b981);
      case 'Active Private': return const Color(0xFF10b981); // Assuming similar or same as per mockup
      case 'Inactive Public': return const Color(0xFFef4444);
      case 'Inactive Private': return const Color(0xFFf59e0b);
      default: return Colors.grey;
    }
  }

  Color _getFunnelColor(String id) {
    switch (id) {
      case 'created': return const Color(0xFF3b82f6);
      case 'shared': return const Color(0xFF8b5cf6);
      case 'viewed': return const Color(0xFF10b981);
      case 'saved': return const Color(0xFFf59e0b);
      default: return Colors.grey;
    }
  }

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF' + hex;
    return Color(int.parse(hex, radix: 16));
  }
}
