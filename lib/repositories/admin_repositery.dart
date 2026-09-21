import 'package:firebase_database/firebase_database.dart';

import '../models/order_model.dart';
import '../models/user_model.dart';

/// Admin-only reads across the whole store.
///
/// [OrderRepository] is scoped to one customer (`watchUserOrders`), which is
/// correct for the shop side. The admin panel needs the full `orders` and
/// `users` nodes, so those live here and every admin screen — dashboard,
/// orders, dispatch, customers, payments, reports — reads from this one place.
///
/// Writes stay in the existing repositories: keep using
/// `OrderRepository.updateOrderStatus` / `updatePaymentStatus` and
/// `UserRepository.updateActiveStatus` / `updateRole`.
class AdminRepository {
  AdminRepository({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  DatabaseReference get _ordersRef => _database.ref('orders');
  DatabaseReference get _usersRef => _database.ref('users');

  // ============================================================
  // ORDERS
  // ============================================================

  /// Live stream of every order in the store, newest first.
  Stream<List<OrderModel>> watchAllOrders() {
    return _ordersRef.onValue.map((event) {
      final value = event.snapshot.value;

      if (value is! Map) return <OrderModel>[];

      final data = Map<String, dynamic>.from(value);
      final orders = <OrderModel>[];

      for (final entry in data.entries) {
        final raw = entry.value;
        if (raw is! Map) continue;

        orders.add(
          OrderModel.fromMap(
            Map<String, dynamic>.from(raw),
            documentId: entry.key.toString(),
          ),
        );
      }

      orders.sort((a, b) {
        final aDate = a.createdAt;
        final bDate = b.createdAt;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

      return orders;
    });
  }

  // ============================================================
  // USERS
  // ============================================================

  /// Live stream of every account. The `users/{id}/orders` mirror node is
  /// ignored here — only the profile fields are parsed.
  Stream<List<UserModel>> watchAllUsers() {
    return _usersRef.onValue.map((event) {
      final value = event.snapshot.value;

      if (value is! Map) return <UserModel>[];

      final data = Map<String, dynamic>.from(value);
      final users = <UserModel>[];

      for (final entry in data.entries) {
        final raw = entry.value;
        if (raw is! Map) continue;

        try {
          users.add(
            UserModel.fromMap(
              Map<String, dynamic>.from(raw),
              documentId: entry.key.toString(),
            ),
          );
        } catch (_) {
          // A malformed profile shouldn't take the whole dashboard down.
          continue;
        }
      }

      users.sort((a, b) {
        final aDate = a.createdAt;
        final bDate = b.createdAt;
        if (aDate == null && bDate == null) return 0;
        if (aDate == null) return 1;
        if (bDate == null) return -1;
        return bDate.compareTo(aDate);
      });

      return users;
    });
  }
}
