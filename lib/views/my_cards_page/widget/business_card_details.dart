import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/contact.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rolo_digi_card/common/snack_bar.dart';
import 'package:rolo_digi_card/models/card_model.dart';
import 'package:rolo_digi_card/services/dio_client.dart';
import 'package:rolo_digi_card/services/end_points.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'dart:convert';
import 'dart:typed_data';

import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class BusinessCardProfilePage extends StatefulWidget {
  final CardModel card;
  BusinessCardProfilePage({Key? key, required this.card}) : super(key: key);

  @override
  State<BusinessCardProfilePage> createState() =>
      _BusinessCardProfilePageState();
}

class _BusinessCardProfilePageState extends State<BusinessCardProfilePage> {
  late Future<CardModel> cardFuture;
  String _getInitials(String name) {
    List<String> names = name.split(' ');
    String initials = '';
    for (var n in names) {
      if (n.isNotEmpty) {
        initials += n[0].toUpperCase();
      }
    }
    return initials.length > 2 ? initials.substring(0, 2) : initials;
  }

  Uint8List? _base64ToImage(String? base64String) {
    if (base64String == null || base64String.isEmpty) return null;
    try {
      // Remove the data:image/png;base64, prefix if present
      final base64Data = base64String.contains(',')
          ? base64String.split(',').last
          : base64String;
      return base64Decode(base64Data);
    } catch (e) {
      return null;
    }
  }

  // Future<CardModel> getCardDetails({bool isOrg = false}) async {
  //   try {
  //     final response = await dioClient.get(
  //       isOrg
  //           ? ApiEndpoints.getOrgCard(widget.cardId)
  //           : ApiEndpoints.viewPublicCard(widget.cardId),
  //     );
  //     // log('Response in :${response.data}');

  //     final cardJson = isOrg ? response.data : response.data['card'];
  //     return CardModel.fromJson(cardJson);
  //   } catch (e, t) {
  //     String errorMessage = 'Failed to load card';
  //     if (e is DioException) {
  //       log('Error in :${e.response?.data}');
  //       errorMessage =
  //           e.response?.data['message'] ??
  //           e.response?.data['error'] ??
  //           errorMessage;
  //     }
  //     log("Error in :$e $t");
  //     throw "dd";
  //   }
  // }

