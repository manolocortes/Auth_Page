import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDataImporter {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final List<Map<String, dynamic>> sampleGroceryItems = [
    {
      'name': 'Fresh Red Apples',
      'description': 'Crispy and sweet red apples, perfect for snacking',
      'price': 3.99,
      'imageUrl': 'https://images.unsplash.com/photo-1560806887-1e4cd0b6cbd6?w=400',
      'category': 'Fruits',
      'qrCode': 'APPLE001',
      'inStock': true,
      'unit': 'kg',
    },
    {
      'name': 'Organic Bananas',
      'description': 'Fresh organic bananas, rich in potassium',
      'price': 2.49,
      'imageUrl': 'https://images.unsplash.com/photo-1571771894821-ce9b6c11b08e?w=400',
      'category': 'Fruits',
      'qrCode': 'BANANA001',
      'inStock': true,
      'unit': 'kg',
    },
    {
      'name': 'Fresh Spinach',
      'description': 'Organic baby spinach leaves, perfect for salads',
      'price': 2.99,
      'imageUrl': 'https://images.unsplash.com/photo-1576045057995-568f588f82fb?w=400',
      'category': 'Vegetables',
      'qrCode': 'SPINACH001',
      'inStock': true,
      'unit': 'bunch',
    },
    {
      'name': 'Roma Tomatoes',
      'description': 'Fresh roma tomatoes, great for cooking',
      'price': 4.99,
      'imageUrl': 'https://images.unsplash.com/photo-1546470427-e26264be0b0d?w=400',
      'category': 'Vegetables',
      'qrCode': 'TOMATO001',
      'inStock': true,
      'unit': 'kg',
    },
    {
      'name': 'Whole Milk',
      'description': 'Fresh whole milk, 1 liter carton',
      'price': 3.49,
      'imageUrl': 'https://images.unsplash.com/photo-1550583724-b2692b85b150?w=400',
      'category': 'Dairy',
      'qrCode': 'MILK001',
      'inStock': true,
      'unit': 'liter',
    },
    {
      'name': 'Greek Yogurt',
      'description': 'Creamy Greek yogurt, high in protein',
      'price': 5.99,
      'imageUrl': 'https://images.unsplash.com/photo-1488477181946-6428a0291777?w=400',
      'category': 'Dairy',
      'qrCode': 'YOGURT001',
      'inStock': true,
      'unit': 'container',
    },
    {
      'name': 'Chicken Breast',
      'description': 'Fresh boneless chicken breast',
      'price': 12.99,
      'imageUrl': 'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=400',
      'category': 'Meat',
      'qrCode': 'CHICKEN001',
      'inStock': true,
      'unit': 'kg',
    },
    {
      'name': 'Ground Beef',
      'description': 'Lean ground beef, 80/20 mix',
      'price': 8.99,
      'imageUrl': 'https://images.unsplash.com/photo-1588347818111-c4b8e6b6e2b1?w=400',
      'category': 'Meat',
      'qrCode': 'BEEF001',
      'inStock': true,
      'unit': 'kg',
    },
    {
      'name': 'Whole Wheat Bread',
      'description': 'Fresh baked whole wheat bread loaf',
      'price': 2.99,
      'imageUrl': 'https://images.unsplash.com/photo-1509440159596-0249088772ff?w=400',
      'category': 'Bakery',
      'qrCode': 'BREAD001',
      'inStock': true,
      'unit': 'loaf',
    },
    {
      'name': 'Croissants',
      'description': 'Buttery French croissants, pack of 6',
      'price': 4.49,
      'imageUrl': 'https://images.unsplash.com/photo-1555507036-ab794f4ade2a?w=400',
      'category': 'Bakery',
      'qrCode': 'CROISSANT001',
      'inStock': true,
      'unit': 'pack',
    },
    {
      'name': 'Orange Juice',
      'description': 'Fresh squeezed orange juice, 1 liter',
      'price': 4.99,
      'imageUrl': 'https://images.unsplash.com/photo-1621506289937-a8e4df240d0b?w=400',
      'category': 'Beverages',
      'qrCode': 'ORANGE001',
      'inStock': true,
      'unit': 'liter',
    },
    {
      'name': 'Sparkling Water',
      'description': 'Natural sparkling water, 500ml bottles pack of 6',
      'price': 3.99,
      'imageUrl': 'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400',
      'category': 'Beverages',
      'qrCode': 'WATER001',
      'inStock': true,
      'unit': 'pack',
    },
    {
      'name': 'Mixed Nuts',
      'description': 'Premium mixed nuts, roasted and salted',
      'price': 7.99,
      'imageUrl': 'https://images.unsplash.com/photo-1599599810769-bcde5a160d32?w=400',
      'category': 'Snacks',
      'qrCode': 'NUTS001',
      'inStock': true,
      'unit': 'bag',
    },
    {
      'name': 'Potato Chips',
      'description': 'Crispy potato chips, original flavor',
      'price': 2.49,
      'imageUrl': 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?w=400',
      'category': 'Snacks',
      'qrCode': 'CHIPS001',
      'inStock': true,
      'unit': 'bag',
    },
    {
      'name': 'Cheddar Cheese',
      'description': 'Aged cheddar cheese block',
      'price': 6.99,
      'imageUrl': 'https://images.unsplash.com/photo-1486297678162-eb2a19b0a32d?w=400',
      'category': 'Dairy',
      'qrCode': 'CHEESE001',
      'inStock': true,
      'unit': 'block',
    },
  ];

  static Future<void> importSampleData() async {
    try {
      print('📦 Starting batch import...');
      
      final batch = _firestore.batch();
      
      for (int i = 0; i < sampleGroceryItems.length; i++) {
        final item = sampleGroceryItems[i];
        final docRef = _firestore.collection('grocery_items').doc();
        batch.set(docRef, item);
        print('📝 Added: ${item['name']} (${i + 1}/${sampleGroceryItems.length})');
      }
      
      await batch.commit();
      print('✅ Successfully imported ${sampleGroceryItems.length} items!');
      
    } catch (e) {
      print('❌ Error importing data: $e');
      rethrow;
    }
  }

  static Future<void> clearAllData() async {
    try {
      print('🗑️ Clearing existing data...');
      
      final snapshot = await _firestore.collection('grocery_items').get();
      final batch = _firestore.batch();
      
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
      print('✅ All data cleared!');
      
    } catch (e) {
      print('❌ Error clearing data: $e');
      rethrow;
    }
  }
}
