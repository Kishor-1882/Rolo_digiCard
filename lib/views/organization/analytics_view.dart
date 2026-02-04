import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/organization/analytics_controller.dart';
import 'package:rolo_digi_card/views/organization/org_theme.dart';

class AnalyticsView extends StatelessWidget {
  AnalyticsView({Key? key}) : super(key: key);

  final AnalyticsController controller = Get.put(AnalyticsController());

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getOverview();
      controller.getAdminAnalytics();
      controller.getGeographyAnalytics();
    });

    return Scaffold(
      backgroundColor: OrgTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildOverviewHeader(),
                    const SizedBox(height: 16),
                    _buildMetricCards(),
                    const SizedBox(height: 24),
                    // _buildCardActivityChart(),
                    // const SizedBox(height: 24),
                    // _buildCardStatusDistribution(),
                    // const SizedBox(height: 32),
                    // _buildFunnelAnalysis(),
                    // const SizedBox(height: 32),
                    // _buildGroupComparison(),
                    // const SizedBox(height: 32),
                    // _buildGeographicalDistribution(),
                    // const SizedBox(height: 40),
                    // _buildExportButton(),
                    // const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text("Analytics", style: OrgTheme.headerStyle),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search, color: OrgTheme.textSecondary),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.notifications_none, color: OrgTheme.textSecondary),
                onPressed: () {},
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF5E17EB),
                  shape: BoxShape.circle,
                ),
                child: const Text("DU", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Overview", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: OrgTheme.cardBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: const [
              Text("Period: ", style: TextStyle(color: OrgTheme.textSecondary, fontSize: 13)),
              Text("Last 30 Days", style: TextStyle(color: OrgTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
              SizedBox(width: 4),
              Icon(Icons.keyboard_arrow_down, color: OrgTheme.textSecondary, size: 16),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCards() {
    return Obx(() {
      final health = controller.overviewData.value?.health;
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildSmallStatCard(
              icon: Icons.people_outline,
              color: Colors.purpleAccent,
              value: "${health?.totalUsers ?? 0}",
              label: "Total Users",
              trend: "8%",
            ),
            const SizedBox(width: 12),
            _buildSmallStatCard(
              icon: Icons.credit_card,
              color: Colors.greenAccent,
              value: "${health?.totalCards ?? 0}",
              label: "Total Cards",
              trend: "12%",
            ),
            const SizedBox(width: 12),
            _buildSmallStatCard(
              icon: Icons.share_outlined,
              color: Colors.pinkAccent,
              value: "2.4k", // Mock for now, should come from engagement
              label: "Total Shares",
              trend: "24%",
            ),
            const SizedBox(width: 12),
            _buildSmallStatCard(
              icon: Icons.remove_red_eye_outlined,
              color: Colors.tealAccent,
              value: "12.4k", // Mock
              label: "Total Views",
              trend: "18%",
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSmallStatCard({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
    required String trend,
  }) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: OrgTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 18),
              ),
              Row(
                children: [
                  const Icon(Icons.arrow_outward, color: OrgTheme.successColor, size: 12),
                  Text(trend, style: const TextStyle(color: OrgTheme.successColor, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: OrgTheme.textSecondary, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCardActivityChart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: OrgTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("CARD ACTIVITY", style: TextStyle(color: OrgTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: LineChartPainter(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildChartLegend("Views", Colors.purpleAccent),
              const SizedBox(width: 24),
              _buildChartLegend("Shares", Colors.greenAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: OrgTheme.textSecondary, fontSize: 12)),
      ],
    );
  }

  Widget _buildCardStatusDistribution() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("CARD STATUS DISTRIBUTION", style: TextStyle(color: OrgTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: OrgTheme.cardDecoration,
          child: Column(
            children: [
              _buildStatusRow("Active", 0.8, Colors.green),
              const SizedBox(height: 20),
              _buildStatusRow("Inactive", 0.2, Colors.redAccent),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, double progress, Color color) {
    return Row(
      children: [
        SizedBox(width: 60, child: Text(label, style: const TextStyle(color: OrgTheme.textSecondary, fontSize: 14))),
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFunnelAnalysis() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("FUNNEL ANALYSIS", style: TextStyle(color: OrgTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: OrgTheme.cardDecoration,
          child: Obx(() {
            final funnel = controller.overviewData.value?.engagement.funnel ?? [];
            return Column(
              children: [
                _buildFunnelItem("Card Views", "12,450", 1.0), // Mock values matching image
                _buildFunnelItem("Profile Clicks", "8,320", 0.7),
                _buildFunnelItem("Contact Saved", "4,150", 0.35),
                _buildFunnelItem("Connections Made", "1,890", 0.15),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFunnelItem(String label, String value, double progress) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: OrgTheme.textPrimary, fontSize: 14)),
              Text(value, style: const TextStyle(color: OrgTheme.textSecondary, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 20,
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(10)),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [OrgTheme.primaryColor, OrgTheme.primaryColor.withOpacity(0.7)]),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupComparison() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("GROUP COMPARISON", style: TextStyle(color: OrgTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: OrgTheme.cardDecoration,
          child: Obx(() {
            final groupComparison = controller.overviewData.value?.groupComparison ?? [];
            return Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
              },
              children: [
                const TableRow(
                  children: [
                    Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Group", style: TextStyle(color: OrgTheme.textSecondary, fontSize: 12))),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Views", style: TextStyle(color: OrgTheme.textSecondary, fontSize: 12), textAlign: TextAlign.right)),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Shares", style: TextStyle(color: OrgTheme.textSecondary, fontSize: 12), textAlign: TextAlign.right)),
                    Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text("Saves", style: TextStyle(color: OrgTheme.textSecondary, fontSize: 12), textAlign: TextAlign.right)),
                  ],
                ),
                if (groupComparison.isEmpty) ...[
                  _buildGroupRow("Marketing", "3,450", "890", "234"),
                  _buildGroupRow("Sales", "2,890", "756", "198"),
                  _buildGroupRow("Engineering", "1,560", "423", "112"),
                  _buildGroupRow("HR", "890", "234", "67"),
                ] else
                   ...groupComparison.map((g) => _buildGroupRow(g['name'] ?? "Unknown", "${g['avgViewsPerCard'] ?? 0}", "${g['totalCards'] ?? 0}", "0")).toList(),
              ],
            );
          }),
        ),
      ],
    );
  }

  TableRow _buildGroupRow(String name, String views, String shares, String saves) {
    return TableRow(
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(name, style: const TextStyle(color: OrgTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500))),
        Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(views, style: const TextStyle(color: OrgTheme.textSecondary, fontSize: 14), textAlign: TextAlign.right)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(shares, style: const TextStyle(color: OrgTheme.textSecondary, fontSize: 14), textAlign: TextAlign.right)),
        Padding(padding: const EdgeInsets.symmetric(vertical: 12), child: Text(saves, style: const TextStyle(color: OrgTheme.textSecondary, fontSize: 14), textAlign: TextAlign.right)),
      ],
    );
  }

  Widget _buildGeographicalDistribution() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("GEOGRAPHICAL DISTRIBUTION", style: TextStyle(color: OrgTheme.textSecondary, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: OrgTheme.cardDecoration,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(border: Border.all(color: Colors.purpleAccent, width: 2), shape: BoxShape.circle),
                child: const Icon(Icons.location_on_outlined, color: Colors.purpleAccent, size: 32),
              ),
              const SizedBox(height: 32),
              Obx(() {
                 final geo = controller.geographyData;
                 if (geo.isEmpty) {
                    return Column(
                        children: [
                             _buildCountryRow("UN", "United States", "4,567", "35%"),
                             _buildCountryRow("UN", "United Kingdom", "2,345", "18%"),
                             _buildCountryRow("IN", "India", "1,890", "15%"),
                             _buildCountryRow("GE", "Germany", "1,234", "10%"),
                             _buildCountryRow("CA", "Canada", "987", "8%"),
                        ],
                    );
                 }
                 return Column(
                     children: geo.map((g) => _buildCountryRow(g.countryCode ?? "??", g.countryName ?? "Unknown", "${g.count}", "${g.percentage}%")).toList(),
                 );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCountryRow(String code, String name, String count, String percentage) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
            child: Text(code, style: const TextStyle(color: OrgTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(name, style: const TextStyle(color: OrgTheme.textPrimary, fontSize: 16))),
          Text(count, style: const TextStyle(color: OrgTheme.textSecondary, fontSize: 16)),
          const SizedBox(width: 16),
          Text(percentage, style: const TextStyle(color: Colors.purpleAccent, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildExportButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        color: OrgTheme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: MaterialButton(
        onPressed: () {},
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.file_download_outlined, color: Colors.white),
            SizedBox(width: 8),
            Text("Export Report", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final viewsPaint = Paint()
      ..color = Colors.purpleAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sharesPaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Dummy paths matching visual curves in image
    final viewsPath = Path();
    viewsPath.moveTo(0, size.height * 0.7);
    viewsPath.quadraticBezierTo(size.width * 0.2, size.height * 0.5, size.width * 0.4, size.height * 0.55);
    viewsPath.quadraticBezierTo(size.width * 0.7, size.height * 0.4, size.width * 0.8, size.height * 0.8);
    viewsPath.lineTo(size.width, size.height * 0.82);

    final sharesPath = Path();
    sharesPath.moveTo(0, size.height * 0.9);
    sharesPath.quadraticBezierTo(size.width * 0.3, size.height * 0.85, size.width * 0.5, size.height * 0.82);
    sharesPath.quadraticBezierTo(size.width * 0.8, size.height * 0.78, size.width, size.height * 0.92);

    canvas.drawPath(viewsPath, viewsPaint);
    canvas.drawPath(sharesPath, sharesPaint);

    // X-axis labels (bottom)
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    const labels = ["Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
    for (int i = 0; i < labels.length; i++) {
        textPainter.text = TextSpan(text: labels[i], style: const TextStyle(color: Colors.grey, fontSize: 10));
        textPainter.layout();
        textPainter.paint(canvas, Offset((i + 1) * (size.width / (labels.length + 1)) - textPainter.width / 2, size.height + 10));
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
