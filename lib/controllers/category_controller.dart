import 'package:get/get.dart';

import '../models/category_model.dart';
import '../repositories/category_repository.dart';

/// Drives the Categories & Subcategories admin screen.
///
/// Categories are kept as one flat, reactive list; the screen builds the
/// nested tree from `parentCategoryId` using the helpers below, so adding a
/// subcategory is just adding a category with a parent set.
class CategoryController extends GetxController {
  CategoryController({CategoryRepository? repository})
      : _repo = repository ?? CategoryRepository();

  final CategoryRepository _repo;

  final categories = <CategoryModel>[].obs;
  final isLoading = true.obs;
  final isSaving = false.obs;

  final searchTerm = ''.obs;
  final statusFilter = 'all'.obs; // all | active | inactive
  final expandedIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _repo.watchAll().listen((list) {
      categories.assignAll(list);
      isLoading.value = false;
      if (expandedIds.isEmpty) {
        expandedIds.addAll(
          list.where((c) => c.isTopLevel).map((c) => c.id),
        );
      }
    }, onError: (_) => isLoading.value = false);
  }

  CategoryModel? byId(String id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<CategoryModel> topLevel() {
    final list = categories.where((c) => c.isTopLevel).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  List<CategoryModel> childrenOf(String id) {
    final list = categories.where((c) => c.parentCategoryId == id).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  /// Every id nested under [id], at any depth — used to stop a category
  /// being re-parented under its own descendant.
  List<String> allDescendants(String id) {
    final out = <String>[];
    for (final child in childrenOf(id)) {
      out.add(child.id);
      out.addAll(allDescendants(child.id));
    }
    return out;
  }

  /// "Women / Dresses" style breadcrumb, used on the products screen too.
  String categoryPath(String? id) {
    if (id == null || id.isEmpty) return '';
    final match = byId(id);
    if (match == null) return '';
    if (match.isTopLevel) return match.name;
    return '${categoryPath(match.parentCategoryId)} / ${match.name}';
  }

  bool matchesFilters(CategoryModel c) {
    final term = searchTerm.value.trim().toLowerCase();
    final matchesSearch = term.isEmpty ||
        c.name.toLowerCase().contains(term) ||
        c.description.toLowerCase().contains(term);
    final matchesStatus = switch (statusFilter.value) {
      'active' => c.isActive,
      'inactive' => !c.isActive,
      _ => true,
    };
    return matchesSearch && matchesStatus;
  }

  /// True if this category itself doesn't match the current filters but a
  /// descendant does — the screen keeps the parent visible in that case so
  /// the match isn't hidden inside a collapsed branch.
  bool subtreeHasMatch(String id) {
    return childrenOf(id).any(
      (c) => matchesFilters(c) || subtreeHasMatch(c.id),
    );
  }

  bool isExpanded(String id) => expandedIds.contains(id);

  void toggleExpanded(String id) {
    if (expandedIds.contains(id)) {
      expandedIds.remove(id);
    } else {
      expandedIds.add(id);
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    isSaving.value = true;
    try {
      await _repo.create(category);
      if (category.parentCategoryId != null) {
        expandedIds.add(category.parentCategoryId!);
      }
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
