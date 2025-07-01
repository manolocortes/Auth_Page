import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/grocery_item.dart';

class GroceryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'grocery_items';

  Stream<List<GroceryItem>> getGroceryItems() {
    return _firestore
        .collection(_collection)
        .where('inStock', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GroceryItem.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Stream<List<GroceryItem>> getGroceryItemsByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .where('inStock', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GroceryItem.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  Future<GroceryItem?> getItemByQRCode(String qrCode) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('qrCode', isEqualTo: qrCode)
          .where('inStock', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return GroceryItem.fromFirestore(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      print('Error fetching item by QR code: $e');
      return null;
    }
  }

  Future<List<String>> getCategories() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();
      final categories = querySnapshot.docs
          .map((doc) => doc.data()['category'] as String)
          .toSet()
          .toList();
      return categories;
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }
}
