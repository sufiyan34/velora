import 'package:get/get.dart';

import '../models/category_model.dart';
import '../repositories/category_repository.dart';

/// Drives the Categories & Subcategories admin screen.
///
/// The screen is two flat lists, not a tree:
/// - "Categories" = every category with no parent.
/// - "Subcategories" = every category that has a parent, shown with which
///   category group it belongs to.
///
/// A subcategory cannot itself have a parent set to another subcategory —
/// the UI only ever offers top-level categories as a "category group", so
/// nesting stays exactly two levels deep.
class CategoryController extends GetxController {
  CategoryController({CategoryRepository? repository})
    : _repo = repository ?? CategoryRepository();

  final CategoryRepository _repo;

  final categories = <CategoryModel>[].obs;
  final isLoading = true.obs;
  final isSaving = false.obs;

  // Categories tab
  final categorySearch = ''.obs;
  final categoryStatusFilter = 'all'.obs; // all | active | inactive

  // Subcategories tab
  final subSearch = ''.obs;
  final subStatusFilter = 'all'.obs; // all | active | inactive
  final subGroupFilter = ''.obs; // '' = all groups, else a category id

  @override
  void onInit() {
    super.onInit();
    _repo.watchAll().listen((list) {
      categories.assignAll(list);
      isLoading.value = false;
    }, onError: (_) => isLoading.value = false);
  }

  CategoryModel? byId(String id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Top-level categories only — these are the "category groups" a
  /// subcategory can be added under.
  List<CategoryModel> topLevel() {
    final list = categories.where((c) => c.isTopLevel).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  /// Every subcategory, regardless of which group it's under.
  List<CategoryModel> allSubcategories() {
    final list = categories.where((c) => c.isSubcategory).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  List<CategoryModel> childrenOf(String id) {
    final list = categories.where((c) => c.parentCategoryId == id).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  int subcategoryCountOf(String id) => childrenOf(id).length;

  /// "Women / Dresses" style breadcrumb, also used by the products screen.
  String categoryPath(String? id) {
    if (id == null || id.isEmpty) return '';
    final match = byId(id);
    if (match == null) return '';
    if (match.isTopLevel) return match.name;
    return '${categoryPath(match.parentCategoryId)} / ${match.name}';
  }

  String groupNameOf(String? parentId) {
    if (parentId == null || parentId.isEmpty) return '—';
    return byId(parentId)?.name ?? '—';
  }

  bool matchesCategoryFilters(CategoryModel c) {
    final term = categorySearch.value.trim().toLowerCase();
    final matchesSearch =
        term.isEmpty ||
        c.name.toLowerCase().contains(term) ||
        c.description.toLowerCase().contains(term);
    final matchesStatus = switch (categoryStatusFilter.value) {
      'active' => c.isActive,
      'inactive' => !c.isActive,
      _ => true,
    };
    return matchesSearch && matchesStatus;
  }

  bool matchesSubFilters(CategoryModel c) {
    final term = subSearch.value.trim().toLowerCase();
    final matchesSearch =
        term.isEmpty ||
        c.name.toLowerCase().contains(term) ||
        c.description.toLowerCase().contains(term);
    final matchesStatus = switch (subStatusFilter.value) {
      'active' => c.isActive,
      'inactive' => !c.isActive,
      _ => true,
    };
    final matchesGroup =
        subGroupFilter.value.isEmpty ||
        c.parentCategoryId == subGroupFilter.value;
    return matchesSearch && matchesStatus && matchesGroup;
  }

  Future<void> addCategory(CategoryModel category) async {
    isSaving.value = true;
    try {
      await _repo.create(category);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    isSaving.value = true;
    try {
      await _repo.update(category);
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteCategory(String id) => _repo.delete(id);
}
