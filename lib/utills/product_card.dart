import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../constants/app_routes.dart';
import '../controllers/cart_controller.dart';
import '../controllers/wishlist_controller.dart';
import '../models/product_model.dart';

/// Shared product card used across the customer-facing grids (Deals,
/// Featured / New Arrivals / On Sale "View All" screens). Mirrors the
/// look of the Home screen's product card — image with discount badge,
/// wishlist toggle, cart indicator, and an add/remove-from-cart button —
/// so every product grid in the app feels like the same product.
class CustomerProductCard extends StatelessWidget {
  const CustomerProductCard({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.productDetails, arguments: product),
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: .9,
              child: Stack(
                children: [
                  // -------------------------------------------------
                  // PRODUCT IMAGE
                  // -------------------------------------------------
                  Positioned.fill(
                    child: product.thumbnail.isEmpty
                        ? Container(
                            color: Colors.grey.shade100,
                            child: Icon(
                              Iconsax.image,
                              size: 35.sp,
                              color: Colors.grey.shade400,
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: product.thumbnail,
                            fit: BoxFit.cover,
                            placeholder: (_, __) =>
                                Container(color: Colors.grey.shade100),
                            errorWidget: (_, __, ___) => Container(
                              color: Colors.grey.shade100,
                              child: Icon(
                                Iconsax.image,
                                color: Colors.grey.shade400,
                              ),
                            ),
                          ),
                  ),

                  // -------------------------------------------------
                  // DISCOUNT BADGE
                  // -------------------------------------------------
                  if (product.hasDiscount)
                    Positioned(
                      top: 9.h,
                      left: 9.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          '-${product.discountPercentage.toStringAsFixed(0)}%',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                  // -------------------------------------------------
                  // WISHLIST BUTTON
                  // -------------------------------------------------
                  Positioned(
                    top: 7.h,
                    right: 7.w,
                    child: Obx(() {
                      if (!Get.isRegistered<WishlistController>()) {
                        return const SizedBox.shrink();
                      }

                      final wishlistController =
                          Get.find<WishlistController>();

                      final isFavorite = wishlistController.isInWishlist(
                        product.id,
                      );

                      return InkWell(
                        borderRadius: BorderRadius.circular(50),
                        onTap: () {
                          wishlistController.toggleWishlist(product);
                        },
                        child: Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: .92),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite ? Iconsax.heart5 : Iconsax.heart,
                            size: 16.sp,
                            color: isFavorite ? Colors.red : Colors.black,
                          ),
                        ),
                      );
                    }),
                  ),

                  // -------------------------------------------------
                  // CART INDICATOR
                  // -------------------------------------------------
                  Positioned(
                    bottom: 9.h,
                    right: 9.w,
                    child: Obx(() {
                      if (!Get.isRegistered<CartController>()) {
                        return const SizedBox.shrink();
                      }

                      final cartController = Get.find<CartController>();

                      final isInCart = cartController.isInCart(product.id);

                      if (!isInCart) {
                        return const SizedBox.shrink();
                      }

                      return Container(
                        width: 32.w,
                        height: 32.w,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: .18),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Iconsax.shopping_cart5,
                          color: Colors.white,
                          size: 16.sp,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            // -----------------------------------------------------
            // PRODUCT INFORMATION
            // -----------------------------------------------------
            Padding(
              padding: EdgeInsets.all(11.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brand.isEmpty
                        ? product.categoryName
                        : product.brand,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 9.sp,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                    ),
                  ),

                  SizedBox(height: 7.h),

                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        size: 14.sp,
                        color: Colors.amber,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        product.rating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '(${product.reviewCount})',
                        style: GoogleFonts.poppins(
                          fontSize: 9.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 8.h),

                  Row(
                    children: [
                      Text(
                        'Rs. ${product.finalPrice.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      if (product.hasDiscount) ...[
                        SizedBox(width: 6.w),
                        Text(
                          'Rs. ${product.price.toStringAsFixed(0)}',
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

                  // ---------------------------------------------------
                  // ADD / REMOVE CART BUTTON
                  // ---------------------------------------------------
                  Obx(() {
                    if (!Get.isRegistered<CartController>()) {
                      return const SizedBox.shrink();
                    }

                    final cartController = Get.find<CartController>();

                    final isInCart = cartController.isInCart(product.id);

                    return SizedBox(
                      width: double.infinity,
                      height: 36.h,
                      child: ElevatedButton.icon(
                        onPressed: product.isOutOfStock
                            ? null
                            : () {
                                if (isInCart) {
                                  final cartItem = cartController.items
                                      .firstWhere(
                                        (item) =>
                                            item.productId == product.id,
                                      );

                                  cartController.removeFromCart(cartItem.id);
                                } else {
                                  cartController.addToCart(product);
                                }
                              },
                        icon: Icon(
                          isInCart ? Iconsax.trash : Iconsax.shopping_cart,
                          size: 15.sp,
                        ),
                        label: Text(
                          product.isOutOfStock
                              ? 'Out of Stock'
                              : isInCart
                              ? 'Remove from Cart'
                              : 'Add to Cart',
                          style: GoogleFonts.poppins(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isInCart
                              ? Colors.red.shade50
                              : Colors.black,
                          foregroundColor: isInCart
                              ? Colors.red
                              : Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                          disabledForegroundColor: Colors.grey.shade600,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9.r),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
