import 'package:e_commerce/utills/admin_badge.dart';
import 'package:e_commerce/utills/admin_buttons.dart';
import 'package:e_commerce/utills/responsive.dart';
import 'package:flutter/material.dart';

import '../../../../controllers/category_controller.dart';
import '../../../../models/product_model.dart';
import '../../../../theme/admin_theme.dart';

class ProductRow extends StatelessWidget {
  const ProductRow({
    super.key,
    required this.product,
    required this.categoryController,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductModel product;
  final CategoryController categoryController;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  String get _priceLabel => '\$${product.price.toStringAsFixed(2)}';
  String get _finalPriceLabel => '\$${product.finalPrice.toStringAsFixed(2)}';

  @override
  Widget build(BuildContext context) {
    final categoryLabel = categoryController.categoryPath(product.categoryId);
    return Responsive.isMobile(context)
        ? _MobileCard(
            product: product,
            categoryLabel: categoryLabel,
            priceLabel: _priceLabel,
            finalPriceLabel: _finalPriceLabel,
            onEdit: onEdit,
            onDelete: onDelete,
          )
        : _DesktopRow(
            product: product,
            categoryLabel: categoryLabel,
            priceLabel: _priceLabel,
            finalPriceLabel: _finalPriceLabel,
            onEdit: onEdit,
            onDelete: onDelete,
          );
  }
}

class _DesktopRow extends StatelessWidget {
  const _DesktopRow({
    required this.product,
    required this.categoryLabel,
    required this.priceLabel,
    required this.finalPriceLabel,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductModel product;
  final String categoryLabel;
  final String priceLabel;
  final String finalPriceLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
                        '${product.sku} · ${product.brand.isEmpty ? "—" : product.brand}',
                        style: AdminText.body(12, color: AdminColors.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              categoryLabel.isEmpty ? '—' : categoryLabel,
              style: AdminText.body(13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: product.hasDiscount
                ? Row(
                    children: [
                      Text(
                        finalPriceLabel,
                        style: AdminText.body(13.5, weight: FontWeight.w600),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        priceLabel,
                        style: AdminText.body(
                          12,
                          color: AdminColors.muted,
                        ).copyWith(decoration: TextDecoration.lineThrough),
                      ),
                    ],
                  )
                : Text(
                    priceLabel,
                    style: AdminText.body(13.5, weight: FontWeight.w600),
                  ),
          ),
          Expanded(flex: 2, child: AdminBadge.stock(stock: product.stock)),
          Expanded(flex: 2, child: AdminBadge.status(product.isActive)),
          SizedBox(
            width: 78,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AdminIconButton(
                  icon: Icons.edit_outlined,
                  tooltip: 'Edit',
                  onPressed: onEdit,
                ),
                const SizedBox(width: 6),
                AdminIconButton(
                  icon: Icons.delete_outline_rounded,
                  danger: true,
                  tooltip: 'Delete',
                  onPressed: onDelete,
                ),
              ],
            ),
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
    required this.priceLabel,
    required this.finalPriceLabel,
    required this.onEdit,
    required this.onDelete,
  });

  final ProductModel product;
  final String categoryLabel;
  final String priceLabel;
  final String finalPriceLabel;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

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
                      '${product.sku} · ${categoryLabel.isEmpty ? "—" : categoryLabel}',
                      style: AdminText.body(12, color: AdminColors.muted),
                    ),
                  ],
                ),
              ),
              AdminIconButton(icon: Icons.edit_outlined, onPressed: onEdit),
              const SizedBox(width: 6),
              AdminIconButton(
                icon: Icons.delete_outline_rounded,
                danger: true,
                onPressed: onDelete,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              product.hasDiscount
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          finalPriceLabel,
                          style: AdminText.body(13.5, weight: FontWeight.w600),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          priceLabel,
                          style: AdminText.body(
                            12,
                            color: AdminColors.muted,
                          ).copyWith(decoration: TextDecoration.lineThrough),
                        ),
                      ],
                    )
                  : Text(
                      priceLabel,
                      style: AdminText.body(13.5, weight: FontWeight.w600),
                    ),
              AdminBadge.stock(stock: product.stock),
              AdminBadge.status(product.isActive),
            ],
          ),
        ],
      ),
    );
  }
}
