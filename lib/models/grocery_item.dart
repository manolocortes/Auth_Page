class GroceryItem {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String qrCode;
  final bool inStock;
  final String unit; // kg, pieces, liters, etc.

  GroceryItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.qrCode,
    required this.inStock,
    required this.unit,
  });

  factory GroceryItem.fromFirestore(Map<String, dynamic> data, String id) {
    return GroceryItem(
      id: id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      category: data['category'] ?? '',
      qrCode: data['qrCode'] ?? '',
      inStock: data['inStock'] ?? true,
      unit: data['unit'] ?? 'pieces',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'qrCode': qrCode,
      'inStock': inStock,
      'unit': unit,
    };
  }
}
