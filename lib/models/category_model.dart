// This file can be deleted or kept for future use
class CategoryModel {
  final String id;
  final String name;
  final String iconPath;
  final int itemCount;

  CategoryModel({
    required this.id,
    required this.name,
    required this.iconPath,
    this.itemCount = 0,
  });

  // Keeping this for potential future use, but not actively used
  static List<CategoryModel> getDefaultCategories() {
    return [
      CategoryModel(id: 'all', name: 'All', iconPath: 'assets/icons/all.png'),
      CategoryModel(
        id: 'fruits',
        name: 'Fruits',
        iconPath: 'assets/icons/fruits.png',
      ),
      CategoryModel(
        id: 'vegetables',
        name: 'Vegetables',
        iconPath: 'assets/icons/vegetables.png',
      ),
      CategoryModel(
        id: 'dairy',
        name: 'Dairy',
        iconPath: 'assets/icons/dairy.png',
      ),
      CategoryModel(
        id: 'meat',
        name: 'Meat',
        iconPath: 'assets/icons/meat.png',
      ),
      CategoryModel(
        id: 'bakery',
        name: 'Bakery',
        iconPath: 'assets/icons/bakery.png',
      ),
      CategoryModel(
        id: 'beverages',
        name: 'Beverages',
        iconPath: 'assets/icons/beverages.png',
      ),
      CategoryModel(
        id: 'snacks',
        name: 'Snacks',
        iconPath: 'assets/icons/snacks.png',
      ),
    ];
  }
}
