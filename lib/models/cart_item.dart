import 'grocery_item.dart';

class CartItem {
  final GroceryItem groceryItem;
  int quantity;

  CartItem({
    required this.groceryItem,
    this.quantity = 1,
  });

  double get totalPrice => groceryItem.price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'groceryItem': groceryItem.toMap(),
      'quantity': quantity,
    };
  }
}
