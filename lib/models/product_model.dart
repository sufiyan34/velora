class ProductModel {
  final String id;
  final String name;
  final String description;

  final String categoryId;
  final String categoryName;
  final String brand;

  final double price;
  final double? salePrice;

  final int stock;
  final int soldCount;

  final List<String> images;
  final List<ProductVariation> variations;

  final double rating;
  final int reviewCount;

  final bool isActive;
  final bool isFeatured;
  final bool isNew;
  final bool isOnSale;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    this.brand = '',
    required this.price,
    this.salePrice,
    this.stock = 0,
    this.soldCount = 0,
    this.images = const [],
    this.variations = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.isNew = false,
    this.isOnSale = false,
    this.createdAt,
    this.updatedAt,
  });

  double get finalPrice => salePrice ?? price;

  bool get hasDiscount => salePrice != null && salePrice! < price;

  double get discountPercentage {
    if (!hasDiscount || price <= 0) return 0;
    return ((price - salePrice!) / price) * 100;
  }

  bool get isOutOfStock => stock <= 0;

  bool get isLowStock => stock > 0 && stock <= 5;

  String get thumbnail => images.isEmpty ? '' : images.first;

  factory ProductModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return ProductModel(
      id: documentId ?? map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      categoryId: map['categoryId']?.toString() ?? '',
      categoryName: map['categoryName']?.toString() ?? '',
      brand: map['brand']?.toString() ?? '',
      price: _toDouble(map['price']),
      salePrice: map['salePrice'] != null ? _toDouble(map['salePrice']) : null,
      stock: _toInt(map['stock']),
      soldCount: _toInt(map['soldCount']),
      images: List<String>.from(map['images'] ?? []),
      variations:
          (map['variations'] as List?)
              ?.map(
                (e) => ProductVariation.fromMap(Map<String, dynamic>.from(e)),
              )
              .toList() ??
          [],
      rating: _toDouble(map['rating']),
      reviewCount: _toInt(map['reviewCount']),
      isActive: map['isActive'] ?? true,
      isFeatured: map['isFeatured'] ?? false,
      isNew: map['isNew'] ?? false,
      isOnSale: map['isOnSale'] ?? false,
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'brand': brand,
      'price': price,
      'salePrice': salePrice,
      'stock': stock,
      'soldCount': soldCount,
      'images': images,
      'variations': variations.map((e) => e.toMap()).toList(),
      'rating': rating,
      'reviewCount': reviewCount,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'isNew': isNew,
      'isOnSale': isOnSale,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    String? categoryName,
    String? brand,
    double? price,
    double? salePrice,
    int? stock,
    int? soldCount,
    List<String>? images,
    List<ProductVariation>? variations,
    double? rating,
    int? reviewCount,
    bool? isActive,
    bool? isFeatured,
    bool? isNew,
    bool? isOnSale,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      salePrice: salePrice ?? this.salePrice,
      stock: stock ?? this.stock,
      soldCount: soldCount ?? this.soldCount,
      images: images ?? this.images,
      variations: variations ?? this.variations,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      isNew: isNew ?? this.isNew,
      isOnSale: isOnSale ?? this.isOnSale,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
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

class ProductVariation {
  final String id;
  final String name;
  final String value;
  final double? additionalPrice;
  final int stock;
  final String image;

  const ProductVariation({
    required this.id,
    required this.name,
    required this.value,
    this.additionalPrice,
    this.stock = 0,
    this.image = '',
  });

  factory ProductVariation.fromMap(Map<String, dynamic> map) {
    return ProductVariation(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      value: map['value']?.toString() ?? '',
      additionalPrice: map['additionalPrice'] != null
          ? _toDouble(map['additionalPrice'])
          : null,
      stock: _toInt(map['stock']),
      image: map['image']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'value': value,
      'additionalPrice': additionalPrice,
      'stock': stock,
      'image': image,
    };
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
