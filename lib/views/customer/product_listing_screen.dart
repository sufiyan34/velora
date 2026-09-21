import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../constants/app_routes.dart';
import '../../controllers/customer_product_listing_controller.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../utills/customer_skeleton.dart';

class ProductListingScreen extends GetView<CustomerProductListingController> {
  const ProductListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = Get.arguments;
    final category = arguments is Map
        ? arguments['category'] as CategoryModel?
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      appBar: AppBar(
        title: Text(
          category?.name ?? 'Products',
          style: GoogleFonts.poppins(
            fontSize: 19.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 8.h),
            child: Row(
              children: [
                Expanded(child: _SearchBox(controller: controller)),
                SizedBox(width: 10.w),
                _SortButton(controller: controller),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.products.isEmpty) {
                return const ProductGridSkeleton();
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return _ErrorState(
                  message: controller.errorMessage.value,
                );
              }

              // Re-reading these inside the same Obx keeps the grid, the
              // "load more" spinner and the empty state all reactive to
              // search/sort/pagination changes together.
              final allFiltered = controller.filteredProducts;
              final products = controller.pagedProducts;
              final hasMore = controller.hasMore;

              if (allFiltered.isEmpty) {
                return const _NoProductsState();
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final columns = width >= 1500
                      ? 5
                      : width >= 1150
                          ? 4
                          : width >= 700
                              ? 3
                              : 2;

                  return NotificationListener<ScrollUpdateNotification>(
                    onNotification: (notification) {
                      final metrics = notification.metrics;

                      // Fetch the next page a little before the user hits
                      // the very bottom, so it never looks like a hard stop.
                      if (hasMore &&
                          metrics.pixels >= metrics.maxScrollExtent - 400) {
                        controller.loadMore();
                      }

                      return false;
                    },
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            width >= 900 ? 30.w : 18.w,
                            10.h,
                            width >= 900 ? 30.w : 18.w,
                            8.h,
                          ),
                          sliver: SliverGrid(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              crossAxisSpacing: width >= 900 ? 18.w : 12.w,
                              mainAxisSpacing: width >= 900 ? 18.h : 12.h,
                              childAspectRatio: width < 520 ? 0.66 : 0.72,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) =>
                                  _ProductTile(product: products[index]),
                              childCount: products.length,
                            ),
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: hasMore
                              ? Padding(
                                  padding: EdgeInsets.symmetric(
                                    vertical: 20.h,
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      width: 22.w,
                                      height: 22.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox(height: 24.h),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  final CustomerProductListingController controller;

  const _SearchBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: controller.setSearchQuery,
      style: GoogleFonts.poppins(fontSize: 11.sp),
      decoration: InputDecoration(
        hintText: 'Search products...',
        prefixIcon: Icon(Iconsax.search_normal, size: 18.sp),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final CustomerProductListingController controller;

  const _SortButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: controller.setSort,
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'recommended', child: Text('Recommended')),
        PopupMenuItem(value: 'newest', child: Text('Newest')),
        PopupMenuItem(value: 'price_low', child: Text('Price: Low to High')),
        PopupMenuItem(value: 'price_high', child: Text('Price: High to Low')),
        PopupMenuItem(value: 'rating', child: Text('Highest Rated')),
        PopupMenuItem(value: 'discount', child: Text('Biggest Discount')),
      ],
      child: Container(
        width: 46.w,
        height: 46.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(Iconsax.sort, size: 19.sp),
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final ProductModel product;

  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final hasImage = product.thumbnail.trim().isNotEmpty;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: () {
          Get.toNamed(
            AppRoutes.productDetails,
            arguments: product,
          );
        },
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.all(10.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: SizedBox(
                    width: double.infinity,
                    child: hasImage
                        ? CachedNetworkImage(
                            imageUrl: product.thumbnail,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                const _ProductImageFallback(),
                          )
                        : const _ProductImageFallback(),
                  ),
                ),
              ),
              SizedBox(height: 9.h),
              Text(
                product.brand.isEmpty ? 'Velora' : product.brand,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 8.sp,
                  color: Colors.grey.shade500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 5.h),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Rs. ${product.finalPrice.toStringAsFixed(0)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.star_rounded,
                    size: 13.sp,
                    color: Colors.amber.shade700,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    product.rating.toStringAsFixed(1),
                    style: GoogleFonts.poppins(
                      fontSize: 8.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              if (product.hasDiscount) ...[
                SizedBox(height: 2.h),
                Text(
                  'Rs. ${product.price.toStringAsFixed(0)}  ${product.discountPercentage.toStringAsFixed(0)}% OFF',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 8.sp,
                    color: Colors.grey.shade500,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductImageFallback extends StatelessWidget {
  const _ProductImageFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF1F2F7),
      alignment: Alignment.center,
      child: Icon(
        Iconsax.image,
        size: 34.sp,
        color: Colors.grey.shade500,
      ),
    );
  }
}

class _NoProductsState extends StatelessWidget {
  const _NoProductsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.shopping_bag, size: 52.sp, color: Colors.grey.shade400),
            SizedBox(height: 12.h),
            Text(
              'No products found',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              'Try another search or category.',
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Text(
          'Unable to load products.\n$message',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 11.sp,
            color: Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
