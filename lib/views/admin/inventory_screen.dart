import 'package:e_commerce/controllers/category_controller.dart';
import 'package:e_commerce/controllers/product_controller.dart';
import 'package:e_commerce/theme/admin_theme.dart';
import 'package:e_commerce/utills/admin_card.dart';
import 'package:e_commerce/utills/admin_search_field.dart';
import 'package:e_commerce/utills/responsive.dart';
import 'package:e_commerce/views/admin/inventory_row.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InventoryScreen extends StatelessWidget {
  const InventoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Shares the same ProductController instance as the Products screen —
    // one live product list, no duplicate Firebase listener.
    final controller = Get.isRegistered<ProductController>(tag: 'products')
        ? Get.find<ProductController>(tag: 'products')
        : Get.put(ProductController(), tag: 'products');

    final categoryController =
        Get.isRegistered<CategoryController>(tag: 'categories')
        ? Get.find<CategoryController>(tag: 'categories')
        : Get.put(CategoryController(), tag: 'categories');

    final bool mobile = Responsive.isMobile(context);

    return Scaffold(
      backgroundColor: AdminColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(mobile ? 16 : 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Inventory', style: AdminText.display(26)),
              const SizedBox(height: 4),
              Obx(
                () => Text(
                  'Stock across ${controller.products.length} products',
                  style: AdminText.body(13.5, color: AdminColors.muted),
                ),
              ),
              SizedBox(height: mobile ? 16 : 20),
              _StatsRow(controller: controller, mobile: mobile),
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
                  if (list.isEmpty) return const _EmptyState();

                  return Container(
                    decoration: BoxDecoration(
                      color: AdminColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AdminColors.line),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        if (!mobile) const _TableHeader(),
                        Expanded(
                          child: ListView.builder(
                            itemCount: list.length,
                            itemBuilder: (context, i) => InventoryRow(
                              product: list[i],
                              controller: controller,
                              categoryController: categoryController,
                            ),
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
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.controller, required this.mobile});

  final ProductController controller;
  final bool mobile;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final cards = [
        AdminStatCard(
          label: 'Total products',
          value: '${controller.products.length}',
          icon: Icons.inventory_2_outlined,
        ),
        AdminStatCard(
          label: 'Low stock',
          value: '${controller.lowStockCount}',
          icon: Icons.warning_amber_rounded,
          accent: AdminColors.warn,
        ),
        AdminStatCard(
          label: 'Out of stock',
          value: '${controller.outOfStockCount}',
          icon: Icons.remove_shopping_cart_outlined,
          accent: AdminColors.danger,
        ),
        AdminStatCard(
          label: 'Inventory value',
          value: '\$${controller.inventoryValue.toStringAsFixed(0)}',
          icon: Icons.payments_outlined,
        ),
      ];

      if (mobile) {
        return Wrap(spacing: 10, runSpacing: 10, children: cards);
      }

      return Row(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(width: 12),
            Expanded(child: cards[i]),
          ],
        ],
      );
    });
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
              DropdownMenuItem(value: 'all', child: Text('All stock levels')),
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
          Expanded(flex: 2, child: Text('STOCK', style: style())),
          Expanded(flex: 2, child: Text('VALUE', style: style())),
          Expanded(flex: 3, child: Text('ADJUST', style: style())),
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
          const Icon(
            Icons.inventory_2_outlined,
            size: 34,
            color: Color(0xFFC7C2D6),
          ),
          const SizedBox(height: 10),
          Text(
            'No products match this filter',
            style: AdminText.body(14.5, weight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          Text(
            'Try a different search, category or stock level.',
            style: AdminText.body(13, color: AdminColors.muted),
          ),
        ],
      ),
    );
  }
}