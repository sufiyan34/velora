import 'package:firebase_database/firebase_database.dart';

import '../models/product_model.dart';

class ProductRepository {
  ProductRepository({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  DatabaseReference get _productsRef => _database.ref('products');

  /// Live stream of all products.
  ///
  /// Downloads the entire `products` table on every change, so prefer
  /// [watchLatest] or [watchByCategory] wherever the screen doesn't
  /// genuinely need every product in the store.
  Stream<List<ProductModel>> watchAll() {
    return _productsRef.onValue.map(_parseSnapshotEvent);
  }

  /// Live stream of only the most recently added [limit] products.
  ///
  /// Firebase push keys are chronological by construction, so ordering by
  /// key and taking the last [limit] gives us "the newest N products"
  /// without needing a `createdAt` index or downloading the whole table.
  /// This is what the Home screen uses for its curated sections — it never
  /// needs the full catalog, just a recent window of it.
  Stream<List<ProductModel>> watchLatest({int limit = 40}) {
    return _productsRef
        .orderByKey()
        .limitToLast(limit)
        .onValue
        .map(_parseSnapshotEvent);
  }

  /// Live stream of only the products belonging to [categoryId].
  ///
  /// Filters on the server (Realtime Database) instead of pulling every
  /// product down and filtering on the device. Used by the subcategory →
  /// products screen. For best performance in production, add
  /// `"categoryId"` to `.indexOn` for the `products` node in your database
  /// rules — the query still works without it, just with a console warning.
  Stream<List<ProductModel>> watchByCategory(String categoryId) {
    return _productsRef
        .orderByChild('categoryId')
        .equalTo(categoryId)
        .onValue
        .map(_parseSnapshotEvent);
  }

  List<ProductModel> _parseSnapshotEvent(DatabaseEvent event) {
    final value = event.snapshot.value;

    if (value == null) {
      return <ProductModel>[];
    }

    final data = Map<String, dynamic>.from(value as Map);

    final products = data.entries.map((entry) {
      final productData = Map<String, dynamic>.from(entry.value as Map);

      return ProductModel.fromMap(productData, documentId: entry.key);
    }).toList();

    // Newest products first.
    products.sort((a, b) {
      final aDate = a.createdAt;
      final bDate = b.createdAt;

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;

      return bDate.compareTo(aDate);
    });

    return products;
  }

  /// Create a new product.
  Future<String> create(ProductModel product) async {
    final ref = _productsRef.push();

    final productWithId = product.copyWith(
      id: ref.key ?? product.id,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await ref.set(productWithId.toMap());

    return ref.key ?? product.id;
  }

  /// Update an existing product.
  Future<void> update(ProductModel product) async {
    final updatedProduct = product.copyWith(updatedAt: DateTime.now());

    await _productsRef.child(product.id).update(updatedProduct.toMap());
  }

  /// Delete a product.
  Future<void> delete(String id) async {
    await _productsRef.child(id).remove();
  }

  /// Get one product.
  Future<ProductModel?> getById(String id) async {
    final snapshot = await _productsRef.child(id).get();

    if (!snapshot.exists || snapshot.value == null) {
      return null;
    }

    final data = Map<String, dynamic>.from(snapshot.value as Map);

    return ProductModel.fromMap(data, documentId: id);
  }
}
