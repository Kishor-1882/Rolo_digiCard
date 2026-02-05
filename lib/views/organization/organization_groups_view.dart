import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/organization/group_management_controller.dart';
import 'package:rolo_digi_card/models/group_model.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/views/organization/widgets/create_group_dialog.dart';

class OrganizationGroupsView extends GetView<GroupManagementController> {
  const OrganizationGroupsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Obx(() {
          final groups = controller.filteredGroups;
          final total = controller.groups.length;
          final shared = controller.groups.where((g) => g.isShared).length;
          final private = controller.groups.where((g) => !g.isShared).length;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 24),
                _buildStatsRow(total, shared, private),
                const SizedBox(height: 24),
                _buildSearchBar(),
                const SizedBox(height: 24),
                _buildGroupList(groups),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Groups',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Organize cards into groups',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE91E8E), Color(0xFF8B5CF6)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: ElevatedButton.icon(
            onPressed: () {
              Get.dialog(
                const CreateGroupDialog(),
                barrierDismissible: true,
              );
            },
            icon: const Icon(Icons.add, color: Colors.white, size: 18),
            label: const Text(
              'Create Group',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(int total, int shared, int private) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatBox(total.toString(), 'Total'),
          const SizedBox(width: 12),
          _buildStatBox(total.toString(), 'Active'), // Assumption: all static ones are active
          const SizedBox(width: 12),
          _buildStatBox(shared.toString(), 'Shared'),
          const SizedBox(width: 12),
          _buildStatBox(private.toString(), 'Private'),
        ],
      ),
    );
  }

  Widget _buildStatBox(String value, String label) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
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
    );
  }

  Widget _buildGroupList(List<GroupModel> groups) {
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
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFFE91E8E).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.folder_open, color: AppColors.primaryPink, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          group.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildBadge(
                          group.isShared ? 'Shared' : 'Private',
                          group.isShared ? Colors.blueAccent : Colors.purpleAccent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      group.description ?? 'No description',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.people_outline, color: Colors.white38, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${group.members.length} members',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.credit_card, color: Colors.white38, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${group.cards.length} cards',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_vert, color: Colors.white54),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
