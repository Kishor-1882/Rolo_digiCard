import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:rolo_digi_card/common/snack_bar.dart';
import 'package:rolo_digi_card/services/dio_client.dart';
import 'package:rolo_digi_card/services/end_points.dart';
import 'package:rolo_digi_card/utils/color.dart';

class OrganizationQRScannerView extends StatefulWidget {
  const OrganizationQRScannerView({super.key});

  @override
  State<OrganizationQRScannerView> createState() => _OrganizationQRScannerViewState();
}

class _OrganizationQRScannerViewState extends State<OrganizationQRScannerView> {
  final _imagePicker = ImagePicker();
  bool _isUploading = false;

  String? _extractCardId(String qrData) {
    final uri = Uri.tryParse(qrData);
    if (uri != null && uri.pathSegments.length >= 2 && uri.pathSegments[uri.pathSegments.length - 2] == 'c') {
      return uri.pathSegments.last;
    }
    return qrData;
  }

  Future<void> _onUploadImage() async {
    if (_isUploading) return;
    try {
      final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (picked == null || !mounted) return;

      setState(() => _isUploading = true);
      final path = picked.path;
      if (path.isEmpty) {
        CommonSnackbar.error('Could not read image');
        return;
      }

      final scannerController = MobileScannerController();
      try {
        final capture = await scannerController.analyzeImage(path);
        if (capture == null || capture.barcodes.isEmpty) {
          CommonSnackbar.error('No QR code found in image');
          return;
        }

        final code = capture.barcodes.first.rawValue;
        if (code == null || code.isEmpty) {
          CommonSnackbar.error('Could not read QR code');
          return;
        }

        final cardId = _extractCardId(code);
        if (cardId == null) {
          CommonSnackbar.error('Invalid QR code format');
          return;
        }

        final response = await dioClient.post(ApiEndpoints.saveCard(cardId));
        if (response.statusCode == 200 || response.statusCode == 201) {
          CommonSnackbar.success('Card saved successfully!');
          Get.offAllNamed('/sidebar');
        } else {
          CommonSnackbar.error('Failed to save card');
        }
      } finally {
        scannerController.dispose();
      }
    } catch (e) {
      CommonSnackbar.error('Failed to process image');
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'QR Scanner',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Scan cards to view details',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            const Spacer(),
            // Center Decorative QR
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer ripple
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE91E8E).withOpacity(0.05),
                    ),
                  ),
                  // Inner ripple
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFE91E8E).withOpacity(0.1),
                    ),
                  ),
                  // Main Purple Container
                  Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE91E8E), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFE91E8E).withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 80,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Action Options
            _buildActionCard(
              icon: Icons.camera_alt_outlined,
              title: 'Enable Camera',
              subtitle: 'Scan QR codes in real-time',
              onTap: () {
                Get.toNamed('/scan-card');
              },
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              icon: Icons.file_upload_outlined,
              title: 'Upload Image',
              subtitle: 'Extract QR from photo',
              onTap: _isUploading ? () {} : _onUploadImage,
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              icon: Icons.keyboard_alt_outlined,
              title: 'Manual Entry',
              subtitle: 'Enter card ID to view card',
              onTap: () {
                Get.toNamed('/manual-entry');
              },
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E8E).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: const Color(0xFFE91E8E), size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.white.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}
