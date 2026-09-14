class CartModel {
  final String id;
  final String productId;

  final String productName;
  final String productImage;

  final double price;
  final double? originalPrice;

  final int quantity;

  final String? variationId;
  final String? variationName;
  final String? variationValue;

  final DateTime? addedAt;

  const CartModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    this.originalPrice,
    this.quantity = 1,
    this.variationId,
    this.variationName,
    this.variationValue,
    this.addedAt,
  });

  double get totalPrice => price * quantity;

  bool get hasVariation => variationId != null && variationId!.isNotEmpty;

  String get variationDisplayName {
    if (!hasVariation) return '';

    if (variationName != null && variationValue != null) {
      return '$variationName: $variationValue';
    }

    return variationValue ?? '';
  }

  factory CartModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return CartModel(
      id: documentId ?? map['id']?.toString() ?? '',
      productId: map['productId']?.toString() ?? '',
      productName: map['productName']?.toString() ?? '',
      productImage: map['productImage']?.toString() ?? '',
      price: _toDouble(map['price']),
      originalPrice: map['originalPrice'] != null
          ? _toDouble(map['originalPrice'])
          : null,
      quantity: _toInt(map['quantity']),
      variationId: map['variationId']?.toString(),
      variationName: map['variationName']?.toString(),
      variationValue: map['variationValue']?.toString(),
      addedAt: _parseDate(map['addedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'originalPrice': originalPrice,
      'quantity': quantity,
      'variationId': variationId,
      'variationName': variationName,
      'variationValue': variationValue,
      'addedAt': addedAt?.toIso8601String(),
    };
  }

  CartModel copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    double? originalPrice,
    int? quantity,
    String? variationId,
    String? variationName,
    String? variationValue,
    DateTime? addedAt,
  }) {
    return CartModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      quantity: quantity ?? this.quantity,
      variationId: variationId ?? this.variationId,
      variationName: variationName ?? this.variationName,
      variationValue: variationValue ?? this.variationValue,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 1;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}
