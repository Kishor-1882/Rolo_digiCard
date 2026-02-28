import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/common/snack_bar.dart';
import 'package:rolo_digi_card/common/common_textfield.dart';
import 'package:rolo_digi_card/controllers/organization/card_management_controller.dart';
import 'package:rolo_digi_card/models/card_model.dart';
import 'package:rolo_digi_card/models/org_model.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/views/home_page/create_new_card.dart';
import 'package:rolo_digi_card/views/my_cards_page/widget/business_card_details.dart';
import 'package:rolo_digi_card/views/organization/widgets/card_details.dart';
import 'package:rolo_digi_card/views/organization/widgets/card_details_card_model.dart';
import 'package:rolo_digi_card/views/organization/widgets/create_group_dialog.dart';

class OrganizationCardsView extends GetView<CardManagementController> {
  const OrganizationCardsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Obx(() {
          final cards = controller.filteredCards;
          final stats = controller.cardStats;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 24),
                _buildStatsGrid(stats),
                const SizedBox(height: 24),
                _buildSearchAndFilter(),
                const SizedBox(height: 16),
                Text(
                  '${cards.length} cards found',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCardList(cards),
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Card Management',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Manage your card groups',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                  ),
                ],
              ),
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
                  icon: const Icon(Icons.add, color: Colors.white, size: 18),
                  label: const Text(
                    'New Group', // Kept as New Group to match screenshot, though functionality is create card
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    // Replaced GridView with Row/Expanded to prevent overflow
    return Row(
      children: [
        Expanded(
          child: _buildStatBox(
            stats['total']?.toString() ?? '0',
            'Total Cards',
            Icons.credit_card,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatBox(
            stats['active']?.toString() ?? '0',
            'Active',
            Icons.check_circle_outline,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatBox(
            stats['totalViews']?.toString() ?? '0',
            'Total Views',
            Icons.visibility_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildStatBox(String value, String label, IconData icon) {
    return Container(
      // Fixed height to prevent layout jumps
      height: 100,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
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
                hintText: 'Search cards...',
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
            child: Obx(
              () => DropdownButton<String>(
                dropdownColor: const Color(0xFF1E1E2C),
                value: controller.statusFilter.value == 'All...' ? 'All' : controller.statusFilter.value,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                items: <String>['All', 'Active', 'Inactive', 'Blocked']
                    .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    })
                    .toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    controller.statusFilter.value = newValue == 'All' ? 'All...' : newValue;
                  }
                },
                icon: const Icon(
                  Icons.keyboard_arrow_down,
                  color: Colors.white54,
                  size: 18
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardList(List<OrgCard> cards) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        final statusColor = card.isActive
            ? Colors.greenAccent
            : (card.isBlocked ? Colors.redAccent : Colors.orangeAccent);
        final statusLabel = card.isActive
            ? 'Active'
            : (card.isBlocked ? 'Blocked' : 'Inactive');

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
            children: [
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
                  card.name[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
              // Container(
              //   width: 60,
              //   height: 60,
              //   decoration: BoxDecoration(
              //     color: const Color(0xFF2B2B36),
              //     borderRadius: BorderRadius.circular(16), // Fixed: Removed conflicts with Shape decoration if any existed in passed data, mostly just safe standard box
              //     image: card.profile != null
              //         ? DecorationImage(
              //             image: NetworkImage(card.profile!),
              //             fit: BoxFit.cover,
              //           )
              //         : null,
              //   ),
              //   child: card.profile == null
              //       ? Center(
              //           child: Text(
              //             card.company.isNotEmpty
              //                 ? card.company[0].toUpperCase()
              //                 : 'C',
              //             style: const TextStyle(
              //               color: Colors.white,
              //               fontWeight: FontWeight.bold,
              //               fontSize: 24,
              //             ),
              //           ),
              //         )
              //       : null,
              // ),
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
                            card.name,
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: statusColor.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            statusLabel,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                         PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white54),
                          color: const Color(0xFF2B2B36),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          onSelected: (value) {
                            if (value == 'delete') {
                              _showDeleteDialog(context, card);
                            } else if (value == 'view') {
                              // View details
                              // Navigate to card detail view if available
                              // Using existing or placeholder for now
                               Get.to(() => CardDetailPage(
                                 card: card,
                                // isOwner: true, 
                               ));
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
                    const SizedBox(height: 4),
                    Text(
                      '${card.title} @ ${card.company}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.visibility_outlined,
                          color: Colors.white38,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${card.viewCount} views',
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                         Icon(
                          Icons.history,
                          color: Colors.white38,
                          size: 14,
                        ),
                         const SizedBox(width: 4),
                        Text(
                          'Updated 2 days ago', // Placeholder
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 12,
                          ),
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

  void _showDeleteDialog(BuildContext context, OrgCard card) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Card', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "${card.company}"? This action cannot be undone.',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              controller.deleteOrgCard(card.id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
