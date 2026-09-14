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

/// Opens the add/edit product panel, sliding in from the right (full-screen
/// on mobile via [showRightDrawer]).
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
  List<ProductVariation> _variations = [];

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

    final p = widget.product;
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

    _categoryId = p?.categoryId;
    _isActive = p?.isActive ?? true;
    _isFeatured = p?.isFeatured ?? false;
    _isNew = p?.isNew ?? false;
    _isOnSale = p?.isOnSale ?? false;
    _variations = List.of(p?.variations ?? const []);
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

  List<DropdownMenuItem<String>> _categoryOptions() {
    final items = <DropdownMenuItem<String>>[];
    void walk(List depth0, int depth) {
      for (final c in depth0) {
        items.add(
          DropdownMenuItem<String>(
            value: c.id as String,
            child: Text('${'—' * depth} ${c.name}'.trim()),
          ),
        );
        walk(_categoryController.childrenOf(c.id), depth + 1);
      }
    }

    walk(_categoryController.topLevel(), 0);
    return items;
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    final price = double.tryParse(_price.text.trim());

    if (name.isEmpty) {
      setState(() => _error = 'Give the product a name first.');
      return;
    }
    if (_categoryId == null || _categoryId!.isEmpty) {
      setState(() => _error = 'Choose a category.');
      return;
    }
    if (price == null || price < 0) {
      setState(() => _error = 'Enter a valid price.');
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
      categoryName: _categoryController.categoryPath(_categoryId),
      brand: _brand.text.trim(),
      sku: sku,
      price: price,
      salePrice: _salePrice.text.trim().isEmpty
          ? null
          : double.tryParse(_salePrice.text.trim()),
      stock: int.tryParse(_stock.text.trim()) ?? 0,
      soldCount: widget.product?.soldCount ?? 0,
      images: widget.product?.images ?? const [],
      variations: _variations,
      rating: widget.product?.rating ?? 0,
      reviewCount: widget.product?.reviewCount ?? 0,
      isActive: _isActive,
      isFeatured: _isFeatured,
      isNew: _isNew,
      isOnSale: _isOnSale,
    );

    try {
      if (_isEditing) {
        await widget.controller.updateProduct(data);
      } else {
        await widget.controller.addProduct(data);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _saving = false;
        _error = "Couldn't save this product. Please try again.";
      });
    }
  }

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
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'What makes this piece worth wearing…',
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
                            onChanged: (v) => setState(() => _categoryId = v),
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
                  const _SectionLabel('Photos'),
                  _Field(
                    label: '',
                    hint:
                        'This prototype shows a colour swatch in place of real photography — wire this to Firebase Storage / image_picker.',
                    child: Row(
                      children: [
                        AdminSwatch(
                          seed: _name.text.isEmpty ? 'New' : _name.text,
                          size: 56,
                        ),
                        const SizedBox(width: 10),
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AdminColors.line,
                              style: BorderStyle.solid,
                            ),
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: const Icon(
                            Icons.add_rounded,
                            color: AdminColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const _SectionLabel('Variations'),
                  VariationEditor(
                    initial: _variations,
                    onChanged: (v) => _variations = v,
                  ),
                  const _SectionLabel('Visibility'),
                  _ToggleRow(
                    label: 'Active',
                    description: 'Visible in the storefront and search',
                    value: _isActive,
                    onChanged: (v) => setState(() => _isActive = v),
                  ),
                  _ToggleRow(
                    label: 'Featured',
                    description: "Shown in the home page's Featured rail",
                    value: _isFeatured,
                    onChanged: (v) => setState(() => _isFeatured = v),
                  ),
                  _ToggleRow(
                    label: 'New arrival',
                    description: 'Flags a "New" badge on the product card',
                    value: _isNew,
                    onChanged: (v) => setState(() => _isNew = v),
                  ),
                  _ToggleRow(
                    label: 'On sale',
                    description: 'Shows the sale price and discount badge',
                    value: _isOnSale,
                    onChanged: (v) => setState(() => _isOnSale = v),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      _error!,
                      style: AdminText.body(12.5, color: AdminColors.danger),
                    ),
                  ],
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AdminColors.line)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AdminGhostButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 10),
                AdminPrimaryButton(
                  label: 'Save product',
                  loading: _saving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
