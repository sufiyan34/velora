// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// import '../models/user_model.dart';

// class AuthController extends GetxController {
//   static AuthController get to => Get.find<AuthController>();

//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final FirebaseDatabase _database = FirebaseDatabase.instance;

//   final Rxn<User> firebaseUser = Rxn<User>();

//   final RxBool isLoading = false.obs;

//   User? get currentFirebaseUser => _auth.currentUser;

//   bool get isLoggedIn => _auth.currentUser != null;

//   @override
//   void onInit() {
//     super.onInit();

//     firebaseUser.value = _auth.currentUser;

//     ever(firebaseUser, (User? user) {
//       // Authentication state can be handled here later.
//     });

//     _auth.authStateChanges().listen((User? user) {
//       firebaseUser.value = user;
//     });
//   }

//   Future<bool> createAdmin({
//     required String name,
//     required String email,
//     required String password,
//     required String phone,
//   }) async {
//     try {
//       isLoading.value = true;

//       final UserCredential credential = await _auth
//           .createUserWithEmailAndPassword(
//             email: email.trim(),
//             password: password,
//           );

//       final User? user = credential.user;

//       if (user == null) {
//         throw Exception('Unable to create Firebase user.');
//       }

//       await user.updateDisplayName(name.trim());

//       final now = DateTime.now().toIso8601String();

//       final admin = UserModel(
//         id: user.uid,
//         name: name.trim(),
//         email: email.trim(),
//         phone: phone.trim(),
//         profileImage: '',
//         role: 'admin',
//         isActive: true,
//         emailVerified: user.emailVerified,
//         addresses: [],
//         createdAt: DateTime.now(),
//         updatedAt: DateTime.now(),
//         lastLoginAt: DateTime.now(),
//       );

//       await _database.ref('users').child(user.uid).set(admin.toMap());

//       firebaseUser.value = user;

//       Get.snackbar(
//         'Admin Created',
//         'Admin account has been created successfully.',
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Get.theme.colorScheme.primary,
//         colorText: Get.theme.colorScheme.onPrimary,
//         margin: const EdgeInsets.all(16),
//       );

//       return true;
//     } on FirebaseAuthException catch (e) {
//       String message = 'Something went wrong.';

//       switch (e.code) {
//         case 'email-already-in-use':
//           message = 'An account already exists with this email.';
//           break;

//         case 'invalid-email':
//           message = 'Please enter a valid email address.';
//           break;

//         case 'weak-password':
//           message = 'Password is too weak.';
//           break;

//         case 'operation-not-allowed':
//           message = 'Email/password authentication is not enabled.';
//           break;

//         default:
//           message = e.message ?? 'Unable to create admin account.';
//       }

//       Get.snackbar(
//         'Admin Creation Failed',
//         message,
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Get.theme.colorScheme.error,
//         colorText: Get.theme.colorScheme.onError,
//         margin: const EdgeInsets.all(16),
//       );

//       return false;
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         e.toString(),
//         snackPosition: SnackPosition.BOTTOM,
//         backgroundColor: Get.theme.colorScheme.error,
//         colorText: Get.theme.colorScheme.onError,
//         margin: EdgeInsets.all(16),
//       );

//       return false;
//     } finally {
//       isLoading.value = false;
//     }
//   }