  @override
  void initState() {
    final args = Get.arguments;
    bool isOrganization = false;
    if (args != null && args is Map<String, dynamic>) {
      isOrganization = args['isOrganization'] ?? false;
    }
    super.initState();
    // cardFuture = getCardDetails(isOrg: isOrganization);
  }

  Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex'; // add alpha
    }
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    // return FutureBuilder<CardModel>(
    //   future: cardFuture,
    //   builder: (context, snapshot) {
          final card = widget.card;
        // if (snapshot.connectionState == ConnectionState.waiting) {
        //   return Scaffold(
        //     backgroundColor: Color(0xFFF5F5F5),
        //     body: Center(child: CircularProgressIndicator()),
        //   );
        // }

        // if (snapshot.hasError) {
        //   return Scaffold(
        //     backgroundColor: Color(0xFFF5F5F5),
        //     body: Center(child: Text('Error loading card')),
        //   );
        // }

        // final card = snapshot.data!;
        // log("Card Json:${card.toJson()}");

        return Scaffold(
          backgroundColor: card.theme.cardStyle == "professional"
              ? Color(0xFFF9FAFB)
              : Color(0xFF0A0A0A),
          body: SafeArea(
            child: Column(
              children: [
                // Top bar with back button
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.arrow_back,
                        color: card.theme.cardStyle == "professional"
                            ? Colors.black
                            : Colors.white,
                        size: 24,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ),
                ),

                // Scrollable content
                Expanded(
                  child: SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          image: DecorationImage(
                            image: AssetImage(
                              card.theme.cardStyle == 'glassmorphic'
                                  ? 'assets/card_background/glass_test.png'
                                  : card.theme.cardStyle == 'dark'
                                  ? 'assets/card_background/black.png'
                                  : 'assets/card_background/white.png',
                            ), // or NetworkImage(...)
                            fit: BoxFit.cover,
                            // colorFilter: ColorFilter.mode(
                            //   Colors.white.withOpacity(0.85), // readability ku
                            //   BlendMode.lighten,
                            // ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 15),

                            // Profile avatar
                            card.profile != null && card.profile!.isNotEmpty
                                ? Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: card.profile!.startsWith('http')
                                            ? NetworkImage(card.profile!)
                                            : MemoryImage(
                                                    _base64ToImage(
                                                      card.profile!,
                                                    )!,
                                                  )
                                                  as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Color(0xFF615FFF),
                                          Color(0xFF9810FA),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getInitials(card.name),
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 36,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                            const SizedBox(height: 16),

                            // Name
                            Text(
                              card.name,
                              style: TextStyle(
                                color: card.theme.cardStyle == 'professional'
                                    ? Color(0xFF101828)
                                    : Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Designation
                            Text(
                              card.title,
                              style: TextStyle(
                                color: card.theme.cardStyle == 'professional'
                                    ? AppColors.lightText
                                    : Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),

                            // Company
                            Text(
                              card.company,
                              style: TextStyle(
                                color: card.theme.cardStyle == 'professional'
                                    ? AppColors.lightText
                                    : Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 2),

                            // Industry
                            Text(
                              card.industry,
                              style: TextStyle(
                                color: card.theme.cardStyle == 'professional'
                                    ? Color(0xFF888888)
                                    : Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Bio
                            if (card.bio.isNotEmpty)
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF9FAFB),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  card.bio,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        card.theme.cardStyle == 'professional'
                                        ? Color(0xFF364153)
                                        : Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w400,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 32),

                            // Contact information
                             if (card.contact.displayEmail != null &&
                                 card.contact.displayEmail!.isNotEmpty)
                               _buildContactItem(
                                 Icons.email_outlined,
                                 card.contact.displayEmail!,
                                 Color(0xFF6C5CE7),
                                 card,
                               ),
                             if (card.contact.displayEmail != null &&
                                 card.contact.displayEmail!.isNotEmpty)
                               const SizedBox(height: 20),

                             if (card.contact.displayPhone != null &&
                                 card.contact.displayPhone!.isNotEmpty)
                               _buildContactItem(
                                 Icons.phone_outlined,
                                 card.contact.displayPhone!,
                                 Color(0xFF6C5CE7),
                                 card,
                               ),
                             if (card.contact.displayPhone != null &&
                                 card.contact.displayPhone!.isNotEmpty)
                               const SizedBox(height: 20),

                             if (card.contact.personalEmail != null &&
                                 card.contact.personalEmail!.isNotEmpty)
                               _buildContactItem(
                                 Icons.email_outlined,
                                 card.contact.personalEmail!,
                                 Color(0xFF6C5CE7),
                                 card,
                               ),
                             if (card.contact.personalEmail != null &&
                                 card.contact.personalEmail!.isNotEmpty)
                               const SizedBox(height: 20),

                             if (card.contact.personalPhone != null &&
                                 card.contact.personalPhone!.isNotEmpty)
                               _buildContactItem(
                                 Icons.smartphone_outlined,
                                 card.contact.personalPhone!,
                                 Color(0xFF6C5CE7),
                                 card,
                               ),
                             if (card.contact.personalPhone != null &&
                                 card.contact.personalPhone!.isNotEmpty)
                               const SizedBox(height: 20),

                             // Address
                             if (card.displayAddress.isNotEmpty)
                               _buildContactItem(
                                 Icons.location_on_outlined,
                                 card.displayAddress,
                                 Color(0xFF6C5CE7),
                                 card,
                               ),
                             if (card.displayAddress.isNotEmpty)
                               const SizedBox(height: 20),

                            // Public URL
                            _buildContactItem(
                              Icons.language,
                              card.publicUrl,
                              Color(0xFF6C5CE7),
                              card,
                            ),
                            const SizedBox(height: 20),

                            // Skills section
                            if (card.tags.isNotEmpty) ...[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Skills',
                                  style: TextStyle(
                                    color:
                                        card.theme.cardStyle == 'professional'
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Skills chips
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: card.tags.map((skill) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            card.theme.cardStyle ==
                                                'professional'
                                            ? Color(0xFF2A2A2A)
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        skill,
                                        style: TextStyle(
                                          color:
                                              card.theme.cardStyle ==
                                                  'professional'
                                              ? Colors.white
                                              : Colors.black,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],

                            // Custom Links section
                            if (card.customLinks.isNotEmpty) ...[
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Connect',
                                  style: TextStyle(
                                    color:
                                        card.theme.cardStyle == 'professional'
                                        ? Colors.black
                                        : Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),

                              // Social icons
                              Row(
                                children: [
                                  ...card.customLinks.take(4).map((link) {
                                    return Padding(
                                      padding: const EdgeInsets.only(
                                        right: 12.0,
                                      ),
                                      child: Container(
                                        width: 44,
                                        height: 44,
                                        decoration: BoxDecoration(
                                          color: Color(0xFFF3F4F6),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                          border: Border.all(
                                            color: Color(0xFFE0E0E0),
                                            width: 1,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.link,
                                          color: Color(0xFF4F39F6),
                                          size: 24,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ],
                              ),
                              const SizedBox(height: 32),
                            ],

                             // Social Links (from socialLinks object)
                             if (card.socialLinks != null) ...[
                               Align(
                                 alignment: Alignment.centerLeft,
                                 child: Text(
                                   'Social Links',
                                   style: TextStyle(
                                     color:
                                         card.theme.cardStyle == 'professional'
                                         ? Colors.black
                                         : Colors.white,
                                     fontSize: 16,
                                     fontWeight: FontWeight.w600,
                                   ),
                                 ),
                               ),
                               const SizedBox(height: 12),
                               Align(
                                 alignment: Alignment.centerLeft,
                                 child: Wrap(
                                   spacing: 12,
                                   runSpacing: 12,
                                   children: card.socialLinks!.toMap().entries
                                       .where((e) => e.value != null && e.value!.isNotEmpty)
                                       .map((e) {
                                     return Container(
                                       width: 44,
                                       height: 44,
                                       decoration: BoxDecoration(
                                         color: Color(0xFFF3F4F6),
                                         borderRadius: BorderRadius.circular(8),
                                         border: Border.all(
                                           color: Color(0xFFE0E0E0),
                                           width: 1,
                                         ),
                                       ),
                                       child: IconButton(
                                         icon: Icon(
                                           e.key == 'linkedin' ? Icons.link :
                                           e.key == 'twitter' ? Icons.link :
                                           e.key == 'facebook' ? Icons.facebook :
                                           Icons.link,
                                           color: Color(0xFF4F39F6),
                                           size: 24,
                                         ),
                                         onPressed: () => launchUrl(Uri.parse(e.value!)),
                                       ),
                                     );
                                   }).toList(),
                                 ),
                               ),
                               const SizedBox(height: 32),
                             ],

                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: AppColors.progressPink,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          await saveContactToPhone(card: card);
                                        } catch (e) {
                                          CommonSnackbar.error(
                                            e.toString().contains('denied')
                                                ? 'Contacts permission is required to save to your phone'
                                                : 'Failed to save contact',
                                          );
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            25,
                                          ),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.file_download_outlined,
                                            color: AppColors.buttonBlack,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Save Contact',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 15,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  flex: 1,
                                  child: Container(
                                    height: 35,
                                    decoration: BoxDecoration(
                                      color: Color(0xFF2C2C2C),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        shareContact(card);
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.share,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            'Share',
                                            style: TextStyle(
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // Powered by
                            Text(
                              'Powered by Rolo Digi Card',
                              style: TextStyle(
                                color: card.theme.cardStyle == 'professional'
                                    ? Color(0xFFAAAAAA)
                                    : Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
    //   },
    // );
  }

  Widget _buildContactItem(
    IconData icon,
    String text,
    Color iconColor,
    CardModel card,
  ) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: card.theme.cardStyle == 'professional'
                  ? Color(0xFF555555)
                  : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  void _saveContact(BuildContext context) {
    // Implement save contact functionality
    // You can use packages like:
    // - contacts_service
    // - flutter_contacts

    // Example implementation:
    /*
    final contact = Contact()
      ..name.first = card.name
      ..emails = [Email(card.contact.email ?? '')]
      ..phones = [Phone(card.contact.phone ?? '')];

    await ContactsService.addContact(contact);
    */
  }
  /// Strips " ext. XXXX" from phone number for saving to device contacts.
  String _phoneWithoutExt(String? phone) {
    if (phone == null || phone.isEmpty) return '';
    return phone.replaceFirst(RegExp(r'\s+ext\.\s*\S+$', caseSensitive: false), '').trim();
  }

  Future<void> saveContactToPhone({required CardModel card}) async {
    // Ask permission
    final permission = await Permission.contacts.request();
    if (!permission.isGranted) {
      throw Exception('Contacts permission denied');
    }

    final phoneForContact = _phoneWithoutExt(card.contact.displayPhone);
    final contact = Contact(
      name: Name(first: card.name),
      phones:
          phoneForContact.isNotEmpty
          ? [Phone(phoneForContact)]
          : [],
      emails:
          card.contact.displayEmail != null &&
              (card.contact.displayEmail?.isNotEmpty ?? false)
          ? [Email(card.contact.displayEmail ?? '')]
          : [],
      organizations: card.company != null && card.company.isNotEmpty
          ? [Organization(company: card.company, title: card.title ?? '')]
          : [],
      // websites: card.contact. != null && card.website.isNotEmpty
      //     ? [Website(card.website)]
      //     : [],
    );

    // 🔑 This opens the SYSTEM contact editor
    await FlutterContacts.openExternalInsert(contact);
  }

  String generateVcf(CardModel card) {
    return '''
BEGIN:VCARD
VERSION:3.0
FN:${card.name}
N:${card.name};;;;
ORG:${card.company ?? ''}
TITLE:${card.title ?? ''}
TEL;TYPE=CELL:${card.contact.displayPhone ?? ''}
EMAIL:${card.contact.displayEmail ?? ''}
END:VCARD
'''
        .trim();
  }

  Future<void> shareContact(CardModel card) async {
    final vcfContent = generateVcf(card);

    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/${card.name}.vcf';

    final file = File(filePath);
    await file.writeAsString(vcfContent);

    await Share.shareXFiles([
      XFile(filePath),
    ], text: 'Contact details for ${card.name}');
  }
}

// Updated navigation call:
// Get.to(() => BusinessCardProfilePage(card: card));
