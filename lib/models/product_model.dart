class ProductModel {
  final String id;
  final String name;
  final String description;
  final String? videoUrl;
  final String categoryId;
  final String categoryName;
  final String brand;
  final String sku;

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

  // ==========================================================
  // OPTIONAL 3D PRODUCT
  // ==========================================================

  /// Main 3D model URL.
  /// Recommended format: GLB / GLTF
  final String? model3dUrl;

  /// Optional iOS Quick Look model.
  /// Recommended format: USDZ
  final String? model3dIosUrl;

  /// Automatically rotate the 3D model.
  final bool model3dAutoRotate;

  /// Enable AR where supported.
  final bool model3dArEnabled;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    this.brand = '',
    this.sku = '',
    required this.price,
    this.salePrice,
    this.stock = 0,
    this.soldCount = 0,
    this.images = const [],
    this.videoUrl,
    this.variations = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isActive = true,
    this.isFeatured = false,
    this.isNew = false,
    this.isOnSale = false,

    // 3D is optional.
    this.model3dUrl,
    this.model3dIosUrl,
    this.model3dAutoRotate = true,
    this.model3dArEnabled = false,

    this.createdAt,
    this.updatedAt,
  });

  // ==========================================================
  // PRICE
  // ==========================================================

  double get finalPrice => salePrice ?? price;

  bool get hasDiscount => salePrice != null && salePrice! < price;

  double get discountPercentage {
    if (!hasDiscount || price <= 0) return 0;

    return ((price - salePrice!) / price) * 100;
  }

  // ==========================================================
  // STOCK
  // ==========================================================

  bool get isOutOfStock => stock <= 0;

  bool get isLowStock => stock > 0 && stock <= 5;

  // ==========================================================
  // IMAGE
  // ==========================================================

  String get thumbnail => images.isEmpty ? '' : images.first;
  // ==========================================================
  // VIDEO
  // ==========================================================

  bool get hasVideo {
    return videoUrl != null && videoUrl!.trim().isNotEmpty;
  }
  // ==========================================================
  // 3D
  // ==========================================================

  /// True when the product has a usable 3D model URL.
  bool get has3dModel {
    return model3dUrl != null && model3dUrl!.trim().isNotEmpty;
  }

  // ==========================================================
  // RTDB STRING LIST PARSER
  // ==========================================================

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value
          .where((item) => item != null)
          .map((item) => item.toString())
          .toList();
    }

    if (value is Map) {
      return value.values
          .where((item) => item != null)
          .map((item) => item.toString())
          .toList();
    }

    return [];
  }

  // ==========================================================
  // RTDB VARIATION PARSER
  // ==========================================================

  static List<ProductVariation> _parseVariations(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value
          .whereType<Map>()
          .map(
            (item) => ProductVariation.fromMap(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    if (value is Map) {
      return value.values
          .whereType<Map>()
          .map(
            (item) => ProductVariation.fromMap(Map<String, dynamic>.from(item)),
          )
          .toList();
    }

    return [];
  }

  // ==========================================================
  // FROM MAP
  // ==========================================================

  factory ProductModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return ProductModel(
      id: documentId ?? map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      videoUrl: _nullableString(map['videoUrl']),
      categoryId: map['categoryId']?.toString() ?? '',
      categoryName: map['categoryName']?.toString() ?? '',

      brand: map['brand']?.toString() ?? '',
      sku: map['sku']?.toString() ?? '',

      price: _toDouble(map['price']),

      salePrice: map['salePrice'] != null ? _toDouble(map['salePrice']) : null,

      stock: _toInt(map['stock']),
      soldCount: _toInt(map['soldCount']),

      images: _parseStringList(map['images']),

      variations: _parseVariations(map['variations']),

      rating: _toDouble(map['rating']),
      reviewCount: _toInt(map['reviewCount']),

      isActive: map['isActive'] is bool ? map['isActive'] as bool : true,

      isFeatured: map['isFeatured'] is bool ? map['isFeatured'] as bool : false,

      isNew: map['isNew'] is bool ? map['isNew'] as bool : false,

      isOnSale: map['isOnSale'] is bool ? map['isOnSale'] as bool : false,

      // ======================================================
      // 3D
      // ======================================================
      model3dUrl: _nullableString(map['model3dUrl']),

      model3dIosUrl: _nullableString(map['model3dIosUrl']),

      model3dAutoRotate: map['model3dAutoRotate'] is bool
          ? map['model3dAutoRotate'] as bool
          : true,

      model3dArEnabled: map['model3dArEnabled'] is bool
          ? map['model3dArEnabled'] as bool
          : false,

      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  // ==========================================================
  // TO MAP
  // ==========================================================

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,

      'categoryId': categoryId,
      'categoryName': categoryName,

      'brand': brand,
      'sku': sku,

      'price': price,
      'salePrice': salePrice,

      'stock': stock,
      'soldCount': soldCount,
      'videoUrl': videoUrl,
      'images': images,

      'variations': variations.map((variation) => variation.toMap()).toList(),

      'rating': rating,
      'reviewCount': reviewCount,

      'isActive': isActive,
      'isFeatured': isFeatured,
      'isNew': isNew,
      'isOnSale': isOnSale,

      // ======================================================
      // 3D
      // ======================================================
      'model3dUrl': model3dUrl,
      'model3dIosUrl': model3dIosUrl,
      'model3dAutoRotate': model3dAutoRotate,
      'model3dArEnabled': model3dArEnabled,

      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // ==========================================================
  // COPY WITH
  // ==========================================================

  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    String? categoryName,
    String? brand,
    String? sku,
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
    String? videoUrl,
    String? model3dUrl,
    String? model3dIosUrl,
    bool? model3dAutoRotate,
    bool? model3dArEnabled,

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
      sku: sku ?? this.sku,
      videoUrl: videoUrl ?? this.videoUrl,
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

      model3dUrl: model3dUrl ?? this.model3dUrl,
      model3dIosUrl: model3dIosUrl ?? this.model3dIosUrl,
      model3dAutoRotate: model3dAutoRotate ?? this.model3dAutoRotate,
      model3dArEnabled: model3dArEnabled ?? this.model3dArEnabled,

      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  static String? _nullableString(dynamic value) {
    final valueString = value?.toString().trim();

    if (valueString == null || valueString.isEmpty) {
      return null;
    }

    return valueString;
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

// ============================================================
// PRODUCT VARIATION
// ============================================================

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
