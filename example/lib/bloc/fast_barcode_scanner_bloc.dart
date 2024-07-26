import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner_example/bloc/fast_barcode_scanner_event.dart';
import 'package:mobile_scanner_example/bloc/fast_barcode_scanner_state.dart';

class FastBarcodeScannerBloc extends Bloc<BarcodeScannerEvent, BarcodeScannerState> {
  FastBarcodeScannerBloc() : super(const BarcodeScannerInitializingState()) {
    on<BarcodeScannerErrorEvent>((event, emit) async {
      emit(const BarcodeScannerErrorState());
    });
    on<BarcodeScannerStartReadingBarcodesEvent>((event, emit) async {
      emit(const BarcodeScannerReadingBarcodesState());
    });
    on<BarcodeScannerSendBarcodeEvent>((event, emit) async {
      final barcode = event.barcode;
      emit(const BarcodeScannerSuccessfulReadState());
      await Future.delayed(const Duration(seconds: 1));
      emit(const BarcodeScannerRedirectingUserState());
      await event.onSuccessfulRead(barcode);
    });
  }
}
