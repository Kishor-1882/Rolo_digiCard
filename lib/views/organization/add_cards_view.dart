import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/organization/group_management_controller.dart';
import 'package:rolo_digi_card/models/check_card_model.dart';
import 'package:rolo_digi_card/models/group_model.dart';
import 'package:rolo_digi_card/utils/color.dart';

class AddCardsView extends StatefulWidget {
  final GroupModel group;
  const AddCardsView({super.key, required this.group});

  @override
  State<AddCardsView> createState() => _AddCardsViewState();
}

class _AddCardsViewState extends State<AddCardsView> {
  final controller = Get.find<GroupManagementController>();
  final Set<String> _selectedIds = {};
  final Set<String> _preExistingIds = {};
  final TextEditingController _searchController = TextEditingController();
  String _search = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    controller.fetchOrganizationCards();
    
    // Pre-select existing cards
    if (controller.selectedGroup.value != null) {
      _preExistingIds.addAll(controller.selectedGroup.value!.cardIds);
    } else {
      _preExistingIds.addAll(widget.group.cardIds);
    }
    _selectedIds.addAll(_preExistingIds);
  }

  void _toggleSelection(String id) {
    if (_preExistingIds.contains(id)) return;
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Cards',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            Text('Search and select cards to add',
                style: TextStyle(color: Colors.white54, fontSize: 12)),
          ],
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        // Filter by search
        final filtered = controller.cardsList.where((c) {
          final q = _search.toLowerCase();
          return c.name.toLowerCase().contains(q) ||
              c.bio.toLowerCase().contains(q);
        }).toList();

        return Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.white),
                onChanged: (v) => setState(() => _search = v),
                decoration: InputDecoration(
                  hintText: 'Search by name or email...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon:
                      const Icon(Icons.search, color: Colors.white38),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white38),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _search = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF1E1E2C),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Select all / Clear + count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${_selectedIds.length} selected',
                      style: const TextStyle(color: Colors.white54)),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => setState(() {
                          final filteredIds = filtered.map((c) => c.id).toSet();
                          if (filteredIds.every((id) => _selectedIds.contains(id))) {
                            // Clear all except pre-existing
                            _selectedIds.clear();
                            _selectedIds.addAll(_preExistingIds);
                          } else {
                            _selectedIds.addAll(filteredIds);
                          }
                        }),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Select All'),
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.white),
                      ),
                      TextButton.icon(
                        onPressed: () =>
                            setState(() {
                              _selectedIds.clear();
                              _selectedIds.addAll(_preExistingIds);
                            }),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Clear'),
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // List
            Expanded(
              child: controller.isLoading.value && controller.cardsList.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : filtered.isEmpty
                      ? const Center(
                          child: Text('No cards found',
                              style: TextStyle(color: Colors.white54)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final card = filtered[index];
                            final isSelected =
                                _selectedIds.contains(card.id);
                            final isPreExisting = _preExistingIds.contains(card.id);

                            final avatarColors = [
                              const Color(0xFF9B59B6),
                              const Color(0xFF3B82F6),
                              const Color(0xFF10B981),
                              const Color(0xFFEF4444),
                              const Color(0xFF6C3EB8),
                            ];
                            final avatarColor =
                                avatarColors[index % avatarColors.length];

                            return GestureDetector(
                              onTap: () => _toggleSelection(card.id),
                              child: Opacity(
                                opacity: isPreExisting ? 0.6 : 1.0,
                                child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E1E2C),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFFE040FB)
                                        : Colors.white.withOpacity(0.1),
                                    width: isSelected ? 1.5 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    // Circle radio
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? const Color(0xFFE040FB)
                                              : Colors.white38,
                                          width: 2,
                                        ),
                                      ),
                                      child: isSelected
                                          ? Center(
                                              child: Container(
                                                width: 14,
                                                height: 14,
                                                decoration:
                                                    const BoxDecoration(
                                                  color: Color(0xFFE040FB),
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 16),

                                    // Avatar
                                    // CircleAvatar(
                                    //   backgroundColor: avatarColor,
                                    //   child: Text(card.initials,
                                    //       style: const TextStyle(
                                    //           color: Colors.white,
                                    //           fontWeight: FontWeight.bold)),
                                    // ),
                                    // const SizedBox(width: 16),

                                    // Name + email
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(card.name,
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight:
                                                      FontWeight.bold)),
                                          Text(card.bio,
                                              style: const TextStyle(
                                                  color: Colors.white54,
                                                  fontSize: 12)),
                                        ],
                                      ),
                                    ),

                                    // Status badge or Already in Group indicator
                                    isPreExisting
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white12,
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: Colors.white24),
                                            ),
                                            child: const Text(
                                              'Already Added',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                        : Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(0.2)),
                                            ),
                                            child: Text(
                                              card.isActive
                                                  ? 'Active'
                                                  : 'Disabled',
                                              style: TextStyle(
                                                color: card.isActive
                                                    ? const Color(0xFF4CAF50)
                                                    : Colors.white54,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                  ],
                                ),
                              ),
                            ),
                            );
                          },
                        ),
            ),

            // Add button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _selectedIds.isEmpty || controller.isLoading.value
                      ? null
                      : () async {
                          await controller.addGroupCards(
                            widget.group.id,
                            _selectedIds.toList(),
                          );
                          Get.back();
                        },
                  icon: controller.isLoading.value
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.add_card, color: Colors.white),
                  label: Text(
                    controller.isLoading.value ? 'Adding...' : 'Add Selected (${_selectedIds.length})',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE040FB),
                    disabledBackgroundColor: Colors.grey.shade800,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}