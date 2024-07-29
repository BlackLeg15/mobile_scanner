// ignore_for_file: unnecessary_breaks

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location/location.dart' hide PermissionStatus;
import 'package:permission_handler/permission_handler.dart';

class FastQrCodeStartIcon extends StatefulWidget {
  final VoidCallback goToScanPage;
  final VoidCallback goToPermissionPage;
  final VoidCallback whenFarFromAStore;

  const FastQrCodeStartIcon({
    super.key,
    required this.goToScanPage,
    required this.goToPermissionPage,
    required this.whenFarFromAStore,
  });

  @override
  State<FastQrCodeStartIcon> createState() => _FastQrCodeStartIconState();
}

class _FastQrCodeStartIconState extends State<FastQrCodeStartIcon> {
  late final AppLifecycleListener appLifecycleListener;
  var _hasOpenedSettings = false;

  @override
  void initState() {
    super.initState();
    appLifecycleListener = AppLifecycleListener(onStateChange: _onStateChange);
  }

  Future<void> _onStateChange(AppLifecycleState value) async {
    switch (value) {
      case AppLifecycleState.resumed:
        if (!_hasOpenedSettings) {
          return;
        }
        _hasOpenedSettings = false;
        final locationPermission = await Geolocator.checkPermission();
        switch (locationPermission) {
          case LocationPermission.always:
          case LocationPermission.whileInUse:
            checkCurrentLocation();
          default:
          //onPermissionDenied();
        }
      default:
    }
  }

  Future<void> checkCameraPermission() async {
    final cameraPermission = await Permission.camera.status;
    switch (cameraPermission) {
      case PermissionStatus.granted:
        return goToScanPage();
      default:
        return goToPermissionPage();
    }
  }

  Future<bool> checkLocationPermission() async {
    final LocationPermission locationPermission = await Geolocator.checkPermission();
    switch (locationPermission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return true;
      case LocationPermission.denied:
        final newStatus = await Geolocator.requestPermission();
        return switch (newStatus) {
          LocationPermission.always || LocationPermission.whileInUse => true,
          _ => false,
        };
      case LocationPermission.deniedForever:
        _hasOpenedSettings = true;
        await openAppSettings();
        return false;
      default:
        return false;
    }
  }

  Future<void> checkCurrentLocation() async {
    final isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      final hasEnabledLocationService = await Location.instance.requestService();
      if (!hasEnabledLocationService) {
        return;
      }
    }

    final hasLocationPermission = await checkLocationPermission();
    if (!hasLocationPermission) {
      return;
    }

    final currentPosition = await Geolocator.getCurrentPosition();
    final mockLatitude = currentPosition.latitude - 20;
    final mockLongitude = currentPosition.longitude - 20;
    final distanceBetween = Geolocator.distanceBetween(
      currentPosition.latitude,
      currentPosition.longitude,
      mockLatitude,
      mockLongitude,
    );

    if (distanceBetween < 200) {
      return widget.whenFarFromAStore();
    }
    return checkCameraPermission();
  }

  void goToPermissionPage() {
    widget.goToPermissionPage();
  }

  void goToScanPage() {
    widget.goToScanPage();
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: checkCurrentLocation,
      icon: const Icon(
        Icons.qr_code_scanner_sharp,
      ),
    );
  }
}
