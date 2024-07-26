import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class FastQrCodeStartIcon extends StatefulWidget {
  const FastQrCodeStartIcon({super.key});

  @override
  State<FastQrCodeStartIcon> createState() => _FastQrCodeStartIconState();
}

class _FastQrCodeStartIconState extends State<FastQrCodeStartIcon> {
  Future<void> checkCameraPermission() async {
    final cameraPermission = await Permission.camera.status;
    switch (cameraPermission) {
      case PermissionStatus.granted:
        return goToScanPage();
      default:
        return goToPermissionPage();
    }
  }

  void goToPermissionPage() {}

  void goToScanPage() {}

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: checkCameraPermission,
      icon: const Icon(
        Icons.qr_code_scanner_sharp,
      ),
    );
  }
}
