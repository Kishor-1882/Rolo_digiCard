import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rolo_digi_card/controllers/organization/organization_user_management_controller.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/views/organization/organization_user_details.dart';
import 'package:rolo_digi_card/views/organization/widgets/invite_team_user_dialog.dart';

class OrganizationUserManagement extends StatelessWidget {
  const OrganizationUserManagement({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered
    if (!Get.isRegistered<OrgUserManagementController>()) {
      Get.put(OrgUserManagementController());
    }
    final controller = Get.find<OrgUserManagementController>();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Obx(() {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(controller),
                const SizedBox(height: 24),
                _buildStatsGrid(controller),
                const SizedBox(height: 24),
                _buildSearchAndFilter(controller),
                const SizedBox(height: 16),
                Text(
                  '${controller.filteredUsers.length} users found',
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 16),
                if (controller.isLoading.value)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                        color: Color(0xFFE91E8E),
                      ),
                    ),
                  )
                else if (controller.filteredUsers.isEmpty)
                  _buildEmptyState()
                else
                  _buildUserList(controller.filteredUsers),
                const SizedBox(height: 32),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(OrgUserManagementController controller) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 18),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User Management',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Manage your team members',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                  ],
                ),
              ),
                          const SizedBox(width: 8),  // ← add spacing between the two sides

              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE91E8E), Color(0xFF8B5CF6)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.dialog(
                      const InviteTeamUserDialog(),
                      barrierDismissible: true,
                    ).then((_) => controller.fetchUsers());
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text(
                    'New User',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Stats Grid ────────────────────────────────────────────────────────────
  Widget _buildStatsGrid(OrgUserManagementController controller) {
    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            controller.totalUsers.toString(),
            'Total Users',
            Icons.people_outline,
            const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatBox(
            controller.activeUsers.toString(),
            'Active',
            Icons.check_circle_outline,
            Colors.greenAccent,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatBox(
            controller.inactiveUsers.toString(),
            'Inactive',
            Icons.pause_circle_outline,
            Colors.orangeAccent,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String value, String label, IconData icon, Color accentColor) {
    return Container(
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2B2B36), Color(0xFF1E1E2C)],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: accentColor.withOpacity(0.8), size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Search & Filter ───────────────────────────────────────────────────────
  Widget _buildSearchAndFilter(OrgUserManagementController controller) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.05)),
            ),
            child: TextField(
              onChanged: (v) => controller.searchQuery.value = v,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search users...',
                hintStyle: TextStyle(color: Colors.white38),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.white38),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: DropdownButtonHideUnderline(
            child: Obx(
              () => DropdownButton<String>(
                dropdownColor: const Color(0xFF1E1E2C),
                value: controller.statusFilter.value,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                items: <String>['All', 'Active', 'Inactive', 'Blocked']
                    .map((v) => DropdownMenuItem(value: v, child: Text(v)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) controller.statusFilter.value = v;
                },
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white54,
                  size: 18,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── User List ─────────────────────────────────────────────────────────────
  Widget _buildUserList(List<OrgUser> users) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: users.length,
      itemBuilder: (context, index) => _buildUserCard(context, users[index]),
    );
  }

  Widget _buildUserCard(BuildContext context, OrgUser user) {
    final controller = Get.find<OrgUserManagementController>();

    Color statusColor;
    if (user.isBlocked) {
      statusColor = Colors.redAccent;
    } else if (user.isActive) {
      statusColor = Colors.greenAccent;
    } else {
      statusColor = Colors.orangeAccent;
    }

    return GestureDetector(
      onTap: () => Get.to(() => OrgUserDetailPage(userId: user.id)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE91E8E).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE91E8E).withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE91E8E), Color(0xFF8B5CF6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  user.initials,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          user.fullName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor.withOpacity(0.5)),
                        ),
                        child: Text(
                          user.statusLabel,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white54),
                        color: const Color(0xFF2B2B36),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onSelected: (value) {
                          switch (value) {
                            case 'view':
                              Get.to(() => OrgUserDetailPage(userId: user.id));
                              break;
                            case 'activate':
                              controller.updateUserStatus(user.id, isActive: true);
                              break;
                            case 'deactivate':
                              controller.updateUserStatus(user.id, isActive: false);
                              break;
                            case 'resend':
                              controller.resendInvitation(user.id);
                              break;
                            case 'delete':
                              _showDeleteDialog(context, user, controller);
                              break;
                          }
                        },
                        itemBuilder: (_) => [
                          _menuItem('view', Icons.visibility_outlined, 'View Details', Colors.white),
                          if (!user.isActive && !user.isBlocked)
                            _menuItem('activate', Icons.check_circle_outline, 'Activate', Colors.greenAccent),
                          if (user.isActive)
                            _menuItem('deactivate', Icons.pause_circle_outline, 'Deactivate', Colors.orangeAccent),
                          if (!user.isEmailVerified)
                            _menuItem('resend', Icons.send_outlined, 'Resend Invite', Colors.blueAccent),
                          _menuItem('delete', Icons.delete_outline, 'Remove User', Colors.redAccent),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.badge_outlined, color: Colors.white38, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        user.displayRole,
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.credit_card_outlined, color: Colors.white38, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${user.cardCount} cards',
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon, String label, Color color) {
    return PopupMenuItem<String>(
      value: value,
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 10),
          Text(label, style: TextStyle(color: color)),
        ],
      ),
    );
  }

  // ── Empty State ───────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.people_outline, color: Colors.white24, size: 64),
            const SizedBox(height: 16),
            const Text(
              'No users found',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'Invite team members to get started',
              style: TextStyle(color: Colors.white38, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ── Delete Dialog ─────────────────────────────────────────────────────────
  void _showDeleteDialog(
    BuildContext context,
    OrgUser user,
    OrgUserManagementController controller,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove User', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to remove "${user.fullName}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await controller.removeUser(user.id);
              if (success) Get.back();
            },
            child: const Text('Remove', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}