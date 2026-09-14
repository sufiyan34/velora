import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_commerce/controllers/wishlist_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../../../models/product_model.dart';

class WishlistScreen extends GetView<WishlistController> {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'My Wishlist',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontSize: 21.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.wishlist.isEmpty) {
          return const _EmptyWishlist();
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            int columns;

            if (width >= 1300) {
              columns = 5;
            } else if (width >= 1000) {
              columns = 4;
            } else if (width >= 650) {
              columns = 3;
            } else {
              columns = 2;
            }

            const horizontalPadding = 18.0;
            const spacing = 12.0;

            final cardWidth =
                (width - horizontalPadding * 2 - spacing * (columns - 1)) /
                columns;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding.w,
                20.h,
                horizontalPadding.w,
                40.h,
              ),
              child: Wrap(
                spacing: spacing.w,
                runSpacing: 18.h,
                children: controller.wishlist.map((product) {
                  return SizedBox(
                    width: cardWidth,
                    child: _WishlistProductCard(product: product),
                  );
                }).toList(),
              ),
            );
          },
        );
      }),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* PRODUCT CARD                                                              */
/* -------------------------------------------------------------------------- */

class _WishlistProductCard extends GetView<WishlistController> {
  final ProductModel product;

  const _WishlistProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                          placeholder: (_, __) {
                            return Container(color: Colors.grey.shade100);
                          },
                          errorWidget: (_, __, ___) {
                            return Container(
                              color: Colors.grey.shade100,
                              child: Icon(
                                Iconsax.image,
                                color: Colors.grey.shade400,
                              ),
                            );
                          },
                        ),
                ),

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

                Positioned(
                  top: 7.h,
                  right: 7.w,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () {
                      controller.removeFromWishlist(product.id);
                    },
                    child: Container(
                      width: 34.w,
                      height: 34.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.94),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Iconsax.heart5,
                        size: 17.sp,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.all(11.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.brand.isEmpty ? product.categoryName : product.brand,
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
                    Icon(Icons.star_rounded, size: 14.sp, color: Colors.amber),
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
                    Expanded(
                      child: Text(
                        'Rs. ${product.finalPrice.toStringAsFixed(0)}',
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),

                    if (product.hasDiscount)
                      Text(
                        'Rs. ${product.price.toStringAsFixed(0)}',
                        style: GoogleFonts.poppins(
                          fontSize: 9.sp,
                          color: Colors.grey.shade500,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 10.h),

                SizedBox(
                  width: double.infinity,
                  height: 38.h,
                  child: ElevatedButton.icon(
                    onPressed: product.isOutOfStock
                        ? null
                        : () {
                            // Cart will be connected here next.
                          },
                    icon: Icon(Iconsax.shopping_cart, size: 16.sp),
                    label: Text(
                      product.isOutOfStock ? 'Out of Stock' : 'Add to Cart',
                      style: GoogleFonts.poppins(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      disabledForegroundColor: Colors.grey.shade600,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(9.r),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* EMPTY STATE                                                               */
/* -------------------------------------------------------------------------- */

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

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
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.heart,
                size: 42.sp,
                color: Colors.grey.shade400,
              ),
            ),

            SizedBox(height: 20.h),

            Text(
              'Your Wishlist is Empty',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 7.h),

            Text(
              'Save products you love and find them here later.',
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
                padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 12.h),
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
