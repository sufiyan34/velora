import 'package:e_commerce/controllers/cloudinary_media_controller.dart';
import 'package:e_commerce/utills/admin_badge.dart';
import 'package:e_commerce/utills/admin_buttons.dart';
import 'package:e_commerce/utills/right_drawer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/category_controller.dart';
import '../../../../controllers/product_controller.dart';
import '../../../../models/product_model.dart';
import '../../../../theme/admin_theme.dart';
import 'variation_editor.dart';

/// Opens the add/edit product panel, sliding in from the right.
/// On mobile, [showRightDrawer] handles the full-screen presentation.
Future<void> showProductFormDrawer({
  required BuildContext context,
  required ProductController controller,
  ProductModel? product,
}) {
  return showRightDrawer(
    context: context,
    builder: (_) => ProductFormDrawer(controller: controller, product: product),
  );
}

class ProductFormDrawer extends StatefulWidget {
  const ProductFormDrawer({super.key, required this.controller, this.product});

  final ProductController controller;
  final ProductModel? product;

  @override
  State<ProductFormDrawer> createState() => _ProductFormDrawerState();
}

class _ProductFormDrawerState extends State<ProductFormDrawer> {
  late final CategoryController _categoryController;
  late final CloudinaryMediaController _mediaController;

  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _brand;
  late final TextEditingController _price;
  late final TextEditingController _salePrice;
  late final TextEditingController _stock;
  late final TextEditingController _sku;

  String? _categoryId;

  bool _isActive = true;
  bool _isFeatured = false;
  bool _isNew = false;
  bool _isOnSale = false;

  bool _model3dAutoRotate = true;
  bool _model3dArEnabled = false;

  List<ProductVariation> _variations = [];

  // ==========================================================
  // MEDIA
  // ==========================================================

  List<String> _images = [];

  String? _videoUrl;

  String? _model3dUrl;

  String? _model3dIosUrl;

  // ==========================================================
  // FORM STATE
  // ==========================================================

  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();

    _categoryController =
        Get.isRegistered<CategoryController>(tag: 'categories')
        ? Get.find<CategoryController>(tag: 'categories')
        : Get.put(CategoryController(), tag: 'categories');

    _mediaController = Get.find<CloudinaryMediaController>();

    final p = widget.product;

    // ========================================================
    // BASIC FIELDS
    // ========================================================

    _name = TextEditingController(text: p?.name ?? '');

    _description = TextEditingController(text: p?.description ?? '');

    _brand = TextEditingController(text: p?.brand ?? '');

    _price = TextEditingController(
      text: p != null ? p.price.toStringAsFixed(2) : '',
    );

    _salePrice = TextEditingController(
      text: p?.salePrice != null ? p!.salePrice!.toStringAsFixed(2) : '',
    );

    _stock = TextEditingController(text: p != null ? p.stock.toString() : '');

    _sku = TextEditingController(text: p?.sku ?? '');

    // ========================================================
    // FORM VALUES
    // ========================================================

    _categoryId = p?.categoryId;

    _isActive = p?.isActive ?? true;

    _isFeatured = p?.isFeatured ?? false;

    _isNew = p?.isNew ?? false;

    _isOnSale = p?.isOnSale ?? false;

    _variations = List<ProductVariation>.of(p?.variations ?? const []);

    // ========================================================
    // MEDIA
    // ========================================================

    _images = List<String>.of(p?.images ?? const []);

    _videoUrl = p?.videoUrl;

    _model3dUrl = p?.model3dUrl;

    _model3dIosUrl = p?.model3dIosUrl;

    _model3dAutoRotate = p?.model3dAutoRotate ?? true;

    _model3dArEnabled = p?.model3dArEnabled ?? false;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _brand.dispose();
    _price.dispose();
    _salePrice.dispose();
    _stock.dispose();
    _sku.dispose();

