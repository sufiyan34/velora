import 'package:e_commerce/constants/app_routes.dart';
import 'package:e_commerce/controllers/cart_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';
import '../../../models/cart_model.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cartController = Get.find<CartController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'My Cart',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
        actions: [
          Obx(() {
            if (cartController.isEmpty) {
              return const SizedBox.shrink();
            }

            return TextButton(
              onPressed: cartController.clearCart,
              child: Text(
                'Clear All',
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            );
          }),
          SizedBox(width: 8.w),
        ],
      ),
      body: Obx(() {
        if (cartController.isEmpty) {
          return _EmptyCart();
        }

        return _CartContent(cartController: cartController);
      }),
    );
  }
}

// =============================================================================
// CART CONTENT
// =============================================================================

class _CartContent extends StatelessWidget {
  final CartController cartController;

  const _CartContent({required this.cartController});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 900;

        if (isDesktop) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(30.w),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 7,
                      child: _CartItems(cartController: cartController),
                    ),
                    SizedBox(width: 24.w),
                    SizedBox(
                      width: 360.w,
                      child: _OrderSummary(cartController: cartController),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              _CartItems(cartController: cartController),
              SizedBox(height: 20.h),
              _OrderSummary(cartController: cartController),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
}

// =============================================================================
// CART ITEMS
// =============================================================================

class _CartItems extends StatelessWidget {
  final CartController cartController;

  const _CartItems({required this.cartController});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${cartController.itemCount} ${cartController.itemCount == 1 ? 'item' : 'items'}',
          style: GoogleFonts.poppins(
            fontSize: 13.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),

        SizedBox(height: 12.h),

        ...cartController.items.map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: _CartItemCard(item: item, cartController: cartController),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// CART ITEM CARD
// =============================================================================

class _CartItemCard extends StatelessWidget {
  final CartModel item;
  final CartController cartController;

  const _CartItemCard({required this.item, required this.cartController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // -------------------------------------------------------------------
          // PRODUCT IMAGE
          // -------------------------------------------------------------------
          Container(
            width: 90.w,
            height: 90.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
            ),
            clipBehavior: Clip.antiAlias,
            child: item.productImage.isEmpty
                ? Icon(Iconsax.image, color: Colors.grey.shade400, size: 28.sp)
                : CachedNetworkImage(
                    imageUrl: item.productImage,
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: Colors.grey.shade100),
                    errorWidget: (_, __, ___) => Icon(
                      Iconsax.image,
                      color: Colors.grey.shade400,
                      size: 28.sp,
                    ),
                  ),
          ),

          SizedBox(width: 14.w),

          // -------------------------------------------------------------------
          // PRODUCT DETAILS
          // -------------------------------------------------------------------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                if (item.hasVariation) ...[
                  SizedBox(height: 4.h),
                  Text(
                    item.variationDisplayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],

                SizedBox(height: 7.h),

                Row(
                  children: [
                    Text(
                      'Rs. ${item.price.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    if (item.originalPrice != null &&
                        item.originalPrice! > item.price) ...[
                      SizedBox(width: 7.w),
                      Text(
                        'Rs. ${item.originalPrice!.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 9.sp,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                  ],
                ),

                SizedBox(height: 10.h),

                // -------------------------------------------------------------
                // QUANTITY CONTROLS
                // -------------------------------------------------------------
                Row(
                  children: [
                    _QuantityButton(
                      icon: Iconsax.minus,
                      onTap: () {
                        cartController.decreaseQuantity(item.id);
                      },
                    ),

                    Container(
                      width: 34.w,
                      alignment: Alignment.center,
                      child: Text(
                        '${item.quantity}',
                        style: GoogleFonts.poppins(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    _QuantityButton(
                      icon: Iconsax.add,
                      onTap: () {
                        cartController.increaseQuantity(item.id);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          // -------------------------------------------------------------------
          // REMOVE BUTTON
          // -------------------------------------------------------------------
          IconButton(
            onPressed: () {
              cartController.removeFromCart(item.id);
            },
            icon: Icon(Iconsax.trash, size: 18.sp, color: Colors.red),
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// QUANTITY BUTTON
// =============================================================================

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(7.r),
      child: Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(7.r),
        ),
        child: Icon(icon, size: 13.sp, color: Colors.black),
      ),
    );
  }
}

// =============================================================================
// ORDER SUMMARY
// =============================================================================

class _OrderSummary extends StatelessWidget {
  final CartController cartController;

  const _OrderSummary({required this.cartController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Summary',
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: 18.h),

          _SummaryRow(
            title: 'Subtotal',
            value: 'Rs. ${cartController.subtotal.toStringAsFixed(0)}',
          ),

          SizedBox(height: 10.h),

          _SummaryRow(
            title: 'Shipping',
            value: cartController.shipping == 0
                ? 'FREE'
                : 'Rs. ${cartController.shipping.toStringAsFixed(0)}',
            valueColor: cartController.shipping == 0
                ? Colors.green
                : Colors.black,
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Divider(color: Colors.grey.shade200),
          ),

          _SummaryRow(
            title: 'Total',
            value: 'Rs. ${cartController.total.toStringAsFixed(0)}',
            isTotal: true,
          ),

          SizedBox(height: 20.h),

          // -------------------------------------------------------------------
          // CHECKOUT BUTTON
          // -------------------------------------------------------------------
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: ElevatedButton(
              onPressed: () {
                Get.snackbar(
                  'Checkout',
                  'Moving to Checkout screen.',
                  snackPosition: SnackPosition.BOTTOM,
                );
                Get.toNamed(AppRoutes.checkout);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(11.r),
                ),
              ),
              child: Text(
                'Proceed to Checkout',
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// SUMMARY ROW
// =============================================================================

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isTotal;
  final Color? valueColor;

  const _SummaryRow({
    required this.title,
    required this.value,
    this.isTotal = false,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 13.sp : 11.sp,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
            color: isTotal ? Colors.black : Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: isTotal ? 15.sp : 11.sp,
            fontWeight: FontWeight.w700,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// EMPTY CART
// =============================================================================

class _EmptyCart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(30.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90.w,
              height: 90.w,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.shopping_cart,
                size: 40.sp,
                color: Colors.grey.shade500,
              ),
            ),

            SizedBox(height: 20.h),

            Text(
              'Your cart is empty',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 7.h),

            Text(
              'Add some products to your cart and they will appear here.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.grey.shade500,
              ),
            ),

            SizedBox(height: 22.h),

            ElevatedButton(
              onPressed: () {
                Get.back();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 13.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              child: Text(
                'Continue Shopping',
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
