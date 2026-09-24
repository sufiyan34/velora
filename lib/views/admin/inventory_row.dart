import 'package:e_commerce/controllers/category_controller.dart';
import 'package:e_commerce/controllers/product_controller.dart';
import 'package:e_commerce/models/product_model.dart';
import 'package:e_commerce/theme/admin_theme.dart';
import 'package:e_commerce/utills/admin_badge.dart';
import 'package:e_commerce/utills/responsive.dart';
import 'package:e_commerce/views/admin/stock_edit_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InventoryRow extends StatelessWidget {
  const InventoryRow({
    super.key,
    required this.product,
    required this.controller,
    required this.categoryController,
  });

  final ProductModel product;
  final ProductController controller;
  final CategoryController categoryController;

  @override
  Widget build(BuildContext context) {
    final categoryLabel = categoryController.categoryPath(product.categoryId);

    return Responsive.isMobile(context)
        ? _MobileCard(
            product: product,
            categoryLabel: categoryLabel,
            controller: controller,
          )
        : _DesktopRow(
            product: product,
            categoryLabel: categoryLabel,
            controller: controller,
          );
  }
}

class _DesktopRow extends StatelessWidget {
  const _DesktopRow({
    required this.product,
    required this.categoryLabel,
    required this.controller,
  });

  final ProductModel product;
  final String categoryLabel;
  final ProductController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AdminColors.line)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 4,
            child: Row(
              children: [
                AdminSwatch(seed: product.name),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        product.name,
                        style: AdminText.body(13.5, weight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${product.sku.isEmpty ? "No SKU" : product.sku} · ${categoryLabel.isEmpty ? "—" : categoryLabel}',
                        style: AdminText.body(12, color: AdminColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(flex: 2, child: AdminBadge.stock(stock: product.stock)),
          Expanded(
            flex: 2,
            child: Text(
              '\$${(product.finalPrice * product.stock).toStringAsFixed(2)}',
              style: AdminText.body(13.5, weight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Obx(() {
              final busy = controller.busyProductId.value == product.id;
              return _StockStepper(
                busy: busy,
                onDecrease: () => controller.adjustStock(product.id, -1),
                onIncrease: () => controller.adjustStock(product.id, 1),
                onEdit: () => showStockEditDialog(
                  context: context,
                  controller: controller,
                  product: product,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _MobileCard extends StatelessWidget {
  const _MobileCard({
    required this.product,
    required this.categoryLabel,
    required this.controller,
  });

  final ProductModel product;
  final String categoryLabel;
  final ProductController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AdminColors.line)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AdminSwatch(seed: product.name),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: AdminText.body(13.5, weight: FontWeight.w600),
                    ),
                    Text(
                      '${product.sku.isEmpty ? "No SKU" : product.sku} · ${categoryLabel.isEmpty ? "—" : categoryLabel}',
                      style: AdminText.body(12, color: AdminColors.muted),
                    ),
                  ],
                ),
              ),
              AdminBadge.stock(stock: product.stock),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Value: \$${(product.finalPrice * product.stock).toStringAsFixed(2)}',
                style: AdminText.body(12.5, color: AdminColors.muted),
              ),
              const Spacer(),
              Obx(() {
                final busy = controller.busyProductId.value == product.id;
                return _StockStepper(
                  busy: busy,
                  onDecrease: () => controller.adjustStock(product.id, -1),
                  onIncrease: () => controller.adjustStock(product.id, 1),
                  onEdit: () => showStockEditDialog(
                    context: context,
                    controller: controller,
                    product: product,
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class _StockStepper extends StatelessWidget {
  const _StockStepper({
    required this.busy,
    required this.onDecrease,
    required this.onIncrease,
    required this.onEdit,
  });

  final bool busy;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        _StepButton(
          icon: Icons.remove_rounded,
          onPressed: busy ? null : onDecrease,
        ),
        SizedBox(
          width: 30,
          child: busy
              ? const Center(
                  child: SizedBox(
                    width: 13,
                    height: 13,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : const SizedBox.shrink(),
        ),
        _StepButton(
          icon: Icons.add_rounded,
          onPressed: busy ? null : onIncrease,
        ),
        const SizedBox(width: 4),
        IconButton(
          onPressed: busy ? null : onEdit,
          tooltip: 'Set exact stock',
          icon: const Icon(
            Icons.edit_outlined,
            size: 16,
            color: AdminColors.muted,
          ),
        ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AdminColors.canvas,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 15, color: AdminColors.inkSoft),
        ),
      ),
    );
  }
}
