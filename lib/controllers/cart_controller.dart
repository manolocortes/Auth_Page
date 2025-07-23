import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/grocery_item_model.dart';

class CartController extends ChangeNotifier {
  final List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  double get totalAmount =>
      _items.fold(0, (sum, item) => sum + item.totalPrice);
  bool get isEmpty => _items.isEmpty;

  void addItem(GroceryItemModel groceryItem, int quantity) {
    final existingIndex = _items.indexWhere(
      (item) => item.groceryItem.id == groceryItem.id,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItemModel(groceryItem: groceryItem, quantity: quantity));
    }
    notifyListeners();
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.groceryItem.id == itemId);
    notifyListeners();
  }

  void updateQuantity(String itemId, int newQuantity) {
    final index = _items.indexWhere((item) => item.groceryItem.id == itemId);
    if (index >= 0) {
      if (newQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQuantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  CartItemModel? getItem(String itemId) {
    try {
      return _items.firstWhere((item) => item.groceryItem.id == itemId);
    } catch (e) {
      return null;
    }
  }

  bool hasItem(String itemId) {
    return _items.any((item) => item.groceryItem.id == itemId);
  }
}
