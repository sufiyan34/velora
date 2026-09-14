import 'package:e_commerce/utills/admin_badge.dart';
import 'package:e_commerce/utills/admin_buttons.dart';
import 'package:e_commerce/utills/responsive.dart';
import 'package:flutter/material.dart';

import '../../../../controllers/category_controller.dart';
import '../../../../models/category_model.dart';
import '../../../../theme/admin_theme.dart';

/// Renders one category row plus, when expanded, its subcategories beneath
/// it — recursively, so a subcategory can itself have children.
class CategoryTreeTile extends StatelessWidget {
  const CategoryTreeTile({
    super.key,
    required this.category,
    required this.depth,
    required this.controller,
    required this.onEdit,
    required this.onDelete,
    required this.onAddSubcategory,
  });

  final CategoryModel category;
  final int depth;
  final CategoryController controller;
  final ValueChanged<CategoryModel> onEdit;
  final ValueChanged<CategoryModel> onDelete;
  final ValueChanged<CategoryModel> onAddSubcategory;

  @override
  Widget build(BuildContext context) {
    final children = controller.childrenOf(category.id);
    final hasChildren = children.isNotEmpty;
    final isOpen = controller.isExpanded(category.id);
    final isMobile = Responsive.isMobile(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(
            left: 16 + depth * 26,
            right: 16,
            top: 13,
            bottom: 13,
          ),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AdminColors.line)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (depth > 0)
                Container(
                  width: 20,
                  height: 34,
                  margin: const EdgeInsets.only(right: 4),
                  decoration: const BoxDecoration(
                    border: Border(
                      left: BorderSide(color: AdminColors.line, width: 1.5),
                      bottom: BorderSide(color: AdminColors.line, width: 1.5),
                    ),
                  ),
                ),
              SizedBox(
                width: 22,
                child: hasChildren
                    ? InkWell(
                        onTap: () => controller.toggleExpanded(category.id),
                        borderRadius: BorderRadius.circular(6),
                        child: AnimatedRotation(
                          turns: isOpen ? 0.25 : 0,
                          duration: const Duration(milliseconds: 150),
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            size: 18,
                            color: AdminColors.muted,
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 4),
              AdminSwatch(seed: category.name, size: depth == 0 ? 38 : 28),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.name,
                      style: AdminText.body(13.5, weight: FontWeight.w600),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      category.description.isNotEmpty
                          ? category.description
                          : (depth == 0 ? 'Top-level category' : 'Subcategory'),
                      style: AdminText.body(12, color: AdminColors.muted),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (!isMobile) ...[
                _Meta(label: 'Products', value: '${category.productCount}'),
                const SizedBox(width: 18),
                _Meta(label: 'Sort', value: '${category.sortOrder}'),
                const SizedBox(width: 14),
                AdminBadge.status(category.isActive),
                const SizedBox(width: 14),
              ] else
                const SizedBox(width: 8),
              AdminIconButton(
                icon: Icons.edit_outlined,
                tooltip: 'Edit',
                onPressed: () => onEdit(category),
              ),
              const SizedBox(width: 6),
              AdminIconButton(
                icon: Icons.delete_outline_rounded,
                danger: true,
                tooltip: 'Delete',
                onPressed: () => onDelete(category),
              ),
            ],
          ),
        ),
        if (isMobile)
          Padding(
            padding: EdgeInsets.only(
              left: 16 + depth * 26,
              right: 16,
              bottom: 10,
              top: 2,
            ),
            child: Wrap(
              spacing: 16,
              runSpacing: 6,
              children: [
                _Meta(label: 'Products', value: '${category.productCount}'),
                _Meta(label: 'Sort', value: '${category.sortOrder}'),
                AdminBadge.status(category.isActive),
              ],
            ),
          ),
        if (depth == 0 && isOpen)
          for (final child in children)
            CategoryTreeTile(
              category: child,
              depth: depth + 1,
              controller: controller,
              onEdit: onEdit,
              onDelete: onDelete,
              onAddSubcategory: onAddSubcategory,
            )
        else if (depth > 0 && isOpen)
          for (final child in children)
            CategoryTreeTile(
              category: child,
              depth: depth + 1,
              controller: controller,
              onEdit: onEdit,
              onDelete: onDelete,
              onAddSubcategory: onAddSubcategory,
            ),
        if (depth == 0 && isOpen)
          Padding(
            padding: EdgeInsets.only(
              left: 16 + (depth + 1) * 26,
              bottom: 12,
              top: 2,
            ),
            child: TextButton.icon(
              onPressed: () => onAddSubcategory(category),
              icon: const Icon(Icons.add_rounded, size: 15),
              label: Text('Add subcategory to ${category.name}'),
              style: TextButton.styleFrom(
                foregroundColor: AdminColors.brassDark,
                textStyle: AdminText.body(12.5, weight: FontWeight.w600),
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 0),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AdminText.body(10, color: const Color(0xFFA29CB4))),
        Text(
          value,
          style: AdminText.body(
            12.5,
            color: AdminColors.muted,
            weight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
