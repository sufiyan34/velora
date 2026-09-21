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

class SubcategoryScreen extends GetView<CustomerCategoryController> {
  const SubcategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final category = Get.arguments as CategoryModel?;

    if (category == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Subcategories')),
        body: const Center(child: Text('Category not found.')),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FA),
      appBar: AppBar(
        title: Text(
          category.name,
          style: GoogleFonts.poppins(
            fontSize: 19.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Obx(() {
        // Was missing before: with no loading check, a category that is
        // still fetching its subcategories looked identical to one that
        // genuinely has none, and briefly flashed the empty state.
        if (controller.isLoading.value) {
          return const CategoryGridSkeleton();
        }

        final items = controller.subcategoriesOf(category.id);

        if (items.isEmpty) {
          return _NoSubcategories(
            categoryName: category.name,
            onViewProducts: () {
              Get.toNamed(
                AppRoutes.customerproducts,
                arguments: {
                  'category': category,
                  'categoryId': category.id,
                },
              );
            },
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final columns = width >= 1400
                ? 6
                : width >= 1050
                    ? 5
                    : width >= 760
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
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final subcategory = items[index];
                    return _SubcategoryTile(
                      category: subcategory,
                      onTap: () {
                        Get.toNamed(
                          AppRoutes.customerproducts,
                          arguments: {
                            'category': subcategory,
                            'categoryId': subcategory.id,
                          },
                        );
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

class _SubcategoryTile extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onTap;

  const _SubcategoryTile({required this.category, required this.onTap});

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
                              Iconsax.category,
                              size: 34.sp,
                              color: Colors.grey.shade600,
                            ),
                          )
                        : CachedNetworkImage(
                            imageUrl: category.image,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => Container(
                              color: const Color(0xFFF1F2F7),
                              alignment: Alignment.center,
                              child: Icon(
                                Iconsax.category,
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
                'View products',
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

class _NoSubcategories extends StatelessWidget {
  final String categoryName;
  final VoidCallback onViewProducts;

  const _NoSubcategories({
    required this.categoryName,
    required this.onViewProducts,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.shopping_bag,
              size: 52.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 12.h),
            Text(
              '$categoryName products',
              style: GoogleFonts.poppins(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'This category has no subcategories yet.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                color: Colors.grey.shade500,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton.icon(
              onPressed: onViewProducts,
              icon: Icon(Iconsax.shopping_bag, size: 16.sp),
              label: const Text('View Products'),
            ),
          ],
        ),
      ),
    );
  }
}
