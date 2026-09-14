import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  final Rxn<User> firebaseUser = Rxn<User>();

  final RxBool isLoading = false.obs;

  User? get currentFirebaseUser => _auth.currentUser;

  bool get isLoggedIn => _auth.currentUser != null;

  @override
  void onInit() {
    super.onInit();

    firebaseUser.value = _auth.currentUser;

    ever(firebaseUser, (User? user) {
      // Authentication state can be handled here later.
    });

    _auth.authStateChanges().listen((User? user) {
      firebaseUser.value = user;
    });
  }

  Future<bool> createAdmin({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      isLoading.value = true;

      final UserCredential credential = await _auth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      final User? user = credential.user;

      if (user == null) {
        throw Exception('Unable to create Firebase user.');
      }

      await user.updateDisplayName(name.trim());

      final now = DateTime.now().toIso8601String();

      final admin = UserModel(
        id: user.uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        profileImage: '',
        role: 'admin',
        isActive: true,
        emailVerified: user.emailVerified,
        addresses: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      await _database.ref('users').child(user.uid).set(admin.toMap());

      firebaseUser.value = user;

      Get.snackbar(
        'Admin Created',
        'Admin account has been created successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
        margin: const EdgeInsets.all(16),
      );

      return true;
    } on FirebaseAuthException catch (e) {
      String message = 'Something went wrong.';

      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account already exists with this email.';
          break;

        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;

        case 'weak-password':
          message = 'Password is too weak.';
          break;

        case 'operation-not-allowed':
          message = 'Email/password authentication is not enabled.';
          break;

        default:
          message = e.message ?? 'Unable to create admin account.';
      }

      Get.snackbar(
        'Admin Creation Failed',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        margin: const EdgeInsets.all(16),
      );

      return false;
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        margin: EdgeInsets.all(16),
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    firebaseUser.value = null;
  }
}
