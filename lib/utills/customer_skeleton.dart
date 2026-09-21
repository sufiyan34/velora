import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer wrapper + building blocks shared by every customer-facing
/// loading state, so Home, Categories, Subcategory and Product Listing all
/// shimmer the same way instead of each screen inventing its own grey box.
class CustomerSkeleton {
  CustomerSkeleton._();

  static Widget shimmer({required Widget child}) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE9E9EC),
      highlightColor: const Color(0xFFF6F6F8),
      period: const Duration(milliseconds: 1300),
      child: child,
    );
  }

  static Widget block({
    double? width,
    double height = 14,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  static Widget circle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
    );
  }
}

/// One shimmering product card — same footprint as the real product card
/// used on Home / Product Listing (image + brand + name + price rows).
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomerSkeleton.shimmer(
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
              child: Container(color: Colors.white),
            ),
            Padding(
              padding: EdgeInsets.all(11.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomerSkeleton.block(width: 50.w, height: 8.h),
                  SizedBox(height: 6.h),
                  CustomerSkeleton.block(height: 11.h),
                  SizedBox(height: 5.h),
                  CustomerSkeleton.block(width: 70.w, height: 8.h),
                  SizedBox(height: 8.h),
                  CustomerSkeleton.block(width: 60.w, height: 12.h),
                  SizedBox(height: 10.h),
                  CustomerSkeleton.block(height: 32.h, radius: 9.r),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A responsive grid of [ProductCardSkeleton]s — used by Home's product
/// sections and the Product Listing screen while data is loading.
class ProductGridSkeleton extends StatelessWidget {
  const ProductGridSkeleton({
    super.key,
    this.itemCount = 6,
    this.padding,
  });

  final int itemCount;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        int columns;
        if (width >= 1500) {
          columns = 5;
        } else if (width >= 1150) {
          columns = 4;
        } else if (width >= 700) {
          columns = 3;
        } else {
          columns = 2;
        }

        return GridView.builder(
          padding: padding ?? EdgeInsets.all(18.w),
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 18.h,
            childAspectRatio: width < 520 ? 0.66 : 0.72,
          ),
          itemBuilder: (_, __) => const ProductCardSkeleton(),
        );
      },
    );
  }
}

/// One shimmering category/subcategory tile — same footprint as the real
/// tile on the Categories and Subcategory screens.
class CategoryTileSkeleton extends StatelessWidget {
  const CategoryTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomerSkeleton.shimmer(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
        ),
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14.r),
                child: Container(color: const Color(0xFFF1F2F7)),
              ),
            ),
            SizedBox(height: 10.h),
            CustomerSkeleton.block(width: 80.w, height: 12.h),
            SizedBox(height: 6.h),
            CustomerSkeleton.block(width: 60.w, height: 9.h),
          ],
        ),
      ),
    );
  }
}

/// A responsive grid of [CategoryTileSkeleton]s — used by the Categories
/// and Subcategory screens while their data is loading.
class CategoryGridSkeleton extends StatelessWidget {
  const CategoryGridSkeleton({super.key, this.itemCount = 8});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1400
            ? 6
            : width >= 1100
                ? 5
                : width >= 800
                    ? 4
                    : width >= 520
                        ? 3
                        : 2;

        return GridView.builder(
          padding: EdgeInsets.all(width >= 900 ? 30.w : 18.w),
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: width >= 900 ? 18.w : 12.w,
            mainAxisSpacing: width >= 900 ? 18.h : 12.h,
            childAspectRatio: width < 520 ? 0.92 : 1.0,
          ),
          itemBuilder: (_, __) => const CategoryTileSkeleton(),
        );
      },
    );
  }
}

/// Circle + label pair matching the Home screen's horizontal category
/// strip.
class _HomeCategoryPillSkeleton extends StatelessWidget {
  const _HomeCategoryPillSkeleton();

  @override
  Widget build(BuildContext context) {
    return CustomerSkeleton.shimmer(
      child: SizedBox(
        width: 90.w,
        child: Column(
          children: [
            CustomerSkeleton.circle(72.w),
            SizedBox(height: 7.h),
            CustomerSkeleton.block(width: 55.w, height: 9.h),
          ],
        ),
      ),
    );
  }
}

/// Full-page skeleton for the Home screen's very first load (no cached and
/// no live data yet). Mirrors the real layout section-for-section — header,
/// search bar, hero banner, category strip, two product sections — so
/// there's no visible layout jump once real content streams in.
class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        // Header
        Padding(
          padding: EdgeInsets.fromLTRB(18.w, 15.h, 18.w, 10.h),
          child: Row(
            children: [
              CustomerSkeleton.shimmer(
                child: CustomerSkeleton.block(width: 110.w, height: 22.h),
              ),
              const Spacer(),
              CustomerSkeleton.shimmer(child: CustomerSkeleton.circle(26.w)),
              SizedBox(width: 14.w),
              CustomerSkeleton.shimmer(child: CustomerSkeleton.circle(26.w)),
            ],
          ),
        ),

        // Search bar
        Padding(
          padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 18.h),
          child: CustomerSkeleton.shimmer(
            child: CustomerSkeleton.block(height: 52.h, radius: 14.r),
          ),
        ),

        // Hero banner
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: CustomerSkeleton.shimmer(
            child: CustomerSkeleton.block(height: 230.h, radius: 22.r),
          ),
        ),

        // Category strip
        Padding(
          padding: EdgeInsets.fromLTRB(18.w, 28.h, 18.w, 0),
          child: CustomerSkeleton.shimmer(
            child: CustomerSkeleton.block(width: 120.w, height: 19.h),
          ),
        ),
        SizedBox(height: 14.h),
        SizedBox(
          height: 115.h,
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            scrollDirection: Axis.horizontal,
            itemCount: 6,
            separatorBuilder: (_, __) => SizedBox(width: 14.w),
            itemBuilder: (_, __) => const _HomeCategoryPillSkeleton(),
          ),
        ),

        // Product section
        Padding(
          padding: EdgeInsets.fromLTRB(18.w, 30.h, 18.w, 0),
          child: CustomerSkeleton.shimmer(
            child: CustomerSkeleton.block(width: 160.w, height: 19.h),
          ),
        ),
        SizedBox(height: 15.h),
        ProductGridSkeleton(
          itemCount: 4,
          padding: EdgeInsets.symmetric(horizontal: 18.w),
        ),

        SizedBox(height: 100.h),
      ],
    );
  }
}
