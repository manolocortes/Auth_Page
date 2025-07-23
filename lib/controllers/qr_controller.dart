import 'package:flutter/foundation.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import '../models/grocery_item_model.dart';
import '../services/grocery_service.dart';

class QRController extends ChangeNotifier {
  final GroceryService _groceryService = GroceryService();

  QRViewController? _qrViewController;
  bool _isProcessing = false;
  String? _errorMessage;
  GroceryItemModel? _scannedItem;

  bool get isProcessing => _isProcessing;
  String? get errorMessage => _errorMessage;
  GroceryItemModel? get scannedItem => _scannedItem;
  QRViewController? get qrViewController => _qrViewController; // Added getter

  void setQRViewController(QRViewController controller) {
    _qrViewController = controller;
    _qrViewController!.scannedDataStream.listen((scanData) {
      if (!_isProcessing && scanData.code != null) {
        processQRCode(scanData.code!);
      }
    });
  }

  void _setProcessing(bool processing) {
    _isProcessing = processing;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _setScannedItem(GroceryItemModel? item) {
    _scannedItem = item;
    notifyListeners();
  }

  Future<void> processQRCode(String qrCode) async {
    if (_isProcessing) return;

    _setProcessing(true);
    _setError(null);

    try {
      final item = await _groceryService.getItemByQRCode(qrCode);

      if (item != null) {
        _qrViewController?.pauseCamera();
        _setScannedItem(item);
      } else {
        _setError('Item not found for QR code: $qrCode');
      }
    } catch (e) {
      _setError('Error processing QR code: $e');
    } finally {
      _setProcessing(false);
    }
  }

  void resumeCamera() {
    _qrViewController?.resumeCamera();
    _setScannedItem(null);
    _setError(null);
  }

  void pauseCamera() {
    _qrViewController?.pauseCamera();
  }

  void clearError() {
    _setError(null);
  }

  void clearScannedItem() {
    _setScannedItem(null);
  }

  // Added method to handle camera reassembly
  void reassembleCamera() {
    if (_qrViewController != null) {
      _qrViewController!.pauseCamera();
      _qrViewController!.resumeCamera();
    }
  }
}
