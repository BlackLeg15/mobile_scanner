// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class FastQrCodeCameraPermissionPage extends StatefulWidget {
  final VoidCallback onGrantedPermission;
  const FastQrCodeCameraPermissionPage({super.key, required this.onGrantedPermission});

  @override
  State<FastQrCodeCameraPermissionPage> createState() => _FastQrCodeCameraPermissionPageState();
}

class _FastQrCodeCameraPermissionPageState extends State<FastQrCodeCameraPermissionPage> {
  late final AppLifecycleListener appLifecycleListener;

  @override
  void initState() {
    super.initState();
    appLifecycleListener = AppLifecycleListener(onStateChange: _onStateChange);
  }

  Future<void> _onStateChange(AppLifecycleState value) async {
    switch (value) {
      case AppLifecycleState.resumed:
        final cameraPermission = await Permission.camera.status;
        switch (cameraPermission) {
          case PermissionStatus.granted:
            return startScanning();
          default:
            onPermissionDenied();
        }
      default:
    }
  }

  Future<void> checkCameraPermission() async {
    final cameraPermission = await Permission.camera.status;
    switch (cameraPermission) {
      case PermissionStatus.granted:
        return startScanning();
      case PermissionStatus.permanentlyDenied:
        await openAppSettings();
        return;
      case PermissionStatus.denied:
        final newStatus = await Permission.camera.request();
        return switch (newStatus) {
          PermissionStatus.granted => startScanning(),
          _ => onPermissionDenied(),
        };
      default:
    }
  }

  void onPermissionDenied() {}

  void startScanning() {
    widget.onGrantedPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leitor de preço'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Color(0xFFD7DDE3),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.qr_code_scanner_sharp),
            ),
            Text('Permitir acesso à câmera'),
            Text(
              'Ative a permissão de acesso a câmera para utilizar o leitor de etiquetas.',
              textAlign: TextAlign.center,
            ),
            ElevatedButton(
              onPressed: checkCameraPermission,
              child: Text('Permitir acesso à câmera'),
            ),
          ],
        ),
      ),
    );
  }
}
