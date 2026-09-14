import 'package:firebase_database/firebase_database.dart';

import '../models/user_model.dart';

class UserRepository {
  UserRepository({FirebaseDatabase? database})
    : _database = database ?? FirebaseDatabase.instance;

  final FirebaseDatabase _database;

  DatabaseReference get _usersRef => _database.ref('users');

  // ==========================================================
  // CREATE USER
  // ==========================================================

  Future<UserModel> createUser(UserModel user) async {
    if (user.id.trim().isEmpty) {
      throw Exception('User ID is required.');
    }

    final now = DateTime.now();

    final newUser = user.copyWith(
      createdAt: user.createdAt ?? now,
      updatedAt: now,
    );

    await _usersRef.child(user.id).set(newUser.toMap());

    return newUser;
  }

  // ==========================================================
  // GET USER
  // ==========================================================

  Future<UserModel?> getUser(String userId) async {
    if (userId.trim().isEmpty) {
      return null;
    }

    final snapshot = await _usersRef.child(userId).get();

    if (!snapshot.exists || snapshot.value == null) {
      return null;
    }

    final value = snapshot.value;

    if (value is! Map) {
      return null;
    }

    return UserModel.fromMap(
      Map<String, dynamic>.from(value),
      documentId: userId,
    );
  }

  // ==========================================================
  // UPDATE USER
  // ==========================================================

  Future<void> updateUser(UserModel user) async {
    if (user.id.trim().isEmpty) {
      throw Exception('User ID is required.');
    }

    final updatedUser = user.copyWith(updatedAt: DateTime.now());

    await _usersRef.child(user.id).update(updatedUser.toMap());
  }

  // ==========================================================
  // UPDATE LAST LOGIN
  // ==========================================================

  Future<void> updateLastLogin(String userId) async {
    if (userId.trim().isEmpty) {
      return;
    }

    await _usersRef.child(userId).update({
      'lastLoginAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // ==========================================================
  // UPDATE EMAIL VERIFIED
  // ==========================================================

  Future<void> updateEmailVerified(String userId, bool verified) async {
    if (userId.trim().isEmpty) {
      return;
    }

    await _usersRef.child(userId).update({
      'emailVerified': verified,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // ==========================================================
  // UPDATE PROFILE
  // ==========================================================

  Future<void> updateProfile({
    required String userId,
    String? name,
    String? phone,
    String? profileImage,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('User ID is required.');
    }

    final updates = <String, dynamic>{
      'updatedAt': DateTime.now().toIso8601String(),
    };

    if (name != null) {
      updates['name'] = name;
    }

    if (phone != null) {
      updates['phone'] = phone;
    }

    if (profileImage != null) {
      updates['profileImage'] = profileImage;
    }

    await _usersRef.child(userId).update(updates);
  }

  // ==========================================================
  // UPDATE ACTIVE STATUS
  // ==========================================================

  Future<void> updateActiveStatus({
    required String userId,
    required bool isActive,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('User ID is required.');
    }

    await _usersRef.child(userId).update({
      'isActive': isActive,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // ==========================================================
  // UPDATE ROLE
  // ==========================================================

  Future<void> updateRole({
    required String userId,
    required String role,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('User ID is required.');
    }

    if (role.trim().isEmpty) {
      throw Exception('Role is required.');
    }

    await _usersRef.child(userId).update({
      'role': role,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // ==========================================================
  // ADD ADDRESS
  // ==========================================================

  Future<void> addAddress({
    required String userId,
    required UserAddress address,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('User ID is required.');
    }

    final userRef = _usersRef.child(userId);
    final addressRef = userRef.child('addresses').push();

    final addressId = addressRef.key;

    if (addressId == null || addressId.isEmpty) {
      throw Exception('Unable to generate address ID.');
    }

    final newAddress = address.copyWith(id: addressId);

    await addressRef.set(newAddress.toMap());

    await userRef.update({'updatedAt': DateTime.now().toIso8601String()});
  }

  // ==========================================================
  // UPDATE ADDRESS
  // ==========================================================

  Future<void> updateAddress({
    required String userId,
    required UserAddress address,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('User ID is required.');
    }

    if (address.id.trim().isEmpty) {
      throw Exception('Address ID is required.');
    }

    await _usersRef
        .child(userId)
        .child('addresses')
        .child(address.id)
        .update(address.toMap());

    await _usersRef.child(userId).update({
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // ==========================================================
  // DELETE ADDRESS
  // ==========================================================

  Future<void> deleteAddress({
    required String userId,
    required String addressId,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('User ID is required.');
    }

    if (addressId.trim().isEmpty) {
      throw Exception('Address ID is required.');
    }

    await _usersRef.child(userId).child('addresses').child(addressId).remove();

    await _usersRef.child(userId).update({
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // ==========================================================
  // SET DEFAULT ADDRESS
  // ==========================================================

  Future<void> setDefaultAddress({
    required String userId,
    required String addressId,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('User ID is required.');
    }

    if (addressId.trim().isEmpty) {
      throw Exception('Address ID is required.');
    }

    final addressesRef = _usersRef.child(userId).child('addresses');

    final snapshot = await addressesRef.get();

    if (!snapshot.exists || snapshot.value == null) {
      throw Exception('No addresses found.');
    }

    final value = snapshot.value;

    if (value is! Map) {
      throw Exception('Invalid address data.');
    }

    final updates = <String, dynamic>{};

    for (final entry in value.entries) {
      final currentAddressId = entry.key.toString();

      updates['$currentAddressId/isDefault'] = currentAddressId == addressId;
    }

    await addressesRef.update(updates);

    await _usersRef.child(userId).update({
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // ==========================================================
  // DELETE USER
  // ==========================================================

  Future<void> deleteUser(String userId) async {
    if (userId.trim().isEmpty) {
      throw Exception('User ID is required.');
    }

    await _usersRef.child(userId).remove();
  }

  // ==========================================================
  // WATCH USER
  // ==========================================================

  Stream<UserModel?> watchUser(String userId) {
    if (userId.trim().isEmpty) {
      return Stream.value(null);
    }

    return _usersRef.child(userId).onValue.map((event) {
      final value = event.snapshot.value;

      if (value == null || value is! Map) {
        return null;
      }

      return UserModel.fromMap(
        Map<String, dynamic>.from(value),
        documentId: userId,
      );
    });
  }
}
