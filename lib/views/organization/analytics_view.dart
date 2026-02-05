import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/organization/analytics_controller.dart';
import 'package:rolo_digi_card/models/analytics_model.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/views/organization/widgets/line_chart_painter.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value && controller.overviewData.value == null) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
          }

          final overview = controller.overviewData.value;
          if (overview == null) {
            return const Center(child: Text('No analytics data available', style: TextStyle(color: Colors.white54)));
          }

          final health = overview.health;
          final engagement = overview.engagement;
          final geo = controller.geographyData;

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
                _buildKPIsGrid(health),
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
                  child: _buildStatusDonut(engagement.combinedStatus),
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
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildKPISelection() {
    // Placeholder for date selection if needed, currently matching mockup style
    return Container();
  }

  Widget _buildKPIsGrid(AnalyticsHealth health) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildKPICard('Total Views', health.totalViews.toString(), '+23%', Icons.visibility, Colors.pink),
        _buildKPICard('Total Shares', health.totalShares.toString(), '+18%', Icons.share, Colors.purple),
        _buildKPICard('Active Cards', '${health.activeCardsPercentage}%', '+12%', Icons.credit_card, Colors.pinkAccent),
        _buildKPICard('Total Users', health.totalUsers.toString(), '+5%', Icons.people, Colors.deepPurpleAccent),
      ],
    );
  }

  Widget _buildKPICard(String title, String value, String trend, IconData icon, Color color) {
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
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
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
    return Column(
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child: CustomPaint(
            painter: LineChartPainter(chartData),
          ),
        ),
        const SizedBox(height: 24),
        Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildChartLegend('Saves', const Color(0xFF00C950)),
          const SizedBox(width: 16),
          _buildChartLegend('Scans', Colors.orange),
          const SizedBox(width: 16),
          _buildChartLegend('Shares', Colors.blueAccent),
          const SizedBox(width: 16),
          _buildChartLegend('Views', Colors.purpleAccent),
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
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildStatusDonut(List<dynamic> combinedStatus) {
    // combinedStatus structure usually: [{name: Active, count: 756, percentage: 75}, ...]
    final active = combinedStatus.firstWhere((e) => e['name'] == 'Active', orElse: () => {'count': 0})['count'];
    final inactive = combinedStatus.firstWhere((e) => e['name'] == 'Inactive', orElse: () => {'count': 0})['count'];
    final pending = combinedStatus.firstWhere((e) => e['name'] == 'Pending', orElse: () => {'count': 0})['count'];

    return Row(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: CustomPaint(
            painter: DonutChartPainter(combinedStatus),
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          child: Column(
            children: [
              _buildStatusRow('Active', active.toString(), const Color(0xFF00C950)),
              const SizedBox(height: 12),
              _buildStatusRow('Inactive', inactive.toString(), const Color(0xFFFB2C36)),
              const SizedBox(height: 12),
              _buildStatusRow('Pending', pending.toString(), const Color(0xFFF6A609)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildConversionFunnel(List<dynamic> funnel) {
    return Column(
      children: funnel.map((item) {
        final label = item['name'] ?? 'Step';
        final value = item['count'].toString();
        final percentage = ((item['percentage'] ?? 0.0) as num).toDouble() / 100.0;
        return _buildFunnelItem(label, value, percentage, const [Color(0xFFE91E8E), Color(0xFF8B5CF6)]);
      }).toList(),
    );
  }

  Widget _buildFunnelItem(String label, String value, double percentage, List<Color> colors) {
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
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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
        final percentage = ((region.percentage ?? 0.0) as num).toDouble() / 100.0;
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
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
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


class DonutChartPainter extends CustomPainter {
  final List<dynamic> combinedStatus;
  DonutChartPainter(this.combinedStatus);

  @override
  void paint(Canvas canvas, Size size) {
    if (combinedStatus.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 20.0;

    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);
    double startAngle = -pi / 2;

    for (var status in combinedStatus) {
      final percentage = ((status['percentage'] ?? 0.0) as num).toDouble() / 100.0;
      if (percentage == 0) continue;

      final paint = Paint()
        ..color = _getStatusColor(status['name'])
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * pi * percentage;
      canvas.drawArc(rect, startAngle + 0.05, sweepAngle - 0.1, false, paint);
      startAngle += sweepAngle;
    }
  }

  Color _getStatusColor(String? name) {
    switch (name) {
      case 'Active':
        return const Color(0xFF00C950);
      case 'Pending':
        return const Color(0xFFF6A609);
      case 'Inactive':
        return const Color(0xFFFB2C36);
      default:
        return Colors.grey;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
