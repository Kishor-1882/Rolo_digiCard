import 'package:flutter/animation.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:dio/dio.dart';
import 'package:rolo_digi_card/common/snack_bar.dart';
import 'package:rolo_digi_card/services/dio_client.dart';
import 'package:rolo_digi_card/services/end_points.dart';

class ScanController extends GetxController with GetSingleTickerProviderStateMixin {
  late MobileScannerController cameraController;
  late AnimationController scanAnimation;

  final Dio _dio = Dio();

  // Observable variables
  var isScanning = false.obs;
  var isLoading = false.obs;
  var scannedData = Rxn<String>();
  var isSuccess = false.obs;

  @override
  void onInit() {
    super.onInit();
    scanAnimation = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
    initialize();
  }

  void initialize() {
    cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  void startScanning() {
    isScanning.value = true;
    update();
  }

  void onDetect(BarcodeCapture capture) async {
    print("Detect");
    if (!isScanning.value || scannedData.value != null) return;

    final List<Barcode> barcodes = capture.barcodes;

    for (final barcode in barcodes) {
      final String? code = barcode.rawValue;

      if (code != null && code.isNotEmpty) {
        isScanning.value = false;
        scannedData.value = code;

        // Extract card ID and call API
        await _saveCard(code);
        break;
      }
    }
  }

  Future<void> _saveCard(String qrData) async {
    try {
      isLoading.value = true;

      // Extract card ID from URL
      final cardId = _extractCardId(qrData);

      if (cardId == null) {
        throw Exception('Invalid QR code format');
      }

      final response = await dioClient.post(
        ApiEndpoints.saveCard(cardId),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        isSuccess.value = true;
        CommonSnackbar.success('Card saved successfully!');
        Get.offAllNamed("/sidebar");
      } else {
        print('Error saving card in response: ${response.data}');
        throw Exception('Failed to save card');
      }
    } catch (e,t) {
      isSuccess.value = false;
      CommonSnackbar.error('Failed to save card');
      scannedData.value = null;
      print('Error saving card: ${e} $t');
    } finally {
      isLoading.value = false;
    }
  }

  String? _extractCardId(String qrData) {
    // Extract card ID from URLs like "https://digi.roloscan.com/c/08YLRtN93"
    final uri = Uri.tryParse(qrData);

    if (uri == null) return null;

    final pathSegments = uri.pathSegments;

    // Check if URL matches expected format
    if (pathSegments.length >= 2 && pathSegments[pathSegments.length - 2] == 'c') {
      return pathSegments.last;
    }

    return null;
  }

  void toggleFlash() {
    cameraController.toggleTorch();
  }

  void resetScan() {
    scannedData.value = null;
    isSuccess.value = false;
    isScanning.value = false;
  }

  @override
  void onClose() {
    cameraController.dispose();
    scanAnimation.dispose();
    super.onClose();
  }
}