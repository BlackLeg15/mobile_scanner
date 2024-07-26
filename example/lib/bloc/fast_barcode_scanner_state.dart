class BarcodeScannerInitializingState extends BarcodeScannerState {
  const BarcodeScannerInitializingState();
}

class BarcodeScannerErrorState extends BarcodeScannerState {
  const BarcodeScannerErrorState();
}
class BarcodeScannerReadingBarcodesState extends BarcodeScannerState {
  const BarcodeScannerReadingBarcodesState();
}

class BarcodeScannerSuccessfulReadState extends BarcodeScannerState {
  const BarcodeScannerSuccessfulReadState();
}

class BarcodeScannerRedirectingUserState extends BarcodeScannerState {
  const BarcodeScannerRedirectingUserState();
}

sealed class BarcodeScannerState {
  const BarcodeScannerState();
}
