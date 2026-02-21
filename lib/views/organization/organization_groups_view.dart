import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/views/organization/organization_group_list_view.dart';

class OrganizationGroupsView extends StatelessWidget {
  const OrganizationGroupsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Groups',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Manage your user and card groups',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 48),
              
              // Folder Icon in center
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE91E8E), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE91E8E).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.folder_open,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
              
              const SizedBox(height: 48),

              // User Groups Button
              _buildGroupOptionCard(
                title: 'User Groups',
                subtitle: 'Manage groups of users and team members',
                meta: '5 groups',
                icon: Icons.people_outline,
                iconColor: const Color(0xFFE040FB), // Pink
                onTap: () {
                   Get.to(() => const OrganizationGroupListView(groupType: 'user'));
                },
              ),

              const SizedBox(height: 16),

              // Card Groups Button
              _buildGroupOptionCard(
                title: 'Card Groups',
                subtitle: 'Organize digital business cards into groups',
                meta: '3 groups',
                icon: Icons.credit_card,
                iconColor: Colors.blueAccent,
                onTap: () {
                   Get.to(() => const OrganizationGroupListView(groupType: 'card'));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupOptionCard({
    required String title,
    required String subtitle,
    required String meta,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E2C), // Dark card background
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    iconColor,
                    iconColor.withOpacity(0.7),
                  ],
                ),
              ),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
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
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    meta,
                    style: const TextStyle(
                      color: AppColors.primaryPink,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white54),
          ],
        ),
      ),
    );
  }
}
