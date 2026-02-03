import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/controllers/home/home_page_controller.dart';
import 'package:rolo_digi_card/models/card_model.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/views/home_page/create_new_card.dart';
import 'package:rolo_digi_card/views/home_page/widget/card_list_item_widget.dart';
import 'package:rolo_digi_card/views/my_cards_page/widget/business_card_details.dart';

class RecentCardsPage extends StatefulWidget {
  const RecentCardsPage({super.key});

  @override
  State<RecentCardsPage> createState() => _RecentCardsPageState();
}

class _RecentCardsPageState extends State<RecentCardsPage> {
  final HomePageController controller = Get.find<HomePageController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.gradientStart.withOpacity(0.80),
                border: Border(
                  bottom: BorderSide(
                    color: AppColors.textPrimary.withOpacity(0.10),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF6339A), Color(0xFF9810FA)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "All Cards",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "View all your cards",
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Cards Section
            Expanded(
              child: Obx(() {
                // Loading state
                if (controller.isLoadingCards.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.textSecondary,
                    ),
                  );
                }

                // Empty state
                if (controller.cardsResponse == null ||
                    controller.cardsResponse!.cards.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.gradientStart.withOpacity(0.3),
                                AppColors.gradientEnd.withOpacity(0.3),
                              ],
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.credit_card_off,
                            size: 40,
                            color: AppColors.textPrimary.withOpacity(0.5),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'No cards found',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first card to get started',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Display all cards
                final allCards = controller.cardsResponse!.cards;
                final totalCards = allCards.length;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Section Title
                        Text(
                          'All Your Cards',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 19,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage and view all your digital cards',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Cards List
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.gradientStart.withOpacity(0.95),
                                    AppColors.gradientEnd.withOpacity(0.95),
                                  ]),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: AppColors.textPrimary.withOpacity(0.10),
                              )
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: allCards.length,
                            itemBuilder: (context, index) {
                              final card = allCards[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: CardListItem(
                                  name: card.name,
                                  role: card.title,
                                  company: card.company,
                                  views: card.viewCount.toString(),
                                    onMenuTap:(TapDownDetails details) {
                                      _showPopupMenu(context,
                                          details.globalPosition, card,controller);
                                    }
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showPopupMenu(BuildContext context, Offset offset, CardModel card,HomePageController controller) async {
    await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy,
        offset.dx,
        offset.dy,
      ),
      color: const Color(0xFF27272A),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFF858585),
          width: 1,
        ),
      ),
      constraints: const BoxConstraints(
        minWidth: 70,  // Set minimum width
        maxWidth: 100,  // Set maximum width
      ),
      items: [
        PopupMenuItem<String>(
          height: 30,
          value: 'view',
          child: Row(
            children: [
              Icon(
                Icons.visibility_outlined,
                color: Colors.white.withOpacity(0.9),
                size: 16,
              ),
              const SizedBox(width: 12),
              Text(
                'View',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          enabled: false,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          height: 8,
          child: const Divider(
            color: Color(0xFF858585),
            thickness: 1,
            height: 1,
          ),
        ),

        PopupMenuItem<String>(
          height: 30,
          value: 'edit',
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                color: Colors.white.withOpacity(0.9),
                size: 16,
              ),
              const SizedBox(width: 12),
              Text(
                'Edit',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        PopupMenuItem<String>(
          enabled: false,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          height: 8,
          child: const Divider(
            color: Color(0xFF858585),
            thickness: 1,
            height: 1,
          ),
        ),

        PopupMenuItem<String>(
          height: 30,
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                color: Colors.white.withOpacity(0.9),
                size: 16,
              ),
              const SizedBox(width: 12),
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    ).then((value) {
      if (value != null) {
        switch (value) {
          case 'view':
          // Handle view action
            Get.to(
                  () => BusinessCardProfilePage(cardId: card.shortUrl,),
            );
            break;
          case 'edit':
          // Handle edit action
            Get.to(
                  () => const CreateNewCard(),
              arguments: {
                'isEdit': true,
                'card': card,
              },
            );
            break;
          case 'delete':
          // Handle delete action
            print('Delete clicked for ${card.name}');
            showDeleteDialog(controller,context,card.id);
            break;
        }
      }
    });
  }

  Future<void> showDeleteDialog(HomePageController controller,BuildContext context, String cardId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.red,
                size: 28,
              ),
              SizedBox(width: 12),
              Text(
                'Delete Card',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Text(
            'Are you sure you want to delete this card? This action cannot be undone.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                ),
              ),
            ),
            Obx(
                  ()=> ElevatedButton(
                onPressed: controller.isLoading.value
                    ? null
                    : () {
                  Navigator.of(context).pop();
                  controller.deleteCard(context, cardId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: controller.isLoading.value
                    ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : Text(
                  'Delete',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}