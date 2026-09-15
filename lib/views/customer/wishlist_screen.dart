import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../controllers/wishlist_controller.dart';
import '../../../controllers/home_controller.dart';
import '../../../controllers/cart_controller.dart';
import '../../../models/product_model.dart';

class WishlistScreen extends StatelessWidget {
  WishlistScreen({super.key});

  final WishlistController wishlistController = Get.find<WishlistController>();

  final HomeController homeController = Get.find<HomeController>();

  final CartController cartController = Get.find<CartController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Wishlist'),
        centerTitle: false,
        actions: [
          Obx(() {
            if (wishlistController.isEmpty) {
              return const SizedBox.shrink();
            }

            return IconButton(
              tooltip: 'Clear Wishlist',
              onPressed: wishlistController.isUpdating.value
                  ? null
                  : () => _showClearWishlistDialog(context),
              icon: const Icon(Iconsax.trash),
            );
          }),
          SizedBox(width: 8.w),
        ],
      ),
      body: Obx(() {
        if (wishlistController.isLoading.value) {
          return const _WishlistLoading();
        }

        if (wishlistController.errorMessage.value.isNotEmpty) {
          return _WishlistError(
            message: wishlistController.errorMessage.value,
            onRetry: wishlistController.refreshUserWishlist,
          );
        }

        if (wishlistController.isEmpty) {
          return const _EmptyWishlist();
        }

        final products = _getWishlistProducts();

        if (products.isEmpty) {
          return const _WishlistProductsUnavailable();
        }

        return RefreshIndicator(
          onRefresh: () async {
            homeController.refreshHome();
            wishlistController.refreshUserWishlist();
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

              return GridView.builder(
                padding: EdgeInsets.all(16.w),
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: _getChildAspectRatio(constraints.maxWidth),
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];

                  return _WishlistProductCard(
                    product: product,
                    wishlistController: wishlistController,
                    cartController: cartController,
                  );
                },
              );
            },
          ),
        );
      }),
    );
  }

  List<ProductModel> _getWishlistProducts() {
    final ids = wishlistController.wishlistIds;

    final products = <ProductModel>[];

    for (final id in ids) {
      final matches = homeController.products.where(
        (product) => product.id == id,
      );

      if (matches.isNotEmpty) {
        products.add(matches.first);
      }
    }

    return products;
  }

  int _getCrossAxisCount(double width) {
    if (width >= 1400) return 5;
    if (width >= 1100) return 4;
    if (width >= 750) return 3;
    if (width >= 500) return 2;
    return 2;
  }

  double _getChildAspectRatio(double width) {
    if (width >= 1400) return 0.72;
    if (width >= 1100) return 0.70;
    if (width >= 750) return 0.68;
    return 0.65;
  }

  Future<void> _showClearWishlistDialog(BuildContext context) async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Clear Wishlist?'),
          content: const Text(
            'Are you sure you want to remove all products from your wishlist?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (shouldClear == true) {
      await wishlistController.clearWishlist();
    }
  }
}

// ==========================================================
// PRODUCT CARD
// ==========================================================

class _WishlistProductCard extends StatelessWidget {
  const _WishlistProductCard({
    required this.product,
    required this.wishlistController,
    required this.cartController,
  });

  final ProductModel product;
  final WishlistController wishlistController;
  final CartController cartController;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      child: InkWell(
        onTap: () {
          // Connect your product-details route here when ready.
          //
          // Example:
          // Get.toNamed(
          //   '/product-details',
          //   arguments: product,
          // );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  Positioned.fill(child: _ProductImage(product: product)),

                  // Discount badge
                  if (product.hasDiscount)
                    Positioned(
                      top: 10.h,
                      left: 10.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '-${product.discountPercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onError,
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                  // Wishlist button
                  Positioned(
                    top: 8.h,
                    right: 8.w,
                    child: Material(
                      color: Theme.of(
                        context,
                      ).colorScheme.surface.withValues(alpha: 0.92),
                      shape: const CircleBorder(),
                      child: Obx(() {
                        final isUpdating = wishlistController.isUpdating.value;

                        return IconButton(
                          tooltip: 'Remove from Wishlist',
                          onPressed: isUpdating
                              ? null
                              : () => wishlistController.removeFromWishlist(
                                  product.id,
                                ),
                          icon: Icon(
                            Iconsax.heart5,
                            size: 20.sp,
                            color: Theme.of(context).colorScheme.error,
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              flex: 4,
              child: Padding(
                padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Brand
                    if (product.brand.trim().isNotEmpty)
                      Text(
                        product.brand,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                    SizedBox(height: 4.h),

                    // Product name
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const Spacer(),

                    // Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Rs. ${product.finalPrice.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (product.hasDiscount) ...[
                          SizedBox(width: 6.w),
                          Flexible(
                            child: Text(
                              'Rs. ${product.price.toStringAsFixed(0)}',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                decoration: TextDecoration.lineThrough,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: 8.h),

                    // Add to cart
                    SizedBox(
                      width: double.infinity,
                      height: 38.h,
                      child: FilledButton.icon(
                        onPressed: product.isOutOfStock
                            ? null
                            : () => cartController.addToCart(product),
                        icon: Icon(Iconsax.shopping_cart, size: 16.sp),
                        label: Text(
                          product.isOutOfStock ? 'Out of Stock' : 'Add to Cart',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// PRODUCT IMAGE
// ==========================================================

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    if (product.thumbnail.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        alignment: Alignment.center,
        child: Icon(
          Iconsax.gallery,
          size: 42.sp,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
    }

    return CachedNetworkImage(
      imageUrl: product.thumbnail,
      fit: BoxFit.cover,
      placeholder: (context, url) {
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: SizedBox(
            width: 24.w,
            height: 24.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
      errorWidget: (context, url, error) {
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          alignment: Alignment.center,
          child: Icon(Iconsax.gallery_slash, size: 38.sp),
        );
      },
    );
  }
}

// ==========================================================
// EMPTY STATE
// ==========================================================

class _EmptyWishlist extends StatelessWidget {
  const _EmptyWishlist();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Icon(
                Iconsax.heart,
                size: 46.sp,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Your Wishlist is Empty',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8.h),
            Text(
              'Save products you love and come back to them later.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 24.h),
            FilledButton.icon(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Iconsax.shopping_bag),
              label: const Text('Continue Shopping'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// PRODUCTS UNAVAILABLE
// ==========================================================

class _WishlistProductsUnavailable extends StatelessWidget {
  const _WishlistProductsUnavailable();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.box_remove,
              size: 60.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 16.h),
            Text(
              'Products Unavailable',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8.h),
            Text(
              'The products saved in your wishlist are currently unavailable.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// LOADING
// ==========================================================

class _WishlistLoading extends StatelessWidget {
  const _WishlistLoading();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 8,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.65,
      ),
      itemBuilder: (context, index) {
        return Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Expanded(
                flex: 6,
                child: Container(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
              Expanded(
                flex: 4,
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60.w,
                        height: 10.h,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: double.infinity,
                        height: 14.h,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 90.w,
                        height: 14.h,
                        color: Theme.of(
                          context,
                        ).colorScheme.surfaceContainerHighest,
                      ),
                      const Spacer(),
                      Container(
                        width: double.infinity,
                        height: 38.h,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==========================================================
// ERROR
// ==========================================================

class _WishlistError extends StatelessWidget {
  const _WishlistError({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Iconsax.warning_2,
              size: 56.sp,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Something went wrong',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 20.h),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Iconsax.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
