import 'package:e_commerce/utills/admin_buttons.dart';
import 'package:flutter/material.dart';

import '../../../../controllers/category_controller.dart';
import '../../../../models/category_model.dart';
import '../../../../theme/admin_theme.dart';

/// Opens the add/edit dialog for a subcategory.
///
/// - Pass [subcategory] to edit an existing one.
/// - Pass [presetGroupId] to pre-select a category group (e.g. when the
///   admin taps "Add subcategory" from within a specific category's row).
Future<void> showSubcategoryFormDialog({
  required BuildContext context,
  required CategoryController controller,
  CategoryModel? subcategory,
  String? presetGroupId,
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    builder: (_) => SubcategoryFormDialog(
      controller: controller,
      subcategory: subcategory,
      presetGroupId: presetGroupId,
    ),
  );
}

class SubcategoryFormDialog extends StatefulWidget {
  const SubcategoryFormDialog({
    super.key,
    required this.controller,
    this.subcategory,
    this.presetGroupId,
  });

  final CategoryController controller;
  final CategoryModel? subcategory;
  final String? presetGroupId;

  @override
  State<SubcategoryFormDialog> createState() => _SubcategoryFormDialogState();
}

class _SubcategoryFormDialogState extends State<SubcategoryFormDialog> {
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _sortOrder;
  String? _groupId;
  bool _isActive = true;
  bool _saving = false;
  String? _error;

  bool get _isEditing => widget.subcategory != null;

  @override
  void initState() {
    super.initState();
    final c = widget.subcategory;
    _name = TextEditingController(text: c?.name ?? '');
    _description = TextEditingController(text: c?.description ?? '');
    _sortOrder = TextEditingController(text: (c?.sortOrder ?? 0).toString());
    _groupId = c?.parentCategoryId ?? widget.presetGroupId;
    _isActive = c?.isActive ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _sortOrder.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Give the subcategory a name first.');
      return;
    }
    if (_groupId == null || _groupId!.isEmpty) {
      setState(() => _error = 'Choose which category group this belongs to.');
      return;
    }
    setState(() {
      _error = null;
      _saving = true;
    });

    final data = CategoryModel(
      id: widget.subcategory?.id ?? '',
      name: name,
      description: _description.text.trim(),
      image: widget.subcategory?.image ?? '',
      parentCategoryId: _groupId,
      productCount: widget.subcategory?.productCount ?? 0,
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
        _error = "Couldn't save this subcategory. Please try again.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final groups = widget.controller.topLevel();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _isEditing ? 'Edit subcategory' : 'Add subcategory',
                    style: AdminText.display(19),
                  ),
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
                        label: 'Category group',
                        hint: groups.isEmpty
                            ? 'Add a category first — subcategories belong to one.'
                            : 'Which category this subcategory sits under.',
                        child: DropdownButtonFormField<String>(
                          initialValue:
                              (_groupId != null &&
                                  groups.any((g) => g.id == _groupId))
                              ? _groupId
                              : null,
                          isExpanded: true,
                          hint: const Text('Select a category group'),
                          items: groups
                              .map(
                                (g) => DropdownMenuItem<String>(
                                  value: g.id,
                                  child: Text(g.name),
                                ),
                              )
                              .toList(),
                          onChanged: groups.isEmpty
                              ? null
                              : (v) => setState(() => _groupId = v),
                        ),
                      ),
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
                        label: 'Description',
                        child: TextField(
                          controller: _description,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText:
                                'Optional — shown on the subcategory landing page',
                          ),
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                    label: 'Save subcategory',
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
