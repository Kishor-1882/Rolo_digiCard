import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/organization/user_management_controller.dart';
import 'package:rolo_digi_card/controllers/organization/analytics_controller.dart';
import 'package:rolo_digi_card/views/organization/org_theme.dart';
import 'package:rolo_digi_card/views/organization/invite_user_dialog.dart';

class OrganizationUsersView extends StatelessWidget {
  OrganizationUsersView({Key? key}) : super(key: key);

  final UserManagementController userController = Get.put(UserManagementController());
  final AnalyticsController analyticsController = Get.put(AnalyticsController());

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userController.getOrganizationUsers();
      analyticsController.getOverview();
    });

    return Scaffold(
      backgroundColor: OrgTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildStatsRow(),
                  const SizedBox(height: 24),
                  _buildSearchAndFilter(),
                ],
              ),
            ),
            Expanded(
              child: _buildUserList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
            Get.bottomSheet(
              InviteUserDialog(),
              isScrollControlled: true,
            );
        },
        backgroundColor: OrgTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("User Management", style: OrgTheme.headerStyle),
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
                  color: Color(0xFF5E17EB), // Dark Purple
                  shape: BoxShape.circle,
              ),
              child: const Text("DU", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
     return Obx(() {
        final totalUsers = userController.users.length;
        final activeUsers = userController.users.where((u) => u.isActive ?? false).length;
        final pendingUsers = totalUsers - activeUsers; // Assuming non-active are pending/inactive

        return Row(
            children: [
                Expanded(child: _buildStatCard(
                    icon: Icons.people_outline,
                    color: Colors.purpleAccent,
                    value: "$totalUsers",
                    label: "Total Users"
                )),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard(
                    icon: Icons.person_add_alt_1_outlined,
                    color: OrgTheme.successColor,
                    value: "$activeUsers",
                    label: "Active Users"
                )),
                // const SizedBox(width: 12),
                // Expanded(child: _buildStatCard(
                //     icon: Icons.schedule,
                //     color: OrgTheme.warningColor,
                //     value: "$pendingUsers",
                //     label: "Pending"
                // )),
            ],
        );
     });
  }

  Widget _buildStatCard({required IconData icon, required Color color, required String value, required String label}) {
      return Container(
          padding: const EdgeInsets.all(16),
          decoration: OrgTheme.cardDecoration,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 12),
                Text(value, style: OrgTheme.cardTitleStyle),
                const SizedBox(height: 4),
                Text(label, style: OrgTheme.cardLabelStyle),
            ],
          ),
      );
  }

  Widget _buildSearchAndFilter() {
      return Column(
        children: [
            TextField(
                decoration: InputDecoration(
                    hintText: "Search by name or email...",
                    hintStyle: const TextStyle(color: OrgTheme.textSecondary),
                    filled: true,
                    fillColor: OrgTheme.cardBackgroundColor,
                    prefixIcon: const Icon(Icons.search, color: OrgTheme.textSecondary),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                    ),
                ),
                style: const TextStyle(color: OrgTheme.textPrimary),
            ),
            const SizedBox(height: 12),
            Row(
                children: [
                    _buildDropdown("Role: All Roles"),
                    const SizedBox(width: 12),
                    _buildDropdown("Status: All Status"),
                ],
            )
        ],
      );
  }

  Widget _buildDropdown(String text) {
      return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
              color: OrgTheme.cardBackgroundColor,
              borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
              children: [
                  Text(text, style: const TextStyle(color: OrgTheme.textSecondary)),
                  const SizedBox(width: 4),
                  const Icon(Icons.keyboard_arrow_down, color: OrgTheme.textSecondary, size: 16),
              ],
          ),
      );
  }

  Widget _buildUserList() {
      return Obx(() {
          if (userController.isLoading.value) return const Center(child: CircularProgressIndicator());
          
          if (userController.users.isEmpty) {
              // Show mockup/empty state or fallback
             return ListView(
                 padding: const EdgeInsets.symmetric(horizontal: 24),
                 children: [
                    _buildUserItem(
                        name: "John Doe",
                        email: "john@example.com",
                        role: "Admin",
                        status: "Active",
                        joined: "Joined Jan 15, 2024",
                        cards: "5 cards",
                        initials: "JD",
                        color: Colors.purple,
                    ),
                     const SizedBox(height: 12),
                    _buildUserItem(
                        name: "Jane Smith",
                        email: "jane@example.com",
                        role: "User",
                        status: "Active",
                        joined: "Joined Feb 20, 2024",
                        cards: "3 cards",
                        initials: "JS",
                        color: Colors.blueAccent,
                    ),
                     const SizedBox(height: 12),
                     _buildUserItem(
                        name: "Mike Johnson",
                        email: "mike@example.com",
                        role: "User",
                        status: "Pending",
                        joined: "Joined Mar 1, 2024",
                        cards: "0 cards",
                        initials: "MJ",
                        color: Colors.pinkAccent,
                    ),
                 ],
             );
          }

          return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: userController.users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                  final user = userController.users[index];
                  return _buildUserItem(
                      name: "${user.firstName} ${user.lastName}",
                      email: user.email,
                      role: user.organizationRole ?? "User",
                      status: (user.isActive ?? false) ? "Active" : "Pending",
                      joined: "Joined recently", // parse user.createdAt
                      cards: "${user.cardCount ?? 0} cards",
                      initials: "${user.firstName.substring(0,1)}${user.lastName.substring(0,1)}",
                      color: Colors.primaries[index % Colors.primaries.length],
                  );
              },
          );
      });
  }

  Widget _buildUserItem({
      required String name,
      required String email,
      required String role,
      required String status,
      required String joined,
      required String cards,
      required String initials,
      required Color color,
  }) {
      final isPending = status == "Pending";
      return Container(
          padding: const EdgeInsets.all(16),
          decoration: OrgTheme.cardDecoration,
          child: Column(
              children: [
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                          Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                  color: color.withOpacity(0.2),
                                  shape: BoxShape.circle,
                              ),
                              child: Text(initials, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                      Row(
                                          children: [
                                              Text(name, style: const TextStyle(color: OrgTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                                              const SizedBox(width: 8),
                                              Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                  decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(12),
                                                  ),
                                                  child: Text(role, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                                              )
                                          ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(email, style: const TextStyle(color: OrgTheme.textSecondary, fontSize: 13)),
                                  ],
                              ),
                          ),
                          const Icon(Icons.more_vert, color: OrgTheme.textSecondary),
                      ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                      children: [
                          Container( // Status badge
                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                               decoration: BoxDecoration(
                                   color: isPending ? OrgTheme.warningColor.withOpacity(0.2) : OrgTheme.successColor.withOpacity(0.2),
                                   borderRadius: BorderRadius.circular(8),
                                   border: Border.all(color: isPending ? OrgTheme.warningColor : OrgTheme.successColor, width: 0.5),
                               ),
                               child: Row(
                                   children: [
                                       if(!isPending) Icon(Icons.check_circle, size: 12, color: OrgTheme.successColor),
                                       if(isPending) Icon(Icons.schedule, size: 12, color: OrgTheme.warningColor),
                                       const SizedBox(width: 4),
                                       Text(status, style: TextStyle(color: isPending ? OrgTheme.warningColor : OrgTheme.successColor, fontSize: 12)),
                                   ],
                               ),
                          ),
                          const SizedBox(width: 16),
                          Text(joined, style: const TextStyle(color: OrgTheme.textSecondary, fontSize: 12)),
                          const SizedBox(width: 16),
                          Text(cards, style: const TextStyle(color: OrgTheme.textSecondary, fontSize: 12)),
                      ],
                  )
              ],
          ),
      );
  }
}
