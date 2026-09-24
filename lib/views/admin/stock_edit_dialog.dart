import 'package:e_commerce/controllers/product_controller.dart';
import 'package:e_commerce/models/product_model.dart';
import 'package:e_commerce/utills/admin_buttons.dart';
import 'package:flutter/material.dart';

import '../../theme/admin_theme.dart';

/// Opens a small dialog to set [product]'s stock to an exact count — for
/// restocks or manual corrections after a physical count.
Future<void> showStockEditDialog({
  required BuildContext context,
  required ProductController controller,
  required ProductModel product,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    builder: (_) => StockEditDialog(controller: controller, product: product),
  );
}

class StockEditDialog extends StatefulWidget {
  const StockEditDialog({
    super.key,
    required this.controller,
    required this.product,
  });

  final ProductController controller;
  final ProductModel product;

  @override
  State<StockEditDialog> createState() => _StockEditDialogState();
}

class _StockEditDialogState extends State<StockEditDialog> {
  late final TextEditingController _stock;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _stock = TextEditingController(text: widget.product.stock.toString());
  }

  @override
  void dispose() {
    _stock.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = int.tryParse(_stock.text.trim());
    if (value == null || value < 0) {
      setState(() => _error = 'Enter a valid, non-negative number.');
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    final ok = await widget.controller.setStock(widget.product.id, value);

    if (!mounted) return;

    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() {
        _saving = false;
        _error = "Couldn't update stock. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
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
                    child: Text('Update stock', style: AdminText.display(19)),
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
                'New stock count',
                style: AdminText.body(
                  12.5,
                  weight: FontWeight.w600,
                  color: AdminColors.inkSoft,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _stock,
                autofocus: true,
                keyboardType: TextInputType.number,
                style: AdminText.body(14),
                decoration: const InputDecoration(hintText: '0'),
                onSubmitted: (_) => _save(),
              ),
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
                    label: 'Save',
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
