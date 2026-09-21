import 'dart:async';

import 'package:get/get.dart';

import '../models/category_model.dart';
import '../repositories/category_repository.dart';
import '../services/local_cache_service.dart';

class CustomerCategoryController extends GetxController {
  CustomerCategoryController({CategoryRepository? repository})
      : _repository = repository ?? CategoryRepository();

  final CategoryRepository _repository;

  static const String _cacheKey = 'cache_all_categories';

  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  StreamSubscription<List<CategoryModel>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _loadFromCache();
    _listen();
  }

  /// Shows the last known category tree immediately (categories/
  /// subcategories rarely change), while the live listener below quietly
  /// refreshes it.
  Future<void> _loadFromCache() async {
    final cached = await LocalCacheService.readJson(_cacheKey);

    if (cached is List && cached.isNotEmpty && categories.isEmpty) {
      final parsed = cached
          .whereType<Map>()
          .map(
            (item) => CategoryModel.fromMap(Map<String, dynamic>.from(item)),
          )
          .where((category) => category.isActive)
          .toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      if (parsed.isNotEmpty) {
        categories.assignAll(parsed);
        isLoading.value = false;
      }
    }
  }

  void _listen() {
    errorMessage.value = '';

    _subscription = _repository.watchAll().listen(
      (items) {
        final active = items.where((category) => category.isActive).toList()
          ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

        categories.assignAll(active);
        isLoading.value = false;

        LocalCacheService.saveJson(
          _cacheKey,
          items.map((category) => category.toMap()).toList(),
        );
      },
      onError: (error) {
        errorMessage.value = error.toString();
        isLoading.value = false;
      },
    );
  }

  List<CategoryModel> get topLevelCategories {
    return categories.where((category) => category.isTopLevel).toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  List<CategoryModel> subcategoriesOf(String parentId) {
    return categories
        .where(
          (category) => category.parentCategoryId == parentId &&
              category.isActive,
        )
        .toList()
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  CategoryModel? byId(String id) {
    for (final category in categories) {
      if (category.id == id) return category;
    }
    return null;
  }

  int subcategoryCount(String parentId) => subcategoriesOf(parentId).length;

  Future<void> refresh() async {
    await _subscription?.cancel();
    _subscription = null;
    _listen();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