    super.dispose();
  }

  // ==========================================================
  // CATEGORY OPTIONS
  // ==========================================================

  List<DropdownMenuItem<String>> _categoryOptions() {
    final items = <DropdownMenuItem<String>>[];

    void walk(List<dynamic> categories, int depth) {
      for (final category in categories) {
        items.add(
          DropdownMenuItem<String>(
            value: category.id as String,
            child: Text('${'—' * depth} ${category.name}'.trim()),
          ),
        );

        walk(_categoryController.childrenOf(category.id), depth + 1);
      }
    }

    walk(_categoryController.topLevel(), 0);

    return items;
  }

  // ==========================================================
  // UPLOAD IMAGES
  // ==========================================================

  Future<void> _uploadImages() async {
    setState(() {
      _error = null;
    });

    try {
      final results = await _mediaController.pickAndUploadImages(maxFiles: 10);

      if (!mounted || results.isEmpty) {
        return;
      }

      final urls = results
          .map((result) => result.secureUrl.trim())
          .where((url) => url.isNotEmpty)
          .toList();

      if (urls.isEmpty) return;

      setState(() {
        _images.addAll(urls);
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = _mediaController.errorMessage.value.isNotEmpty
            ? _mediaController.errorMessage.value
            : 'Unable to upload images.';
      });
    }
  }

  // ==========================================================
  // UPLOAD VIDEO
  // ==========================================================

  Future<void> _uploadVideo() async {
    setState(() {
      _error = null;
    });

    try {
      final result = await _mediaController.pickAndUploadVideo();

      if (!mounted || result == null) {
        return;
      }

      final url = result.secureUrl.trim();

      if (url.isEmpty) {
        throw Exception('Cloudinary returned an empty video URL.');
      }

      setState(() {
        _videoUrl = url;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = _mediaController.errorMessage.value.isNotEmpty
            ? _mediaController.errorMessage.value
            : 'Unable to upload video.';
      });
    }
  }

  // ==========================================================
  // UPLOAD GLB / GLTF
  // ==========================================================

  Future<void> _upload3dModel() async {
    setState(() {
      _error = null;
    });

    try {
      final result = await _mediaController.pickAndUploadGlb();

      if (!mounted || result == null) {
        return;
      }

      final url = result.secureUrl.trim();

      if (url.isEmpty) {
        throw Exception('Cloudinary returned an empty 3D URL.');
      }

      setState(() {
        _model3dUrl = url;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = _mediaController.errorMessage.value.isNotEmpty
            ? _mediaController.errorMessage.value
            : 'Unable to upload 3D model.';
      });
    }
  }

  // ==========================================================
  // UPLOAD USDZ
  // ==========================================================

  Future<void> _uploadUsdZ() async {
    setState(() {
      _error = null;
    });

    try {
      final result = await _mediaController.pickAndUploadUsdZ();

      if (!mounted || result == null) {
        return;
      }

      final url = result.secureUrl.trim();

      if (url.isEmpty) {
        throw Exception('Cloudinary returned an empty USDZ URL.');
      }

      setState(() {
        _model3dIosUrl = url;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _error = _mediaController.errorMessage.value.isNotEmpty
            ? _mediaController.errorMessage.value
            : 'Unable to upload USDZ model.';
      });
    }
  }

  // ==========================================================
  // SAVE
  // ==========================================================

  Future<void> _save() async {
    final name = _name.text.trim();

    final price = double.tryParse(_price.text.trim());

    if (name.isEmpty) {
      setState(() {
        _error = 'Give the product a name first.';
      });
      return;
    }

    if (_categoryId == null || _categoryId!.isEmpty) {
      setState(() {
        _error = 'Choose a category.';
      });
      return;
    }

    if (price == null || price < 0) {
      setState(() {
        _error = 'Enter a valid price.';
      });
      return;
    }

    final salePriceText = _salePrice.text.trim();

    final parsedSalePrice = salePriceText.isEmpty
        ? null
        : double.tryParse(salePriceText);

    if (salePriceText.isNotEmpty &&
        (parsedSalePrice == null || parsedSalePrice < 0)) {
      setState(() {
        _error = 'Enter a valid sale price.';
      });
      return;
    }

    if (parsedSalePrice != null && parsedSalePrice > price) {
      setState(() {
        _error = 'Sale price cannot be greater than the regular price.';
      });
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    final sku = _sku.text.trim().isEmpty
        ? widget.controller.suggestSku()
        : _sku.text.trim();

    final data = ProductModel(
      id: widget.product?.id ?? '',
      name: name,
      description: _description.text.trim(),

      categoryId: _categoryId!,

      categoryName: _categoryController.categoryPath(_categoryId!),

      brand: _brand.text.trim(),

      sku: sku,

      price: price,

      salePrice: parsedSalePrice,

      stock: int.tryParse(_stock.text.trim()) ?? 0,

      soldCount: widget.product?.soldCount ?? 0,

      images: List<String>.of(_images),

      videoUrl: _videoUrl,

      variations: List<ProductVariation>.of(_variations),

      rating: widget.product?.rating ?? 0,

      reviewCount: widget.product?.reviewCount ?? 0,

      isActive: _isActive,

      isFeatured: _isFeatured,

      isNew: _isNew,

      isOnSale: _isOnSale,

      model3dUrl: _model3dUrl,

      model3dIosUrl: _model3dIosUrl,

      model3dAutoRotate: _model3dAutoRotate,

      model3dArEnabled: _model3dArEnabled,

      createdAt: widget.product?.createdAt,

      updatedAt: DateTime.now(),
    );

    try {
      if (_isEditing) {
        await widget.controller.updateProduct(data);
      } else {
        await widget.controller.addProduct(data);
      }

      if (!mounted) return;

      Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _saving = false;
        _error = "Couldn't save this product. Please try again.";
      });
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AdminColors.surface,

      child: Column(
        children: [
          _DrawerHeader(isEditing: _isEditing),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // BASICS
                  // ==================================================

                  const _SectionLabel('Basics'),

                  _Field(
                    label: 'Product name',
                    child: TextField(
                      controller: _name,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Silk Wrap Dress',
                      ),
                    ),
                  ),

                  _Field(
                    label: 'Description',
                    child: TextField(
                      controller: _description,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: 'What makes this product worth buying…',
                      ),
                    ),
                  ),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _Field(
                          label: 'Category',
                          child: DropdownButtonFormField<String>(
                            initialValue: _categoryId,
                            isExpanded: true,
                            items: _categoryOptions(),
                            hint: const Text('Select a category'),
                            onChanged: (value) {
                              setState(() {
                                _categoryId = value;
                              });
                            },
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: _Field(
                          label: 'Brand',
                          child: TextField(
                            controller: _brand,
                            decoration: const InputDecoration(
                              hintText: 'Velora Atelier',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // ==================================================
                  // PRICING
                  // ==================================================
                  const _SectionLabel('Pricing & stock'),

                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          label: 'Price',
                          child: TextField(
                            controller: _price,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(hintText: '0.00'),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _Field(
                          label: 'Sale price',
                          child: TextField(
                            controller: _salePrice,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Optional',
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: _Field(
                          label: 'Stock',
                          child: TextField(
                            controller: _stock,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(hintText: '0'),
                          ),
                        ),
                      ),
                    ],
                  ),

                  _Field(
                    label: 'SKU',
                    child: TextField(
                      controller: _sku,
                      decoration: const InputDecoration(
                        hintText: 'Auto-generated if left blank',
                      ),
                    ),
                  ),

                  // ==================================================
                  // MEDIA
                  // ==================================================
                  const _SectionLabel('Media'),

                  Obx(
                    () => _MediaSection(
                      isUploading: _mediaController.isUploading.value,
                      progress: _mediaController.progress.value,
                      currentFileName: _mediaController.currentFileName.value,
                      images: _images,
                      videoUrl: _videoUrl,
                      onUploadImages: _uploadImages,
                      onUploadVideo: _uploadVideo,
                      onRemoveImage: (image) {
                        setState(() {
                          _images.remove(image);
                        });
                      },
                      onRemoveVideo: () {
                        setState(() {
                          _videoUrl = null;
                        });
                      },
                    ),
                  ),

                  // ==================================================
                  // VARIATIONS
                  // ==================================================
                  const _SectionLabel('Variations'),

                  VariationEditor(
                    initial: _variations,
                    onChanged: (value) {
                      _variations = value;
                    },
                  ),

                  // ==================================================
                  // 3D
                  // ==================================================
                  const _SectionLabel('3D Product'),

                  Obx(
                    () => _ThreeDSection(
                      isUploading: _mediaController.isUploading.value,
                      model3dUrl: _model3dUrl,
                      model3dIosUrl: _model3dIosUrl,
                      onUploadModel: _upload3dModel,
                      onUploadUsdZ: _uploadUsdZ,
                      onRemoveModel: () {
                        setState(() {
                          _model3dUrl = null;
                        });
                      },
                      onRemoveUsdZ: () {
                        setState(() {
                          _model3dIosUrl = null;
                        });
                      },
                    ),
                  ),

                  _ToggleRow(
                    label: '3D auto rotate',
                    description: 'Automatically rotate the 3D product',
                    value: _model3dAutoRotate,
                    onChanged: (value) {
                      setState(() {
                        _model3dAutoRotate = value;
                      });
                    },
                  ),

                  _ToggleRow(
                    label: '3D AR experience',
                    description: 'Enable AR where the device supports it',
                    value: _model3dArEnabled,
                    onChanged: (value) {
                      setState(() {
                        _model3dArEnabled = value;
                      });
                    },
                  ),

                  // ==================================================
                  // VISIBILITY
                  // ==================================================
                  const _SectionLabel('Visibility'),

                  _ToggleRow(
                    label: 'Active',
                    description: 'Visible in the storefront and search',
                    value: _isActive,
                    onChanged: (value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                  ),

                  _ToggleRow(
                    label: 'Featured',
                    description: "Shown in the home page's Featured rail",
                    value: _isFeatured,
                    onChanged: (value) {
                      setState(() {
                        _isFeatured = value;
                      });
                    },
                  ),

                  _ToggleRow(
                    label: 'New arrival',
                    description: 'Flags a "New" badge on the product card',
                    value: _isNew,
                    onChanged: (value) {
                      setState(() {
                        _isNew = value;
                      });
                    },
                  ),

                  _ToggleRow(
                    label: 'On sale',
                    description: 'Shows the sale price and discount badge',
                    value: _isOnSale,
                    onChanged: (value) {
                      setState(() {
                        _isOnSale = value;
                      });
                    },
                  ),

                  if (_error != null) ...[
                    const SizedBox(height: 10),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AdminColors.danger.withValues(alpha: 0.08),
                        border: Border.all(
                          color: AdminColors.danger.withValues(alpha: 0.25),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _error!,
                        style: AdminText.body(12.5, color: AdminColors.danger),
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // ========================================================
          // FOOTER
          // ========================================================
          Obx(() {
            final uploading = _mediaController.isUploading.value;

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AdminColors.line)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AdminGhostButton(
                    label: 'Cancel',
                    onPressed: _saving || uploading
                        ? null
                        : () {
                            Navigator.of(context).pop();
                          },
                  ),

                  const SizedBox(width: 10),

                  AdminPrimaryButton(
                    label: 'Save product',
                    loading: _saving,
                    onPressed: _saving || uploading ? null : _save,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ============================================================================
// MEDIA SECTION
// ============================================================================

class _MediaSection extends StatelessWidget {
  const _MediaSection({
    required this.isUploading,
    required this.progress,
    required this.currentFileName,
    required this.images,
    required this.videoUrl,
    required this.onUploadImages,
    required this.onUploadVideo,
    required this.onRemoveImage,
    required this.onRemoveVideo,
  });

  final bool isUploading;
  final double progress;
  final String currentFileName;

  final List<String> images;
  final String? videoUrl;

  final VoidCallback onUploadImages;
  final VoidCallback onUploadVideo;

  final ValueChanged<String> onRemoveImage;

  final VoidCallback onRemoveVideo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product images',
          style: AdminText.body(
            12.5,
            weight: FontWeight.w600,
            color: AdminColors.inkSoft,
          ),
        ),

        const SizedBox(height: 8),

        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final image in images)
              _ImagePreview(
                imageUrl: image,
                onRemove: () {
                  onRemoveImage(image);
                },
              ),

            InkWell(
              onTap: isUploading ? null : onUploadImages,
              borderRadius: BorderRadius.circular(10),
              child: Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  border: Border.all(color: AdminColors.line),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined),
                    SizedBox(height: 5),
                    Text('Add images', style: TextStyle(fontSize: 11)),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),

        Text(
          'Images are compressed and resized automatically before upload.',
          style: AdminText.body(11.5, color: AdminColors.muted),
        ),

        const SizedBox(height: 14),

        Text(
          'Product video',
          style: AdminText.body(
            12.5,
            weight: FontWeight.w600,
            color: AdminColors.inkSoft,
          ),
        ),

        const SizedBox(height: 8),

        if (videoUrl != null && videoUrl!.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: AdminColors.line),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.video_library_outlined, size: 20),

                const SizedBox(width: 8),

                const Expanded(child: Text('Product video uploaded')),

                IconButton(
                  tooltip: 'Remove video',
                  onPressed: isUploading ? null : onRemoveVideo,
                  icon: const Icon(Icons.close_rounded, size: 18),
                ),
              ],
            ),
          ),

        const SizedBox(height: 8),

        OutlinedButton.icon(
          onPressed: isUploading ? null : onUploadVideo,
          icon: const Icon(Icons.video_library_outlined),
          label: Text(videoUrl == null ? 'Upload video' : 'Replace video'),
        ),

        if (isUploading) ...[
          const SizedBox(height: 14),

          LinearProgressIndicator(value: progress <= 0 ? null : progress),

          const SizedBox(height: 6),

          Text(
            currentFileName.isEmpty
                ? 'Uploading media...'
                : 'Uploading $currentFileName',
            style: AdminText.body(11.5, color: AdminColors.muted),
          ),
        ],
      ],
    );
  }
}

// ============================================================================
// 3D SECTION
// ============================================================================

class _ThreeDSection extends StatelessWidget {
  const _ThreeDSection({
    required this.isUploading,
    required this.model3dUrl,
    required this.model3dIosUrl,
    required this.onUploadModel,
    required this.onUploadUsdZ,
    required this.onRemoveModel,
    required this.onRemoveUsdZ,
  });

  final bool isUploading;

  final String? model3dUrl;
  final String? model3dIosUrl;

  final VoidCallback onUploadModel;
  final VoidCallback onUploadUsdZ;

  final VoidCallback onRemoveModel;
  final VoidCallback onRemoveUsdZ;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Primary 3D model',
          style: AdminText.body(
            12.5,
            weight: FontWeight.w600,
            color: AdminColors.inkSoft,
          ),
        ),

        const SizedBox(height: 8),

        _UploadAssetTile(
          icon: Icons.view_in_ar_outlined,
          title: model3dUrl == null ? 'Upload GLB / GLTF' : '3D model uploaded',
          subtitle: model3dUrl == null
              ? 'Recommended: GLB'
              : 'Ready for the customer 3D viewer',
          uploaded: model3dUrl != null,
          enabled: !isUploading,
          onUpload: onUploadModel,
          onRemove: model3dUrl != null ? onRemoveModel : null,
        ),

        const SizedBox(height: 12),

        Text(
          'iOS AR model',
          style: AdminText.body(
            12.5,
            weight: FontWeight.w600,
            color: AdminColors.inkSoft,
          ),
        ),

        const SizedBox(height: 8),

        _UploadAssetTile(
          icon: Icons.phone_iphone_rounded,
          title: model3dIosUrl == null ? 'Upload USDZ' : 'USDZ model uploaded',
          subtitle: model3dIosUrl == null
              ? 'Optional iOS AR asset'
              : 'Ready for supported iOS AR experiences',
          uploaded: model3dIosUrl != null,
          enabled: !isUploading,
          onUpload: onUploadUsdZ,
          onRemove: model3dIosUrl != null ? onRemoveUsdZ : null,
        ),
      ],
    );
  }
}

