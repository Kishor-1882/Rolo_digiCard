import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/organization/group_management_controller.dart';
import 'package:rolo_digi_card/models/group_model.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/views/organization/group_detail_view.dart';
import 'package:rolo_digi_card/views/organization/widgets/create_group_dialog.dart';

class OrganizationGroupListView extends GetView<GroupManagementController> {
  final String groupType; // 'user' or 'card'

  const OrganizationGroupListView({super.key, required this.groupType});

  @override
  Widget build(BuildContext context) {
    // Determine labels based on type
    final isUserGroup = groupType == 'user';
    final title = isUserGroup ? 'User Group Management' : 'Card Group Management';
    final subtitle = isUserGroup ? 'Manage your user groups' : 'Manage your card groups';
    final searchHint = isUserGroup ? 'Search user groups...' : 'Search card groups...';

    // Set the group type in controller when building/entering
    WidgetsBinding.instance.addPostFrameCallback((_) {
       if (controller.groupType.value != groupType) {
         controller.setGroupType(groupType);
       }
    });

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Obx(() {
          final groups = controller.filteredGroups;
          log("kanchana:${groups.length}");
          final total = controller.groups.length;
final active =
    controller.groups.where((group) => group.isActive).length;
              final members = controller.groups.fold(0, (sum, g) => sum + g.members.length);          final primaryCount = groups.fold(0, (sum, g) => sum + (isUserGroup ? g.members.length : g.cards.length));
          
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(title, subtitle),
                const SizedBox(height: 24),
                _buildStatsGrid(total, active, primaryCount, isUserGroup),
                const SizedBox(height: 24),
                _buildSearchAndFilter(searchHint),
                const SizedBox(height: 24),
                _buildGroupList(context, groups, isUserGroup),
                const SizedBox(height: 32),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildHeader(String title, String subtitle) {
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
                     Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(int total, int active, int primaryCount, bool isUserGroup) {
    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            total.toString(),
            'Total Groups',
            Icons.group_work_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatBox(
            active.toString(), // active groups
            'Active',
            Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatBox(
            primaryCount.toString(),
            isUserGroup ? 'Total Members' : 'Total Cards',
            isUserGroup ? Icons.people_outline : Icons.credit_card,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF2B2B36),
            const Color(0xFF1E1E2C),
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
              fontSize: 18,
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
      ),
    );
  }

  Widget _buildSearchAndFilter(String hintText) {
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
                hintText: hintText,
                hintStyle: const TextStyle(color: Colors.white38),
                border: InputBorder.none,
                icon: const Icon(Icons.search, color: Colors.white38),
                suffixIcon: controller.searchQuery.value.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.clear,
                          color: Colors.white38,
                          size: 18,
                        ),
                        onPressed: () => controller.searchQuery.value = '',
                      )
                    : null,
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
            child: DropdownButton<String>(
              dropdownColor: const Color(0xFF1E1E2C),
               value: 'Active', // Placeholder
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              items: <String>['Active', 'Inactive']
                  .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  })
                  .toList(),
              onChanged: (String? newValue) {
                // controller.groupStatusFilter.value = newValue!;
              },
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.white54,
                size: 18
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroupList(BuildContext context, List<GroupModel> groups, bool isUserGroup) {
    String timeAgo(String? createdAt) {
  if (createdAt == null) return '';

  DateTime createdTime = DateTime.parse(createdAt);
  Duration difference = DateTime.now().difference(createdTime);

  if (difference.inSeconds < 60) {
    return 'Just now';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes} minutes ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours} hours ago';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else {
    return '${createdTime.day}-${createdTime.month}-${createdTime.year}';
  }
}

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2B2B36),
                       borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        group.name.isNotEmpty ? group.name[0].toUpperCase() : 'G',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              group.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                             PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert, color: Colors.white54),
                              color: const Color(0xFF2B2B36),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              onSelected: (value) async {
                                if (value == 'view') {
                                   Get.to(() => GroupDetailView(group: group,isUserGroup: isUserGroup));
                                } else if (value == 'delete') {
                                  _showDeleteDialog(context, group);
                                }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                 const PopupMenuItem<String>(
                                  value: 'view',
                                  child: Row(
                                    children: [
                                      Icon(Icons.visibility_outlined, color: Colors.white, size: 20),
                                      SizedBox(width: 12),
                                      Text('View Details', style: TextStyle(color: Colors.white)),
                                    ],
                                  ),
                                ),
                                  const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Row(
                                    children: [
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
                        if (group.description != null && group.description!.isNotEmpty)
                          Text(
                            group.description!,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
               Row(
                children: [
                   _buildMetaItem(
                    icon: isUserGroup ? Icons.people_outline : Icons.credit_card, 
                    label: '${isUserGroup ? group.members.length : group.cards.length} ${isUserGroup ? 'Members' : 'Cards'}'
                  ),
                  const SizedBox(width: 16),
                  _buildMetaItem(icon: Icons.calendar_today_outlined, label: timeAgo(group.createdAt)), // Placeholder
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetaItem({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(icon, color: Colors.white38, size: 14),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 12,
          ),
        ),
      ],
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
              controller.deleteGroup(group.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
