// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_breaks

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mobile_scanner_example/bloc/fast_barcode_scanner_bloc.dart';
import 'package:mobile_scanner_example/bloc/fast_barcode_scanner_event.dart';
import 'package:mobile_scanner_example/bloc/fast_barcode_scanner_state.dart';
import 'package:mobile_scanner_example/fast_scanner_button_widgets.dart';
import 'package:mobile_scanner_example/old/scanner_error_widget.dart';
import 'package:permission_handler/permission_handler.dart';

class FastBarcodeScannerWithScanWindow extends StatefulWidget {
  final void Function(String productId) onScan;
  const FastBarcodeScannerWithScanWindow({super.key, required this.onScan});

  @override
  State<FastBarcodeScannerWithScanWindow> createState() => _FastBarcodeScannerWithScanWindowState();
}

class _FastBarcodeScannerWithScanWindowState extends State<FastBarcodeScannerWithScanWindow> {
  late final MobileScannerController controller;
  late final FastBarcodeScannerBloc bloc;
  bool isReading = false;
  late final AppLifecycleListener appLifecycleListener;

  Future<void> _onStateChange(AppLifecycleState value) async {
    switch (value) {
      case AppLifecycleState.resumed:
        final status = await Permission.camera.status;
        if (status != PermissionStatus.granted) {
          onPermissionDenied();
        }
        break;
      default:
    }
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    appLifecycleListener = AppLifecycleListener(onStateChange: _onStateChange);
    bloc = FastBarcodeScannerBloc();
    controller = MobileScannerController(autoStart: false)
      ..barcodes.listen((barcodeCapture) async {
        if (isReading) {
          return;
        }
        isReading = true;
        await controller.stop();
        final barcodes = barcodeCapture.barcodes;
        if (barcodes.length != 1) {
          return;
        }
        final barcode = barcodes.first.displayValue;
        if (barcode == null) {
          return;
        }
        bloc.add(BarcodeScannerSendBarcodeEvent(barcode, (barcode) async => widget.onScan(barcode)));
      });
    checkCameraPermission();
  }

  Future<void> checkCameraPermission() async {
    final status = await Permission.camera.status;
    return switch (status) {
      PermissionStatus.granted => startScanning(),
      _ => onPermissionDenied(),
    };
  }

  void startScanning() {
    bloc.add(const BarcodeScannerStartReadingBarcodesEvent());
    controller.start();
  }

  void onPermissionDenied() {
    //exit screen
  }

  Widget _buildScanWindow(Rect scanWindowRect) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, value, child) {
        // Not ready.
        if (!value.isInitialized || !value.isRunning || value.error != null || value.size.isEmpty) {
          return const SizedBox();
        }

        return CustomPaint(
          painter: ScannerOverlay(scanWindowRect),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final rectWidth = size.width * 0.65;
    //final rectHeight = size.height * 0.35;
    final scanWindow = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: rectWidth,
      height: rectWidth,
    );
    final horizontalMargin = size.width * 0.18;
    final topMargin = size.height * 0.1625;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            fit: BoxFit.contain,
            scanWindow: scanWindow,
            controller: controller,
            errorBuilder: (context, error, child) {
              return ScannerErrorWidget(error: error);
            },
          ),
          _buildScanWindow(scanWindow),
          Positioned.fill(
            top: topMargin,
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: horizontalMargin,
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.qr_code_scanner_sharp,
                    color: Colors.white,
                    size: 27,
                  ),
                  SizedBox(height: size.height * 0.0125),
                  Text(
                    'Escanear QR code',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: size.height * 0.0250),
                  Text(
                    'Posicione a câmera em direção ao código e encaixe no quadrado abaixo:',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            top: 18,
            left: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  iconSize: 14,
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                  ),
                ),
              ],
            ),
          ),
          Positioned.fill(
            bottom: size.height * 0.10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FastToggleFlashlightButton(controller: controller),
              ],
            ),
          ),
          Align(
            child: BlocBuilder<FastBarcodeScannerBloc, BarcodeScannerState>(
              bloc: bloc,
              builder: (context, state) {
                return switch (state) {
                  BarcodeScannerErrorState() => Text('Não foi possível iniciar a leitura de QR Code. \nTente novamente mais tarde.'),
                  BarcodeScannerInitializingState() => const CircularProgressIndicator(),
                  BarcodeScannerReadingBarcodesState() => const SizedBox.shrink(),
                  BarcodeScannerSuccessfulReadState() => Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF1A7A1C),
                        size: 39,
                      ),
                    ),
                  BarcodeScannerRedirectingUserState() => Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: CircularProgressIndicator(
                        color: Colors.black,
                      ),
                    ),
                };
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Future<void> dispose() async {
    super.dispose();
    appLifecycleListener.dispose();
    await controller.dispose();
  }
}