// ============================================================================
// UPLOAD TILE
// ============================================================================

class _UploadAssetTile extends StatelessWidget {
  const _UploadAssetTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.uploaded,
    required this.enabled,
    required this.onUpload,
    required this.onRemove,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  final bool uploaded;
  final bool enabled;

  final VoidCallback onUpload;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AdminColors.line),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AdminColors.line.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 21),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AdminText.body(12.5, weight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AdminText.body(11.5, color: AdminColors.muted),
                ),
              ],
            ),
          ),

          if (uploaded && onRemove != null)
            IconButton(
              tooltip: 'Remove',
              onPressed: enabled ? onRemove : null,
              icon: const Icon(Icons.delete_outline_rounded, size: 19),
            ),

          OutlinedButton(
            onPressed: enabled ? onUpload : null,
            child: Text(uploaded ? 'Replace' : 'Upload'),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// IMAGE PREVIEW
// ============================================================================

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.imageUrl, required this.onRemove});

  final String imageUrl;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            imageUrl,
            width: 88,
            height: 88,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 88,
                height: 88,
                color: AdminColors.line,
                alignment: Alignment.center,
                child: const Icon(Icons.broken_image_outlined),
              );
            },
          ),
        ),

        Positioned(
          top: 4,
          right: 4,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onRemove,
              child: const Padding(
                padding: EdgeInsets.all(5),
                child: Icon(Icons.close_rounded, size: 14, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// HEADER
// ============================================================================

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader({required this.isEditing});

  final bool isEditing;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AdminColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEditing ? 'Edit product' : 'Add product',
                  style: AdminText.display(20),
                ),
                const SizedBox(height: 2),
                Text(
                  isEditing
                      ? 'Update details for this item'
                      : 'New item in your catalog',
                  style: AdminText.body(12.5, color: AdminColors.muted),
                ),
              ],
            ),
          ),

          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SECTION LABEL
// ============================================================================

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: AdminText.body(
          11.5,
          weight: FontWeight.w700,
          color: AdminColors.muted,
        ),
      ),
    );
  }
}

// ============================================================================
// FIELD
// ============================================================================

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child, this.hint});

  final String label;
  final Widget child;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            Text(
              label,
              style: AdminText.body(
                12.5,
                weight: FontWeight.w600,
                color: AdminColors.inkSoft,
              ),
            ),
            const SizedBox(height: 6),
          ],

          child,

          if (hint != null) ...[
            const SizedBox(height: 5),
            Text(hint!, style: AdminText.body(11.5, color: AdminColors.muted)),
          ],
        ],
      ),
    );
  }
}

// ============================================================================
// TOGGLE
// ============================================================================

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.description,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String description;
  final bool value;

  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AdminColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AdminText.body(13, weight: FontWeight.w500)),
                Text(
                  description,
                  style: AdminText.body(11.5, color: AdminColors.muted),
                ),
              ],
            ),
          ),

          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AdminColors.brass,
          ),
        ],
      ),
    );
  }
}
