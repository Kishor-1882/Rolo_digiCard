import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/organization/analytics_controller.dart';
import 'package:rolo_digi_card/models/analytics_model.dart';
import 'package:rolo_digi_card/utils/color.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value &&
              controller.overviewData.value == null) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryPink),
            );
          }

          final overview = controller.overviewData.value;
          if (overview == null) {
            return const Center(
              child: Text(
                'No analytics data available',
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          final health = overview.health;
          final engagement = overview.engagement;
          final geo = controller.geographyData;
          final userData = controller.userData;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 24),
                _buildKPISelection(),
                const SizedBox(height: 24),
                _buildKPIsGrid(userData.value),
                const SizedBox(height: 24),
                _buildSectionCard(
                  title: 'Card Activity',
                  subtitle: 'Last 30 days',
                  icon: Icons.bar_chart,
                  child: _buildActivityChart(engagement.chartData),
                ),
                const SizedBox(height: 24),
                _buildSectionCard(
                  title: 'Card Status',
                  subtitle: 'Distribution',
                  icon: Icons.pie_chart_outline,
                  child: _buildStatusPie(engagement.combinedStatus),
                ),
                const SizedBox(height: 24),
                _buildSectionCard(
                  title: 'Conversion Funnel',
                  subtitle: 'User journey',
                  icon: Icons.filter_list,
                  child: _buildConversionFunnel(engagement.funnel),
                ),
                const SizedBox(height: 24),
                _buildSectionCard(
                  title: 'Geographic Distribution',
                  subtitle: 'Where your cards are viewed',
                  icon: Icons.public,
                  child: _buildGeographicDistribution(geo),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
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
    );
  }

  Widget _buildKPISelection() {
    // Placeholder for date selection if needed, currently matching mockup style
    return Container();
  }

  Widget _buildKPIsGrid(AnalyticsUserCardsModel? userData) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildKPICard(
          'Total Views',
          userData?.kpi["views"].toString() ?? '0',
          '+23%',
          Icons.visibility,
          Colors.pink,
        ),
        _buildKPICard(
          'Total Shares',
          userData?.kpi["shares"].toString() ?? '0',
          '+18%',
          Icons.share,
          Colors.purple,
        ),
        _buildKPICard(
          'Total Cards',
          userData?.kpi["totalCards"].toString() ?? '0',
          '+5%',
          Icons.card_membership,
          Colors.deepPurpleAccent,
        ),
        _buildKPICard(
          'Active Cards',
          userData?.kpi["activeCards"].toString() ?? '0',
          '+12%',
          Icons.credit_card,
          Colors.pinkAccent,
        ),
  
      ],
    );
  }

  Widget _buildKPICard(
    String title,
    String value,
    String trend,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 16),
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
                trend,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
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
    required String subtitle,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
              Icon(icon, color: Colors.white38, size: 24),
            ],
          ),
          const SizedBox(height: 32),
          child,
        ],
      ),
    );
  }

  Widget _buildActivityChart(List<dynamic> chartData) {
    if (chartData.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text(
            'No activity data',
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: [
                10.0,
                chartData.fold<double>(
                  0,
                  (max, e) => [
                    max,
                    ((e['created'] ?? 0) as num).toDouble(),
                    ((e['scanned'] ?? e['hits'] ?? 0) as num).toDouble(),
                  ].reduce((a, b) => a > b ? a : b),
                ),
              ].reduce((a, b) => a > b ? a : b),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.blueGrey,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final metric = rodIndex == 0 ? 'Created' : 'Scanned';
                    return BarTooltipItem(
                      '$metric\n${rod.toY.toInt()}',
                      const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < chartData.length) {
                        final period =
                            chartData[index]['period']?.toString() ?? '';
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            period.contains('-')
                                ? period.split('-').last
                                : period,
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      if (value == 1 || value == 5 || value == 10) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 10,
                            ),
                          ),
                        );
                      }
                      return const SizedBox();
                    },
                    reservedSize: 22,
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 5,
                getDrawingHorizontalLine: (value) =>
                    FlLine(color: Colors.white10, strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              barGroups: chartData.asMap().entries.map((entry) {
                final index = entry.key;
                final data = entry.value;
                return BarChartGroupData(
                  x: index,
                  barRods: [
                    BarChartRodData(
                      toY: ((data['created'] ?? 0) as num).toDouble(),
                      color: AppColors.primaryPink,
                      width: 12,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                    BarChartRodData(
                      toY: ((data['scanned'] ?? data['hits'] ?? 0) as num)
                          .toDouble(),
                      color: Colors.orange,
                      width: 12,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(4),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          // alignment: WrapAlignment.start,
          // spacing: 16,
          // runSpacing: 8,
          children: [
            _buildChartLegend('Created', AppColors.primaryPink),
            _buildChartLegend('Scanned', Colors.orange),
          ],
        ),
      ],
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  List<Map<String, dynamic>> normalizeStatus(List<dynamic> raw) {
    final total = raw.fold<int>(
      0,
      (sum, e) => sum + ((e['value'] ?? 0) as int),
    );

    if (total == 0) return [];

    return raw.map((e) {
      final value = e['value'] ?? 0;
      return {
        'name': e['name'],
        'value': value,
        'percentage': (value / total) * 100,
      };
    }).toList();
  }

  Widget _buildStatusPie(List<dynamic> combinedStatus) {
    final statusData = normalizeStatus(combinedStatus);

    // Get a status to display in the center (first non-zero value)
    final centerStatus = statusData.firstWhere(
      (e) => (e['value'] ?? 0) > 0,
      orElse: () => statusData.isNotEmpty
          ? statusData.first
          : {'name': 'No Data', 'value': 0},
    );

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: Stack(
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 4,
                  centerSpaceRadius: 60,
                  startDegreeOffset: -90,
                  sections: statusData.map((status) {
                    return PieChartSectionData(
                      value: (status['value'] ?? 0).toDouble(),
                      color: _getStatusColor(status['name']),
                      radius: 25,
                      showTitle: false,
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: statusData.length > 0
                      ? _buildHorizontalLegendItem(
                          statusData[0]['name'],
                          '10',
                          // statusData[0]['value'].toString(),
                          _getStatusColor(statusData[0]['name']),
                        )
                      : const SizedBox(),
                ),
                Expanded(
                  child: statusData.length > 1
                      ? _buildHorizontalLegendItem(
                          statusData[1]['name'],
                          '10',
                          // statusData[1]['value'].toString(),
                          _getStatusColor(statusData[1]['name']),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: statusData.length > 2
                      ? _buildHorizontalLegendItem(
                          statusData[2]['name'],
                          '10',
                          // statusData[2]['value'].toString(),
                          _getStatusColor(statusData[2]['name']),
                        )
                      : const SizedBox(),
                ),
                Expanded(
                  child: statusData.length > 3
                      ? _buildHorizontalLegendItem(
                          statusData[3]['name'],
                          '10',
                          // statusData[3]['value'].toString(),
                          _getStatusColor(statusData[3]['name']),
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHorizontalLegendItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                if (value != '0')
                  TextSpan(
                    text: ': $value',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String? name) {
    switch (name) {
      case 'Active & Assigned':
        return const Color(0xFF00C950);
      case 'Active & Unassigned':
        return const Color(0xFFF6A609);
      case 'Inactive & Assigned':
        return const Color(0xFF9CA3AF);
      case 'Inactive & Unassigned':
        return const Color(0xFFFB2C36);
      default:
        return Colors.grey;
    }
  }

  Widget _buildConversionFunnel(List<dynamic> funnel) {
    // Determine max value for percentage calculation
    final maxValue = funnel.isNotEmpty
        ? funnel.fold<double>(
            0,
            (max, e) => (e['value'] as num).toDouble() > max
                ? (e['value'] as num).toDouble()
                : max,
          )
        : 1.0;

    return Column(
      children: funnel.map((item) {
        final label = item['label'] ?? 'Step';
        final value = item['value'].toString();
        // Calculate percentage relative to max value in funnel, or 1.0 if max is 0
        final percentage = maxValue > 0
            ? ((item['value'] ?? 0.0) as num).toDouble() / maxValue
            : 0.0;

        return _buildFunnelItem(label, value, percentage, const [
          Color(0xFFE91E8E),
          Color(0xFF8B5CF6),
        ]);
      }).toList(),
    );
  }

  Widget _buildFunnelItem(
    String label,
    String value,
    double percentage,
    List<Color> colors,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: 8,
                    width: constraints.maxWidth * percentage,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: colors),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGeographicDistribution(List<GeographyModel> geo) {
    return Column(
      children: geo.map((region) {
        final percentage =
            ((region.percentage ?? 0.0) as num).toDouble() / 100.0;
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    region.countryName ?? 'Unknown',
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    '${region.percentage}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  Container(
                    height: 6,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        height: 6,
                        width: constraints.maxWidth * percentage,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFE91E8E), Color(0xFF8B5CF6)],
                          ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
