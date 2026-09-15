import 'package:e_commerce/utills/admin_buttons.dart';
import 'package:e_commerce/utills/category_form_dialog.dart';
import 'package:e_commerce/utills/category_list_view.dart';
import 'package:e_commerce/utills/subcategory_form_dialog.dart';
import 'package:e_commerce/utills/subcategory_list_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/category_controller.dart';
import '../../../theme/admin_theme.dart';

/// Categories & Subcategories admin screen.
///
/// Two plain, separate lists rather than a nested tree:
/// - "Categories" tab — add/edit/delete top-level categories.
/// - "Subcategories" tab — add/edit/delete subcategories, each one tied to
///   a category group picked from a dropdown.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late final CategoryController _controller;
  int _tab = 0; // 0 = Categories, 1 = Subcategories

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<CategoryController>(tag: 'categories')
        ? Get.find<CategoryController>(tag: 'categories')
        : Get.put(CategoryController(), tag: 'categories');
  }

  void _onAddPressed() {
    if (_tab == 0) {
      showCategoryFormDialog(context: context, controller: _controller);
    } else {
      showSubcategoryFormDialog(context: context, controller: _controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AdminColors.canvas,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                controller: _controller,
                onAddPressed: _onAddPressed,
                tab: _tab,
              ),
              const SizedBox(height: 16),
              _TabSwitcher(
                tab: _tab,
                onChanged: (i) => setState(() => _tab = i),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Obx(() {
                  if (_controller.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return _tab == 0
                      ? CategoryListView(controller: _controller)
                      : SubcategoryListView(controller: _controller);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.controller,
    required this.onAddPressed,
    required this.tab,
  });

  final CategoryController controller;
  final VoidCallback onAddPressed;
  final int tab;

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
                  '${controller.topLevel().length} categories · '
                  '${controller.allSubcategories().length} subcategories',
                  style: AdminText.body(13.5, color: AdminColors.muted),
                ),
              ),
            ],
          ),
        ),
        AdminPrimaryButton(
          label: tab == 0 ? 'Add category' : 'Add subcategory',
          icon: Icons.add_rounded,
          onPressed: onAddPressed,
        ),
      ],
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  const _TabSwitcher({required this.tab, required this.onChanged});

  final int tab;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _TabButton(
          label: 'Categories',
          selected: tab == 0,
          onTap: () => onChanged(0),
        ),
        const SizedBox(width: 8),
        _TabButton(
          label: 'Subcategories',
          selected: tab == 1,
          onTap: () => onChanged(1),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AdminColors.ink : AdminColors.surface,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: selected ? AdminColors.ink : AdminColors.line,
          ),
        ),
        child: Text(
          label,
          style: AdminText.body(
            13.5,
            weight: FontWeight.w600,
            color: selected ? Colors.white : AdminColors.inkSoft,
          ),
        ),
      ),
    );
  }
}
