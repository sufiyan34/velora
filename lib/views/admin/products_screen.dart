import 'package:e_commerce/utills/admin_buttons.dart';
import 'package:e_commerce/utills/admin_search_field.dart';
import 'package:e_commerce/utills/confirm_delete_dialog.dart';
import 'package:e_commerce/utills/responsive.dart';
import 'package:e_commerce/views/admin/product_form_drawer.dart';
import 'package:e_commerce/views/admin/product_row.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/category_controller.dart';
import '../../../controllers/product_controller.dart';
import '../../../models/product_model.dart';
import '../../../theme/admin_theme.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProductController(), tag: 'products');
    final categoryController =
        Get.isRegistered<CategoryController>(tag: 'categories')
        ? Get.find<CategoryController>(tag: 'categories')
        : Get.put(CategoryController(), tag: 'categories');

    return Scaffold(
      backgroundColor: AdminColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(controller: controller),
              const SizedBox(height: 18),
              _Toolbar(
                controller: controller,
                categoryController: categoryController,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final list = controller.filtered;
                  if (list.isEmpty) {
                    return const _EmptyState();
                  }
                  return Container(
                    decoration: BoxDecoration(
                      color: AdminColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AdminColors.line),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        if (!Responsive.isMobile(context)) const _TableHeader(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: list.length,
                            itemBuilder: (context, i) {
                              final product = list[i];
                              return ProductRow(
                                product: product,
                                categoryController: categoryController,
                                onEdit: () => showProductFormDrawer(
                                  context: context,
                                  controller: controller,
                                  product: product,
                                ),
                                onDelete: () => _confirmDeleteProduct(
                                  context,
                                  controller,
                                  product,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteProduct(
    BuildContext context,
    ProductController controller,
    ProductModel product,
  ) async {
    final confirmed = await confirmDelete(
      context: context,
      title: 'Delete product?',
      message:
          '"${product.name}" will be permanently removed from your catalog.',
    );
    if (confirmed) {
      await controller.deleteProduct(product.id);
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final ProductController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Products', style: AdminText.display(26)),
              const SizedBox(height: 4),
              Obx(
                () => Text(
                  '${controller.products.length} items in your catalog',
                  style: AdminText.body(13.5, color: AdminColors.muted),
                ),
              ),
            ],
          ),
        ),
        AdminPrimaryButton(
          label: 'Add product',
          icon: Icons.add_rounded,
          onPressed: () =>
              showProductFormDrawer(context: context, controller: controller),
        ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.controller, required this.categoryController});

  final ProductController controller;
  final CategoryController categoryController;

  List<DropdownMenuItem<String>> _categoryItems() {
    final items = <DropdownMenuItem<String>>[
      const DropdownMenuItem(value: '', child: Text('All categories')),
    ];
    void walk(List depth0, int depth) {
      for (final c in depth0) {
        items.add(
          DropdownMenuItem<String>(
            value: c.id as String,
            child: Text('${'—' * depth} ${c.name}'.trim()),
          ),
        );
        walk(categoryController.childrenOf(c.id), depth + 1);
      }
    }

    walk(categoryController.topLevel(), 0);
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: [
        AdminSearchField(
          hintText: 'Search by name, SKU or brand…',
          onChanged: (v) => controller.searchTerm.value = v,
        ),
        Obx(
          () => _Dropdown(
            value: controller.categoryFilter.value,
            items: _categoryItems(),
            onChanged: (v) => controller.categoryFilter.value = v ?? '',
          ),
        ),
        Obx(
          () => _Dropdown(
            value: controller.statusFilter.value,
            items: const [
              DropdownMenuItem(value: 'all', child: Text('All statuses')),
              DropdownMenuItem(value: 'active', child: Text('Active')),
              DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
              DropdownMenuItem(value: 'low', child: Text('Low stock')),
              DropdownMenuItem(value: 'out', child: Text('Out of stock')),
            ],
            onChanged: (v) => controller.statusFilter.value = v ?? 'all',
          ),
        ),
      ],
    );
  }
}

class _Dropdown extends StatelessWidget {
  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        border: Border.all(color: AdminColors.line),
        borderRadius: BorderRadius.circular(9),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.any((i) => i.value == value) ? value : null,
          items: items,
          onChanged: onChanged,
          style: AdminText.body(13, color: AdminColors.inkSoft),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AdminColors.muted,
          ),
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
    TextStyle style() =>
        AdminText.body(11.5, weight: FontWeight.w600, color: AdminColors.muted);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AdminColors.line)),
      ),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text('PRODUCT', style: style())),
          Expanded(flex: 2, child: Text('CATEGORY', style: style())),
          Expanded(flex: 2, child: Text('PRICE', style: style())),
          Expanded(flex: 2, child: Text('STOCK', style: style())),
          Expanded(flex: 2, child: Text('STATUS', style: style())),
          const SizedBox(width: 78, child: Text('')),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.line),
      ),
      padding: const EdgeInsets.symmetric(vertical: 52),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_rounded, size: 34, color: Color(0xFFC7C2D6)),
          const SizedBox(height: 10),
          Text(
            'No products found',
            style: AdminText.body(14.5, weight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          Text(
            'Try a different search, or add your first product.',
            style: AdminText.body(13, color: AdminColors.muted),
          ),
        ],
      ),
    );
  }
}
