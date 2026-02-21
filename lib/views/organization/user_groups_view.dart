import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/organization/group_management_controller.dart';
import 'package:rolo_digi_card/models/group_model.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/views/organization/group_detail_view.dart';
import 'package:rolo_digi_card/views/organization/widgets/create_group_dialog.dart';

class UserGroupsView extends GetView<GroupManagementController> {
  const UserGroupsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Obx(() {
          final groups = controller.filteredGroups;
          final total = controller.groups.length;
final active =
    controller.groups.where((group) => group.isActive).length;
              final members = controller.groups.fold(0, (sum, g) => sum + g.members.length);
          final cards = controller.groups.fold(0, (sum, g) => sum + g.cards.length);
          
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 24),
                _buildStatsGrid(total, active, members, cards),
                const SizedBox(height: 24),
                _buildSearchAndFilter(),
                const SizedBox(height: 24),
                _buildGroupList(context, groups),
                const SizedBox(height: 32),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User Group Management',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18, // Slightly reduced font size
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Manage your user groups',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12, // Slightly reduced font size
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
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
                      const CreateGroupDialog(),
                      barrierDismissible: true,
                    );
                  },
                  icon: const Icon(Icons.add, color: Colors.white, size: 16),
                  label: const Text(
                    'New Group',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), // Reduced padding
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    minimumSize: Size.zero, 
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(int total, int active, int members, int cards) {
    // Replaced GridView with Row/Expanded to prevent overflow and ensure equal spacing
    return Row(
      children: [
        Expanded(child: _buildStatBox(total.toString(), 'Total', Icons.folder_outlined)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatBox(active.toString(), 'Active', Icons.check_circle_outline)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatBox(members.toString(), 'Members', Icons.people_outline)),
        const SizedBox(width: 8),
        Expanded(child: _buildStatBox(cards.toString(), 'Cards', Icons.credit_card)),
      ],
    );
  }

  Widget _buildStatBox(String value, String label, IconData icon) {
    return Container(
      // Height fixed to prevent layout jumps, slightly reduced padding
      height: 100, 
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C), // Darker card background
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
         gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
             Color(0xFF2B2B36),
             Color(0xFF1E1E2C),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white54, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18, // Slightly smaller font
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      )
    );
  }

  Widget _buildSearchAndFilter() {
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
              onChanged: (value) => controller.searchQuery.value = value,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search groups...',
                hintStyle: const TextStyle(color: Colors.white38),
                border: InputBorder.none,
                icon: const Icon(Icons.search, color: Colors.white38),
                suffixIcon: controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white38, size: 18),
                        onPressed: () => controller.searchQuery.value = '',
                      )
                    : null,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12), // Reduced padding
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              dropdownColor: const Color(0xFF1E1E2C),
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54, size: 18),
              value: 'All', // This should be bound to controller
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              items: <String>['All', 'Active', 'Inactive'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (_) {}, // Implement filter logic
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupList(BuildContext context, List<GroupModel> groups) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return Container(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.people_outline, color: Color(0xFFE040FB), size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            group.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildStatusBadge('active'), // Placeholder for status
                        const SizedBox(width: 12),
                        
                        // Dropdown Menu
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white54),
                          color: const Color(0xFF2B2B36),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onSelected: (value) {
                            if (value == 'delete') {
                              _showDeleteDialog(context, group);
                            } else if (value == 'view') {
                              Get.to(() => GroupDetailView(group: group,isUserGroup: true));
                            }
                          },
                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                             PopupMenuItem<String>(
                              value: 'view',
                              child: Row(
                                children: const [
                                  Icon(Icons.visibility_outlined, color: Colors.white, size: 20),
                                  SizedBox(width: 12),
                                  Text('View Details', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                             PopupMenuItem<String>(
                              value: 'delete',
                              child: Row(
                                children: const [
                                  Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                                  SizedBox(width: 12),
                                  Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildMetaItem(Icons.people_outline, '${group.members.length}'), 
                        const SizedBox(width: 16),
                        _buildMetaItem(Icons.credit_card, '${group.cards.length}'),
                        const SizedBox(width: 16),
                         const Text(
                          '2024-01-15', // Placeholder date
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
             
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, GroupModel group) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Group', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${group.name}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              // Delete logic
              controller.deleteGroup(group.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color = Colors.greenAccent;
    if (status != 'active') color = Colors.redAccent;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildMetaItem(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, color: Colors.white54, size: 14),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
