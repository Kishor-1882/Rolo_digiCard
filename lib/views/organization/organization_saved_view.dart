import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/organization/organization_controller.dart';
import 'package:rolo_digi_card/controllers/organization/saved_items_controller.dart';
import 'package:rolo_digi_card/models/card_model.dart';
import 'package:rolo_digi_card/models/organization_user_model.dart';
import 'package:rolo_digi_card/utils/color.dart';

class OrganizationSavedView extends GetView<SavedItemsController> {
  const OrganizationSavedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Obx(() {
          final cards = controller.filteredCards;
          final contacts = controller.filteredContacts;
          final total = cards.length + contacts.length;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(),
                const SizedBox(height: 24),
                _buildStatsCard(total),
                const SizedBox(height: 24),
                _buildSearchBar(),
                const SizedBox(height: 24),
                _buildCategoryFilter(),
                const SizedBox(height: 24),
                _buildSavedItemsList(cards, contacts),
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
              'Saved Items',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Quick access to your bookmarks',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.shade400,
            shape: BoxShape.circle,
          ),
          child: Obx(() {
            final initials = Get.find<OrganizationController>().currentUser.value?.initials ?? 'JD';
            return Text(
              initials,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStatsCard(int total) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                total.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Total Saved',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE91E8E), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE91E8E).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.bookmark_outline, color: Colors.white, size: 32),
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
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: TextField(
        onChanged: (value) => controller.setSearchQuery(value),
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Search saved items...',
          hintStyle: const TextStyle(color: Colors.white24),
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: Colors.white24),
          suffixIcon: controller.searchQuery.value.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.white24, size: 18),
                onPressed: () => controller.setSearchQuery(''),
              )
            : null,
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categories = ['All', 'Cards', 'Groups', 'Contacts'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(() => Row(
            children: categories.map((cat) {
              final isSelected = controller.selectedCategory.value == cat;
              return Expanded(
                child: GestureDetector(
                  onTap: () => controller.setCategory(cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.white.withOpacity(0.05) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isSelected ? Border.all(color: Colors.white10) : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cat,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.white54,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          )),
    );
  }

  Widget _buildSavedItemsList(List<CardModel> cards, List<OrganizationUserModel> contacts) {
    final List<Map<String, dynamic>> allItems = [];
    
    // Add cards if filter matches
    if (controller.selectedCategory.value == 'All' || controller.selectedCategory.value == 'Cards') {
      allItems.addAll(cards.map((c) => {
        'title': c.name,
        'type': 'Card',
        'subtitle': c.title,
        'time': 'Member since ${_formatDate(c.createdAt)}',
        'icon': Icons.credit_card,
        'color': Colors.pink
      }));
    }
    
    // Add contacts if filter matches
    if (controller.selectedCategory.value == 'All' || controller.selectedCategory.value == 'Contacts') {
      allItems.addAll(contacts.map((contact) => {
        'title': contact.fullName,
        'type': 'Contact',
        'subtitle': contact.email,
        'time': 'Invited: ${contact.invitedAt ?? 'N/A'}',
        'icon': Icons.person_outline,
        'color': Colors.purpleAccent
      }));
    }

    if (allItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Text(
            'No saved items found',
            style: TextStyle(color: Colors.white.withOpacity(0.3)),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: allItems.length,
      itemBuilder: (context, index) {
        final item = allItems[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      (item['color'] as Color).withOpacity(0.8),
                      (item['color'] as Color).withOpacity(0.4),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(item['icon'] as IconData, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['title'] as String,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildTypeBadge(item['type'] as String),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['subtitle'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['time'] as String,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Widget _buildTypeBadge(String type) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.white10),
      ),
      child: Text(
        type,
        style: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
