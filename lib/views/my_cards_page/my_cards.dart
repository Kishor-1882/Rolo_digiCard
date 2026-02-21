import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/common/header.dart';
import 'package:rolo_digi_card/controllers/home/home_page_controller.dart';
import 'package:rolo_digi_card/models/card_model.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/views/home_page/create_new_card.dart';
import 'package:rolo_digi_card/views/my_cards_page/widget/CommonCardWidget.dart';
import 'package:rolo_digi_card/views/my_cards_page/widget/business_card_details.dart';
import 'package:rolo_digi_card/views/my_cards_page/widget/qr_details.dart';

class MyCardsPage extends StatelessWidget {
   const MyCardsPage({Key? key}) : super(key: key);


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
                  () => BusinessCardProfilePage(card: card,),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: GetBuilder<HomePageController>(builder: (controller) {
          String _getInitials(String name) {
            List<String> names = name.trim().split(' ');
            if (names.isEmpty) return '';
            if (names.length == 1) {
              return names[0].substring(0, 1).toUpperCase();
            }
            return '${names[0].substring(0, 1)}${names[names.length - 1].substring(0, 1)}'
                .toUpperCase();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              AppHeader(),
              SizedBox(
                height: 10,
              ),
              // Padding(
              //
              //   padding: const EdgeInsets.all(15.0),
              //   child:
              // ),
              // Replace your current ListView.builder section with this:

              Expanded(
                child: SingleChildScrollView(
                  child: controller.cardsResponse == null
                      ? Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                              child: CircularProgressIndicator(
                                color: AppColors.textPrimary,
                              ),
                            ),
                        ],
                      )
                      : controller.cardsResponse!.cards.isEmpty
                          ? Center(
                              child: Container(
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.credit_card_off,
                                      size: 60,
                                      color: AppColors.textSecondary,
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      "No cards created yet",
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${controller.cardsResponse!.cards.length} card${controller.cardsResponse!.cards.length > 1 ? 's' : ''} created",
                                    style: TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 15,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  ListView.builder(
                                    itemCount:
                                        controller.cardsResponse!.cards.length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      final card =
                                          controller.cardsResponse!.cards[index];
                                      return Padding(
                                        padding: const EdgeInsets.only(bottom: 5.0),
                                        child: CommonCardWidget(
                                          initials: _getInitials(card.name),
                                          name: card.name,
                                          role: card.title,
                                          company: card.company,
                                          visibility:
                                              card.isPublic ? "Public" : "Private",
                                          viewsCount: card.viewCount,
                                          qrCount: card.scanCount,
                                          themeMode:
                                              card.theme.cardStyle.capitalize ??
                                                  "Default",
                                          onQrTap: () {
                                            Get.to(() => QRCodeSharePage(
                                                  card: card,
                                                ));
                                          },
                                          onMenuTap: (TapDownDetails details) {
                                            _showPopupMenu(context,
                                                details.globalPosition, card,controller);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
