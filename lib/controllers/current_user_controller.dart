import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class CurrentUserController extends GetxController {
  static CurrentUserController get to =>
      Get.find<CurrentUserController>();

  CurrentUserController({
    UserRepository? userRepository,
  }) : _userRepository = userRepository ?? UserRepository();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserRepository _userRepository;

  // ===========================================================================
  // STATE
  // ===========================================================================

  final Rxn<User> firebaseUser = Rxn<User>();

  final Rxn<UserModel> user = Rxn<UserModel>();

  final RxBool isLoading = false.obs;

  final RxString errorMessage = ''.obs;

  StreamSubscription<User?>? _authSubscription;

  // ===========================================================================
  // BASIC GETTERS
  // ===========================================================================

  User? get authUser => firebaseUser.value;

  UserModel? get currentUser => user.value;

  String get userId => firebaseUser.value?.uid ?? '';

  String get name => currentUser?.name ?? '';

  String get email => currentUser?.email ?? '';

  String get phone => currentUser?.phone ?? '';

  String get profileImage => currentUser?.profileImage ?? '';

  String get role => currentUser?.role ?? '';

  bool get isLoggedIn => firebaseUser.value != null;

  bool get isActive => currentUser?.isActive ?? false;

  bool get emailVerified => currentUser?.emailVerified ?? false;

  bool get hasUserProfile => currentUser != null;

  // ===========================================================================
  // ROLE HELPERS
  // ===========================================================================

  bool get isCustomer => currentUser?.isCustomer ?? false;

  bool get isAdmin => currentUser?.isAdmin ?? false;

  bool get isSuperAdmin => currentUser?.isSuperAdmin ?? false;

  bool get isStaff => isAdmin || isSuperAdmin;

  bool hasRole(String requiredRole) {
    return role.trim().toLowerCase() ==
        requiredRole.trim().toLowerCase();
  }

  bool hasAnyRole(List<String> roles) {
    final currentRole = role.trim().toLowerCase();

    return roles.any(
      (item) => item.trim().toLowerCase() == currentRole,
    );
  }

  // ===========================================================================
  // ACCOUNT HELPERS
  // ===========================================================================

  bool get canUseAccount {
    return isLoggedIn && isActive && hasUserProfile;
  }

  bool get canPlaceOrder {
    return isLoggedIn && isActive && hasUserProfile;
  }

  bool get canViewOrders {
    return isLoggedIn && isActive && hasUserProfile;
  }

  bool get canManageAdminArea {
    return isLoggedIn && isActive && (isAdmin || isSuperAdmin);
  }

  bool get canManageSuperAdminArea {
    return isLoggedIn && isActive && isSuperAdmin;
  }

  bool isCurrentUser(String id) {
    return userId.isNotEmpty && userId == id;
  }

  // ===========================================================================
  // AUTH STATE
  // ===========================================================================

  @override
  void onInit() {
    super.onInit();

    firebaseUser.value = _auth.currentUser;

    _authSubscription = _auth.authStateChanges().listen(
      (User? firebaseUserValue) async {
        firebaseUser.value = firebaseUserValue;

        if (firebaseUserValue == null) {
          clear();
          return;
        }

        await loadCurrentUser();
      },
    );

    if (_auth.currentUser != null) {
      loadCurrentUser();
    }
  }

  // ===========================================================================
  // LOAD USER
  // ===========================================================================

  Future<void> loadCurrentUser() async {
    final firebaseAuthUser = _auth.currentUser;

    if (firebaseAuthUser == null) {
      clear();
      return;
    }

    try {
      isLoading.value = true;
      errorMessage.value = '';

      firebaseUser.value = firebaseAuthUser;

      final UserModel? profile =
          await _userRepository.getUser(firebaseAuthUser.uid);

      if (profile != null) {
        user.value = profile;
      } else {
        user.value = null;
        errorMessage.value = 'User profile was not found.';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  // ===========================================================================
  // REFRESH
  // ===========================================================================

  Future<void> refresh() async {
    await loadCurrentUser();
  }

  // ===========================================================================
  // LOCAL USER UPDATE
  // ===========================================================================

  void setUser(UserModel userModel) {
    user.value = userModel;
  }

  void clear() {
    firebaseUser.value = null;
    user.value = null;
    errorMessage.value = '';
  }

  // ===========================================================================
  // LOGIN / ACCESS HELPERS
  // ===========================================================================

  bool requireLogin() {
    if (isLoggedIn) {
      return true;
    }

    Get.snackbar(
      'Login Required',
      'Please login to continue.',
      snackPosition: SnackPosition.BOTTOM,
    );

    return false;
  }

  bool requireActiveAccount() {
    if (!requireLogin()) {
      return false;
    }

    if (isActive) {
      return true;
    }

    Get.snackbar(
      'Account Disabled',
      'Your account is currently disabled.',
      snackPosition: SnackPosition.BOTTOM,
    );

    return false;
  }

  // ===========================================================================
  // CLEANUP
  // ===========================================================================

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
}