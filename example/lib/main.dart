import 'package:flutter/material.dart';
import 'package:mobile_scanner_example/barcode_scanner_controller.dart';
import 'package:mobile_scanner_example/barcode_scanner_listview.dart';
import 'package:mobile_scanner_example/barcode_scanner_pageview.dart';
import 'package:mobile_scanner_example/barcode_scanner_returning_image.dart';
import 'package:mobile_scanner_example/barcode_scanner_simple.dart';
import 'package:mobile_scanner_example/barcode_scanner_zoom.dart';
import 'package:mobile_scanner_example/fast/fast_qr_code_camera_permission_page.dart';
import 'package:mobile_scanner_example/fast/fast_qr_code_start_icon.dart';
import 'package:mobile_scanner_example/mobile_scanner_overlay.dart';
import 'package:mobile_scanner_example/old/barcode_scanner_window.dart';
import 'package:mobile_scanner_example/old/fast_barcode_scanner_window.dart';

void main() {
  runApp(
    const MaterialApp(
      title: 'Mobile Scanner Example',
      home: MyHome(),
    ),
  );
}

class MyHome extends StatelessWidget {
  const MyHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mobile Scanner Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            FastQrCodeStartIcon(
              whenFarFromAStore: () {
                
              },
              goToPermissionPage: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FastQrCodeCameraPermissionPage(
                      onGrantedPermission: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => FastBarcodeScannerWithScanWindow(
                              onScan: (productId) {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => Scaffold(
                                      appBar: AppBar(
                                        title: const Text('Scan success'),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              goToScanPage: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => FastBarcodeScannerWithScanWindow(
                      onScan: (productId) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => Scaffold(
                              appBar: AppBar(
                                title: const Text('Scan success'),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BarcodeScannerSimple(),
                  ),
                );
              },
              child: const Text('MobileScanner Simple'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BarcodeScannerListView(),
                  ),
                );
              },
              child: const Text('MobileScanner with ListView'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BarcodeScannerWithController(),
                  ),
                );
              },
              child: const Text('MobileScanner with Controller'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BarcodeScannerWithScanWindow(),
                  ),
                );
              },
              child: const Text('MobileScanner with ScanWindow'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BarcodeScannerReturningImage(),
                  ),
                );
              },
              child: const Text(
                'MobileScanner with Controller (returning image)',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BarcodeScannerWithZoom(),
                  ),
                );
              },
              child: const Text('MobileScanner with zoom slider'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const BarcodeScannerPageView(),
                  ),
                );
              },
              child: const Text('MobileScanner pageView'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => BarcodeScannerWithOverlay(),
                  ),
                );
              },
              child: const Text('MobileScanner with Overlay'),
            ),
          ],
        ),
      ),
    );
  }
}
