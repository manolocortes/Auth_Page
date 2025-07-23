import 'package:flutter/foundation.dart';
import '../models/grocery_item_model.dart';
import '../services/grocery_service.dart';

class GroceryController extends ChangeNotifier {
  final GroceryService _groceryService = GroceryService();

  List<GroceryItemModel> _items = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<GroceryItemModel> get items => _items;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  GroceryController() {
    _initializeData();
  }

  void _initializeData() {
    _loadItems();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _loadItems() {
    _setLoading(true);
    _setError(null);

    _groceryService.getGroceryItems().listen(
      (items) {
        _items = items;
        _setLoading(false);
      },
      onError: (error) {
        _setError('Error loading items: $error');
        _setLoading(false);
      },
    );
  }

  Future<GroceryItemModel?> getItemByQRCode(String qrCode) async {
    try {
      return await _groceryService.getItemByQRCode(qrCode);
    } catch (e) {
      _setError('Error processing QR code: $e');
      return null;
    }
  }

  void clearError() {
    _setError(null);
  }

  void refresh() {
    _loadItems();
  }
}
