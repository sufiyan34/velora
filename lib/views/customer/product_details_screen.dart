import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constants/app_routes.dart';
import '../../controllers/cart_controller.dart';
import '../../controllers/wishlist_controller.dart';
import '../../models/product_model.dart';

class ProductDetailsScreen extends StatefulWidget {
  const ProductDetailsScreen({super.key});

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  late final ProductModel product;

  final PageController _imageController = PageController();
  int _selectedImage = 0;
  ProductVariation? _selectedVariation;
  int _quantity = 1;

  CartController get _cartController => Get.find<CartController>();
  WishlistController get _wishlistController => Get.find<WishlistController>();

  @override
  void initState() {
    super.initState();
    final argument = Get.arguments;
    if (argument is! ProductModel) {
      throw ArgumentError(
        'ProductDetailsScreen requires a ProductModel in Get.arguments.',
      );
    }
    product = argument;
  }

  @override
  void dispose() {
    _imageController.dispose();
    super.dispose();
  }

  double get _variationPrice => _selectedVariation?.additionalPrice ?? 0;

  double get _currentPrice => product.finalPrice + _variationPrice;

  double get _currentOriginalPrice => product.price + _variationPrice;

  int get _currentStock => _selectedVariation?.stock ?? product.stock;

  bool get _hasVariants => product.variations.isNotEmpty;

  List<ProductVariation> get _uniqueVariationValues {
    final seen = <String>{};
    return product.variations.where((variation) {
      final key = '${variation.name}|${variation.value}';
      return seen.add(key);
    }).toList();
  }

  Map<String, List<ProductVariation>> get _variationGroups {
    final groups = <String, List<ProductVariation>>{};
    for (final variation in product.variations) {
      groups.putIfAbsent(variation.name, () => []).add(variation);
    }
    return groups;
  }

  Future<void> _openVideo() async {
    final raw = product.videoUrl;
    if (raw == null || raw.trim().isEmpty) return;

    final uri = Uri.tryParse(raw);
    if (uri == null) {
      Get.snackbar('Video Error', 'The product video link is invalid.');
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched) {
      Get.snackbar('Video Error', 'Unable to open the product video.');
    }
  }

  Future<void> _addToCart({bool buyNow = false}) async {
    if (_currentStock <= 0) {
      Get.snackbar('Out of Stock', 'This product is currently unavailable.');
      return;
    }

    if (_hasVariants && _selectedVariation == null) {
      Get.snackbar(
        'Choose an option',
        'Please select a product variation first.',
      );
      return;
    }

    await _cartController.addToCart(
      product,
      quantity: _quantity,
      variation: _selectedVariation,
    );

    if (buyNow) {
      Get.toNamed(AppRoutes.cart);
    }
  }

