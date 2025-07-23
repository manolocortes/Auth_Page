class GroceryItemModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final String qrCode;
  final bool inStock;
  final String unit;

  GroceryItemModel({
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

  factory GroceryItemModel.fromFirestore(Map<String, dynamic> data, String id) {
    return GroceryItemModel(
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

  GroceryItemModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? category,
    String? qrCode,
    bool? inStock,
    String? unit,
  }) {
    return GroceryItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      qrCode: qrCode ?? this.qrCode,
      inStock: inStock ?? this.inStock,
      unit: unit ?? this.unit,
    );
  }
}
