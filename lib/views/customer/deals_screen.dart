import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/deals_controller.dart';
import '../../utills/customer_skeleton.dart';
import '../../utills/product_card.dart';

class DealsScreen extends GetView<DealsController> {
  const DealsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        title: Text(
          'Deals',
          style: GoogleFonts.poppins(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.products.isEmpty) {
          return const _DealsSkeleton();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _ErrorState(message: controller.errorMessage.value);
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

            final allFiltered = controller.filteredProducts;
            final products = controller.pagedProducts;
            final hasMore = controller.hasMore;

            return NotificationListener<ScrollUpdateNotification>(
              onNotification: (notification) {
                final metrics = notification.metrics;

                if (hasMore && metrics.pixels >= metrics.maxScrollExtent - 400) {
                  controller.loadMore();
                }

                return false;
              },
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _DealsBanner()),
                  SliverToBoxAdapter(child: _TierChips()),
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      width >= 900 ? 30.w : 18.w,
                      6.h,
                      width >= 900 ? 30.w : 18.w,
                      2.h,
                    ),
                    sliver: SliverToBoxAdapter(child: _SearchAndSortRow()),
                  ),

                  if (allFiltered.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: _EmptyDealsState(),
                    )
                  else ...[
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
                              padding: EdgeInsets.symmetric(vertical: 20.h),
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
                ],
              ),
            );
          },
        );
      }),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* HERO BANNER                                                               */
/* -------------------------------------------------------------------------- */

class _DealsBanner extends GetView<DealsController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(22.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22.r),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF171717), Color(0xFF343434)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20.w,
              top: -20.h,
              child: Container(
                width: 140.w,
                height: 140.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: .07),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Iconsax.discount_shape5, color: Colors.white, size: 20.sp),
                    SizedBox(width: 6.w),
                    Text(
                      'LIVE DEALS',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Obx(() {
                  final top = controller.topDiscount;
                  return Text(
                    top > 0
                        ? 'Up to ${top.toStringAsFixed(0)}% OFF'
                        : 'Today\'s Best Deals',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }),
                SizedBox(height: 6.h),
                Text(
                  'Handpicked discounts across the store — grab them before they\'re gone.',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Icon(Iconsax.timer_1, color: Colors.white, size: 16.sp),
                    SizedBox(width: 6.w),
                    Text(
                      'New deals in',
                      style: GoogleFonts.poppins(
                        color: Colors.white70,
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Obx(
                      () => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: .12),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          controller.countdownLabel,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* TIER CHIPS                                                                */
/* -------------------------------------------------------------------------- */

class _TierChips extends GetView<DealsController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 0),
      child: SizedBox(
        height: 40.h,
        child: Obx(() {
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: DealsController.tierLabels.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final selected = controller.minDiscountTier.value == index;
              final count = controller.dealCountForTier(index);

              return InkWell(
                borderRadius: BorderRadius.circular(20.r),
                onTap: () => controller.setTier(index),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected ? Colors.black : Colors.white,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: selected ? Colors.black : Colors.grey.shade300,
                    ),
                  ),
                  child: Text(
                    '${DealsController.tierLabels[index]} ($count)',
                    style: GoogleFonts.poppins(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* SEARCH + SORT                                                             */
/* -------------------------------------------------------------------------- */

class _SearchAndSortRow extends GetView<DealsController> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: controller.setSearchQuery,
            style: GoogleFonts.poppins(fontSize: 11.sp),
            decoration: InputDecoration(
              hintText: 'Search deals...',
              prefixIcon: Icon(Iconsax.search_normal, size: 18.sp),
              filled: true,
              fillColor: Colors.white,
              contentPadding: EdgeInsets.symmetric(vertical: 12.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        PopupMenuButton<String>(
          onSelected: controller.setSort,
          itemBuilder: (_) => const [
            PopupMenuItem(value: 'discount', child: Text('Biggest Discount')),
            PopupMenuItem(value: 'newest', child: Text('Newest')),
            PopupMenuItem(
              value: 'price_low',
              child: Text('Price: Low to High'),
            ),
            PopupMenuItem(
              value: 'price_high',
              child: Text('Price: High to Low'),
            ),
            PopupMenuItem(value: 'rating', child: Text('Highest Rated')),
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
        ),
        SizedBox(width: 4.w),
      ],
    );
  }
}

/* -------------------------------------------------------------------------- */
/* EMPTY / ERROR / SKELETON                                                  */
/* -------------------------------------------------------------------------- */

class _EmptyDealsState extends StatelessWidget {
  const _EmptyDealsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.discount_shape, size: 52.sp, color: Colors.grey.shade400),
            SizedBox(height: 12.h),
            Text(
              'No deals match this filter',
              style: GoogleFonts.poppins(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 5.h),
            Text(
              'Try a lower discount tier or clear your search.',
              textAlign: TextAlign.center,
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
          'Unable to load deals.\n$message',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(fontSize: 11.sp, color: Colors.grey.shade600),
        ),
      ),
    );
  }
}

class _DealsSkeleton extends StatelessWidget {
  const _DealsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(18.w, 14.h, 18.w, 0),
          child: CustomerSkeleton.shimmer(
            child: CustomerSkeleton.block(height: 200.h, radius: 22.r),
          ),
        ),
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Row(
            children: List.generate(
              4,
              (index) => Padding(
                padding: EdgeInsets.only(right: 8.w),
                child: CustomerSkeleton.shimmer(
                  child: CustomerSkeleton.block(
                    width: 90.w,
                    height: 34.h,
                    radius: 20.r,
                  ),
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: 20.h),
        const ProductGridSkeleton(itemCount: 6),
      ],
    );
  }
}
