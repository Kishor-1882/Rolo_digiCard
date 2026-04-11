import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrganizationActivityChart extends StatelessWidget {
  final List<dynamic> chartData;

  const OrganizationActivityChart({Key? key, required this.chartData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (chartData.isEmpty) return const SizedBox.shrink();

    List<FlSpot> saveSpots = [];
    List<FlSpot> scanSpots = [];
    List<FlSpot> shareSpots = [];
    List<FlSpot> viewSpots = [];

    double maxY = 0;

    for (int i = 0; i < chartData.length; i++) {
      final data = chartData[i];
      double saves = ((data['saves'] ?? 0) as num).toDouble();
      double scans = ((data['scans'] ?? data['hits'] ?? 0) as num).toDouble();
      double shares = ((data['shares'] ?? 0) as num).toDouble();
      double views = ((data['views'] ?? 0) as num).toDouble();

      saveSpots.add(FlSpot(i.toDouble(), saves));
      scanSpots.add(FlSpot(i.toDouble(), scans));
      shareSpots.add(FlSpot(i.toDouble(), shares));
      viewSpots.add(FlSpot(i.toDouble(), views));

      if (saves > maxY) maxY = saves;
      if (scans > maxY) maxY = scans;
      if (shares > maxY) maxY = shares;
      if (views > maxY) maxY = views;
    }

    if (maxY == 0) maxY = 1; // avoid division by zero

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: (chartData.length - 1).toDouble(),
        minY: 0,
        maxY: maxY + (maxY * 0.1),
        lineBarsData: [
          _buildLineChartBarData(saveSpots, const Color(0xFF00C950)),
          _buildLineChartBarData(scanSpots, Colors.orange),
          _buildLineChartBarData(shareSpots, Colors.blueAccent),
          _buildLineChartBarData(viewSpots, Colors.purpleAccent),
        ],
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY > 5 ? maxY / 5 : 1,
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
              reservedSize: 22,
              interval: max(1, chartData.length / 7).floorToDouble(),
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index < 0 ||
                    index >= chartData.length ||
                    value != value.truncateToDouble()) {
                  return const SizedBox.shrink();
                }

                String dateStr =
                    (chartData[index]['_id'] ?? chartData[index]['date'])
                            ?.toString() ??
                        '';
                String formatted = dateStr;
                try {
                  if (dateStr.isNotEmpty) {
                    DateTime dt = DateTime.parse(dateStr);
                    formatted = DateFormat('d MMM').format(dt);
                  }
                } catch (e) {
                  formatted = dateStr.split('-').last;
                }

                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    formatted,
                    style: const TextStyle(color: Colors.white54, fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: maxY > 5 ? maxY / 5 : (maxY / 2 > 0 ? maxY / 2 : 1),
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toStringAsFixed(
                      value == value.truncateToDouble() ? 0 : 1),
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                  textAlign: TextAlign.left,
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: Colors.black87,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  spot.y.toStringAsFixed(0),
                  const TextStyle(color: Colors.white, fontSize: 12),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  LineChartBarData _buildLineChartBarData(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      spots: spots,
      isCurved: true,
      preventCurveOverShooting: true,
      color: color,
      barWidth: 2,
      isStrokeCapRound: true,
      dotData: const FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.3), color.withOpacity(0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }
}
