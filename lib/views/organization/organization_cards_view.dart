import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/organization/card_management_controller.dart';
import 'package:rolo_digi_card/models/card_model.dart';
import 'package:rolo_digi_card/utils/color.dart';

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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Card Management',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Manage digital business cards',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.cardBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.qr_code_2, color: Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE91E8E), Color(0xFF8B5CF6)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsGrid(Map<String, dynamic> stats) {
    log("Stats: $stats"); 
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.8,
      children: [
        _buildStatCard(stats['total']?.toString() ?? '0', 'Total Cards', Icons.credit_card, AppColors.primaryPink),
        _buildStatCard(stats['active']?.toString() ?? '0', 'Active', Icons.check_circle_outline, Colors.greenAccent),
        _buildStatCard(stats['disabled']?.toString() ?? '0', 'Inactive', Icons.cancel_outlined, Colors.redAccent),
        _buildStatCard(stats['totalViews']?.toString() ?? '0', 'Views', Icons.access_time, Colors.orangeAccent),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
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
                label,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
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
                hintText: 'Search cards...',
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: DropdownButtonHideUnderline(
            child: Obx(() => DropdownButton<String>(
              dropdownColor: AppColors.cardBackground,
              value: controller.statusFilter.value,
              items: <String>['All...', 'Active', 'Inactive', 'Blocked']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.statusFilter.value = newValue;
                }
              },
              icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
            )),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(Icons.grid_view_sharp, color: Colors.white54, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildCardList(List<CardModel> cards) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        final statusColor = card.isActive ? Colors.greenAccent : (card.isBlocked ? Colors.redAccent : Colors.orangeAccent);
        final statusLabel = card.isActive ? 'Active' : (card.isBlocked ? 'Blocked' : 'Inactive');
        
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
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE91E8E), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.credit_card, color: Colors.white, size: 28),
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
                          card.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        _buildStatusBadge(statusLabel, statusColor),
                      ],
                    ),
                    Text(
                      card.id,
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.qr_code_scanner, color: AppColors.primaryPink, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${card.scanCount} scans',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        const Icon(Icons.visibility_outlined, color: Colors.blueAccent, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${card.viewCount} views',
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Owner: ${card.userId}', // We don't have ownerName in model, but userId is there
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
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

  Widget _buildStatusBadge(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            status == 'Active' ? Icons.check_circle : status == 'Pending' ? Icons.access_time : Icons.cancel,
            color: color,
            size: 12,
          ),
          const SizedBox(width: 4),
          Text(
            status,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
