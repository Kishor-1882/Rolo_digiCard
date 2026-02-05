import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/organization/group_management_controller.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/views/organization/widgets/create_group_dialog.dart';

class OrganizationGroupsView extends GetView<GroupManagementController> {
  const OrganizationGroupsView({super.key});

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
              _buildStatsRow(),
              const SizedBox(height: 24),
              _buildSearchBar(),
              const SizedBox(height: 24),
              _buildGroupList(),
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

  Widget _buildStatsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStatBox('5', 'Total'),
          const SizedBox(width: 12),
          _buildStatBox('4', 'Active'),
          const SizedBox(width: 12),
          _buildStatBox('3', 'Shared'),
          const SizedBox(width: 12),
          _buildStatBox('2', 'Private'),
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
      child: const TextField(
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search groups...',
          hintStyle: TextStyle(color: Colors.white38),
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Colors.white38),
        ),
      ),
    );
  }

  Widget _buildGroupList() {
    final groups = [
      {
        'name': 'Marketing Team',
        'subtitle': 'All marketing staff cards',
        'members': '12 members',
        'badges': [
          {'label': 'Shared', 'color': Colors.blueAccent},
        ]
      },
      {
        'name': 'Sales Division',
        'subtitle': 'Sales team digital cards',
        'members': '24 members',
        'badges': [
          {'label': 'Shared', 'color': Colors.blueAccent},
        ]
      },
      {
        'name': 'Executive Board',
        'subtitle': 'C-suite and executives',
        'members': '5 members',
        'badges': [
          {'label': 'Private', 'color': Colors.purpleAccent},
        ]
      },
      {
        'name': 'Engineering',
        'subtitle': 'Technical team cards',
        'members': '35 members',
        'badges': [
          {'label': 'Shared', 'color': Colors.blueAccent},
        ]
      },
      {
        'name': 'HR Department',
        'subtitle': 'Human resources team',
        'members': '8 members',
        'badges': [
          {'label': 'Private', 'color': Colors.purpleAccent},
          {'label': 'Inactive', 'color': Colors.redAccent},
        ]
      },
    ];

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
                          group['name'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Wrap(
                          spacing: 4,
                          children: (group['badges'] as List).map((badge) {
                            return _buildBadge(badge['label'] as String, badge['color'] as Color);
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      group['subtitle'] as String,
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.people_outline, color: Colors.white38, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          group['members'] as String,
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
