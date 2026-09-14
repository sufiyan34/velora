import 'package:e_commerce/constants/app_routes.dart';
import 'package:e_commerce/controllers/cart_controller.dart';
import 'package:e_commerce/controllers/home_controller.dart';
import 'package:e_commerce/controllers/wishlist_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax/iconsax.dart';

import '../../../models/category_model.dart';
import '../../../models/product_model.dart';

class HomeScreen extends GetView<HomeController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;

            return CustomScrollView(
              shrinkWrap: true,
              slivers: [
                SliverToBoxAdapter(
                  child: isDesktop
                      ? const _DesktopHeader()
                      : const _MobileHeader(),
                ),

                SliverToBoxAdapter(child: _SearchBar()),
                SliverToBoxAdapter(
                  child: Obx(() {
                    if (controller.searchQuery.value.isEmpty) {
                      return const SizedBox.shrink();
                    }

                    return _SearchResults();
                  }),
                ),
                SliverToBoxAdapter(child: _HeroBanner()),

                SliverToBoxAdapter(child: _CategorySection()),

                SliverToBoxAdapter(
                  child: _ProductSection(
                    title: 'Featured Products',
                    subtitle: 'Handpicked products just for you',
                    products: controller.featuredProducts,
                  ),
                ),

                SliverToBoxAdapter(child: _PromoBanner()),

                SliverToBoxAdapter(
                  child: _ProductSection(
                    title: 'New Arrivals',
                    subtitle: 'Fresh products added recently',
                    products: controller.newArrivals,
                  ),
                ),

                SliverToBoxAdapter(
                  child: _ProductSection(
                    title: 'On Sale',
                    subtitle: 'Grab your favorites at better prices',
                    products: controller.saleProducts,
                  ),
                ),

                SliverToBoxAdapter(child: SizedBox(height: 100.h)),
              ],
            );
          },
        ),
      ),

      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (MediaQuery.of(context).size.width >= 900) {
            return const SizedBox.shrink();
          }

          return const _MobileBottomNavigation();
        },
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* DESKTOP HEADER                                                            */
/* -------------------------------------------------------------------------- */

class _DesktopHeader extends StatelessWidget {
  const _DesktopHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 18.h),
      color: Colors.white,
      child: Row(
        children: [
          Text(
            'VELORA',
            style: GoogleFonts.poppins(
              fontSize: 27.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),

          SizedBox(width: 55.w),

          _HeaderItem(
            title: 'Home',
            selected: true,
            onTap: () {
              Get.toNamed(AppRoutes.home);
            },
          ),

          _HeaderItem(title: 'Categories', onTap: () {}),

          _HeaderItem(title: 'Shop', onTap: () {}),

          _HeaderItem(title: 'Deals', onTap: () {}),

          const Spacer(),

          _HeaderIcon(
            icon: Iconsax.heart,
            onTap: () {
              Get.toNamed(AppRoutes.wishlistScreen);
            },
          ),

          SizedBox(width: 12.w),

          _HeaderIcon(
            icon: Iconsax.shopping_cart,
            onTap: () {
              Get.toNamed(AppRoutes.cart);
            },
          ),

          SizedBox(width: 12.w),

          _HeaderIcon(icon: Iconsax.user, onTap: () {}),
        ],
      ),
    );
  }
}

