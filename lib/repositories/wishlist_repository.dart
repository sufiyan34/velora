import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

class WishlistRepository {
  WishlistRepository({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  DatabaseReference _wishlistRef(String userId) {
    return _database.ref('users/$userId/wishlist');
  }

  /// Listen to the user's wishlist in realtime.
  ///
  /// Firebase structure:
  ///
  /// users
  ///   └── userId
  ///       └── wishlist
  ///           ├── productId1: true
  ///           ├── productId2: true
  ///           └── productId3: true
  Stream<List<String>> watchWishlist(String userId) {
    if (userId.isEmpty) {
      return Stream.value(<String>[]);
    }

    return _wishlistRef(userId).onValue.map((event) {
      final value = event.snapshot.value;

      if (value == null) {
        return <String>[];
      }

      if (value is! Map) {
        return <String>[];
      }

      return value.keys
          .map((key) => key.toString())
          .where((id) => id.isNotEmpty)
          .toList();
    });
  }

  /// Add a product to wishlist.
  Future<void> add(String userId, String productId) async {
    if (userId.isEmpty) {
      throw Exception('User is not logged in.');
    }

    if (productId.isEmpty) {
      throw Exception('Product ID is required.');
    }

    await _wishlistRef(userId).child(productId).set(true);
  }

  /// Remove a product from wishlist.
  Future<void> remove(String userId, String productId) async {
    if (userId.isEmpty || productId.isEmpty) {
      return;
    }

    await _wishlistRef(userId).child(productId).remove();
  }

  /// Remove all wishlist items.
  Future<void> clear(String userId) async {
    if (userId.isEmpty) {
      return;
    }

    await _wishlistRef(userId).remove();
  }

  /// Check whether a product is in the wishlist.
  Future<bool> contains(String userId, String productId) async {
    if (userId.isEmpty || productId.isEmpty) {
      return false;
    }

    final snapshot = await _wishlistRef(userId).child(productId).get();

    return snapshot.exists;
  }
}
