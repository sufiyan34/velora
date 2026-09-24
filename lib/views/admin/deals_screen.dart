import 'package:e_commerce/controllers/product_controller.dart';
import 'package:e_commerce/models/product_model.dart';
import 'package:e_commerce/utills/admin_buttons.dart';
import 'package:flutter/material.dart';

import '../../theme/admin_theme.dart';

/// Opens a dialog to put [product] on sale, or change its existing sale
/// price. Deleting a deal (taking a product off sale) doesn't need a
/// dialog — that's a single confirm, handled by the caller.
Future<void> showDealEditDialog({
  required BuildContext context,
  required ProductController controller,
  required ProductModel product,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    builder: (_) => DealEditDialog(controller: controller, product: product),
  );
}

class DealEditDialog extends StatefulWidget {
  const DealEditDialog({
    super.key,
    required this.controller,
    required this.product,
  });

  final ProductController controller;
  final ProductModel product;

  @override
  State<DealEditDialog> createState() => _DealEditDialogState();
}

class _DealEditDialogState extends State<DealEditDialog> {
  late final TextEditingController _salePrice;
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.product.hasDiscount;

  @override
  void initState() {
    super.initState();
    _salePrice = TextEditingController(
      text: widget.product.salePrice?.toStringAsFixed(2) ?? '',
    );
    _salePrice.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _salePrice.dispose();
    super.dispose();
  }

  double? get _parsedSalePrice => double.tryParse(_salePrice.text.trim());

  double get _discountPercent {
    final sale = _parsedSalePrice;
    final price = widget.product.price;
    if (sale == null || price <= 0 || sale >= price) return 0;
    return ((price - sale) / price) * 100;
  }

  Future<void> _save() async {
    final sale = _parsedSalePrice;

    if (sale == null || sale <= 0) {
      setState(() => _error = 'Enter a valid sale price.');
      return;
    }

    if (sale >= widget.product.price) {
      setState(
        () => _error =
            'Sale price must be lower than the regular price (\$${widget.product.price.toStringAsFixed(2)}).',
      );
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    final ok = await widget.controller.setDeal(widget.product.id, sale);

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't save this deal. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _isEditing ? 'Edit deal' : 'Add deal',
                      style: AdminText.display(19),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                widget.product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AdminText.body(13, color: AdminColors.muted),
              ),
              const SizedBox(height: 16),
              Text(
                'Regular price',
                style: AdminText.body(
                  12.5,
                  weight: FontWeight.w600,
                  color: AdminColors.inkSoft,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '\$${widget.product.price.toStringAsFixed(2)}',
                style: AdminText.body(14, weight: FontWeight.w600),
              ),
              const SizedBox(height: 14),
              Text(
                'Sale price',
                style: AdminText.body(
                  12.5,
                  weight: FontWeight.w600,
                  color: AdminColors.inkSoft,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _salePrice,
                autofocus: true,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                style: AdminText.body(14),
                decoration: const InputDecoration(hintText: '0.00'),
                onSubmitted: (_) => _save(),
              ),
              if (_discountPercent > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AdminColors.successTint,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_discountPercent.toStringAsFixed(0)}% off',
                    style: AdminText.body(
                      12,
                      weight: FontWeight.w700,
                      color: AdminColors.success,
                    ),
                  ),
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: AdminText.body(12.5, color: AdminColors.danger),
                ),
              ],
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AdminGhostButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  AdminPrimaryButton(
                    label: _isEditing ? 'Save deal' : 'Start deal',
                    loading: _saving,
                    onPressed: _save,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
