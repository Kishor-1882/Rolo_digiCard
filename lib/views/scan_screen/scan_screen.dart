import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:rolo_digi_card/controllers/home/scan_controller.dart';

class QRScannerPage extends StatelessWidget {
  const QRScannerPage({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    final ScanController scanController = Get.put(ScanController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        return Stack(
          children: [
            // Black background
            Container(
              color: Colors.black,
            ),

            // Camera Preview in square box
            Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 400,
                    child: MobileScanner(
                      controller: scanController.cameraController,
                      onDetect: scanController.onDetect,
                    ),
                  ),
                ),
              ),
            ),

            // Top Bar
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white, size: 28),
                      onPressed: () {
                        scanController.dispose();
                        Navigator.pop(context);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.flash_on,
                          color: Colors.white, size: 28),
                      onPressed: scanController.toggleFlash,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Scan Button
            if (scanController.scannedData.value == null)
              Positioned(
                bottom: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: GestureDetector(
                    onTap: scanController.startScanning,
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF6339A), Color(0xFF9810FA)],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: scanController.isScanning.value
                            ? [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          )
                        ]
                            : null,
                      ),
                      child: Center(
                        child: scanController.isScanning.value
                            ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                            : Image.asset(
                          'assets/home_page/qr_scans.png',
                          height: 30,
                          width: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Scanning Animation Overlay
            //remove if needed
            // if (scanController.isScanning.value)
            //   Center(
            //     child: Padding(
            //       padding: EdgeInsets.all(16.0),
            //       child: Container(
            //         width: double.infinity,
            //         height: 400,
            //         decoration: BoxDecoration(
            //           borderRadius: BorderRadius.circular(20),
            //           // border: Border.all(color: Colors.purple, width: 2),
            //         ),
            //         child: Stack(
            //           children: [
            //             // Corner brackets
            //             ...List.generate(4, (index) {
            //               return Positioned(
            //                 top: index < 2 ? 0 : null,
            //                 bottom: index >= 2 ? 0 : null,
            //                 left: index % 2 == 0 ? 0 : null,
            //                 right: index % 2 == 1 ? 0 : null,
            //                 child: Container(
            //                   width: 40,
            //                   height: 40,
            //                   decoration: BoxDecoration(
            //                     border: Border(
            //                       top: index < 2 ? BorderSide(color: Colors.purple, width: 4) : BorderSide.none,
            //                       bottom: index >= 2 ? BorderSide(color: Colors.purple, width: 4) : BorderSide.none,
            //                       left: index % 2 == 0 ? BorderSide(color: Colors.purple, width: 4) : BorderSide.none,
            //                       right: index % 2 == 1 ? BorderSide(color: Colors.purple, width: 4) : BorderSide.none,
            //                     ),
            //                     borderRadius: BorderRadius.only(
            //                       topLeft: index == 0 ? Radius.circular(20) : Radius.zero,
            //                       topRight: index == 1 ? Radius.circular(20) : Radius.zero,
            //                       bottomLeft: index == 2 ? Radius.circular(20) : Radius.zero,
            //                       bottomRight: index == 3 ? Radius.circular(20) : Radius.zero,
            //                     ),
            //                   ),
            //                 ),
            //               );
            //             }),
            //
            //             // Animated scanning line
            //             // Animated scanning line
            //             AnimatedBuilder(
            //               animation: scanController.scanAnimation,
            //               builder: (context, child) {
            //                 return Positioned(
            //                   top: scanController.scanAnimation.value * 360,
            //                   left: 20,
            //                   right: 20,
            //                   child: Container(
            //                     height: 2,
            //                     decoration: BoxDecoration(
            //                       gradient: LinearGradient(
            //                         colors: [
            //                           Colors.transparent,
            //                           Colors.purple,
            //                           Colors.transparent,
            //                         ],
            //                       ),
            //                       boxShadow: [
            //                         BoxShadow(
            //                           color: Colors.purple.withOpacity(0.5),
            //                           blurRadius: 10,
            //                           spreadRadius: 2,
            //                         ),
            //                       ],
            //                     ),
            //                   ),
            //                 );
            //               },
            //             ),
            //
            //           ],
            //         ),
            //       ),
            //     ),
            //   ),

            // Purple Border with Corner Brackets (Always visible)
            Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Container(
                  width: double.infinity,
                  height: 400,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      // Corner brackets
                      ...List.generate(4, (index) {
                        return Positioned(
                          top: index < 2 ? 0 : null,
                          bottom: index >= 2 ? 0 : null,
                          left: index % 2 == 0 ? 0 : null,
                          right: index % 2 == 1 ? 0 : null,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border(
                                top: index < 2 ? BorderSide(color: Colors.purple, width: 4) : BorderSide.none,
                                bottom: index >= 2 ? BorderSide(color: Colors.purple, width: 4) : BorderSide.none,
                                left: index % 2 == 0 ? BorderSide(color: Colors.purple, width: 4) : BorderSide.none,
                                right: index % 2 == 1 ? BorderSide(color: Colors.purple, width: 4) : BorderSide.none,
                              ),
                              borderRadius: BorderRadius.only(
                                topLeft: index == 0 ? Radius.circular(20) : Radius.zero,
                                topRight: index == 1 ? Radius.circular(20) : Radius.zero,
                                bottomLeft: index == 2 ? Radius.circular(20) : Radius.zero,
                                bottomRight: index == 3 ? Radius.circular(20) : Radius.zero,
                              ),
                            ),
                          ),
                        );
                      }),

                      // Animated scanning line (only when scanning)
                      if (scanController.isScanning.value)
                        AnimatedBuilder(
                          animation: scanController.scanAnimation,
                          builder: (context, child) {
                            return Positioned(
                              top: scanController.scanAnimation.value * 360,
                              left: 20,
                              right: 20,
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.purple,
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.purple.withOpacity(0.5),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),

            // Result Card
            // if (scanController.scannedData.value != null)
            //   _buildResultCard(scanController),

            // Loading Indicator
            if (scanController.isLoading.value)
              Container(
                color: Colors.black.withOpacity(0.7),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.purple,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildResultCard(ScanController scanController) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2D2D),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              scanController.isSuccess.value
                  ? Icons.check_circle
                  : Icons.error,
              color: scanController.isSuccess.value
                  ? Colors.purple
                  : Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              scanController.isSuccess.value
                  ? 'Card Saved Successfully!'
                  : 'Failed to Save Card',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                scanController.scannedData.value ?? '',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: scanController.resetScan,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                'Scan Again',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}