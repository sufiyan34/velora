import 'package:e_commerce/utills/admin_buttons.dart';
import 'package:flutter/material.dart';

import '../../../../controllers/category_controller.dart';
import '../../../../models/category_model.dart';
import '../../../../theme/admin_theme.dart';

/// Opens the add/edit category dialog.
///
/// - Pass [category] to edit an existing one.
/// - Pass [presetParentId] when the admin tapped "Add subcategory to X", so
///   the parent is pre-selected.
Future<void> showCategoryFormDialog({
  required BuildContext context,
  required CategoryController controller,
  CategoryModel? category,
  String? presetParentId,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    builder: (_) => CategoryFormDialog(
      controller: controller,
      category: category,
      presetParentId: presetParentId,
    ),
  );
}

class CategoryFormDialog extends StatefulWidget {
  const CategoryFormDialog({
    super.key,
    required this.controller,
    this.category,
    this.presetParentId,
  });

  final CategoryController controller;
  final CategoryModel? category;
  final String? presetParentId;

  @override
  State<CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<CategoryFormDialog> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _sortOrder;
  String? _parentId;
  bool _isActive = true;
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    final c = widget.category;
    _name = TextEditingController(text: c?.name ?? '');
    _description = TextEditingController(text: c?.description ?? '');
    _sortOrder = TextEditingController(
      text: (c?.sortOrder ?? widget.controller.topLevel().length).toString(),
    );
    _parentId = c?.parentCategoryId ?? widget.presetParentId;
    _isActive = c?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  /// Categories that are the one being edited, or nested under it, can't be
  /// chosen as its own parent.
  List<CategoryModel> _validParentOptions() {
    final excluded = <String>{
      if (_isEditing) widget.category!.id,
      if (_isEditing) ...widget.controller.allDescendants(widget.category!.id),
    };

    final options = <CategoryModel>[];
    void walk(List<CategoryModel> list) {
      for (final c in list) {
        if (excluded.contains(c.id)) continue;
        options.add(c);
        walk(widget.controller.childrenOf(c.id));
      }
    }

    walk(widget.controller.topLevel());
    return options;
  }

  int _depthOf(CategoryModel c) {
    var depth = 0;
    var current = c;
    while (current.parentCategoryId != null) {
      final parent = widget.controller.byId(current.parentCategoryId!);
      if (parent == null) break;
      current = parent;
      depth++;
    }
    return depth;
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Give the category a name first.');
      return;
    }
    setState(() {
      _error = null;
      _saving = true;
    });

    final data = CategoryModel(
      id: widget.category?.id ?? '',
      name: name,
      description: _description.text.trim(),
      image: widget.category?.image ?? '',
      parentCategoryId: _parentId,
      productCount: widget.category?.productCount ?? 0,
      sortOrder: int.tryParse(_sortOrder.text.trim()) ?? 0,
      isActive: _isActive,
    );

    try {
      if (_isEditing) {
        await widget.controller.updateCategory(data);
      } else {
        await widget.controller.addCategory(data);
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      setState(() {
        _saving = false;
        _error = "Couldn't save this category. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final parentOptions = _validParentOptions();
    final title = _isEditing
        ? 'Edit category'
        : (widget.presetParentId != null ? 'Add subcategory' : 'Add category');

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: AdminText.display(19)),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Field(
                        label: 'Name',
                        child: TextField(
                          controller: _name,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Dresses',
                          ),
                        ),
                      ),
                      _Field(
                        label: 'Parent category',
                        hint:
                            'Choosing a parent makes this a subcategory of it.',
                        child: DropdownButtonFormField<String?>(
                          initialValue: _parentId,
                          isExpanded: true,
                          items: [
                            const DropdownMenuItem<String?>(
                              value: null,
                              child: Text('None — top level'),
                            ),
                            ...parentOptions.map(
                              (c) => DropdownMenuItem<String?>(
                                value: c.id,
                                child: Text(
                                  '${'—' * _depthOf(c)} ${c.name}'.trim(),
                                ),
                              ),
                            ),
                          ],
                          onChanged: (value) =>
                              setState(() => _parentId = value),
                        ),
                      ),
                      _Field(
                        label: 'Description',
                        child: TextField(
                          controller: _description,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText:
                                'Optional — shown on category landing pages',
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: _Field(
                              label: 'Sort order',
                              child: TextField(
                                controller: _sortOrder,
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  hintText: '0',
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _Field(
                              label: 'Status',
                              child: SwitchListTile.adaptive(
                                contentPadding: EdgeInsets.zero,
                                value: _isActive,
                                onChanged: (v) => setState(() => _isActive = v),
                                title: Text(
                                  _isActive ? 'Active' : 'Inactive',
                                  style: AdminText.body(13),
                                ),
                                activeTrackColor: AdminColors.brass,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _error!,
                          style: AdminText.body(
                            12.5,
                            color: AdminColors.danger,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AdminGhostButton(
                    label: 'Cancel',
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  AdminPrimaryButton(
                    label: 'Save category',
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

class _Field extends StatelessWidget {
  const _Field({required this.label, required this.child, this.hint});

  final String label;
  final Widget child;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AdminText.body(
              12.5,
              weight: FontWeight.w600,
              color: AdminColors.inkSoft,
            ),
          ),
          const SizedBox(height: 6),
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