  void _changeQuantity(int delta) {
    final next = _quantity + delta;
    if (next < 1) return;
    if (_currentStock > 0 && next > _currentStock) {
      Get.snackbar('Stock Limit', 'Only $_currentStock item(s) are available.');
      return;
    }
    setState(() => _quantity = next);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: Text(
          'Product Details',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
        actions: [
          Obx(() {
            final favorite = _wishlistController.isInWishlist(product.id);
            return IconButton(
              tooltip: 'Wishlist',
              onPressed: () => _wishlistController.toggleWishlist(product),
              icon: Icon(
                favorite ? Iconsax.heart5 : Iconsax.heart,
                color: favorite ? Colors.red : Colors.black87,
              ),
            );
          }),
          IconButton(
            tooltip: 'Cart',
            onPressed: () => Get.toNamed(AppRoutes.cart),
            icon: const Icon(Iconsax.shopping_cart),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 900;
          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: desktop ? 42.w : 16.w,
              vertical: 22.h,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1320),
                child: desktop ? _desktopLayout() : _mobileLayout(),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 900) return const SizedBox.shrink();
          return _mobileBottomBar();
        },
      ),
    );
  }

  Widget _desktopLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _breadcrumb(),
        SizedBox(height: 18.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: _mediaPanel()),
            SizedBox(width: 34.w),
            Expanded(flex: 5, child: _detailsPanel()),
          ],
        ),
        SizedBox(height: 36.h),
        _descriptionSection(),
        if (product.variations.isNotEmpty) ...[
          SizedBox(height: 24.h),
          _specificationSection(),
        ],
      ],
    );
  }

  Widget _mobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _breadcrumb(),
        SizedBox(height: 12.h),
        _mediaPanel(),
        SizedBox(height: 22.h),
        _detailsPanel(),
        SizedBox(height: 28.h),
        _descriptionSection(),
        SizedBox(height: 20.h),
        _specificationSection(),
        SizedBox(height: 95.h),
      ],
    );
  }

  Widget _breadcrumb() {
    return Row(
      children: [
        Text(
          'Home',
          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
        ),
        Icon(Icons.chevron_right, size: 16.sp, color: Colors.grey.shade400),
        Text(
          product.categoryName.isEmpty ? 'Shop' : product.categoryName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
        ),
        Icon(Icons.chevron_right, size: 16.sp, color: Colors.grey.shade400),
        Expanded(
          child: Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _mediaPanel() {
    final hasImages = product.images.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22.r),
      ),
      padding: EdgeInsets.all(12.w),
      child: Column(
        children: [
          _imageGallery(hasImages),
          if (product.hasVideo) ...[
            SizedBox(height: 12.h),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _openVideo,
                icon: const Icon(Iconsax.video_play, size: 17),
                label: const Text('Watch product video'),
              ),
            ),
          ],
          if (product.has3dModel) ...[
            SizedBox(height: 20.h),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Interactive 3D',
                style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800),
              ),
            ),
            SizedBox(height: 12.h),
            _build3DViewer(product),
          ],
        ],
      ),
    );
  }

  Widget _imageGallery(bool hasImages) {
    final imageCount = product.images.length;
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.r),
            child: hasImages
                ? PageView.builder(
                    controller: _imageController,
                    itemCount: imageCount,
                    onPageChanged: (index) =>
                        setState(() => _selectedImage = index),
                    itemBuilder: (_, index) {
                      return Hero(
                        tag: 'product-${product.id}-$index',
                        child: CachedNetworkImage(
                          imageUrl: product.images[index],
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: Colors.grey.shade100,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: Colors.grey.shade100,
                            child: Icon(
                              Iconsax.image,
                              size: 42.sp,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    color: Colors.grey.shade100,
                    child: Icon(
                      Iconsax.image,
                      size: 52.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
          ),
        ),
        if (imageCount > 1) ...[
          SizedBox(height: 12.h),
          SizedBox(
            height: 74.w,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: imageCount,
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (_, index) {
                final active = _selectedImage == index;
                return InkWell(
                  onTap: () {
                    setState(() => _selectedImage = index);
                    _imageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 260),
                      curve: Curves.easeOut,
                    );
                  },
                  borderRadius: BorderRadius.circular(10.r),
                  child: Container(
                    width: 74.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: active ? Colors.black : Colors.grey.shade200,
                        width: active ? 2 : 1,
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: CachedNetworkImage(
                      imageUrl: product.images[index],
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Icon(Iconsax.image),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _build3DViewer(ProductModel product) {
    if (!product.has3dModel) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 420.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: ModelViewer(
        src: product.model3dUrl!,
        iosSrc: product.model3dIosUrl,
        alt: '3D model of ${product.name}',
        ar: product.model3dArEnabled,
        arModes: const ['scene-viewer', 'webxr', 'quick-look'],
        autoRotate: product.model3dAutoRotate,
        cameraControls: true,
        disableZoom: false,
      ),
    );
  }

  Widget _detailsPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.brand.isNotEmpty)
          Text(
            product.brand.toUpperCase(),
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.3,
            ),
          ),
        SizedBox(height: 8.h),
        Text(
          product.name,
          style: TextStyle(
            fontSize: 28.sp,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
        SizedBox(height: 12.h),
        _ratingRow(),
        SizedBox(height: 18.h),
        _priceBlock(),
        SizedBox(height: 16.h),
        _stockBadge(),
        if (_hasVariants) ...[SizedBox(height: 22.h), _variationSelector()],
        SizedBox(height: 22.h),
        _quantitySelector(),
        SizedBox(height: 18.h),
        _desktopActions(),
        SizedBox(height: 20.h),
        _featureStrip(),
      ],
    );
  }

  Widget _ratingRow() {
    return Row(
      children: [
        ...List.generate(5, (index) {
          final filled = index + 1 <= product.rating.round();
          return Icon(
            Icons.star_rounded,
            size: 18.sp,
            color: filled ? Colors.amber : Colors.grey.shade300,
          );
        }),
        SizedBox(width: 7.w),
        Text(
          '${product.rating.toStringAsFixed(1)} · ${product.reviewCount} reviews',
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _priceBlock() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'Rs. ${_currentPrice.toStringAsFixed(0)}',
          style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.w800),
        ),
        if (product.hasDiscount ||
            _selectedVariation?.additionalPrice != null) ...[
          SizedBox(width: 10.w),
          Text(
            'Rs. ${_currentOriginalPrice.toStringAsFixed(0)}',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ],
        if (product.hasDiscount) ...[
          SizedBox(width: 10.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(7.r),
            ),
            child: Text(
              '${product.discountPercentage.toStringAsFixed(0)}% OFF',
              style: TextStyle(
                color: Colors.white,
                fontSize: 9.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _stockBadge() {
    final stock = _currentStock;
    final out = stock <= 0;
    final low = !out && stock <= 5;
    final text = out
        ? 'Out of stock'
        : low
        ? 'Only $stock left'
        : 'In stock';

    return Row(
      children: [
        Icon(
          out ? Iconsax.close_circle : Iconsax.tick_circle,
          size: 17.sp,
          color: out
              ? Colors.red
              : low
              ? Colors.orange
              : Colors.green,
        ),
        SizedBox(width: 6.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: out
                ? Colors.red
                : low
                ? Colors.orange
                : Colors.green,
          ),
        ),
      ],
    );
  }

  Widget _variationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _variationGroups.entries.map((entry) {
        final title = entry.key;
        final values = entry.value;
        return Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: values.map((variation) {
                  final selected = _selectedVariation?.id == variation.id;
                  final disabled = variation.stock <= 0;
                  return ChoiceChip(
                    label: Text(
                      variation.value,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: disabled
                            ? Colors.grey.shade400
                            : selected
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    selected: selected,
                    onSelected: disabled
                        ? null
                        : (_) {
                            setState(() {
                              _selectedVariation = variation;
                              _quantity = 1;
                            });
                          },
                    selectedColor: Colors.black,
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: selected ? Colors.black : Colors.grey.shade300,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9.r),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _quantitySelector() {
    return Row(
      children: [
        Text(
          'Quantity',
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(width: 14.w),
        Container(
          height: 42.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(11.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: _quantity <= 1 ? null : () => _changeQuantity(-1),
                icon: const Icon(Icons.remove_rounded, size: 17),
              ),
              Text(
                '$_quantity',
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
              ),
              IconButton(
                onPressed: _currentStock <= _quantity
                    ? null
                    : () => _changeQuantity(1),
                icon: const Icon(Icons.add_rounded, size: 17),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _desktopActions() {
    final disabled =
        product.isOutOfStock || (_hasVariants && _selectedVariation == null);
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50.h,
            child: ElevatedButton.icon(
              onPressed: disabled ? null : () => _addToCart(),
              icon: const Icon(Iconsax.shopping_cart, size: 18),
              label: const Text('Add to Cart'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.r),
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: SizedBox(
            height: 50.h,
            child: OutlinedButton(
              onPressed: disabled ? null : () => _addToCart(buyNow: true),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13.r),
                ),
              ),
              child: const Text('Buy Now'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _mobileBottomBar() {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .08),
              blurRadius: 14,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46.h,
                child: ElevatedButton(
                  onPressed:
                      product.isOutOfStock ||
                          (_hasVariants && _selectedVariation == null)
                      ? null
                      : () => _addToCart(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: const Text('Add to Cart'),
                ),
              ),
            ),
            SizedBox(width: 10.w),
            SizedBox(
              width: 116.w,
              height: 46.h,
              child: OutlinedButton(
                onPressed:
                    product.isOutOfStock ||
                        (_hasVariants && _selectedVariation == null)
                    ? null
                    : () => _addToCart(buyNow: true),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black,
                  side: const BorderSide(color: Colors.black),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: const Text('Buy Now'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _featureStrip() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _feature(Iconsax.truck_fast, 'Fast delivery')),
          Expanded(child: _feature(Iconsax.shield_tick, 'Secure checkout')),
          Expanded(child: _feature(Iconsax.refresh, 'Easy returns')),
        ],
      ),
    );
  }

  Widget _feature(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.grey.shade700),
        SizedBox(width: 7.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _descriptionSection() {
    final description = product.description.trim();
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Description',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 10.h),
          Text(
            description.isEmpty
                ? 'No description available for this product yet.'
                : description,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade700,
              height: 1.65,
            ),
          ),
        ],
      ),
    );
  }

  Widget _specificationSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Product information',
            style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: 14.h),
          _infoRow('Brand', product.brand.isEmpty ? '—' : product.brand),
          _infoRow(
            'Category',
            product.categoryName.isEmpty ? '—' : product.categoryName,
          ),
          _infoRow('SKU', product.sku.isEmpty ? '—' : product.sku),
          if (product.has3dModel) _infoRow('3D', 'Interactive model available'),
          if (product.hasVideo) _infoRow('Video', 'Product video available'),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 7.h),
      child: Row(
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
