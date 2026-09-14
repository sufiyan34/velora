class CategoryModel {
  final String id;
  final String name;
  final String description;
  final String image;

  /// Null/empty for a top-level category. When set, this category is a
  /// subcategory nested under the category with this id.
  final String? parentCategoryId;

  final int productCount;
  final int sortOrder;

  final bool isActive;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoryModel({
    required this.id,
    required this.name,
    this.description = '',
    this.image = '',
    this.parentCategoryId,
    this.productCount = 0,
    this.sortOrder = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// True for a top-level category (no parent).
  bool get isTopLevel => parentCategoryId == null || parentCategoryId!.isEmpty;

  /// True if this category is nested under another category.
  bool get isSubcategory => !isTopLevel;

  factory CategoryModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    return CategoryModel(
      id: documentId ?? map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      image: map['image']?.toString() ?? '',
      parentCategoryId: (map['parentCategoryId']?.toString().isEmpty ?? true)
          ? null
          : map['parentCategoryId'].toString(),
      productCount: _toInt(map['productCount']),
      sortOrder: _toInt(map['sortOrder']),
      isActive: map['isActive'] ?? true,
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'parentCategoryId': parentCategoryId,
      'productCount': productCount,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  CategoryModel copyWith({
    String? id,
    String? name,
    String? description,
    String? image,
    String? parentCategoryId,
    bool clearParentCategoryId = false,
    int? productCount,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      parentCategoryId: clearParentCategoryId
          ? null
          : (parentCategoryId ?? this.parentCategoryId),
      productCount: productCount ?? this.productCount,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
