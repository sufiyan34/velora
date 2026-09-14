import 'package:firebase_database/firebase_database.dart';

import '../models/product_model.dart';

class ProductRepository {
  ProductRepository({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  DatabaseReference get _productsRef => _database.ref('products');

  /// Live stream of all products.
  Stream<List<ProductModel>> watchAll() {
    return _productsRef.onValue.map((event) {
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
    });
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
