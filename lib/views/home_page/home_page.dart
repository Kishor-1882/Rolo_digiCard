import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:rolo_digi_card/common/header.dart';
import 'package:rolo_digi_card/controllers/home/home_page_controller.dart';
import 'package:rolo_digi_card/controllers/profile/profile_controller.dart';
import 'package:rolo_digi_card/models/card_model.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/views/home_page/create_new_card.dart';
import 'package:rolo_digi_card/views/home_page/widget/activity_item_widget.dart';
import 'package:rolo_digi_card/views/home_page/widget/card_list_item_widget.dart';
import 'package:rolo_digi_card/views/home_page/widget/progress_bar_widget.dart';
import 'package:rolo_digi_card/views/home_page/widget/recent_activity_page.dart';
import 'package:rolo_digi_card/views/home_page/widget/recent_cards_page.dart';
import 'package:rolo_digi_card/views/home_page/widget/stat_card_widget.dart';
import 'package:rolo_digi_card/views/my_cards_page/widget/business_card_details.dart';

class DashboardPage extends StatelessWidget {
   DashboardPage({Key? key}) : super(key: key);
  final profileController = Get.put(ProfileController());
  final homepageController = Get.put(HomePageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: GetBuilder<HomePageController>(
          builder: (controller) {
            final dashboardAnalytics = controller.dashboardAnalytics;
            return Column(
              children: [
                // Header
                AppHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Dashboard Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dashboard',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 19,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Track your digital card performance',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    overflow: TextOverflow.ellipsis
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: (){
                                  Get.toNamed('/create-card');
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 11,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFF6339A), Color(0xFF9810FA)],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.add,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Create Card',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 10,),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Get.toNamed('/scan-card');
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(2), // thickness of gradient border
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFF6339A), Color(0xFF9810FA)],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 11,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black, // your background (match your UI)
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.qr_code,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Scan Card',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Stats Grid
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.2,
                          children:  [
                            StatCard(
                              title: 'Total Cards',
                              value:controller.totalCards.toString(),
                              icon: Icons.credit_card,
                              iconColor: AppColors.primaryPink,
                            ),
                            StatCard(
                              title: 'Total Views',
                              value: controller.totalViews.toString(),
                              icon: Icons.visibility,
                              iconColor: AppColors.primaryPink,
                            ),
                            StatCard(
                              title: 'QR Scans',
                              value: controller.totalScans.toString(),
                              icon: Icons.qr_code_scanner,
                              iconColor: AppColors.chartPurple,
                            ),
                          ],
                        ),
                        // const SizedBox(height: 24),
                        // // Chart Section
                        // Container(
                        //   padding: const EdgeInsets.all(20),
                        //   decoration: BoxDecoration(
                        //     color: AppColors.cardBackground,
                        //     borderRadius: BorderRadius.circular(16),
                        //   ),
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Row(
                        //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //         children: [
                        //           const Row(
                        //             children: [
                        //               Icon(
                        //                 Icons.trending_up,
                        //                 color: AppColors.primaryPink,
                        //                 size: 20,
                        //               ),
                        //               SizedBox(width: 8),
                        //               Text(
                        //                 'Your Progress',
                        //                 style: TextStyle(
                        //                   color: AppColors.textPrimary,
                        //                   fontSize: 16,
                        //                   fontWeight: FontWeight.w600,
                        //                 ),
                        //               ),
                        //             ],
                        //           ),
                        //           Container(
                        //             padding: const EdgeInsets.symmetric(
                        //               horizontal: 12,
                        //               vertical: 6,
                        //             ),
                        //             decoration: BoxDecoration(
                        //               color: AppColors.inputBackground,
                        //               borderRadius: BorderRadius.circular(8),
                        //             ),
                        //             child: const Row(
                        //               children: [
                        //                 Text(
                        //                   'June',
                        //                   style: TextStyle(
                        //                     color: AppColors.textPrimary,
                        //                     fontSize: 12,
                        //                   ),
                        //                 ),
                        //                 SizedBox(width: 4),
                        //                 Icon(
                        //                   Icons.keyboard_arrow_down,
                        //                   color: AppColors.textSecondary,
                        //                   size: 16,
                        //                 ),
                        //               ],
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //       const SizedBox(height: 20),
                        //       // Simple chart placeholder
                        //       SizedBox(
                        //         height: 150,
                        //         child: CustomPaint(
                        //           painter: ChartPainter(),
                        //           size: const Size(double.infinity, 150),
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        const SizedBox(height: 24),
                        // Performance Section
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.textPrimary.withOpacity(0.10),
                            ),
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                              AppColors.gradientStart.withOpacity(0.95),
                              AppColors.gradientEnd.withOpacity(0.95),
                            ])
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Performance',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  GestureDetector(
                                    child: const Icon(
                                      Icons.close,
                                      color: AppColors.textSecondary,
                                      size: 20,
                                    ),
                                    onTap: () {},

                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const ProgressBarWidget(
                                title: 'Profile Completion',
                                percentage: '100%',
                                progress: 1.0,
                              ),
                              const ProgressBarWidget(
                                title: 'Engagement Rate',
                                percentage: '50%',
                                progress: 0.5,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Recent Cards
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
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Recent Cards',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      log("CLicked");
                                        Get.to(()=>RecentCardsPage());
                                    },
                                    child: const Row(
                                      children: [
                                        Text(
                                          'View all',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 13,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward,
                                          color: AppColors.textSecondary,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Divider(
                                color:AppColors.textPrimary.withOpacity(0.10),     // line color
                              ),
                              const SizedBox(height: 12),
                              _buildCardsList(context,controller),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Recent Activity
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
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Recent Activity (Dummy Data)',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(()=>RecentActivityPage());
                                    },
                                    child: const Row(
                                      children: [
                                        Text(
                                          'View all',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        SizedBox(width: 4),
                                        Icon(
                                          Icons.arrow_forward,
                                          color: AppColors.textSecondary,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                               Divider(
                                color:AppColors.textPrimary.withOpacity(0.10),     // line color
                              ),
                              const SizedBox(height: 12),
                              const ActivityItem(
                                title: 'Your "Samuel Thornton" card was viewed',
                                time: 'Live now',
                              ),
                              const ActivityItem(
                                title: 'Your "Sarah Simmons" card was viewed',
                                time: '4 hours ago',
                              ),
                              const ActivityItem(
                                title: 'Your "Daniel Kimura" card was viewed',
                                time: '5 hours ago',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
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

   Widget _buildCardsList(BuildContext context,HomePageController controller) {
     // Loading state
     if (controller.isLoadingCards.value) {
       return const Padding(
         padding: EdgeInsets.all(20),
         child: Center(
           child: CircularProgressIndicator(
             color: AppColors.textSecondary,
           ),
         ),
       );
     }

     // Empty state
     if (controller.cardsResponse == null || controller.cardsResponse!.cards.isEmpty) {
       return Padding(
         padding: const EdgeInsets.all(20),
         child: Column(
           children: [
             Icon(
               Icons.credit_card_off,
               size: 48,
               color: AppColors.textPrimary.withOpacity(0.3),
             ),
             const SizedBox(height: 12),
             Text(
               'No cards found',
               style: TextStyle(
                 color: AppColors.textPrimary.withOpacity(0.5),
                 fontSize: 14,
               ),
             ),
           ],
         ),
       );
     }

     // Display cards (limited to first 3 for recent section)
     final recentCards = controller.cardsResponse!.cards.take(3).toList();

     return Column(
       children: recentCards.map((card) {
         return CardListItem(
           name: card.name,
           role: card.title,
           company: card.company,
           views: card.viewCount.toString(),
             onMenuTap:(TapDownDetails details) {
               _showPopupMenu(context,
                   details.globalPosition, card,controller);
             }
         );
       }).toList(),
     );
   }
}
