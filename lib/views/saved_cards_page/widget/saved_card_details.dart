// import 'dart:developer';
//
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:rolo_digi_card/models/card_model.dart';
// import 'package:rolo_digi_card/models/save_card_model.dart';
// import 'package:rolo_digi_card/utils/color.dart';
// import 'dart:convert';
// import 'dart:typed_data';
//
// class SavedCardProfilePage extends StatelessWidget {
//   final SavedCard card = Get.arguments;
//
//   SavedCardProfilePage({
//     Key? key,
//   }) : super(key: key);
//
//   String _getInitials(String name) {
//     List<String> names = name.split(' ');
//     String initials = '';
//     for (var n in names) {
//       if (n.isNotEmpty) {
//         initials += n[0].toUpperCase();
//       }
//     }
//     return initials.length > 2 ? initials.substring(0, 2) : initials;
//   }
//
//   Uint8List? _base64ToImage(String? base64String) {
//     if (base64String == null || base64String.isEmpty) return null;
//     try {
//       // Remove the data:image/png;base64, prefix if present
//       final base64Data = base64String.contains(',')
//           ? base64String.split(',').last
//           : base64String;
//       return base64Decode(base64Data);
//     } catch (e) {
//       return null;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFF5F5F5),
//       body: SafeArea(
//         child: Column(
//           children: [
//             // Top bar with back button
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Align(
//                 alignment: Alignment.centerLeft,
//                 child: IconButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                   },
//                   icon: Icon(Icons.arrow_back, color: Colors.black, size: 24),
//                   padding: EdgeInsets.zero,
//                   constraints: BoxConstraints(),
//                 ),
//               ),
//             ),
//
//             // Scrollable content
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(horizontal: 24),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     const SizedBox(height: 8),
//
//                     // Profile avatar
//                    Container(
//                       width: 90,
//                       height: 90,
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.centerLeft,
//                           end: Alignment.centerRight,
//                           colors: [
//                             Color(0xFF615FFF),
//                             Color(0xFF9810FA),
//                           ],
//                         ),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Center(
//                         child: Text(
//                           _getInitials(card.name),
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 36,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//
//                     // Name
//                     Text(
//                       card.name,
//                       style: TextStyle(
//                         color: Color(0xFF101828),
//                         fontSize: 15,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     const SizedBox(height: 8),
//
//                     // Designation
//                     Text(
//                       card.title,
//                       style: TextStyle(
//                         color: AppColors.lightText,
//                         fontSize: 15,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//
//                     // Company
//                     Text(
//                       card.company,
//                       style: TextStyle(
//                         color: AppColors.lightText,
//                         fontSize: 14,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                     const SizedBox(height: 2),
//
//                     // Industry
//                     Text(
//                       card.industry,
//                       style: TextStyle(
//                         color: Color(0xFF888888),
//                         fontSize: 13,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                     const SizedBox(height: 24),
//
//                     // Bio
//                     if (card.bio.isNotEmpty)
//                       Container(
//                         padding: EdgeInsets.all(10),
//                         decoration: BoxDecoration(
//                           color: Color(0xFFF9FAFB),
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         child: Text(
//                           card.bio,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color: Color(0xFF364153),
//                             fontSize: 13,
//                             fontWeight: FontWeight.w400,
//                             height: 1.5,
//                           ),
//                         ),
//                       ),
//                     const SizedBox(height: 32),
//
//                     // Contact information
//                     if (card.contact.email != null &&
//                         card.contact.email!.isNotEmpty)
//                       _buildContactItem(
//                         Icons.email_outlined,
//                         card.email!,
//                         Color(0xFF6C5CE7),
//                       ),
//                     if (card.contact.email != null &&
//                         card.contact.email!.isNotEmpty)
//                       const SizedBox(height: 20),
//
//                     if (card.contact.phone != null &&
//                         card.contact.phone!.isNotEmpty)
//                       _buildContactItem(
//                         Icons.phone_outlined,
//                         card.contact.phone!,
//                         Color(0xFF6C5CE7),
//                       ),
//                     if (card.contact.phone != null &&
//                         card.contact.phone!.isNotEmpty)
//                       const SizedBox(height: 20),
//
//                     if (card.contact.mobileNumber != null &&
//                         card.contact.mobileNumber!.isNotEmpty)
//                       _buildContactItem(
//                         Icons.smartphone_outlined,
//                         card.contact.mobileNumber!,
//                         Color(0xFF6C5CE7),
//                       ),
//                     if (card.contact.mobileNumber != null &&
//                         card.contact.mobileNumber!.isNotEmpty)
//                       const SizedBox(height: 20),
//
//                     // Public URL
//                     _buildContactItem(
//                       Icons.language,
//                       card.publicUrl,
//                       Color(0xFF6C5CE7),
//                     ),
//                     const SizedBox(height: 20),
//
//                     // Skills section
//                     if (card.tags.isNotEmpty) ...[
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           'Skills',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w400,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//
//                       // Skills chips
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: Wrap(
//                           spacing: 8,
//                           runSpacing: 8,
//                           children: card.tags.map((skill) {
//                             return Container(
//                               padding: const EdgeInsets.symmetric(
//                                 horizontal: 16,
//                                 vertical: 8,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: Color(0xFF2A2A2A),
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                               child: Text(
//                                 skill,
//                                 style: TextStyle(
//                                   color: Colors.white,
//                                   fontSize: 13,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                         ),
//                       ),
//                       const SizedBox(height: 32),
//                     ],
//
//                     // Custom Links section
//                     if (card.customLinks.isNotEmpty) ...[
//                       Align(
//                         alignment: Alignment.centerLeft,
//                         child: Text(
//                           'Connect',
//                           style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 12),
//
//                       // Social icons
//                       Row(
//                         children: [
//                           ...card.customLinks.take(4).map((link) {
//                             return Padding(
//                               padding: const EdgeInsets.only(right: 12.0),
//                               child: Container(
//                                 width: 44,
//                                 height: 44,
//                                 decoration: BoxDecoration(
//                                   color: Color(0xFFF3F4F6),
//                                   borderRadius: BorderRadius.circular(8),
//                                   border: Border.all(
//                                     color: Color(0xFFE0E0E0),
//                                     width: 1,
//                                   ),
//                                 ),
//                                 child: Icon(
//                                   Icons.link,
//                                   color: Color(0xFF4F39F6),
//                                   size: 24,
//                                 ),
//                               ),
//                             );
//                           }).toList(),
//                         ],
//                       ),
//                       const SizedBox(height: 32),
//                     ],
//
//                     // Action buttons
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Container(
//                             height: 50,
//                             decoration: BoxDecoration(
//                               color: AppColors.progressPink,
//                               borderRadius: BorderRadius.circular(25),
//                             ),
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 _saveContact(context);
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 backgroundColor: Colors.transparent,
//                                 shadowColor: Colors.transparent,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(25),
//                                 ),
//                               ),
//                               child: Row(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Icon(
//                                     Icons.file_download_outlined,
//                                     color: AppColors.buttonBlack,
//                                     size: 20,
//                                   ),
//                                   const SizedBox(width: 8),
//                                   Text(
//                                     'Save Contact',
//                                     style: TextStyle(
//                                       color: AppColors.buttonBlack,
//                                       fontSize: 15,
//                                       fontWeight: FontWeight.w500,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 12),
//                         Container(
//                           height: 50,
//                           padding: EdgeInsets.all(15),
//                           decoration: BoxDecoration(
//                             color: Color(0xFF2C2C2C),
//                             borderRadius: BorderRadius.circular(25),
//                           ),
//                           child: GestureDetector(
//                             onTap: () {
//                               _shareCard(context);
//                             },
//                             child: Row(
//                               children: [
//                                 Icon(
//                                   Icons.share,
//                                   color: Colors.white,
//                                   size: 20,
//                                 ),
//                                 SizedBox(width: 10),
//                                 Text(
//                                   'Share',
//                                   style: TextStyle(
//                                     color: AppColors.textPrimary,
//                                   ),
//                                 )
//                               ],
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 24),
//
//                     // Powered by
//                     Text(
//                       'Powered by Rolo Digi Card',
//                       style: TextStyle(
//                         color: Color(0xFFAAAAAA),
//                         fontSize: 12,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                     const SizedBox(height: 32),
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildContactItem(IconData icon, String text, Color iconColor) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           color: iconColor,
//           size: 22,
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Text(
//             text,
//             style: TextStyle(
//               color: Color(0xFF555555),
//               fontSize: 14,
//               fontWeight: FontWeight.w400,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   void _saveContact(BuildContext context) {
//     // Implement save contact functionality
//     // You can use packages like:
//     // - contacts_service
//     // - flutter_contacts
//
//     // Example implementation:
//     /*
//     final contact = Contact()
//       ..name.first = card.name
//       ..emails = [Email(card.contact.email ?? '')]
//       ..phones = [Phone(card.contact.phone ?? '')];
//
//     await ContactsService.addContact(contact);
//     */
//   }
//
//   void _shareCard(BuildContext context) {
//     // Implement share functionality
//     // You can use packages like:
//     // - share_plus
//
//     // Example implementation:
//     /*
//     Share.share(
//       'Check out ${card.name}\'s digital business card: ${card.publicUrl}',
//       subject: '${card.name} - Digital Business Card',
//     );
//     */
//   }
// }
//
// // Updated navigation call:
// // Get.to(() => BusinessCardProfilePage(card: card));