class _HeaderItem extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _HeaderItem({
    required this.title,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: InkWell(
        onTap: onTap,
        child: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 14.sp,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.black : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(50),
      onTap: onTap,
      child: Container(
        width: 42.w,
        height: 42.w,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20.sp),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* MOBILE HEADER                                                             */
/* -------------------------------------------------------------------------- */

class _MobileHeader extends StatelessWidget {
  const _MobileHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 15.h, 18.w, 10.h),
      child: Row(
        children: [
          Text(
            'VELORA',
            style: GoogleFonts.poppins(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),

          const Spacer(),

          IconButton(
            onPressed: () {},
            icon: Icon(Iconsax.notification, size: 23.sp),
          ),

          IconButton(
            onPressed: () {},
            icon: Icon(Iconsax.shopping_cart, size: 23.sp),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* SEARCH                                                                    */
/* -------------------------------------------------------------------------- */

class _SearchBar extends GetView<HomeController> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 8.h, 18.w, 18.h),
      child: Container(
        height: 52.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: TextField(
          onChanged: controller.setSearchQuery,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: GoogleFonts.poppins(
              fontSize: 13.sp,
              color: Colors.grey.shade500,
            ),
            prefixIcon: Icon(Iconsax.search_normal, size: 20.sp),
            suffixIcon: Obx(() {
              if (controller.searchQuery.value.isEmpty) {
                return Icon(Iconsax.setting_4, size: 20.sp);
              }

              return IconButton(
                onPressed: controller.clearSearch,
                icon: Icon(Iconsax.close_circle, size: 20.sp),
              );
            }),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15.h),
          ),
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* HERO BANNER                                                               */
/* -------------------------------------------------------------------------- */

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Container(
        height: 230.h,
        width: double.infinity,
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
              right: -30.w,
              top: -30.h,
              child: Container(
                width: 180.w,
                height: 180.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(.07),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(25.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'NEW COLLECTION',
                    style: GoogleFonts.poppins(
                      color: Colors.white70,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  Text(
                    'Discover Your\nPerfect Style',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 25.sp,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      padding: EdgeInsets.symmetric(
                        horizontal: 18.w,
                        vertical: 10.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      'Shop Now',
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* CATEGORIES                                                                */
/* -------------------------------------------------------------------------- */

class _CategorySection extends GetView<HomeController> {
  const _CategorySection();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.categories.isEmpty) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: EdgeInsets.only(top: 28.h),
        child: Column(
          children: [
            _SectionHeader(title: 'Categories', onTap: () {}),

            SizedBox(height: 14.h),

            SizedBox(
              height: 115.h,
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                scrollDirection: Axis.horizontal,
                itemCount: controller.categories.length,
                separatorBuilder: (_, __) => SizedBox(width: 14.w),
                itemBuilder: (context, index) {
                  return _CategoryCard(category: controller.categories[index]);
                },
              ),
            ),
          ],
        ),
      );
    });
  }
}

class _CategoryCard extends StatelessWidget {
  final CategoryModel category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90.w,
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16.r),
        child: Column(
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: category.image.isEmpty
                  ? Icon(
                      Iconsax.category,
                      size: 28.sp,
                      color: Colors.grey.shade600,
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16.r),
                      child: CachedNetworkImage(
                        imageUrl: category.image,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) =>
                            Icon(Iconsax.category, size: 28.sp),
                      ),
                    ),
            ),

            SizedBox(height: 7.h),

            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* PRODUCT SECTION                                                           */
/* -------------------------------------------------------------------------- */

class _ProductSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<ProductModel> products;

  const _ProductSection({
    required this.title,
    required this.subtitle,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: EdgeInsets.only(top: 30.h),
      child: Column(
        children: [
          _SectionHeader(title: title, subtitle: subtitle, onTap: () {}),

          SizedBox(height: 15.h),

          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              int columns;

              if (width >= 1300) {
                columns = 5;
              } else if (width >= 900) {
                columns = 4;
              } else if (width >= 600) {
                columns = 3;
              } else {
                columns = 2;
              }

              final horizontalPadding = 18.w;
              final spacing = 12.w;

              final cardWidth =
                  (width - horizontalPadding * 2 - spacing * (columns - 1)) /
                  columns;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Wrap(
                  spacing: spacing,
                  runSpacing: 18.h,
                  children: products.map((product) {
                    return SizedBox(
                      width: cardWidth,
                      child: _ProductCard(product: product),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* PRODUCT CARD                                                              */
/* -------------------------------------------------------------------------- */

class _ProductCard extends StatelessWidget {
  final ProductModel product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
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
                  // ---------------------------------------------------------
                  // PRODUCT IMAGE
                  // ---------------------------------------------------------
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

                  // ---------------------------------------------------------
                  // DISCOUNT BADGE
                  // ---------------------------------------------------------
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

                  // ---------------------------------------------------------
                  // WISHLIST BUTTON
                  // ---------------------------------------------------------
                  Positioned(
                    top: 7.h,
                    right: 7.w,
                    child: Obx(() {
                      final wishlistController = Get.find<WishlistController>();

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
                            color: Colors.white.withOpacity(.92),
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

                  // ---------------------------------------------------------
                  // CART INDICATOR
                  // Shows only when product is already in cart
                  // ---------------------------------------------------------
                  Positioned(
                    bottom: 9.h,
                    right: 9.w,
                    child: Obx(() {
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
                              color: Colors.black.withOpacity(.18),
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

            // ---------------------------------------------------------------
            // PRODUCT INFORMATION
            // ---------------------------------------------------------------
            Padding(
              padding: EdgeInsets.all(11.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand / Category
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

                  // Product Name
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

                  // Rating
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

                  // Price
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

                  // ---------------------------------------------------------
                  // ADD / REMOVE CART BUTTON
                  // ---------------------------------------------------------
                  Obx(() {
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
                                        (item) => item.productId == product.id,
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
                          foregroundColor: isInCart ? Colors.red : Colors.white,
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

/* -------------------------------------------------------------------------- */
/* SECTION HEADER                                                            */
/* -------------------------------------------------------------------------- */

class _SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _SectionHeader({
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),

          TextButton(
            onPressed: onTap,
            child: Text(
              'View All',
              style: GoogleFonts.poppins(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* PROMO BANNER                                                              */
/* -------------------------------------------------------------------------- */

class _PromoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 30.h, 18.w, 0),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SPECIAL OFFER',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                    ),
                  ),

                  SizedBox(height: 5.h),

                  Text(
                    'Up to 40% OFF',
                    style: GoogleFonts.poppins(
                      fontSize: 21.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  SizedBox(height: 3.h),

                  Text(
                    'Limited time deals on selected products.',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            Icon(Iconsax.discount_shape, size: 55.sp),
          ],
        ),
      ),
    );
  }
}

/* -------------------------------------------------------------------------- */
/* MOBILE BOTTOM NAVIGATION                                                  */
/* -------------------------------------------------------------------------- */

class _MobileBottomNavigation extends StatelessWidget {
  const _MobileBottomNavigation();

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      elevation: 10,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: GoogleFonts.poppins(
        fontSize: 10.sp,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: GoogleFonts.poppins(fontSize: 10.sp),
      onTap: (index) {},
      items: const [
        BottomNavigationBarItem(icon: Icon(Iconsax.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.category),
          label: 'Categories',
        ),
        BottomNavigationBarItem(icon: Icon(Iconsax.heart), label: 'Wishlist'),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.shopping_cart),
          label: 'Cart',
        ),
        BottomNavigationBarItem(icon: Icon(Iconsax.user), label: 'Profile'),
      ],
    );
  }
}

class _SearchResults extends GetView<HomeController> {
  const _SearchResults();

  @override
  Widget build(BuildContext context) {
    final results = controller.searchResults;

    return Padding(
      padding: EdgeInsets.only(top: 5.h, bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: Text(
              '${results.length} products found',
              style: GoogleFonts.poppins(
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          SizedBox(height: 15.h),

          if (results.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 30.h),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Iconsax.search_status,
                      size: 45.sp,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'No products found',
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Try another search term',
                      style: GoogleFonts.poppins(
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;

                int columns;

                if (width >= 1300) {
                  columns = 5;
                } else if (width >= 900) {
                  columns = 4;
                } else if (width >= 600) {
                  columns = 3;
                } else {
                  columns = 2;
                }

                final horizontalPadding = 18.w;
                final spacing = 12.w;

                final cardWidth =
                    (width - horizontalPadding * 2 - spacing * (columns - 1)) /
                    columns;

                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Wrap(
                    spacing: spacing,
                    runSpacing: 18.h,
                    children: results.map((product) {
                      return SizedBox(
                        width: cardWidth,
                        child: _ProductCard(product: product),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