//   Future<void> logout() async {
//     await _auth.signOut();
//     firebaseUser.value = null;
//   }
// }
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class AuthController extends GetxController {
  static AuthController get to => Get.find<AuthController>();

  AuthController({UserRepository? userRepository})
    : _userRepository = userRepository ?? UserRepository();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository;

  // ==========================================================
  // OBSERVABLES
  // ==========================================================

  final Rxn<User> firebaseUser = Rxn<User>();

  final Rxn<UserModel> currentUserModel = Rxn<UserModel>();

  final RxBool isLoading = false.obs;

  final RxString errorMessage = ''.obs;

  StreamSubscription<User?>? _authSubscription;

  // ==========================================================
  // GETTERS
  // ==========================================================

  User? get currentFirebaseUser => _auth.currentUser;

  UserModel? get currentUser => currentUserModel.value;

  bool get isLoggedIn => _auth.currentUser != null;

  bool get isCustomer => currentUser?.isCustomer ?? false;

  bool get isAdmin => currentUser?.isAdmin ?? false;

  bool get isSuperAdmin => currentUser?.isSuperAdmin ?? false;

  String get userId => _auth.currentUser?.uid ?? '';

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void onInit() {
    super.onInit();

    firebaseUser.value = _auth.currentUser;

    _authSubscription = _auth.authStateChanges().listen((User? user) async {
      firebaseUser.value = user;

      if (user != null) {
        await loadCurrentUser();
      } else {
        currentUserModel.value = null;
      }
    });
  }

  // ==========================================================
  // CUSTOMER SIGN UP
  // ==========================================================

  Future<bool> createCustomer({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

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

      final now = DateTime.now();

      final customer = UserModel(
        id: user.uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        profileImage: '',
        role: 'customer',
        isActive: true,
        emailVerified: user.emailVerified,
        addresses: const [],
        createdAt: now,
        updatedAt: now,
        lastLoginAt: now,
      );

      await _userRepository.createUser(customer);

      firebaseUser.value = user;
      currentUserModel.value = customer;

      Get.snackbar(
        'Account Created',
        'Your account has been created successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
        margin: const EdgeInsets.all(16),
      );

      return true;
    } on FirebaseAuthException catch (e) {
      final message = _getAuthErrorMessage(e);

      errorMessage.value = message;

      Get.snackbar(
        'Sign Up Failed',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        margin: const EdgeInsets.all(16),
      );

      return false;
    } catch (e) {
      errorMessage.value = e.toString();

      Get.snackbar(
        'Error',
        'Unable to create your account. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        margin: const EdgeInsets.all(16),
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================
  // ADMIN SIGN UP
  // ==========================================================

  Future<bool> createAdmin({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

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

      final now = DateTime.now();

      final admin = UserModel(
        id: user.uid,
        name: name.trim(),
        email: email.trim(),
        phone: phone.trim(),
        profileImage: '',
        role: 'admin',
        isActive: true,
        emailVerified: user.emailVerified,
        addresses: const [],
        createdAt: now,
        updatedAt: now,
        lastLoginAt: now,
      );

      await _userRepository.createUser(admin);

      firebaseUser.value = user;
      currentUserModel.value = admin;

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
      final message = _getAuthErrorMessage(e);

      errorMessage.value = message;

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
      errorMessage.value = e.toString();

      Get.snackbar(
        'Error',
        'Unable to create admin account.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        margin: const EdgeInsets.all(16),
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================
  // LOGIN
  // ==========================================================

  Future<bool> login({required String email, required String password}) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = credential.user;

      if (user == null) {
        throw Exception('Unable to login.');
      }

      firebaseUser.value = user;

      final UserModel? profile = await _userRepository.getUser(user.uid);

      if (profile == null) {
        throw Exception('User profile was not found.');
      }

      if (!profile.isActive) {
        await _auth.signOut();

        Get.snackbar(
          'Account Disabled',
          'Your account has been disabled. Please contact support.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          margin: const EdgeInsets.all(16),
        );

        return false;
      }

      currentUserModel.value = profile;

      await _userRepository.updateLastLogin(user.uid);

      await _userRepository.updateEmailVerified(user.uid, user.emailVerified);

      Get.snackbar(
        'Welcome Back',
        'You have logged in successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
        margin: const EdgeInsets.all(16),
      );

      return true;
    } on FirebaseAuthException catch (e) {
      final message = _getAuthErrorMessage(e);

      errorMessage.value = message;

      Get.snackbar(
        'Login Failed',
        message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        margin: const EdgeInsets.all(16),
      );

      return false;
    } catch (e) {
      errorMessage.value = e.toString();

      Get.snackbar(
        'Login Failed',
        'Unable to login. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        margin: const EdgeInsets.all(16),
      );

      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ==========================================================
  // LOAD CURRENT USER
  // ==========================================================

  Future<void> loadCurrentUser() async {
    final User? user = _auth.currentUser;

    if (user == null) {
      currentUserModel.value = null;
      return;
    }

    try {
      final UserModel? profile = await _userRepository.getUser(user.uid);

      if (profile != null) {
        currentUserModel.value = profile;
      }
    } catch (e) {
      errorMessage.value = e.toString();
    }
  }

  // ==========================================================
  // REFRESH CURRENT USER
  // ==========================================================

  Future<void> refreshCurrentUser() async {
    await loadCurrentUser();
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  Future<void> logout() async {
    try {
      await _auth.signOut();

      firebaseUser.value = null;
      currentUserModel.value = null;
      errorMessage.value = '';
    } catch (e) {
      Get.snackbar(
        'Logout Failed',
        'Unable to logout. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  // ==========================================================
  // FIREBASE AUTH ERROR MESSAGES
  // ==========================================================

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists with this email.';

      case 'invalid-email':
        return 'Please enter a valid email address.';

      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';

      case 'operation-not-allowed':
        return 'Email/password authentication is not enabled.';

      case 'user-not-found':
        return 'No account was found with this email.';

      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';

      default:
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  // ==========================================================
  // CLEANUP
  // ==========================================================

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
}
