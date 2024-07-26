class BarcodeScannerErrorEvent extends BarcodeScannerEvent {
  const BarcodeScannerErrorEvent();
}

class BarcodeScannerStartReadingBarcodesEvent extends BarcodeScannerEvent {
  const BarcodeScannerStartReadingBarcodesEvent();
}

class BarcodeScannerSendBarcodeEvent extends BarcodeScannerEvent {
  final String barcode;
  final Future<void> Function(String productId) onSuccessfulRead;

  const BarcodeScannerSendBarcodeEvent(
    this.barcode,
    this.onSuccessfulRead,
  );
}

abstract class BarcodeScannerEvent {
  const BarcodeScannerEvent();
}
