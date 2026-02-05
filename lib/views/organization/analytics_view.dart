import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/organization/analytics_controller.dart';
import 'package:rolo_digi_card/utils/color.dart';

class AnalyticsView extends GetView<AnalyticsController> {
  const AnalyticsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildKPISelection(),
              const SizedBox(height: 24),
              _buildKPIsGrid(),
              const SizedBox(height: 24),
              _buildSectionCard(
                title: 'Card Activity',
                subtitle: 'Last 7 days',
                icon: Icons.bar_chart,
                child: _buildActivityChart(),
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                title: 'Card Status',
                subtitle: 'Distribution',
                icon: Icons.pie_chart_outline,
                child: _buildStatusDonut(),
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                title: 'Conversion Funnel',
                subtitle: 'User journey',
                icon: Icons.filter_list,
                child: _buildConversionFunnel(),
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                title: 'Geographic Distribution',
                subtitle: 'Where your cards are viewed',
                icon: Icons.public,
                child: _buildGeographicDistribution(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
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

  Widget _buildKPIsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildKPICard('Total Views', '24.5K', '+23%', Icons.visibility, Colors.pink),
        _buildKPICard('Total Scans', '1,260', '+18%', Icons.qr_code_scanner, Colors.purple),
        _buildKPICard('Active Users', '1,156', '+12%', Icons.people, Colors.pinkAccent),
        _buildKPICard('Conversion', '8.9%', '+5%', Icons.trending_up, Colors.deepPurpleAccent),
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

  Widget _buildActivityChart() {
    return Column(
      children: [
        SizedBox(
          height: 200,
          width: double.infinity,
          child: CustomPaint(
            painter: LineChartPainter(),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildChartLegend('Scans', Colors.pink),
            const SizedBox(width: 24),
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

  Widget _buildStatusDonut() {
    return Row(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: CustomPaint(
            painter: DonutChartPainter(),
          ),
        ),
        const SizedBox(width: 40),
        Expanded(
          child: Column(
            children: [
              _buildStatusRow('Active', '756', const Color(0xFF00C950)),
              const SizedBox(height: 12),
              _buildStatusRow('Inactive', '89', const Color(0xFFFB2C36)),
              const SizedBox(height: 12),
              _buildStatusRow('Pending', '47', const Color(0xFFF6A609)),
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

  Widget _buildConversionFunnel() {
    return Column(
      children: [
        _buildFunnelItem('Card Views', '24,500', 1.0, const [Color(0xFFE91E8E), Color(0xFF8B5CF6)]),
        _buildFunnelItem('Profile Visits', '8,650', 0.35, const [Color(0xFFE91E8E), Color(0xFF8B5CF6)]),
        _buildFunnelItem('Contact Saved', '2,180', 0.15, const [Color(0xFFE91E8E), Color(0xFF8B5CF6)]),
        _buildFunnelItem('Follow-up', '890', 0.05, const [Color(0xFFE91E8E), Color(0xFF8B5CF6)]),
      ],
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

  Widget _buildGeographicDistribution() {
    final regions = [
      {'name': 'North America', 'value': '42%', 'percent': 0.42},
      {'name': 'Europe', 'value': '28%', 'percent': 0.28},
      {'name': 'Asia Pacific', 'value': '18%', 'percent': 0.18},
      {'name': 'Others', 'value': '12%', 'percent': 0.12},
    ];

    return Column(
      children: regions.map((region) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    region['name'] as String,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  Text(
                    region['value'] as String,
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
                        width: constraints.maxWidth * (region['percent'] as double),
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

class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintPink = Paint()
      ..color = Colors.pink
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final paintPurple = Paint()
      ..color = Colors.purpleAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPink = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.pink.withOpacity(0.3), Colors.pink.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final fillPurple = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.purpleAccent.withOpacity(0.3), Colors.purpleAccent.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final pathPink = Path();
    final pathPurple = Path();

    final scanPoints = [0.8, 0.7, 0.9, 0.75, 0.85, 0.6, 0.7];
    final viewPoints = [0.4, 0.35, 0.5, 0.45, 0.6, 0.3, 0.4];

    final dx = size.width / 6;

    // Pink Path (Scans)
    pathPink.moveTo(0, size.height * (1 - scanPoints[0]));
    for (int i = 1; i < scanPoints.length; i++) {
      pathPink.lineTo(dx * i, size.height * (1 - scanPoints[i]));
    }

    final fillPathPink = Path.from(pathPink)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    // Purple Path (Views)
    pathPurple.moveTo(0, size.height * (1 - viewPoints[0]));
    for (int i = 1; i < viewPoints.length; i++) {
      pathPurple.lineTo(dx * i, size.height * (1 - viewPoints[i]));
    }

    final fillPathPurple = Path.from(pathPurple)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPathPink, fillPink);
    canvas.drawPath(pathPink, paintPink);
    
    canvas.drawPath(fillPathPurple, fillPurple);
    canvas.drawPath(pathPurple, paintPurple);

    // Draw bottom labels
    final textStyle = const TextStyle(color: Colors.white38, fontSize: 10);
    final days = ['Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    for (int i = 0; i < days.length; i++) {
      final textSpan = TextSpan(text: days[i], style: textStyle);
      final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr)..layout();
      textPainter.paint(canvas, Offset(dx * (i+1) - textPainter.width/2, size.height + 10));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class DonutChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final strokeWidth = 20.0;

    final paintGreen = Paint()
      ..color = const Color(0xFF00C950)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paintOrange = Paint()
      ..color = const Color(0xFFF6A609)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final paintRed = Paint()
      ..color = const Color(0xFFFB2C36)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);

    // Percentages: 75% active, 15% inactive, 10% pending
    canvas.drawArc(rect, -pi / 2, 2 * pi * 0.75, false, paintGreen);
    canvas.drawArc(rect, -pi / 2 + 2 * pi * 0.75 + 0.1, 2 * pi * 0.15, false, paintRed);
    canvas.drawArc(rect, -pi / 2 + 2 * pi * 0.90 + 0.2, 2 * pi * 0.10, false, paintOrange);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
