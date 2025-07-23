import 'grocery_item_model.dart';

class CartItemModel {
  final GroceryItemModel groceryItem;
  int quantity;

  CartItemModel({required this.groceryItem, this.quantity = 1});

  double get totalPrice => groceryItem.price * quantity;

  Map<String, dynamic> toMap() {
    return {'groceryItem': groceryItem.toMap(), 'quantity': quantity};
  }

  CartItemModel copyWith({GroceryItemModel? groceryItem, int? quantity}) {
    return CartItemModel(
      groceryItem: groceryItem ?? this.groceryItem,
      quantity: quantity ?? this.quantity,
    );
  }
}
