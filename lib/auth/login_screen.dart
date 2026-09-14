import 'package:e_commerce/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isPasswordVisible = false;
  bool rememberMe = false;

  late AnimationController animationController;
  late Animation<double> fadeAnimation;
  late Animation<Offset> slideAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    fadeAnimation = CurvedAnimation(
      parent: animationController,
      curve: Curves.easeOut,
    );

    slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(
          CurvedAnimation(
            parent: animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    animationController.forward();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            final bool isMobile = width < 600;
            final bool isTablet = width >= 600 && width < 1100;
            final bool isDesktop = width >= 1100;

            return Stack(
              children: [
                // ==========================================
                // Decorative Background
                // ==========================================
                Positioned(
                  top: -130,
                  right: -100,
                  child: _decorativeCircle(size: isMobile ? 220 : 350),
                ),

                Positioned(
                  bottom: -160,
                  left: -130,
                  child: _decorativeCircle(size: isMobile ? 250 : 400),
                ),

                // ==========================================
                // Main Layout
                // ==========================================
                Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isMobile
                          ? 22.w
                          : isTablet
                          ? 60
                          : 40,
                      vertical: 30,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: isDesktop ? 1050 : 520,
                      ),
                      child: isDesktop
                          ? Row(
                              children: [
                                Expanded(child: _buildBrandSection()),
                                const SizedBox(width: 70),
                                SizedBox(width: 430, child: _buildLoginCard()),
                              ],
                            )
                          : _buildLoginCard(),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ==========================================================
  // LOGIN CARD
  // ==========================================================

  Widget _buildLoginCard() {
    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Container(
          padding: EdgeInsets.all(28.w.clamp(24, 36)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 35,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // Mobile Logo
                // ==========================================
                Center(child: _buildLogo(showText: true)),

                SizedBox(height: 30.h),

                Text(
                  'Welcome Back!',
                  style: GoogleFonts.poppins(
                    fontSize: 26.sp.clamp(24, 30),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF202024),
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Sign in to continue shopping with Velora.',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp.clamp(12, 14),
                    color: Colors.grey.shade600,
                  ),
                ),

                SizedBox(height: 28.h),

                // ==========================================
                // Email
                // ==========================================
                _fieldLabel('Email Address'),

                const SizedBox(height: 8),

                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }

                    if (!GetUtils.isEmail(value.trim())) {
                      return 'Please enter a valid email';
                    }

                    return null;
                  },
                  decoration: _inputDecoration(
                    hint: 'Enter your email',
                    icon: Icons.email_outlined,
                  ),
                ),

                SizedBox(height: 18.h),

                // ==========================================
                // Password
                // ==========================================
                _fieldLabel('Password'),

                const SizedBox(height: 8),

                TextFormField(
                  controller: passwordController,
                  obscureText: !isPasswordVisible,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }

                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }

                    return null;
                  },
                  decoration: _inputDecoration(
                    hint: 'Enter your password',
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                      icon: Icon(
                        isPasswordVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 12.h),

                // ==========================================
                // Remember + Forgot
                // ==========================================
                Row(
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: rememberMe,
                        activeColor: const Color(0xFF6846E8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                        onChanged: (value) {
                          setState(() {
                            rememberMe = value ?? false;
                          });
                        },
                      ),
                    ),

                    const SizedBox(width: 8),

                    Text(
                      'Remember me',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp.clamp(11, 13),
                        color: Colors.grey.shade700,
                      ),
                    ),

                    const Spacer(),

                    TextButton(
                      onPressed: () {
                        // TODO: Forgot password
                      },
                      child: Text(
                        'Forgot Password?',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp.clamp(11, 13),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6846E8),
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 18.h),

                // ==========================================
                // Login Button
                // ==========================================
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6846E8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                    child: Text(
                      'Sign In',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 22.h),

                // ==========================================
                // Divider
                // ==========================================
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade200)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        'OR',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade200)),
                  ],
                ),

                SizedBox(height: 22.h),

                // ==========================================
                // Google Button
                // ==========================================
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Google Sign In
                    },
                    icon: const Icon(Icons.g_mobiledata_rounded, size: 27),
                    label: Text(
                      'Continue with Google',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF333338),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // ==========================================
                // Register
                // ==========================================
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp.clamp(11, 13),
                          color: Colors.grey.shade600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(AppRoutes.register);
                        },
                        child: Text(
                          'Create Account',
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp.clamp(11, 13),
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6846E8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // DESKTOP BRAND SECTION
  // ==========================================================

  Widget _buildBrandSection() {
    return FadeTransition(
      opacity: fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildLogo(showText: true),

          const SizedBox(height: 45),

          Text(
            'Everything you love,\nall in one place.',
            style: GoogleFonts.poppins(
              fontSize: 42,
              height: 1.15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF202024),
            ),
          ),

          const SizedBox(height: 18),

          Text(
            'Discover products you love, explore new trends, '
            'and enjoy a seamless shopping experience with Velora.',
            style: GoogleFonts.poppins(
              fontSize: 15,
              height: 1.7,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 35),

          _feature(
            icon: Icons.local_shipping_outlined,
            title: 'Fast Delivery',
            subtitle: 'Get your orders delivered quickly.',
          ),

          const SizedBox(height: 18),

          _feature(
            icon: Icons.verified_outlined,
            title: 'Secure Shopping',
            subtitle: 'Your payments and data stay protected.',
          ),

          const SizedBox(height: 18),

          _feature(
            icon: Icons.favorite_border,
            title: 'Curated Products',
            subtitle: 'Find products worth adding to your cart.',
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // LOGO
  // ==========================================================

  Widget _buildLogo({required bool showText}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF7C5CFC), Color(0xFF4C2FB8)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6846E8).withValues(alpha: 0.25),
                blurRadius: 15,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'V',
              style: GoogleFonts.poppins(
                fontSize: 25,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),

        if (showText) ...[
          const SizedBox(width: 12),
          Text(
            'Velora',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF202024),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }

  // ==========================================================
  // FEATURE
  // ==========================================================

  Widget _feature({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF6846E8).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(Icons.check, color: Color(0xFF6846E8)),
        ),

        const SizedBox(width: 14),

        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF28282D),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // INPUT
  // ==========================================================

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade500),
      suffixIcon: suffixIcon,
      hintStyle: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade400),
      filled: true,
      fillColor: const Color(0xFFF8F8FA),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFF6846E8), width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF303035),
      ),
    );
  }

  Widget _decorativeCircle({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF6846E8).withValues(alpha: 0.035),
      ),
    );
  }

  // ==========================================================
  // LOGIN
  // ==========================================================

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Firebase authentication will be connected here.
    //
    // Example later:
    //
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
    );

    Get.offAllNamed(AppRoutes.home);
  }
}
