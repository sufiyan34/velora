import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};

    final String orderId = args['orderId']?.toString() ?? '';
    final double total = _toDouble(args['total']);
    final String paymentMethod =
        args['paymentMethod']?.toString() ?? 'Cash on Delivery';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 30.h),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 650.w),
              child: Column(
                children: [
                  _buildSuccessIcon(),

                  SizedBox(height: 28.h),

                  Text(
                    'Order Confirmed!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF202020),
                    ),
                  ),

                  SizedBox(height: 10.h),

                  Text(
                    'Thank you for your order. Your order has been placed successfully.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      height: 1.6,
                      color: const Color(0xFF686868),
                    ),
                  ),

                  SizedBox(height: 28.h),

                  _buildOrderCard(
                    orderId: orderId,
                    total: total,
                    paymentMethod: paymentMethod,
                  ),

                  SizedBox(height: 28.h),

                  _buildDeliveryInfo(),

                  SizedBox(height: 30.h),

                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Get.toNamed(
                          '/orders',
                          arguments: {'highlightOrderId': orderId},
                        );
                      },
                      icon: Icon(Iconsax.receipt_item, size: 20.sp),
                      label: Text(
                        'View Order',
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C4CF1),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Get.offAllNamed('/home');
                      },
                      icon: Icon(Iconsax.home_2, size: 20.sp),
                      label: Text(
                        'Continue Shopping',
                        style: GoogleFonts.poppins(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6C4CF1),
                        side: BorderSide(
                          color: const Color(0xFF6C4CF1),
                          width: 1.2.w,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  Text(
                    'You can track your order anytime from My Orders.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Container(
      width: 110.w,
      height: 110.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF6C4CF1), Color(0xFF8B5CF6)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C4CF1).withValues(alpha: 0.20),
            blurRadius: 30.r,
            spreadRadius: 5.r,
          ),
        ],
      ),
      child: Icon(Icons.check_rounded, size: 58.sp, color: Colors.white),
    );
  }

  Widget _buildOrderCard({
    required String orderId,
    required double total,
    required String paymentMethod,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20.r,
            offset: Offset(0, 8.h),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Iconsax.receipt_2,
            label: 'Order ID',
            value: orderId.isEmpty ? 'Processing' : orderId,
          ),

          Divider(height: 28.h, color: Colors.grey.shade200),

          _buildInfoRow(
            icon: Iconsax.wallet_2,
            label: 'Payment',
            value: paymentMethod,
          ),

          Divider(height: 28.h, color: Colors.grey.shade200),

          _buildInfoRow(
            icon: Iconsax.money,
            label: 'Total',
            value: 'Rs. ${total.toStringAsFixed(0)}',
            valueBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    bool valueBold = false,
  }) {
    return Row(
      children: [
        Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            color: const Color(0xFF6C4CF1).withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: const Color(0xFF6C4CF1), size: 20.sp),
        ),

        SizedBox(width: 14.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: valueBold ? FontWeight.w700 : FontWeight.w600,
                  color: const Color(0xFF202020),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryInfo() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        color: const Color(0xFF6C4CF1).withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF6C4CF1).withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Iconsax.truck_fast, color: const Color(0xFF6C4CF1), size: 24.sp),

          SizedBox(width: 12.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cash on Delivery',
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF202020),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Please keep the exact amount ready when your order arrives.',
                  style: GoogleFonts.poppins(
                    fontSize: 12.sp,
                    height: 1.5,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
