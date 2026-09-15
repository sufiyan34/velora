import 'package:e_commerce/controllers/auth_controller.dart';
import 'package:e_commerce/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'My Profile',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF202024),
          ),
        ),
      ),
      body: Obx(() {
        final UserModel? user = authController.currentUser;

        if (authController.isLoading.value && user == null) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6846E8)),
          );
        }

        if (user == null) {
          return _buildNotLoggedIn(authController);
        }

        return _buildProfile(context, authController, user);
      }),
    );
  }

  // ==========================================================
  // PROFILE
  // ==========================================================

  Widget _buildProfile(
    BuildContext context,
    AuthController authController,
    UserModel user,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w.clamp(16, 24)),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            children: [
              _buildProfileHeader(user),

              SizedBox(height: 20.h),

              _buildSection(
                title: 'Account',
                children: [
                  _profileTile(
                    icon: Icons.person_outline,
                    title: 'Personal Information',
                    subtitle: 'Name, email and phone number',
                    onTap: () {
                      Get.snackbar(
                        'Coming Soon',
                        'Profile editing will be added next.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  _profileTile(
                    icon: Icons.location_on_outlined,
                    title: 'My Addresses',
                    subtitle: 'Manage your delivery addresses',
                    onTap: () {
                      Get.snackbar(
                        'Coming Soon',
                        'Address management will be added next.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              _buildSection(
                title: 'Shopping',
                children: [
                  _profileTile(
                    icon: Iconsax.box,
                    title: 'My Orders',
                    subtitle: 'View your orders and their status',
                    onTap: () {
                      Get.snackbar(
                        'Coming Soon',
                        'Orders screen will be connected next.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                  _profileTile(
                    icon: Iconsax.heart,
                    title: 'Wishlist',
                    subtitle: 'Products you saved',
                    onTap: () {
                      Get.snackbar(
                        'Coming Soon',
                        'Wishlist screen will be connected next.',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              _buildSection(
                title: 'Account Actions',
                children: [
                  _profileTile(
                    icon: Iconsax.logout,
                    title: 'Logout',
                    subtitle: 'Sign out of your Velora account',
                    iconColor: Colors.redAccent,
                    titleColor: Colors.redAccent,
                    showArrow: false,
                    onTap: () => _confirmLogout(authController),
                  ),
                ],
              ),

              SizedBox(height: 30.h),

              Text(
                'Velora',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                'Your shopping experience, simplified.',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey.shade500,
                ),
              ),

              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // PROFILE HEADER
  // ==========================================================

  Widget _buildProfileHeader(UserModel user) {
    final String displayName = user.name.trim().isEmpty
        ? 'Velora Customer'
        : user.name.trim();

    final String initial = displayName.isNotEmpty
        ? displayName.substring(0, 1).toUpperCase()
        : 'V';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w.clamp(20, 28)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool compact = constraints.maxWidth < 500;

          if (compact) {
            return Column(
              children: [
                _buildAvatar(user, initial),
                const SizedBox(height: 16),
                _buildUserInfo(user, displayName),
              ],
            );
          }

          return Row(
            children: [
              _buildAvatar(user, initial),
              const SizedBox(width: 18),
              Expanded(child: _buildUserInfo(user, displayName)),
            ],
          );
        },
      ),
    );
  }

  // ==========================================================
  // AVATAR
  // ==========================================================

  Widget _buildAvatar(UserModel user, String initial) {
    final hasImage = user.profileImage.trim().isNotEmpty;

    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7C5CFC), Color(0xFF4C2FB8)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6846E8).withValues(alpha: 0.20),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: hasImage
          ? ClipOval(
              child: Image.network(
                user.profileImage,
                width: 82,
                height: 82,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) {
                  return Center(
                    child: Text(
                      initial,
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            )
          : Center(
              child: Text(
                initial,
                style: GoogleFonts.poppins(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }

  // ==========================================================
  // USER INFORMATION
  // ==========================================================

  Widget _buildUserInfo(UserModel user, String displayName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayName,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 21,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF202024),
          ),
        ),

        const SizedBox(height: 4),

        Text(
          user.email,
          style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
        ),

        if (user.phone.trim().isNotEmpty) ...[
          const SizedBox(height: 3),
          Text(
            user.phone,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],

        const SizedBox(height: 10),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF6846E8).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.role.toUpperCase(),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6846E8),
                ),
              ),
            ),

            const SizedBox(width: 8),

            if (user.isActive)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ACTIVE',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.green.shade700,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // SECTION
  // ==========================================================

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 8.h),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF303035),
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  // ==========================================================
  // PROFILE TILE
  // ==========================================================

  Widget _profileTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? iconColor,
    Color? titleColor,
    bool showArrow = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: (iconColor ?? const Color(0xFF6846E8)).withValues(
                  alpha: 0.08,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: iconColor ?? const Color(0xFF6846E8),
              ),
            ),

            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? const Color(0xFF303035),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 10.5,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            if (showArrow)
              Icon(
                Icons.chevron_right_rounded,
                size: 21,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // NOT LOGGED IN
  // ==========================================================

  Widget _buildNotLoggedIn(AuthController authController) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF6846E8).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                size: 38,
                color: Color(0xFF6846E8),
              ),
            ),

            const SizedBox(height: 18),

            Text(
              'You are not logged in',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF202024),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Sign in to view your profile and manage your account.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Get.toNamed('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6846E8),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
                child: Text(
                  'Sign In',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // LOGOUT
  // ==========================================================

  void _confirmLogout(AuthController authController) {
    Get.dialog(
      AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Are you sure you want to logout from Velora?',
          style: GoogleFonts.poppins(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();

              await authController.logout();

              Get.offAllNamed('/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
