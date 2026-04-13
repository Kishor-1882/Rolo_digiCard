import 'dart:developer';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/common/header.dart';
import 'package:rolo_digi_card/controllers/organization/analytics_controller.dart';
import 'package:rolo_digi_card/models/analytics_model.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/views/organization/widgets/date_filter_dropdown.dart';
import 'package:intl/intl.dart';

class AdminAnalyticsView extends GetView<AnalyticsController> {
  const AdminAnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Obx(() {
          final isLoading = controller.isLoading.value;
          final adminData = controller.adminData.value;

          if (isLoading && adminData == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPink),
            );
          }

          if (adminData == null) {
            return const Center(
              child: Text(
                'No admin analytics data available',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          final summary = adminData.summary;
          final inventory = adminData.inventory;
          final groups = adminData.groups;

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

                          // 1. KPI Grid (Total Users, Cards, etc.)
                          _buildKPIGrid(summary, groups),
                          const SizedBox(height: 24),

                          // 2. Inventory Health
                          _buildInventoryHealth(inventory),
                          const SizedBox(height: 24),

                          // // 3. Usage Trends (Line Chart)
                          // _buildUsageTrendsChart(adminData.usageTrends),
                          // const SizedBox(height: 24),

                          // 4. Tabbed Group Analytics
                          _buildGroupAnalyticsSection(adminData),
                          const SizedBox(height: 24),

                          // 5. User Performance Overview
                          _buildUserPerformanceSection(
                              adminData.userPerformance),
                          const SizedBox(height: 24),

                          // 6. Top Performing Cards
                          _buildTopPerformingCardsSection(
                              adminData.topPerformingCards),
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
                    child:
                        CircularProgressIndicator(color: AppColors.primaryPink),
                  ),
                ),
            ],
          );
        }),
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
              'Admin Dashboard',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Organization-wide performance',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
          ],
        ),
        Obx(() => DateFilterDropdown(
              selected: controller.selectedFilter.value,
              onChanged: (value) {
                controller.selectedFilter.value = value;
                controller.getAdminAnalytics(days: value.days);
              },
            )),
      ],
    );
  }

  Widget _buildKPIGrid(
      Map<String, dynamic> summary, Map<String, dynamic> groups) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildKPICard('Total Users', summary['totalUsers']?.toString() ?? '0',
              Icons.people_outline, const Color(0xFF8b5cf6)),
          _buildKPICard('Total Cards', summary['totalCards']?.toString() ?? '0',
              Icons.credit_card, const Color(0xFF10b981)),
          _buildKPICard(
              'Active Cards',
              summary['activeCards']?.toString() ?? '0',
              Icons.trending_up,
              const Color(0xFF6366f1)),
          _buildKPICard(
              'Total Card Groups',
              groups['cardGroups']?.toString() ?? '0',
              Icons.groups_outlined,
              const Color(0xFF10b981)),
          _buildKPICard('Total Views', summary['totalViews']?.toString() ?? '0',
              Icons.visibility_outlined, const Color(0xFFf59e0b)),
        ],
      ),
    );
  }

  Widget _buildKPICard(String title, String value, IconData icon, Color color) {
    return Container(
      width: 154,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
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
                  style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
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
            style: const TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryHealth(Map<String, dynamic> inventory) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Inventory Health',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildInventoryCard(
                  'Unassigned',
                  inventory['unassignedCards']?.toString() ?? '0',
                  Icons.error_outline,
                  const Color(0xFFef4444)),
              _buildInventoryCard(
                  'Inactive Cards',
                  inventory['inactiveCards']?.toString() ?? '0',
                  Icons.access_time,
                  const Color(0xFFf59e0b)),
              _buildInventoryCard(
                  'Pending Users',
                  inventory['inactiveUsers']?.toString() ?? '0',
                  Icons.person_remove_outlined,
                  const Color(0xFFef4444)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInventoryCard(
      String title, String value, IconData icon, Color color) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildUsageTrendsChart(List<dynamic> usageTrends) {
    if (usageTrends.isEmpty) return const SizedBox.shrink();

    return _buildSectionCard(
      title: 'Usage Trends (Weekly)',
      child: SizedBox(
        height: 220,
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) =>
                  const FlLine(color: Colors.white10, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < usageTrends.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          usageTrends[index]['week']?.toString() ?? '',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 10),
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
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              _buildLineBar(usageTrends, 'views', const Color(0xFF8b5cf6)),
              _buildLineBar(usageTrends, 'shares', const Color(0xFF10b981)),
              _buildLineBar(
                  usageTrends, 'activeUsers', const Color(0xFFf59e0b)),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: AppColors.cardBackground,
              ),
            ),
          ),
        ),
      ),
    );
  }

  LineChartBarData _buildLineBar(List<dynamic> data, String key, Color color) {
    return LineChartBarData(
      spots: data.asMap().entries.map((e) {
        return FlSpot(
            e.key.toDouble(), ((e.value[key] ?? 0) as num).toDouble());
      }).toList(),
      isCurved: true,
      color: color,
      barWidth: 3,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: true),
      belowBarData: BarAreaData(show: false),
    );
  }

  Widget _buildGroupAnalyticsSection(AnalyticsAdminModel data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Group Analytics',
          style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          'Detailed group performance metrics',
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
        const SizedBox(height: 16),
        _buildTabSwitcher(),
        const SizedBox(height: 20),
        Obx(() => controller.selectedTabIndex.value == 0
            ? _buildSectionCard(
                title: 'Group Distribution',
                subtitle: 'Card Groups vs User Groups',
                child: _buildGroupDistributionPie(data.groups),
              )
            : Column(
                children: [
                  _buildSectionCard(
                    title: 'Top Performing Groups',
                    icon: Icons.emoji_events_outlined,
                    child: _buildTopPerformingGroupsList(
                        data.groupDetails['cardsPerCardGroup'] ?? []),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionCard(
                    title: 'Cards per Card Group',
                    subtitle: 'Top groups by card count',
                    child: _buildCardsPerGroupBarChart(
                        data.groupDetails['cardsPerCardGroup'] ?? []),
                  ),
                ],
              )),
      ],
    );
  }

  // --- Group Distribution Pie ---
  Widget _buildGroupDistributionPie(Map<String, dynamic> groups) {
    final cardGroups = (groups['cardGroups'] ?? 0) as num;
    final userGroups = (groups['userGroups'] ?? 0) as num;

    if (cardGroups == 0 && userGroups == 0) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PieChart(
            PieChartData(
              sectionsSpace: 0,
              centerSpaceRadius: 0,
              sections: [
                PieChartSectionData(
                    value: cardGroups.toDouble(),
                    color: const Color(0xFF8b5cf6),
                    radius: 60,
                    showTitle: false),
                PieChartSectionData(
                    value: userGroups.toDouble(),
                    color: const Color(0xFF10b981),
                    radius: 60,
                    showTitle: false),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Card Groups', const Color(0xFF8b5cf6)),
            const SizedBox(width: 24),
            _buildLegendItem('User Groups', const Color(0xFF10b981)),
          ],
        ),
      ],
    );
  }

  Widget _buildUserPerformanceSection(List<dynamic> users) {
    return _buildSectionCard(
      title: 'User Performance Overview',
      icon: Icons.people_outline,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final user = users[index];
          return _buildUserPerformanceItem(user);
        },
      ),
    );
  }

  Widget _buildUserPerformanceItem(dynamic user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryPink.withOpacity(0.1),
            child: Text(
              (user['firstName']?[0] ?? '') + (user['lastName']?[0] ?? ''),
              style:
                  const TextStyle(color: AppColors.primaryPink, fontSize: 12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                Text(
                  user['email'] ?? '',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${user['cardsAssigned'] ?? 0} Cards',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              _buildStatusBadge(
                  user['isActive'] == true ? 'Active' : 'Inactive'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformingCardsSection(List<dynamic> cards) {
    return _buildSectionCard(
      title: 'Top Performing Cards',
      icon: Icons.credit_card,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cards.length,
        itemBuilder: (context, index) {
          final card = cards[index];
          return _buildTopCardItem(card);
        },
      ),
    );
  }

  Widget _buildTopCardItem(dynamic card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.amber,
            radius: 14,
            child: Icon(Icons.star, color: Colors.white, size: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card['name'] ?? 'Unnamed',
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
                Text(
                  card['ownerName'] ?? 'Unknown Owner',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.6), fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${card['views'] ?? 0} Views',
                style: const TextStyle(
                    color: AppColors.primaryPink,
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
              Text(
                '${card['shares'] ?? 0} Shares',
                style: const TextStyle(color: Color(0xFF10b981), fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Common UI Helpers ---
  Widget _buildSectionCard(
      {required String title,
      String? subtitle,
      IconData? icon,
      required Widget child}) {
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
                const SizedBox(width: 10)
              ],
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(subtitle,
                style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ],
          const SizedBox(height: 24),
          child,
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
      child: Row(
        children: [
          _buildTabItem(0, 'User Groups', Icons.people_outline),
          _buildTabItem(1, 'Card Groups', Icons.credit_card_outlined),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, IconData icon) {
    return Obx(() {
      final isSelected = controller.selectedTabIndex.value == index;
      return Expanded(
        child: GestureDetector(
          onTap: () => controller.selectedTabIndex.value = index,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    color: isSelected ? AppColors.primaryPink : Colors.white54,
                    size: 18),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white54,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    bool isActive = status.toLowerCase() == 'active';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: (isActive ? const Color(0xFF10b981) : Colors.white10)
            .withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: (isActive ? const Color(0xFF10b981) : Colors.white24)
                .withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(
            color: isActive ? const Color(0xFF10b981) : Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildTopPerformingGroupsList(List<dynamic> groups) {
    if (groups.isEmpty) return const SizedBox.shrink();
    return Column(
      children: groups.asMap().entries.take(3).map((entry) {
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
                color:
                    isFirst ? Colors.yellow.withOpacity(0.3) : Colors.white10,
                width: isFirst ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: isFirst ? Colors.white : Colors.white10,
                    shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text((idx + 1).toString(),
                    style: TextStyle(
                        color: isFirst ? Colors.black : Colors.white70,
                        fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group['name'] ?? group['groupName'] ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    const Row(children: [
                      CircleAvatar(
                          radius: 3, backgroundColor: Color(0xFF10B981)),
                      SizedBox(width: 6),
                      Text('Active',
                          style: TextStyle(color: Colors.white38, fontSize: 11))
                    ]),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text((group['value'] ?? group['totalCards'] ?? 0).toString(),
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  const Text('CARDS',
                      style: TextStyle(
                          color: Colors.white38,
                          fontSize: 9,
                          fontWeight: FontWeight.w500)),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCardsPerGroupBarChart(List<dynamic> groupData) {
    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: groupData.fold<double>(
                  1,
                  (max, e) => (e['value'] ?? e['totalCards'] ?? 0) > max
                      ? (e['value'] ?? e['totalCards'] as num).toDouble()
                      : max) +
              1,
          barGroups: groupData.asMap().entries.take(5).map((entry) {
            return BarChartGroupData(x: entry.key, barRods: [
              BarChartRodData(
                  toY: ((entry.value['value'] ?? entry.value['totalCards'] ?? 0)
                          as num)
                      .toDouble(),
                  color: const Color(0xFF8b5cf6),
                  width: 16,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(4)))
            ]);
          }).toList(),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      int idx = value.toInt();
                      if (idx >= 0 && idx < groupData.length) {
                        return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                                groupData[idx]['name'] ??
                                    groupData[idx]['groupName'] ??
                                    '',
                                style: const TextStyle(
                                    color: Colors.white38, fontSize: 9)));
                      }
                      return const SizedBox();
                    })),
            leftTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 20,
                    getTitlesWidget: (v, m) => Text(v.toInt().toString(),
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 9)))),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (v) =>
                  const FlLine(color: Colors.white10, strokeWidth: 1)),
          borderData: FlBorderData(show: false),
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppColors.cardBackground,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${groupData[groupIndex]['name'] ?? groupData[groupIndex]['groupName'] ?? ''}\n',
                  const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                  children: [
                    TextSpan(
                      text: rod.toY.toInt().toString(),
                      style: const TextStyle(
                          color: AppColors.primaryPink,
                          fontSize: 12,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
