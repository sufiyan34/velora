import 'package:flutter/material.dart';

import '../../../../models/product_model.dart';
import '../../../../theme/admin_theme.dart';

/// Lets the admin add/remove variation rows (e.g. Size: M, Colour: Black)
/// with an optional price add-on and per-variation stock.
class VariationEditor extends StatefulWidget {
  const VariationEditor({super.key, required this.initial, required this.onChanged});

  final List<ProductVariation> initial;
  final ValueChanged<List<ProductVariation>> onChanged;

  @override
  State<VariationEditor> createState() => _VariationEditorState();
}

class _RowControllers {
  _RowControllers(ProductVariation v)
      : id = v.id,
        name = TextEditingController(text: v.name),
        value = TextEditingController(text: v.value),
        price = TextEditingController(
            text: v.additionalPrice != null ? v.additionalPrice!.toStringAsFixed(2) : ''),
        stock = TextEditingController(text: v.stock.toString());

  final String id;
  final TextEditingController name;
  final TextEditingController value;
  final TextEditingController price;
  final TextEditingController stock;

  void dispose() {
    name.dispose();
    value.dispose();
    price.dispose();
    stock.dispose();
  }
}

class _VariationEditorState extends State<VariationEditor> {
  late List<_RowControllers> _rows;
  int _seq = 0;

  @override
  void initState() {
    super.initState();
    _rows = widget.initial.map((v) => _RowControllers(v)).toList();
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    super.dispose();
  }

  void _emit() {
    widget.onChanged(
      _rows
          .where((r) => r.name.text.trim().isNotEmpty || r.value.text.trim().isNotEmpty)
          .map((r) => ProductVariation(
                id: r.id,
                name: r.name.text.trim(),
                value: r.value.text.trim(),
                additionalPrice: double.tryParse(r.price.text.trim()),
                stock: int.tryParse(r.stock.text.trim()) ?? 0,
              ))
          .toList(),
    );
  }

  void _addRow() {
    setState(() {
      _rows.add(_RowControllers(ProductVariation(
        id: 'new_${_seq++}_${DateTime.now().microsecondsSinceEpoch}',
        name: '',
        value: '',
      )));
    });
  }

  void _removeRow(_RowControllers row) {
    setState(() {
      _rows.remove(row);
      row.dispose();
    });
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in _rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _mini(row.name, 'Name', onChanged: (_) => _emit()),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 3,
                  child: _mini(row.value, 'Value', onChanged: (_) => _emit()),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 2,
                  child: _mini(row.price, '+ Price', numeric: true, onChanged: (_) => _emit()),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 2,
                  child: _mini(row.stock, 'Stock', numeric: true, onChanged: (_) => _emit()),
                ),
                const SizedBox(width: 6),
                InkWell(
                  onTap: () => _removeRow(row),
                  borderRadius: BorderRadius.circular(7),
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: AdminColors.line),
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: const Icon(Icons.close_rounded, size: 14, color: AdminColors.muted),
                  ),
                ),
              ],
            ),
          ),
        TextButton.icon(
          onPressed: _addRow,
          icon: const Icon(Icons.add_rounded, size: 15),
          label: const Text('Add variation (size, colour…)'),
          style: TextButton.styleFrom(
            foregroundColor: AdminColors.brassDark,
            textStyle: AdminText.body(12.5, weight: FontWeight.w600),
            padding: EdgeInsets.zero,
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _mini(TextEditingController c, String hint,
      {bool numeric = false, required ValueChanged<String> onChanged}) {
    return TextField(
      controller: c,
      keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      onChanged: onChanged,
      style: AdminText.body(12.5),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        contentPadding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AdminColors.line),
        ),
      ),
    );
  }
}
