import 'package:e_commerce/controllers/product_controller.dart';
import 'package:e_commerce/models/product_model.dart';
import 'package:e_commerce/theme/admin_theme.dart';
import 'package:e_commerce/utills/admin_badge.dart';
import 'package:e_commerce/utills/admin_buttons.dart';
import 'package:e_commerce/utills/confirm_delete_dialog.dart';
import 'package:e_commerce/utills/responsive.dart';
import 'package:e_commerce/views/admin/deal_edit_dialog.dart';
import 'package:e_commerce/views/admin/deals_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// A product currently on sale — shows the discount and lets the admin
/// edit the sale price or remove the deal entirely.
class ActiveDealRow extends StatelessWidget {
  const ActiveDealRow({
    super.key,
    required this.product,
    required this.controller,
  });

  final ProductModel product;
  final ProductController controller;

  Future<void> _remove(BuildContext context) async {
    final confirmed = await confirmDelete(
      context: context,
      title: 'Remove this deal?',
      message:
          '"${product.name}" will go back to its regular price of \$${product.price.toStringAsFixed(2)}.',
    );
    if (confirmed) {
      await controller.clearDeal(product.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final busy = controller.busyProductId.value == product.id;

      return Responsive.isMobile(context)
          ? _MobileActive(
              product: product,
              busy: busy,
              controller: controller,
              onRemove: () => _remove(context),
            )
          : _DesktopActive(
              product: product,
              busy: busy,
              controller: controller,
              onRemove: () => _remove(context),
            );
    });
  }
}

class _RowActions extends StatelessWidget {
  const _RowActions({
    required this.busy,
    required this.controller,
    required this.product,
    required this.onRemove,
  });

  final bool busy;
  final ProductController controller;
  final ProductModel product;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    if (busy) {
      return const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AdminIconButton(
          icon: Icons.edit_outlined,
          tooltip: 'Edit deal',
          onPressed: () => showDealEditDialog(
            context: context,
            controller: controller,
            product: product,
          ),
        ),
        const SizedBox(width: 6),
        AdminIconButton(
          icon: Icons.close_rounded,
          danger: true,
          tooltip: 'Remove deal',
          onPressed: onRemove,
        ),
      ],
    );
  }
}

class _DesktopActive extends StatelessWidget {
  const _DesktopActive({
    required this.product,
    required this.busy,
    required this.controller,
    required this.onRemove,
  });

  final ProductModel product;
  final bool busy;
  final ProductController controller;
  final VoidCallback onRemove;

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
                  child: Text(
                    product.name,
                    style: AdminText.body(13.5, weight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Text(
                  '\$${product.finalPrice.toStringAsFixed(2)}',
                  style: AdminText.body(13.5, weight: FontWeight.w600),
                ),
                const SizedBox(width: 6),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: AdminText.body(
                    12,
                    color: AdminColors.muted,
                  ).copyWith(decoration: TextDecoration.lineThrough),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: AdminColors.successTint,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${product.discountPercentage.toStringAsFixed(0)}% off',
                style: AdminText.body(
                  11.5,
                  weight: FontWeight.w700,
                  color: AdminColors.success,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 78,
            child: Align(
              alignment: Alignment.centerRight,
              child: _RowActions(
                busy: busy,
                controller: controller,
                product: product,
                onRemove: onRemove,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileActive extends StatelessWidget {
  const _MobileActive({
    required this.product,
    required this.busy,
    required this.controller,
    required this.onRemove,
  });

  final ProductModel product;
  final bool busy;
  final ProductController controller;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AdminSwatch(seed: product.name, size: 40),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  product.name,
                  style: AdminText.body(13.5, weight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              _RowActions(
                busy: busy,
                controller: controller,
                product: product,
                onRemove: onRemove,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                '\$${product.finalPrice.toStringAsFixed(2)}',
                style: AdminText.body(13.5, weight: FontWeight.w600),
              ),
              Text(
                '\$${product.price.toStringAsFixed(2)}',
                style: AdminText.body(
                  12,
                  color: AdminColors.muted,
                ).copyWith(decoration: TextDecoration.lineThrough),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AdminColors.successTint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${product.discountPercentage.toStringAsFixed(0)}% off',
                  style: AdminText.body(
                    11.5,
                    weight: FontWeight.w700,
                    color: AdminColors.success,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A product not currently on sale — a candidate the admin can start a
/// deal on.
class DealCandidateRow extends StatelessWidget {
  const DealCandidateRow({
    super.key,
    required this.product,
    required this.controller,
  });

  final ProductModel product;
  final ProductController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final busy = controller.busyProductId.value == product.id;

      return Container(
        padding: EdgeInsets.symmetric(
          horizontal: 16,
          vertical: Responsive.isMobile(context) ? 14 : 12,
        ),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AdminColors.line)),
        ),
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
                    '\$${product.price.toStringAsFixed(2)} · ${product.categoryName}',
                    style: AdminText.body(12, color: AdminColors.muted),
                  ),
                ],
              ),
            ),
            AdminPrimaryButton(
              label: 'Add deal',
              icon: Icons.local_offer_outlined,
              loading: busy,
              onPressed: () => showDealEditDialog(
                context: context,
                controller: controller,
                product: product,
              ),
            ),
          ],
        ),
      );
    });
  }
}
