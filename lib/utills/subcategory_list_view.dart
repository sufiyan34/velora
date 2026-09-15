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
import 'subcategory_form_dialog.dart';

class SubcategoryListView extends StatelessWidget {
  const SubcategoryListView({super.key, required this.controller});

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
              hintText: 'Search subcategories…',
              onChanged: (v) => controller.subSearch.value = v,
            ),
            Obx(
              () => _GroupDropdown(
                controller: controller,
                value: controller.subGroupFilter.value,
                onChanged: (v) => controller.subGroupFilter.value = v ?? '',
              ),
            ),
            Obx(
              () => _StatusDropdown(
                value: controller.subStatusFilter.value,
                onChanged: (v) => controller.subStatusFilter.value = v ?? 'all',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Obx(() {
            if (controller.topLevel().isEmpty) {
              return const _EmptyState(
                title: 'Add a category first',
                subtitle:
                    'Subcategories belong to a category group — create one on the Categories tab.',
              );
            }

            final list = controller
                .allSubcategories()
                .where((c) => controller.matchesSubFilters(c))
                .toList();

            if (list.isEmpty) {
              return const _EmptyState(
                title: 'No subcategories found',
                subtitle:
                    'Try a different search or filter, or add your first subcategory.',
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
                      itemBuilder: (context, i) => _SubcategoryRow(
                        subcategory: list[i],
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

class _SubcategoryRow extends StatelessWidget {
  const _SubcategoryRow({required this.subcategory, required this.controller});

  final CategoryModel subcategory;
  final CategoryController controller;

  Future<void> _delete(BuildContext context) async {
    String? warning;
    if (subcategory.productCount > 0) {
      warning =
          '${subcategory.productCount} product${subcategory.productCount == 1 ? '' : 's'} '
          'still tagged to this subcategory. Deleting it won\'t delete those — reassign them first if you don\'t want orphaned items.';
    }

    final confirmed = await confirmDelete(
      context: context,
      title: 'Delete subcategory?',
      message: '"${subcategory.name}" will be permanently removed.',
      warning: warning,
    );
    if (confirmed) {
      await controller.deleteCategory(subcategory.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupName = controller.groupNameOf(subcategory.parentCategoryId);

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
                AdminSwatch(seed: subcategory.name),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        subcategory.name,
                        style: AdminText.body(13.5, weight: FontWeight.w600),
                      ),
                      Text(
                        'In $groupName',
                        style: AdminText.body(12, color: AdminColors.muted),
                      ),
                    ],
                  ),
                ),
                AdminIconButton(
                  icon: Icons.edit_outlined,
                  onPressed: () => showSubcategoryFormDialog(
                    context: context,
                    controller: controller,
                    subcategory: subcategory,
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
                _Meta(label: 'Products', value: '${subcategory.productCount}'),
                _Meta(label: 'Sort', value: '${subcategory.sortOrder}'),
                AdminBadge.status(subcategory.isActive),
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
            flex: 3,
            child: Row(
              children: [
                AdminSwatch(seed: subcategory.name),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                    subcategory.name,
                    style: AdminText.body(13.5, weight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: AdminColors.brassTint,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  groupName,
                  style: AdminText.body(
                    11.5,
                    weight: FontWeight.w600,
                    color: AdminColors.brassDark,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${subcategory.productCount}',
              style: AdminText.body(13),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text('${subcategory.sortOrder}', style: AdminText.body(13)),
          ),
          Expanded(flex: 2, child: AdminBadge.status(subcategory.isActive)),
          SizedBox(
            width: 78,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AdminIconButton(
                  icon: Icons.edit_outlined,
                  tooltip: 'Edit',
                  onPressed: () => showSubcategoryFormDialog(
                    context: context,
                    controller: controller,
                    subcategory: subcategory,
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
          Expanded(flex: 3, child: Text('SUBCATEGORY', style: style())),
          Expanded(flex: 2, child: Text('CATEGORY GROUP', style: style())),
          Expanded(flex: 2, child: Text('PRODUCTS', style: style())),
          Expanded(flex: 1, child: Text('SORT', style: style())),
          Expanded(flex: 2, child: Text('STATUS', style: style())),
          const SizedBox(width: 78, child: Text('')),
        ],
      ),
    );
  }
}

class _GroupDropdown extends StatelessWidget {
  const _GroupDropdown({
    required this.controller,
    required this.value,
    required this.onChanged,
  });

  final CategoryController controller;
  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final groups = controller.topLevel();
    final items = <DropdownMenuItem<String>>[
      const DropdownMenuItem(value: '', child: Text('All category groups')),
      ...groups.map((g) => DropdownMenuItem(value: g.id, child: Text(g.name))),
    ];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        border: Border.all(color: AdminColors.line),
        borderRadius: BorderRadius.circular(9),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.any((i) => i.value == value) ? value : '',
          items: items,
          onChanged: onChanged,
          style: AdminText.body(13, color: AdminColors.inkSoft),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AdminColors.muted,
          ),
        ),
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.value, required this.onChanged});

  final String value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AdminColors.surface,
        border: Border.all(color: AdminColors.line),
        borderRadius: BorderRadius.circular(9),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          items: const [
            DropdownMenuItem(value: 'all', child: Text('All statuses')),
            DropdownMenuItem(value: 'active', child: Text('Active')),
            DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
          ],
          onChanged: onChanged,
          style: AdminText.body(13, color: AdminColors.inkSoft),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: AdminColors.muted,
          ),
        ),
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
      padding: const EdgeInsets.symmetric(vertical: 52, horizontal: 24),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_rounded, size: 34, color: Color(0xFFC7C2D6)),
          const SizedBox(height: 10),
          Text(
            title,
            style: AdminText.body(14.5, weight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: AdminText.body(13, color: AdminColors.muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