class ScannerOverlay extends CustomPainter {
  const ScannerOverlay(this.scanWindow);

  final Rect scanWindow;

  @override
  void paint(Canvas canvas, Size size) {
    drawFocus(canvas);
    drawBorder(canvas);
  }

  void drawFocus(Canvas canvas) {
    final backgroundPath = Path()..addRect(Rect.largest);
    final cutoutPath = Path()..addRect(scanWindow);

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    canvas.drawPath(backgroundWithCutout, backgroundPaint);
  }

  void drawBorder(Canvas canvas) {
    final cornerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;

    const cornerSize = 22.0;

    canvas.drawLine(
      Offset(scanWindow.left - 1, scanWindow.top),
      Offset(scanWindow.left + cornerSize, scanWindow.top),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(scanWindow.left, scanWindow.top - 1),
      Offset(scanWindow.left, scanWindow.top + cornerSize),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(scanWindow.right + 1, scanWindow.top),
      Offset(scanWindow.right - cornerSize, scanWindow.top),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(scanWindow.right, scanWindow.top - 1),
      Offset(scanWindow.right, scanWindow.top + cornerSize),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(scanWindow.left - 1, scanWindow.bottom),
      Offset(scanWindow.left + cornerSize, scanWindow.bottom),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(scanWindow.left, scanWindow.bottom + 1),
      Offset(scanWindow.left, scanWindow.bottom - cornerSize),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(scanWindow.right + 1, scanWindow.bottom),
      Offset(scanWindow.right - cornerSize, scanWindow.bottom),
      cornerPaint,
    );

    canvas.drawLine(
      Offset(scanWindow.right, scanWindow.bottom + 1),
      Offset(scanWindow.right, scanWindow.bottom - cornerSize),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class BarcodeOverlay extends CustomPainter {
  BarcodeOverlay({
    required this.barcodeCorners,
    required this.barcodeSize,
    required this.boxFit,
    required this.cameraPreviewSize,
  });

  final List<Offset> barcodeCorners;
  final Size barcodeSize;
  final BoxFit boxFit;
  final Size cameraPreviewSize;

  @override
  void paint(Canvas canvas, Size size) {
    if (barcodeCorners.isEmpty || barcodeSize.isEmpty || cameraPreviewSize.isEmpty) {
      return;
    }

    final adjustedSize = applyBoxFit(boxFit, cameraPreviewSize, size);

    double verticalPadding = size.height - adjustedSize.destination.height;
    double horizontalPadding = size.width - adjustedSize.destination.width;
    if (verticalPadding > 0) {
      verticalPadding = verticalPadding / 2;
    } else {
      verticalPadding = 0;
    }

    if (horizontalPadding > 0) {
      horizontalPadding = horizontalPadding / 2;
    } else {
      horizontalPadding = 0;
    }

    final double ratioWidth;
    final double ratioHeight;

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      ratioWidth = barcodeSize.width / adjustedSize.destination.width;
      ratioHeight = barcodeSize.height / adjustedSize.destination.height;
    } else {
      ratioWidth = cameraPreviewSize.width / adjustedSize.destination.width;
      ratioHeight = cameraPreviewSize.height / adjustedSize.destination.height;
    }

    final List<Offset> adjustedOffset = [
      for (final offset in barcodeCorners)
        Offset(
          offset.dx / ratioWidth + horizontalPadding,
          offset.dy / ratioHeight + verticalPadding,
        ),
    ];

    final cutoutPath = Path()..addPolygon(adjustedOffset, true);

    final backgroundPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    canvas.drawPath(cutoutPath, backgroundPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
