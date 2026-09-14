import 'package:e_commerce/utills/admin_buttons.dart';
import 'package:e_commerce/utills/admin_search_field.dart';
import 'package:e_commerce/utills/category_form_dialog.dart';
import 'package:e_commerce/utills/category_tree_tile.dart';
import 'package:e_commerce/utills/confirm_delete_dialog.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/category_controller.dart';
import '../../../models/category_model.dart';
import '../../../theme/admin_theme.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CategoryController(), tag: 'categories');

    return Scaffold(
      backgroundColor: AdminColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(controller: controller),
              const SizedBox(height: 18),
              _Toolbar(controller: controller),
              const SizedBox(height: 16),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final visibleTop = controller.topLevel().where(
                    (c) =>
                        controller.matchesFilters(c) ||
                        controller.subtreeHasMatch(c.id),
                  );

                  if (visibleTop.isEmpty) {
                    return const _EmptyState();
                  }

                  return Container(
                    decoration: BoxDecoration(
                      color: AdminColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AdminColors.line),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (final c in visibleTop)
                            CategoryTreeTile(
                              category: c,
                              depth: 0,
                              controller: controller,
                              onEdit: (cat) => showCategoryFormDialog(
                                context: context,
                                controller: controller,
                                category: cat,
                              ),
                              onDelete: (cat) => _confirmDeleteCategory(
                                context,
                                controller,
                                cat,
                              ),
                              onAddSubcategory: (parent) =>
                                  showCategoryFormDialog(
                                    context: context,
                                    controller: controller,
                                    presetParentId: parent.id,
                                  ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDeleteCategory(
    BuildContext context,
    CategoryController controller,
    CategoryModel category,
  ) async {
    final children = controller.childrenOf(category.id);
    String? warning;
    if (children.isNotEmpty || category.productCount > 0) {
      final parts = <String>[
        if (children.isNotEmpty)
          '${children.length} subcategor${children.length == 1 ? 'y' : 'ies'}',
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
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final CategoryController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Categories', style: AdminText.display(26)),
              const SizedBox(height: 4),
              Obx(
                () => Text(
                  '${controller.categories.length} categories, including subcategories',
                  style: AdminText.body(13.5, color: AdminColors.muted),
                ),
              ),
            ],
          ),
        ),
        AdminPrimaryButton(
          label: 'Add category',
          icon: Icons.add_rounded,
          onPressed: () =>
              showCategoryFormDialog(context: context, controller: controller),
        ),
      ],
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.controller});

  final CategoryController controller;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 10,
      children: [
        AdminSearchField(
          hintText: 'Search categories & subcategories…',
          onChanged: (v) => controller.searchTerm.value = v,
        ),
        Obx(
          () => _FilterPills(
            value: controller.statusFilter.value,
            onChanged: (v) => controller.statusFilter.value = v,
          ),
        ),
      ],
    );
  }
}

class _FilterPills extends StatelessWidget {
  const _FilterPills({required this.value, required this.onChanged});

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
  const _EmptyState();

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
          Text(
            'No categories found',
            style: AdminText.body(14.5, weight: FontWeight.w600),
          ),
          const SizedBox(height: 3),
          Text(
            'Try a different search, or add your first category.',
            style: AdminText.body(13, color: AdminColors.muted),
          ),
        ],
      ),
    );
  }
}
