import 'package:firebase_database/firebase_database.dart';

import '../models/cart_model.dart';

class CartRepository {
  CartRepository({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  DatabaseReference _cartRef(String userId) {
    return _database.ref('users/$userId/cart');
  }

  /// Listen to the user's cart in realtime.
  Stream<List<CartModel>> watchCart(String userId) {
    if (userId.isEmpty) {
      return Stream.value(<CartModel>[]);
    }

    return _cartRef(userId).onValue.map((event) {
      final value = event.snapshot.value;

      if (value == null) {
        return <CartModel>[];
      }

      if (value is! Map) {
        return <CartModel>[];
      }

      final items = <CartModel>[];

      for (final entry in value.entries) {
        final cartId = entry.key.toString();
        final rawItem = entry.value;

        if (rawItem is Map) {
          final map = Map<String, dynamic>.from(rawItem);

          items.add(CartModel.fromMap(map, documentId: cartId));
        }
      }

      return items;
    });
  }

  /// Add a new cart item.
  Future<CartModel> addItem(String userId, CartModel item) async {
    if (userId.isEmpty) {
      throw Exception('User is not logged in.');
    }

    final cartRef = _cartRef(userId);

    final itemId = item.id.isNotEmpty ? item.id : cartRef.push().key;

    if (itemId == null || itemId.isEmpty) {
      throw Exception('Unable to generate cart item ID.');
    }

    final newItem = item.copyWith(id: itemId);

    await cartRef.child(itemId).set(newItem.toMap());

    return newItem;
  }

  /// Update an existing cart item.
  Future<void> updateItem(String userId, CartModel item) async {
    if (userId.isEmpty) {
      throw Exception('User is not logged in.');
    }

    if (item.id.isEmpty) {
      throw Exception('Cart item ID is required.');
    }

    await _cartRef(userId).child(item.id).update(item.toMap());
  }

  /// Remove one cart item.
  Future<void> removeItem(String userId, String cartItemId) async {
    if (userId.isEmpty) {
      throw Exception('User is not logged in.');
    }

    if (cartItemId.isEmpty) {
      return;
    }

    await _cartRef(userId).child(cartItemId).remove();
  }

  /// Remove the entire cart.
  Future<void> clearCart(String userId) async {
    if (userId.isEmpty) {
      return;
    }

    await _cartRef(userId).remove();
  }

  /// Get one cart item.
  Future<CartModel?> getItem(String userId, String cartItemId) async {
    if (userId.isEmpty || cartItemId.isEmpty) {
      return null;
    }

    final snapshot = await _cartRef(userId).child(cartItemId).get();

    if (!snapshot.exists || snapshot.value is! Map) {
      return null;
    }

    final map = Map<String, dynamic>.from(snapshot.value as Map);

    return CartModel.fromMap(map, documentId: cartItemId);
  }
}
