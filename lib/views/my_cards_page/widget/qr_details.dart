import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:rolo_digi_card/common/snack_bar.dart';
import 'package:rolo_digi_card/models/card_model.dart';
import 'package:rolo_digi_card/utils/color.dart';
import 'package:rolo_digi_card/views/my_cards_page/widget/business_card_details.dart';
import 'package:share_plus/share_plus.dart';

class QRCodeSharePage extends StatelessWidget {
  final CardModel card;

   QRCodeSharePage({
    Key? key,
    required this.card,
  }) : super(key: key);
   final GlobalKey _qrKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 80),

                    // Name
                    Text(
                      'Scan to Save Contact',
                      style: TextStyle(
                        color: AppColors.qrText,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    Text(
                      'Your digital business card is ready to share!',
                      style: TextStyle(
                        color: AppColors.qrText,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // QR Code Container
                    Container(
                      width: 240,
                      height: 240,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: card.qrCodeUrl.startsWith('data:image')
                          ? Image.memory(
                        _base64ToImage(card.qrCodeUrl),
                        fit: BoxFit.contain,
                      )
                          : RepaintBoundary(
                                 key: _qrKey,

                            child: QrImageView(
                                                    data: card.publicUrl,
                                                    version: QrVersions.auto,
                                                    size: 200.0,
                                                    backgroundColor: Colors.white,
                                                  ),
                          ),
                    ),
                    const SizedBox(height: 40),

                    // Download QR Code button
                    InkWell(
                      onTap: () async {
                        // Handle download
                        await _downloadQRCode();
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: AppColors.textPrimary.withOpacity(0.10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.file_download_outlined,
                              color: AppColors.buttonQrText,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Download QR Code',
                              style: TextStyle(
                                color: AppColors.buttonQrText,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Share QR Code button
                    InkWell(
                      onTap: () async {
                        // Handle share
                        await _shareQRCode();
                      },
                      child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: AppColors.textPrimary.withOpacity(0.10),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.share_outlined,
                              color: AppColors.buttonQrText,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Share QR Code',
                              style: TextStyle(
                                color: AppColors.buttonQrText,
                                fontSize: 15,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // View Card button
                    Container(
                      width: double.infinity,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.progressPink,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Get.to(
                                  () => BusinessCardProfilePage(card: card,),
                            );
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.remove_red_eye_outlined,
                                color: AppColors.buttonBlack,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'View Card',
                                style: TextStyle(
                                  color: AppColors.buttonBlack,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Scan instruction
                    Text(
                      'Scan with your phone camera to save instantly',
                      style: TextStyle(
                        color: AppColors.qrText,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      card.title,
                      style: TextStyle(
                        color: AppColors.qrText,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Powered by
                    Text(
                      'Powered by Rolo Digi Card',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // Close button
          Positioned(
            top: 40,
            right: 20,
            child: SafeArea(
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 30,
                ),
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to decode base64 image
  Uint8List _base64ToImage(String base64String) {
    // Remove the data:image/png;base64, prefix
    final base64Data = base64String.split(',').last;
    return base64Decode(base64Data);
  }

  // Download QR Code
Future<void> _downloadQRCode() async {
  try {
    // Capture QR code as image
    final boundary = _qrKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    final image = await boundary.toImage(pixelRatio: 3.0);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();
    
    // Save to temporary file
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/qr_${DateTime.now().millisecondsSinceEpoch}.png';
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    
    // Save to gallery using gal
    await Gal.putImage(file.path);
    
    debugPrint('QR code saved to gallery');
    
    // Optional: Show success message
    // if (mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('QR code saved to gallery')),
    //   );
    // }
  } catch (e) {
    debugPrint('Save QR failed: $e');
    // if (mounted) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Failed to save: $e')),
    //   );
    // }
  }
}

  // Share QR Code
  Future<void> _shareQRCode() async {
    try {
      final bytes = _base64ToImage(card.qrCodeUrl);
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/qr_code.png');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out ${card.name}\'s digital business card',
      );
    } catch (e) {
      CommonSnackbar.error('Failed to share QR Code');
    }

  }
}

// Updated navigation call:
// Get.to(() => QRCodeSharePage(card: card));