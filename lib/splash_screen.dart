import 'dart:async';

import 'package:e_commerce/constants/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();

    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Get.offAllNamed(AppRoutes.home);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF7C5CFC), Color(0xFF6846E8), Color(0xFF4C2FB8)],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              final bool isMobile = width < 600;
              final bool isTablet = width >= 600 && width < 1100;

              final double logoSize = isMobile
                  ? 105.w
                  : isTablet
                  ? 125
                  : 145;

              final double titleSize = isMobile
                  ? 38.sp
                  : isTablet
                  ? 42
                  : 48;

              return Stack(
                children: [
                  // ==========================================
                  // Background Decorative Circles
                  // ==========================================
                  Positioned(
                    top: -100,
                    right: -100,
                    child: _backgroundCircle(size: isMobile ? 220 : 320),
                  ),

                  Positioned(
                    bottom: -130,
                    left: -110,
                    child: _backgroundCircle(size: isMobile ? 260 : 380),
                  ),

                  Positioned(
                    top: constraints.maxHeight * 0.18,
                    left: -60,
                    child: _backgroundCircle(size: isMobile ? 120 : 170),
                  ),

                  // ==========================================
                  // Main Content
                  // ==========================================
                  Center(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              width: logoSize,
                              height: logoSize,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.28),
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 35,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: logoSize * 0.72,
                                  height: logoSize * 0.72,
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      'V',
                                      style: GoogleFonts.poppins(
                                        fontSize: logoSize * 0.42,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF6846E8),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: isMobile ? 24.h : 28),

                          SlideTransition(
                            position: _slideAnimation,
                            child: Column(
                              children: [
                                Text(
                                  'Velora',
                                  style: GoogleFonts.poppins(
                                    fontSize: titleSize,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.2,
                                    color: Colors.white,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                Text(
                                  'SHOP • DISCOVER • ENJOY',
                                  style: GoogleFonts.poppins(
                                    fontSize: isMobile ? 9.sp : 11,
                                    fontWeight: FontWeight.w500,
                                    letterSpacing: 3.2,
                                    color: Colors.white.withValues(alpha: 0.78),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ==========================================
                  // Bottom Loading Indicator
                  // ==========================================
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: isMobile ? 35.h : 45,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          SizedBox(
                            width: isMobile ? 85.w : 100,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: const LinearProgressIndicator(
                                minHeight: 3,
                                backgroundColor: Color(0x35FFFFFF),
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            'Loading...',
                            style: GoogleFonts.poppins(
                              fontSize: isMobile ? 10.sp : 11,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withValues(alpha: 0.65),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _backgroundCircle({required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.035),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
    );
  }
}
