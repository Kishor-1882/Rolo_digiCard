import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/utils/color.dart';

import 'package:rolo_digi_card/controllers/individual_group_controller.dart';
import 'package:rolo_digi_card/models/group_model.dart';

class AddCardsToGroupDialog extends StatefulWidget {
  final GroupModel group;
  const AddCardsToGroupDialog({Key? key, required this.group}) : super(key: key);

  static void show(BuildContext context, GroupModel group) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddCardsToGroupDialog(group: group),
      ),
    );
  }

  @override
  State<AddCardsToGroupDialog> createState() => _AddCardsToGroupDialogState();
}

class _AddCardsToGroupDialogState extends State<AddCardsToGroupDialog> {
  final IndividualGroupController controller = Get.find<IndividualGroupController>();
  final Set<String> _selectedCardIds = {};
  late final Set<String> _alreadyAddedCardIds;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _alreadyAddedCardIds = widget.group.cardIds.toSet();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchMyCards();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Determine screen height to limit modal size
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.85,
      ),
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Color(0xFF14141E), // Similar dark background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Add Cards to Group',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white54),
                onPressed: () => Get.back(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search Input
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E2C),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search cards...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Cards List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.myCards.isEmpty) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primaryPink));
              }

              final filteredCards = controller.myCards.where((card) {
                return card.name.toLowerCase().contains(_searchQuery) ||
                       (card.title?.toLowerCase().contains(_searchQuery) ?? false) ||
                       (card.company?.toLowerCase().contains(_searchQuery) ?? false);
              }).toList();

              if (filteredCards.isEmpty) {
                return Center(
                  child: Text('No cards found', style: TextStyle(color: Colors.grey[500])),
                );
              }

              return ListView.builder(
                itemCount: filteredCards.length,
                itemBuilder: (context, index) {
                  return _buildCardItem(filteredCards[index]);
                },
              );
            }),
          ),

          // Actions
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () {
                  if (_selectedCardIds.isNotEmpty) {
                    controller.addCardsToGroup(widget.group.id, _selectedCardIds.toList());
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF5A4181),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Obx(() => controller.isLoading.value
                    ? const SizedBox(
                        width: 18, 
                        height: 18, 
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF9074B6))
                      )
                    : Text(
                        'Add ${_selectedCardIds.isEmpty ? "" : "(${_selectedCardIds.length}) "}Cards',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardItem(var card) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2C), // Dark card surface
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (card.title?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 4),
                  Text(
                    card.title!,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
                if (card.company?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 2),
                  Text(
                    card.company!,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Theme(
            data: ThemeData(
              unselectedWidgetColor: Colors.white54,
              disabledColor: Colors.white24,
            ),
            child: Checkbox(
              value: _alreadyAddedCardIds.contains(card.id) || _selectedCardIds.contains(card.id),
              onChanged: _alreadyAddedCardIds.contains(card.id)
                  ? null
                  : (bool? value) {
                      if (value != null) {
                        setState(() {
                          if (value) {
                            _selectedCardIds.add(card.id);
                          } else {
                            _selectedCardIds.remove(card.id);
                          }
                        });
                      }
                    },
              activeColor: const Color(0xFF8B5CF6), // Purple
              checkColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
