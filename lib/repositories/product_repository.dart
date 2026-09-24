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

  /// Set a product's stock to an exact value — used by the Inventory screen
  /// for manual counts/restocks.
  Future<void> setStock({required String id, required int stock}) async {
    await _productsRef.child(id).update({
      'stock': stock < 0 ? 0 : stock,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Nudge a product's stock up or down by [delta] using a transaction, so
  /// two admins adjusting the same product at once don't clobber each
  /// other's change. Returns the resulting stock level.
  Future<int> adjustStock({required String id, required int delta}) async {
    final stockRef = _productsRef.child(id).child('stock');

    final result = await stockRef.runTransaction((currentData) {
      final current = currentData is num ? currentData.toInt() : 0;
      final next = current + delta;
      return Transaction.success(next < 0 ? 0 : next);
    });

    await _productsRef
        .child(id)
        .child('updatedAt')
        .set(DateTime.now().toIso8601String());

    final value = result.snapshot.value;
    return value is num ? value.toInt() : 0;
  }

  /// Put a product on sale (or change its sale price) — a "deal" in this
  /// app is just a product with [ProductModel.isOnSale] set and a
  /// [ProductModel.salePrice] below its regular price.
  Future<void> setDeal({required String id, required double salePrice}) async {
    await _productsRef.child(id).update({
      'salePrice': salePrice,
      'isOnSale': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  /// Take a product off sale. Passing `null` in an RTDB `.update()` removes
  /// that key entirely, so this clears `salePrice` rather than zeroing it.
  Future<void> clearDeal({required String id}) async {
    await _productsRef.child(id).update({
      'salePrice': null,
      'isOnSale': false,
      'updatedAt': DateTime.now().toIso8601String(),
    });
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
