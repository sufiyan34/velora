import 'package:e_commerce/utills/admin_badge.dart';
import 'package:e_commerce/utills/admin_buttons.dart';
import 'package:e_commerce/utills/admin_search_field.dart';
import 'package:e_commerce/utills/confirm_delete_dialog.dart';
import 'package:e_commerce/utills/responsive.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../controllers/category_controller.dart';
import '../../../../models/category_model.dart';
import '../../../../theme/admin_theme.dart';

import 'category_form_dialog.dart';

class CategoryListView extends StatelessWidget {
  const CategoryListView({super.key, required this.controller});

  final CategoryController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 10,
          children: [
            AdminSearchField(
              hintText: 'Search categories…',
              onChanged: (v) => controller.categorySearch.value = v,
            ),
            Obx(
              () => _StatusPills(
                value: controller.categoryStatusFilter.value,
                onChanged: (v) => controller.categoryStatusFilter.value = v,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Obx(() {
            final list = controller
                .topLevel()
                .where((c) => controller.matchesCategoryFilters(c))
                .toList();

            if (list.isEmpty) {
              return const _EmptyState(
                title: 'No categories found',
                subtitle: 'Try a different search, or add your first category.',
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: AdminColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AdminColors.line),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  if (!Responsive.isMobile(context)) const _TableHeader(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (context, i) => _CategoryRow(
                        category: list[i],
                        controller: controller,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.controller});

  final CategoryModel category;
  final CategoryController controller;

  Future<void> _delete(BuildContext context) async {
    final subCount = controller.subcategoryCountOf(category.id);
    String? warning;
    if (subCount > 0 || category.productCount > 0) {
      final parts = <String>[
        if (subCount > 0) '$subCount subcategor${subCount == 1 ? 'y' : 'ies'}',
        if (category.productCount > 0)
          '${category.productCount} product${category.productCount == 1 ? '' : 's'} tagged to it',
      ];
      warning =
          'This category has ${parts.join(' and ')}. Deleting it won\'t delete those — reassign them first if you don\'t want orphaned items.';
    }

    final confirmed = await confirmDelete(
      context: context,
      title: 'Delete category?',
      message: '"${category.name}" will be permanently removed.',
      warning: warning,
    );
    if (confirmed) {
      await controller.deleteCategory(category.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final subCount = controller.subcategoryCountOf(category.id);

    if (Responsive.isMobile(context)) {
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
                AdminSwatch(seed: category.name),
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
                      Text(
                        category.description.isEmpty
                            ? 'No description'
                            : category.description,
                        style: AdminText.body(12, color: AdminColors.muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                AdminIconButton(
                  icon: Icons.edit_outlined,
                  onPressed: () => showCategoryFormDialog(
                    context: context,
                    controller: controller,
                    category: category,
                  ),
                ),
                const SizedBox(width: 6),
                AdminIconButton(
                  icon: Icons.delete_outline_rounded,
                  danger: true,
                  onPressed: () => _delete(context),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _Meta(label: 'Subcategories', value: '$subCount'),
                _Meta(label: 'Products', value: '${category.productCount}'),
                _Meta(label: 'Sort', value: '${category.sortOrder}'),
                AdminBadge.status(category.isActive),
              ],
            ),
          ],
        ),
      );
    }

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
                AdminSwatch(seed: category.name),
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
                      Text(
                        category.description.isEmpty
                            ? 'No description'
                            : category.description,
                        style: AdminText.body(12, color: AdminColors.muted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text('$subCount', style: AdminText.body(13)),
          ),
          Expanded(
            flex: 2,
            child: Text('${category.productCount}', style: AdminText.body(13)),
          ),
          Expanded(
            flex: 1,
            child: Text('${category.sortOrder}', style: AdminText.body(13)),
          ),
          Expanded(flex: 2, child: AdminBadge.status(category.isActive)),
          SizedBox(
            width: 78,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AdminIconButton(
                  icon: Icons.edit_outlined,
                  tooltip: 'Edit',
                  onPressed: () => showCategoryFormDialog(
                    context: context,
                    controller: controller,
                    category: category,
                  ),
                ),
                const SizedBox(width: 6),
                AdminIconButton(
                  icon: Icons.delete_outline_rounded,
                  danger: true,
                  tooltip: 'Delete',
                  onPressed: () => _delete(context),
                ),
              ],
            ),
          ),
        ],
      ),
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
          Expanded(flex: 4, child: Text('CATEGORY', style: style())),
          Expanded(flex: 2, child: Text('SUBCATEGORIES', style: style())),
          Expanded(flex: 2, child: Text('PRODUCTS', style: style())),
          Expanded(flex: 1, child: Text('SORT', style: style())),
          Expanded(flex: 2, child: Text('STATUS', style: style())),
          const SizedBox(width: 78, child: Text('')),
        ],
      ),
    );
  }
}

class _StatusPills extends StatelessWidget {
  const _StatusPills({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String> onChanged;

  static const _options = [
    MapEntry('all', 'All'),
    MapEntry('active', 'Active'),
    MapEntry('inactive', 'Inactive'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFECEAF3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _options.map((entry) {
          final selected = value == entry.key;
          return InkWell(
            onTap: () => onChanged(entry.key),
            borderRadius: BorderRadius.circular(7),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AdminColors.surface : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
                boxShadow: selected
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
              child: Text(
                entry.value,
                style: AdminText.body(
                  12.5,
                  weight: FontWeight.w600,
                  color: selected ? AdminColors.ink : AdminColors.muted,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

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
          const Icon(Icons.search_rounded, size: 34, color: Color(0xFFC7C2D6)),
          const SizedBox(height: 10),
          Text(title, style: AdminText.body(14.5, weight: FontWeight.w600)),
          const SizedBox(height: 3),
          Text(subtitle, style: AdminText.body(13, color: AdminColors.muted)),
        ],
      ),
    );
  }
}
