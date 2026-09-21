import 'order_model.dart' show OrderItem;

// ============================================================
// RETURN ITEM
// ============================================================
//
// A single line item being returned, derived from the original
// [OrderItem] it was purchased as. Keeps its own return quantity so a
// customer can return only part of what they originally ordered.

class ReturnItem {
  final String productId;
  final String productName;
  final String productImage;

  final double price;
  final int orderedQuantity;
  final int returnQuantity;

  final String? variationDisplayName;

  const ReturnItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.orderedQuantity,
    required this.returnQuantity,
    this.variationDisplayName,
  });

  double get subtotal => price * returnQuantity;

  factory ReturnItem.fromOrderItem(
    OrderItem item, {
    required int returnQuantity,
  }) {
    return ReturnItem(
      productId: item.productId,
      productName: item.productName,
      productImage: item.productImage,
      price: item.price,
      orderedQuantity: item.quantity,
      returnQuantity: returnQuantity,
      variationDisplayName: item.hasVariation
          ? item.variationDisplayName
          : null,
    );
  }

  factory ReturnItem.fromMap(Map<String, dynamic> map) {
    return ReturnItem(
      productId: map['productId']?.toString() ?? '',
      productName: map['productName']?.toString() ?? '',
      productImage: map['productImage']?.toString() ?? '',
      price: _toDouble(map['price']),
      orderedQuantity: _toInt(map['orderedQuantity']),
      returnQuantity: _toInt(map['returnQuantity']),
      variationDisplayName: _nullableString(map['variationDisplayName']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'orderedQuantity': orderedQuantity,
      'returnQuantity': returnQuantity,
      'variationDisplayName': variationDisplayName,
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

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    final result = value.toString().trim();
    return result.isEmpty ? null : result;
  }
}

// ============================================================
// RETURN REQUEST
// ============================================================
//
// A customer-submitted request to return one or more items from a
// delivered order. Stored under `returns/{id}` with a lightweight
// reference under `users/{userId}/returns/{id}` — the same pattern
// [OrderModel] uses for `orders/`.

class ReturnRequestModel {
  final String id;
  final String userId;
  final String orderId;

  final List<ReturnItem> items;

  final String reason;
  final String description;

  /// refund | exchange | store_credit
  final String resolution;

  /// pending | approved | rejected | completed
  final String status;

  final List<String> photoUrls;

  final String? adminNote;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ReturnRequestModel({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.items,
    required this.reason,
    this.description = '',
    this.resolution = 'refund',
    this.status = 'pending',
    this.photoUrls = const [],
    this.adminNote,
    this.createdAt,
    this.updatedAt,
  });

  // ------------------------------------------------------------
  // HELPERS
  // ------------------------------------------------------------

  int get itemCount {
    return items.fold(0, (total, item) => total + item.returnQuantity);
  }

  double get estimatedRefund {
    return items.fold(0.0, (total, item) => total + item.subtotal);
  }

  bool get isPending => status == 'pending';

  bool get isApproved => status == 'approved';

  bool get isRejected => status == 'rejected';

  bool get isCompleted => status == 'completed';

  /// A request is still "open" while it hasn't been rejected — rejected
  /// requests don't block a customer from filing a new one on the same
  /// order.
  bool get isActive => !isRejected;

  // ------------------------------------------------------------
  // FIREBASE REALTIME DATABASE
  // ------------------------------------------------------------

  factory ReturnRequestModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    return ReturnRequestModel(
      id: documentId ?? map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      orderId: map['orderId']?.toString() ?? '',
      items: _parseItems(map['items']),
      reason: map['reason']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      resolution: map['resolution']?.toString() ?? 'refund',
      status: map['status']?.toString() ?? 'pending',
      photoUrls: _parseStringList(map['photoUrls']),
      adminNote: _nullableString(map['adminNote']),
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'orderId': orderId,
      'items': items.map((item) => item.toMap()).toList(),
      'reason': reason,
      'description': description,
      'resolution': resolution,
      'status': status,
      'photoUrls': photoUrls,
      'adminNote': adminNote,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  ReturnRequestModel copyWith({
    String? id,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReturnRequestModel(
      id: id ?? this.id,
      userId: userId,
      orderId: orderId,
      items: items,
      reason: reason,
      description: description,
      resolution: resolution,
      status: status ?? this.status,
      photoUrls: photoUrls,
      adminNote: adminNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static List<ReturnItem> _parseItems(dynamic value) {
    if (value == null) return [];

    final result = <ReturnItem>[];

    if (value is List) {
      for (final item in value) {
        if (item is Map) {
          result.add(ReturnItem.fromMap(Map<String, dynamic>.from(item)));
        }
      }

      return result;
    }

    if (value is Map) {
      for (final entry in value.entries) {
        if (entry.value is Map) {
          result.add(
            ReturnItem.fromMap(Map<String, dynamic>.from(entry.value as Map)),
          );
        }
      }
    }

    return result;
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];

    if (value is List) {
      return value
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList();
    }

    if (value is Map) {
      return value.values
          .map((item) => item.toString())
          .where((item) => item.trim().isNotEmpty)
          .toList();
    }

    return [];
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;

    final result = value.toString().trim();

    return result.isEmpty ? null : result;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

// ============================================================
// RETURN REASONS
// ============================================================
//
// Fixed set of reasons offered in the return form UI.

class ReturnReasons {
  ReturnReasons._();

  static const List<String> all = [
    'Damaged or defective',
    'Wrong item delivered',
    'Size or fit issue',
    'Not as described',
    'No longer needed',
    'Better price found elsewhere',
    'Other',
  ];
}
