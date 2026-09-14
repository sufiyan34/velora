import 'package:firebase_database/firebase_database.dart';

import '../models/category_model.dart';

class CategoryRepository {
  CategoryRepository({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  DatabaseReference get _categoriesRef => _database.ref('categories');

  /// Live stream of all categories.
  ///
  /// Top-level categories and subcategories are stored together.
  /// The `parentCategoryId` field determines the hierarchy.
  Stream<List<CategoryModel>> watchAll() {
    return _categoriesRef.onValue.map((event) {
      final value = event.snapshot.value;

      if (value == null) {
        return <CategoryModel>[];
      }

      final data = Map<String, dynamic>.from(value as Map);

      final categories = data.entries.map((entry) {
        final categoryData = Map<String, dynamic>.from(entry.value as Map);

        return CategoryModel.fromMap(categoryData, documentId: entry.key);
      }).toList();

      categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      return categories;
    });
  }

  /// Create a new category.
  Future<String> create(CategoryModel category) async {
    final ref = _categoriesRef.push();

    final categoryWithId = category.copyWith(
      id: ref.key ?? category.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.set(categoryWithId.toMap());

    return ref.key ?? category.id;
  }

  /// Update an existing category.
  Future<void> update(CategoryModel category) async {
    final updatedCategory = category.copyWith(updatedAt: DateTime.now());

    await _categoriesRef.child(category.id).update(updatedCategory.toMap());
  }

  /// Delete a category.
  Future<void> delete(String id) async {
    await _categoriesRef.child(id).remove();
  }

  /// Get one category.
  Future<CategoryModel?> getById(String id) async {
    final snapshot = await _categoriesRef.child(id).get();

    if (!snapshot.exists || snapshot.value == null) {
      return null;
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    return CategoryModel.fromMap(data, documentId: id);
  }
}
