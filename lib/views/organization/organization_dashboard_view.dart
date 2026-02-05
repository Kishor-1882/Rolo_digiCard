import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/organization/organization_controller.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/views/organization/organization_qr_scanner_view.dart';

class OrganizationDashboardView extends GetView<OrganizationController> {
  const OrganizationDashboardView({super.key});

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
              _buildMetricsGrid(),
              const SizedBox(height: 16),
              _buildFullWidthMetric(
                title: 'Total Scans',
                value: '3,892',
                trend: '+18% this week',
                icon: Icons.qr_code_scanner,
                color: Colors.purple.shade400,
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                title: 'Organization Activity',
                icon: Icons.bar_chart,
                child: _buildActivityChart(),
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                title: 'Card Status Distribution',
                icon: Icons.credit_card,
                child: _buildStatusDistribution(),
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                title: 'Top Performing Cards',
                icon: Icons.emoji_events_outlined,
                child: _buildTopPerformingCards(),
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                title: 'Groups Summary',
                icon: Icons.folder_open,
                showViewAll: true,
                child: _buildGroupsSummary(),
              ),
              const SizedBox(height: 24),
              _buildSectionCard(
                title: 'Recent Activity',
                icon: Icons.access_time,
                child: _buildRecentActivity(),
              ),
              const SizedBox(height: 24),
              _buildScannedCards(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.menu, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primaryPink,
                shape: BoxShape.circle,
              ),
              child: const Text(
                'R',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Rolo Digi Cards',
              style: TextStyle(
                color: AppColors.primaryPink,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.shade400,
            shape: BoxShape.circle,
          ),
          child: const Text(
            'JD',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Good Morning, Ram',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              '👋',
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
        const Text(
          'Organization overview',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsGrid() {
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
          value: '1,248',
          trend: '12%',
          isUp: true,
          icon: Icons.people_outline,
          isGradient: true,
        ),
        _buildMetricCard(
          title: 'Total Cards',
          value: '892',
          trend: '8%',
          isUp: true,
          icon: Icons.credit_card,
        ),
        _buildMetricCard(
          title: 'Active Cards',
          value: '756',
          trend: '3%',
          isUp: false,
          icon: Icons.show_chart,
        ),
        _buildMetricCard(
          title: 'Total Views',
          value: '24.5K',
          trend: '23%',
          isUp: true,
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
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
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
          Column(
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
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.north_east, color: Colors.greenAccent, size: 16),
              const SizedBox(width: 4),
              Text(
                trend,
                style: const TextStyle(
                  color: Colors.greenAccent,
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
                Row(
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
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildActivityChart() {
    final List<double> values = [0.3, 0.6, 0.4, 0.8, 0.5, 1.0, 0.7];
    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(7, (index) {
            return Column(
              children: [
                Container(
                  width: 40,
                  height: 100 * values[index],
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE91E8E), Color(0xFF8B5CF6)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  days[index],
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStatusDistribution() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Row(
            children: [
              Expanded(flex: 51, child: Container(height: 12, color: const Color(0xFF00C950))),
              Expanded(flex: 34, child: Container(height: 12, color: const Color(0xFF51A2FF))),
              Expanded(flex: 10, child: Container(height: 12, color: const Color(0xFFF6A609))),
              Expanded(flex: 5, child: Container(height: 12, color: const Color(0xFFFB2C36))),
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
            _buildStatusItem('Active (Assigned)', '456 (51%)', const Color(0xFF00C950)),
            _buildStatusItem('Active (Unassigned)', '300 (34%)', const Color(0xFF51A2FF)),
            _buildStatusItem('Inactive (Assigned)', '89 (10%)', const Color(0xFFF6A609)),
            _buildStatusItem('Inactive (Unassigned)', '47 (5%)', const Color(0xFFFB2C36)),
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
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopPerformingCards() {
    final cards = [
      {'rank': '#1', 'name': 'Executive Card', 'scans': '567', 'views': '2340', 'color': Colors.orange},
      {'rank': '#2', 'name': 'Marketing Card', 'scans': '423', 'views': '1890', 'color': Colors.blueGrey},
      {'rank': '#3', 'name': 'Sales Premium', 'scans': '356', 'views': '1456', 'color': Colors.brown},
    ];

    return Column(
      children: cards.map((card) {
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
                  color: card['color'] as Color,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  card['rank'] as String,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      card['name'] as String,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.qr_code_scanner, color: Colors.white54, size: 14),
                        const SizedBox(width: 4),
                        Text(card['scans'] as String, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        const SizedBox(width: 12),
                        const Icon(Icons.visibility_outlined, color: Colors.white54, size: 14),
                        const SizedBox(width: 4),
                        Text(card['views'] as String, style: const TextStyle(color: Colors.white54, fontSize: 12)),
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

  Widget _buildGroupsSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildSummaryBox('12', 'Total Groups'),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSummaryBox('8', 'Shared Groups', icon: Icons.share),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Recently Added',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 12),
        _buildGroupItem('Marketing Team', '12 members'),
        _buildGroupItem('Sales Division', '24 members'),
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
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
          Text(members, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    final activities = [
      {'title': 'User activated', 'subtitle': 'John D.', 'time': '2 min ago', 'icon': Icons.person_add, 'color': Colors.green},
      {'title': 'New user invited', 'subtitle': 'Sarah M.', 'time': '15 min ago', 'icon': Icons.person_add_alt_1, 'color': Colors.blue},
      {'title': 'Card assigned', 'subtitle': 'Mike R.', 'time': '1 hour ago', 'icon': Icons.credit_card, 'color': Colors.pink},
      {'title': 'User deactivated', 'subtitle': 'Emma L.', 'time': '3 hours ago', 'icon': Icons.person_remove, 'color': Colors.red},
    ];

    return Column(
      children: activities.map((activity) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (activity['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(activity['icon'] as IconData, color: activity['color'] as Color, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity['title'] as String,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      activity['subtitle'] as String,
                      style: const TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Text(
                activity['time'] as String,
                style: const TextStyle(color: Colors.white38, fontSize: 10),
              ),
            ],
          ),
        );
      }).toList(),
    );
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
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
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
