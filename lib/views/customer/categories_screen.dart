import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

import '../../constants/app_routes.dart';
import '../../controllers/customer_category_controller.dart';
import '../../models/category_model.dart';
import '../../utills/customer_skeleton.dart';

class CustomerCategoriesScreen extends GetView<CustomerCategoryController> {
  const CustomerCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      appBar: AppBar(
        title: Text(
          'Categories',
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const CategoryGridSkeleton();
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return _ErrorState(
            message: controller.errorMessage.value,
            onRetry: controller.refresh,
          );
        }

        final categories = controller.topLevelCategories;

        if (categories.isEmpty) {
          return const _EmptyState();
        }

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

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: GridView.builder(
                  padding: EdgeInsets.all(width >= 900 ? 30.w : 18.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: width >= 900 ? 18.w : 12.w,
                    mainAxisSpacing: width >= 900 ? 18.h : 12.h,
                    childAspectRatio: width < 520 ? 0.92 : 1.0,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return _CategoryTile(
                      category: category,
                      subcategoryCount: controller.subcategoryCount(
                        category.id,
                      ),
                      onTap: () {
                        Get.toNamed(AppRoutes.subcategory, arguments: category);
                      },
                    );
                  },
                ),
              ),
            );
          },
        );
      }),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final int subcategoryCount;
  final VoidCallback onTap;

  const _CategoryTile({
    required this.category,
    required this.subcategoryCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: SizedBox(
                    width: double.infinity,
                    child: category.image.trim().isEmpty
                        ? Container(
                            color: const Color(0xFFF1F2F7),
                            alignment: Alignment.center,
                            child: Icon(
                              Iconsax.category_2,
                              size: 34.sp,
                              color: Colors.grey.shade600,
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: category.image,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: const Color(0xFFF1F2F7),
                              alignment: Alignment.center,
                              child: const CircularProgressIndicator.adaptive(
                                strokeWidth: 2,
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: const Color(0xFFF1F2F7),
                              alignment: Alignment.center,
                              child: Icon(
                                Iconsax.category_2,
                                size: 34.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subcategoryCount == 0
                    ? 'Explore products'
                    : '$subcategoryCount subcategories',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 9.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.category_2, size: 52.sp, color: Colors.grey.shade400),
            SizedBox(height: 12.h),
            Text(
              'No categories available',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'Categories will appear here once they are added.',
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
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.warning_2, size: 50.sp, color: Colors.orange),
            SizedBox(height: 12.h),
            Text(
              'Unable to load categories',
              style: GoogleFonts.poppins(
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              message,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: 10.sp,
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
