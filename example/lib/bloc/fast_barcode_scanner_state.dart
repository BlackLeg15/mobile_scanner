class BarcodeScannerInitialState extends BarcodeScannerState {
  const BarcodeScannerInitialState();
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
