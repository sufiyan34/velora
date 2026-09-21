import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/product_section_listing_controller.dart';
import '../../utills/customer_skeleton.dart';
import '../../utills/product_card.dart';

/// Full-page listing shown when the user taps "View All" on the Home
/// screen's Featured Products, New Arrivals, or On Sale sections.
/// Parameterized by [ProductSectionListingController.sectionType], so one
/// screen + controller serves all three.
class ProductSectionScreen extends GetView<ProductSectionListingController> {
  const ProductSectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: Text(
          controller.title,
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 8.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (controller.subtitle.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: Text(
                      controller.subtitle,
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                Row(
                  children: [
                    Expanded(child: _SearchBox(controller: controller)),
                    SizedBox(width: 10.w),
                    _SortButton(controller: controller),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.products.isEmpty) {
                return const ProductGridSkeleton(itemCount: 8);
              }

              if (controller.errorMessage.value.isNotEmpty) {
                return _ErrorState(message: controller.errorMessage.value);
              }

              final allFiltered = controller.filteredProducts;
              final products = controller.pagedProducts;
              final hasMore = controller.hasMore;

              if (allFiltered.isEmpty) {
                return const _EmptySectionState();
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
                            2.h,
                            width >= 900 ? 30.w : 18.w,
                            4.h,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: Text(
                              '${controller.resultCount} products',
                              style: GoogleFonts.poppins(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                        ),
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
                                  childAspectRatio: width < 520 ? 0.62 : 0.68,
                                ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) =>
                                  CustomerProductCard(product: products[index]),
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
  final ProductSectionListingController controller;

  const _SearchBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: controller.setSearchQuery,
      style: GoogleFonts.poppins(fontSize: 11.sp),
      decoration: InputDecoration(
        hintText: 'Search in this list...',
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
  final ProductSectionListingController controller;

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

class _EmptySectionState extends StatelessWidget {
  const _EmptySectionState();

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
              'Try another search term.',
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
          style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey.shade600),
        ),
      ),
    );
  }
}
