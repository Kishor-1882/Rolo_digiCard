import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/common/header.dart';
import 'package:rolo_digi_card/common/snack_bar.dart';
import 'package:rolo_digi_card/controllers/save/save_controller.dart';
import 'package:rolo_digi_card/models/save_card_model.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/views/my_cards_page/widget/business_card_details.dart';
import 'package:rolo_digi_card/views/saved_cards_page/widget/card_widget.dart';
import 'package:rolo_digi_card/views/saved_cards_page/widget/saved_card_details.dart';

class SavedCards extends StatelessWidget {
  const SavedCards({Key? key}) : super(key: key);

  Future<void> showDeleteDialog(SaveController controller,BuildContext context, String cardId) async {
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
                  controller.deleteCard(cardId);
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

  void _showPopupMenu(BuildContext context, Offset offset, SavedCardModel card,SaveController controller) async {
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
            // Get.to(
            //       () => BusinessCardProfilePage(card: card.card,),
            // );
            break;
          case 'delete':
          // Handle delete action
          //   print('Delete clicked for ${card.name}');
            showDeleteDialog(controller,context,card.id);
            break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final SaveController saveController = Get.put(SaveController());

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child:  RefreshIndicator(
            onRefresh: saveController.refreshSavedCards,
            color: AppColors.iconBlue,
            backgroundColor: AppColors.gradientStart,
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  AppHeader(),
                  SizedBox(height: 10),
                  GetBuilder<SaveController>(
                    builder: (controller) {
                      if (controller.isLoading.value) {
                        return Center(
                          child: CircularProgressIndicator(
                            color: AppColors.iconBlue,
                          ),
                        );
                      }

                      return Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Title and count
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Saved Cards',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 19,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${controller.cardCount} cards saved',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),

                                // Sort dropdown
                                GestureDetector(
                                  onTap: () => _showSortOptions(context, controller),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.gradientStart,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: AppColors.textPrimary.withOpacity(0.10),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          _getSortText(controller.sortBy.value),
                                          style: TextStyle(
                                            color: AppColors.textGrayPrimary,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        Icon(
                                          Icons.keyboard_arrow_down,
                                          color: AppColors.iconGrey,
                                          size: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

                            // Empty state card
                            if (controller.filteredCards.isEmpty)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(colors: [
                                    AppColors.gradientStart,
                                    AppColors.gradientEnd,
                                  ]),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: AppColors.textPrimary.withOpacity(0.10),
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Icon circle
                                    Container(
                                      width: 64,
                                      height: 64,
                                      decoration: BoxDecoration(
                                        color: Color(0xFF2B7FFF).withOpacity(0.20),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.bookmark_outline,
                                        color: AppColors.iconBlue,
                                        size: 40,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      'No saved cards',
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Scan QR codes to save contacts here',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else
                            // Cards list

                              Column(
                                children: [
                                  Obx(() {
                                    if (controller.isSelectionMode.value && controller.selectedCount > 0) {
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 12),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                controller.exportSelectedCards();
                                              },
                                              icon: Icon(
                                                Icons.file_download_outlined,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                              label: Text(
                                                'Export Contact',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: AppColors.iconBlue,
                                                foregroundColor: Colors.white,
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 10,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                elevation: 2,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return SizedBox.shrink();
                                  }),

                                  ListView.builder(
                                    itemCount: controller.filteredCards.length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final savedCard = controller.filteredCards[index];
                                      final card = savedCard.card;
                                      final cardModel = controller.getCardModelFromSaved(savedCard);
                                      print("Refresh");
                                      return BusinessCardWidget(
                                        name: card.name,
                                        designation: card.title,
                                        company: card.company,
                                        savedDate: _formatDate(savedCard.savedAt),
                                        isSelected: controller.isCardSelected(savedCard.id),
                                        isFavorite: savedCard.isFavorite,
                                        onCheckboxTap: () {
                                          if (controller.isSelectionMode.value) {
                                            controller.toggleCardSelection(savedCard.id);
                                          } else {
                                            controller.toggleSelectionMode();
                                            controller.toggleCardSelection(savedCard.id);
                                          }
                                        },
                                        onFavoriteTap: () {
                                          controller.toggleFavorite(savedCard.id,savedCard.isFavorite);
                                        },
                                        onDownloadTap: () {
                                          print("Download");
                                          if (cardModel != null) {
                                            controller.downloadCard(card: cardModel);
                                          } else {
                                            CommonSnackbar.error('Card details not available');
                                          }
                                        },
                                        onShareTap: () {
                                          print("Share");
                                          if (cardModel != null) {
                                            controller.shareCard(cardModel);
                                          } else {
                                            CommonSnackbar.error('Card details not available');
                                          }
                                        },
                                        onMenuTap: (TapDownDetails details) {
                                          _showPopupMenu(context,
                                              details.globalPosition, savedCard,controller);
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                          ],
                        ),
                      );
                    }
                  ),
                ],
              ),
            ),
          ),
      ),
      // Show bulk actions when in selection mode
      // bottomNavigationBar: Obx(() {
      //   if (saveController.isSelectionMode.value && saveController.selectedCount > 0) {
      //     return Container(
      //       padding: EdgeInsets.all(16),
      //       decoration: BoxDecoration(
      //         color: AppColors.gradientStart,
      //         border: Border(
      //           top: BorderSide(
      //             color: AppColors.textPrimary.withOpacity(0.10),
      //           ),
      //         ),
      //       ),
      //       child: Row(
      //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //         children: [
      //           Text(
      //             '${controller.selectedCount} selected',
      //             style: TextStyle(
      //               color: AppColors.textPrimary,
      //               fontSize: 16,
      //               fontWeight: FontWeight.w500,
      //             ),
      //           ),
      //           Row(
      //             children: [
      //               TextButton(
      //                 onPressed: () {
      //                   controller.deselectAllCards();
      //                   controller.toggleSelectionMode();
      //                 },
      //                 child: Text(
      //                   'Cancel',
      //                   style: TextStyle(
      //                     color: AppColors.textSecondary,
      //                   ),
      //                 ),
      //               ),
      //               SizedBox(width: 8),
      //               ElevatedButton(
      //                 onPressed: () {
      //                   _showDeleteConfirmation(context, controller);
      //                 },
      //                 style: ElevatedButton.styleFrom(
      //                   backgroundColor: Colors.red,
      //                   shape: RoundedRectangleBorder(
      //                     borderRadius: BorderRadius.circular(12),
      //                   ),
      //                 ),
      //                 child: Text('Delete'),
      //               ),
      //             ],
      //           ),
      //         ],
      //       ),
      //     );
      //   }
      //   return SizedBox.shrink();
      // }),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _getSortText(String sortBy) {
    switch (sortBy) {
      case 'date':
        return 'Sort by Date';
      case 'name':
        return 'Sort by Name';
      case 'company':
        return 'Sort by Company';
      default:
        return 'Sort by Date';
    }
  }

  void _showSortOptions(BuildContext context, SaveController controller) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.gradientStart,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Sort By',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 16),
              _buildSortOption(context, controller, 'date', 'Date'),
              _buildSortOption(context, controller, 'name', 'Name'),
              _buildSortOption(context, controller, 'company', 'Company'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(
      BuildContext context,
      SaveController controller,
      String value,
      String label,
      ) {
    return Obx(() {
      final isSelected = controller.sortBy.value == value;
      return ListTile(
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.iconBlue : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check, color: AppColors.iconBlue)
            : null,
        onTap: () {
          controller.changeSortBy(value);
          Navigator.pop(context);
        },
      );
    });
  }

  void _showCardOptions(
      BuildContext context,
      SaveController controller,
      dynamic savedCard,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.gradientStart,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.share, color: AppColors.iconBlue),
                title: Text(
                  'Share',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  controller.shareCard(savedCard);
                },
              ),
              ListTile(
                leading: Icon(Icons.download, color: AppColors.iconBlue),
                title: Text(
                  'Download',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  controller.downloadCard(card: savedCard);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  controller.removeCard(savedCard.id);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, SaveController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.gradientStart,
          title: Text(
            'Delete Cards',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Text(
            'Are you sure you want to delete ${controller.selectedCount} card(s)?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                controller.deleteSelectedCards();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}