import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/organization/analytics_controller.dart'; 
import 'package:rolo_digi_card/controllers/organization/organization_controller.dart';
import 'package:rolo_digi_card/views/organization/org_theme.dart';

class OrganizationDashboardView extends StatelessWidget {
  OrganizationDashboardView({Key? key}) : super(key: key);

  final AnalyticsController analyticsController = Get.put(AnalyticsController());
  final OrganizationController orgController = Get.put(OrganizationController());

  @override
  Widget build(BuildContext context) {
    // Trigger fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      analyticsController.getOverview();
      orgController.getOrganization();
      orgController.getDashboardStats(); // Fetch recent activity if there
    });

    return Scaffold(
      backgroundColor: OrgTheme.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildStatsRow(),
              const SizedBox(height: 32),
              const Text(
                "RECENT ACTIVITY",
                style: TextStyle(
                  color: OrgTheme.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 16),
              _buildRecentActivityList(),
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Obx(() {
                 final name = orgController.currentUser.value?.firstName ?? 'User';
                 return Text(
                  "Good Afternoon, $name 👋",
                  style: OrgTheme.headerStyle,
                );
             }),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: OrgTheme.primaryColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Owner",
                style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        // Container(
        //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        //   decoration: BoxDecoration(
        //     color: OrgTheme.cardBackgroundColor,
        //     borderRadius: BorderRadius.circular(8),
        //     border: Border.all(color: Colors.white.withOpacity(0.1)),
        //   ),
        //   child: Row(
        //     children: const [
        //       Text(
        //         "Period: ",
        //         style: TextStyle(color: OrgTheme.textSecondary, fontSize: 13),
        //       ),
        //       Text(
        //         "Last 7 Days",
        //         style: TextStyle(color: OrgTheme.textPrimary, fontSize: 13, fontWeight: FontWeight.bold),
        //       ),
        //       SizedBox(width: 4),
        //       Icon(Icons.keyboard_arrow_down, color: OrgTheme.textSecondary, size: 16),
        //     ],
        //   ),
        // ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Obx(() {
      final health = analyticsController.overviewData.value?.health;
      return Row(
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.people_outline,
              iconColor: Colors.purpleAccent,
              value: "${health?.totalUsers ?? 0}",
              label: "Total Users",
              trend: "12%",
              isPositive: true,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              icon: Icons.credit_card,
              iconColor: Colors.greenAccent,
              value: "${health?.totalCards ?? 0}",
              label: "Total Cards",
              trend: "8%",
              isPositive: true,
            ),
          ),
          // const SizedBox(width: 16),
          // Expanded(
          //   child: _buildStatCard(
          //     icon: Icons.show_chart,
          //     iconColor: Colors.orangeAccent,
          //     value: "${health?.activeCardsPercentage ?? 0}", // Using pct as placeholder for count if needed, or calc
          //     label: "Active Cards",
          //     trend: "3%",
          //     isPositive: false,
          //   ),
          // ),
        ],
      );
    });
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required String trend,
    required bool isPositive,
  }) {
    return Container(
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
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              Row(
                children: [
                  Icon(
                    isPositive ? Icons.arrow_outward : Icons.arrow_outward, // rotated if negative conceptually
                     // simplifying for UI match
                    color: isPositive ? OrgTheme.successColor : OrgTheme.errorColor,
                    size: 14,
                  ),
                  Text(
                    trend,
                    style: TextStyle(
                      color: isPositive ? OrgTheme.successColor : OrgTheme.errorColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(value, style: OrgTheme.cardTitleStyle),
          const SizedBox(height: 4),
          Text(label, style: OrgTheme.cardLabelStyle),
        ],
      ),
    );
  }

  Widget _buildRecentActivityList() {
    // using dummy data or mapping from controller if available. 
    // OrgController has dashboardStats which had recentActivities
    return Obx(() {
        final activities = orgController.dashboardStats.value?.recentActivities ?? [];
        if (activities.isEmpty) {
             return Column(
                children: [
                    _buildActivityItem(
                        icon: Icons.credit_card,
                        title: "New card created",
                        subtitle: "John Doe",
                        time: "2 min ago",
                    ),
                    const SizedBox(height: 12),
                    _buildActivityItem(
                        icon: Icons.person_add_outlined,
                        title: "User invited",
                        subtitle: "Admin",
                        time: "15 min ago",
                    ),
                ],
             );
        }
        return Column(
            children: activities.map((activity) {
                 return Column(
                   children: [
                     _buildActivityItem(
                        icon: Icons.notifications_none, 
                        title: activity.action ?? "Activity",
                        subtitle: activity.user ?? "",
                        time: "Just now", // Calculate time diff in real app
                     ),
                     const SizedBox(height: 12),
                   ],
                 );
            }).toList(),
        );
    });
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: OrgTheme.cardDecoration,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.purple.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.purpleAccent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: OrgTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: OrgTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              color: OrgTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
