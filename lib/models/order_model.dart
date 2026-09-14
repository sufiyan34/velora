// class OrderModel {
//   final String id;
//   final String userId;

//   final List<OrderItem> items;

//   final double subtotal;
//   final double shippingFee;
//   final double discount;
//   final double total;

//   final String currency;

//   final String paymentMethod;
//   final String paymentStatus;
//   final String? transactionId;

//   final String orderStatus;

//   final ShippingAddress shippingAddress;

//   final String? customerNote;
//   final String? adminNote;

//   final DateTime? createdAt;
//   final DateTime? updatedAt;
//   final DateTime? acceptedAt;
//   final DateTime? dispatchedAt;
//   final DateTime? deliveredAt;
//   final DateTime? cancelledAt;

//   const OrderModel({
//     required this.id,
//     required this.userId,
//     required this.items,
//     required this.subtotal,
//     required this.shippingFee,
//     required this.discount,
//     required this.total,
//     this.currency = 'PKR',
//     required this.paymentMethod,
//     required this.paymentStatus,
//     this.transactionId,
//     this.orderStatus = 'pending',
//     required this.shippingAddress,
//     this.customerNote,
//     this.adminNote,
//     this.createdAt,
//     this.updatedAt,
//     this.acceptedAt,
//     this.dispatchedAt,
//     this.deliveredAt,
//     this.cancelledAt,
//   });

//   // ==========================================================
//   // STATUS HELPERS
//   // ==========================================================

//   bool get isPending => orderStatus == 'pending';

//   bool get isAccepted => orderStatus == 'accepted';

//   bool get isProcessing => orderStatus == 'processing';

//   bool get isDispatched => orderStatus == 'dispatched';

//   bool get isDelivered => orderStatus == 'delivered';

//   bool get isCancelled => orderStatus == 'cancelled';

//   bool get isRejected => orderStatus == 'rejected';

//   // ==========================================================
//   // FIREBASE
//   // ==========================================================

//   factory OrderModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
//     return OrderModel(
//       id: documentId ?? map['id']?.toString() ?? '',
//       userId: map['userId']?.toString() ?? '',

//       items:
//           (map['items'] as List?)
//               ?.map(
//                 (item) => OrderItem.fromMap(Map<String, dynamic>.from(item)),
//               )
//               .toList() ??
//           [],

//       subtotal: _toDouble(map['subtotal']),
//       shippingFee: _toDouble(map['shippingFee']),
//       discount: _toDouble(map['discount']),
//       total: _toDouble(map['total']),

//       currency: map['currency']?.toString() ?? 'PKR',

//       paymentMethod: map['paymentMethod']?.toString() ?? '',

//       paymentStatus: map['paymentStatus']?.toString() ?? 'pending',

//       transactionId: map['transactionId']?.toString(),

//       orderStatus: map['orderStatus']?.toString() ?? 'pending',

//       shippingAddress: ShippingAddress.fromMap(
//         Map<String, dynamic>.from(map['shippingAddress'] ?? {}),
//       ),

//       customerNote: map['customerNote']?.toString(),

//       adminNote: map['adminNote']?.toString(),

//       createdAt: _parseDate(map['createdAt']),
//       updatedAt: _parseDate(map['updatedAt']),
//       acceptedAt: _parseDate(map['acceptedAt']),
//       dispatchedAt: _parseDate(map['dispatchedAt']),
//       deliveredAt: _parseDate(map['deliveredAt']),
//       cancelledAt: _parseDate(map['cancelledAt']),
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'userId': userId,
//       'items': items.map((item) => item.toMap()).toList(),
//       'subtotal': subtotal,
//       'shippingFee': shippingFee,
//       'discount': discount,
//       'total': total,
//       'currency': currency,
//       'paymentMethod': paymentMethod,
//       'paymentStatus': paymentStatus,
//       'transactionId': transactionId,
//       'orderStatus': orderStatus,
//       'shippingAddress': shippingAddress.toMap(),
//       'customerNote': customerNote,
//       'adminNote': adminNote,
//       'createdAt': createdAt?.toIso8601String(),
//       'updatedAt': updatedAt?.toIso8601String(),
//       'acceptedAt': acceptedAt?.toIso8601String(),
//       'dispatchedAt': dispatchedAt?.toIso8601String(),
//       'deliveredAt': deliveredAt?.toIso8601String(),
//       'cancelledAt': cancelledAt?.toIso8601String(),
//     };
//   }

//   OrderModel copyWith({
//     String? id,
//     String? userId,
//     List<OrderItem>? items,
//     double? subtotal,
//     double? shippingFee,
//     double? discount,
//     double? total,
//     String? currency,
//     String? paymentMethod,
//     String? paymentStatus,
//     String? transactionId,
//     String? orderStatus,
//     ShippingAddress? shippingAddress,
//     String? customerNote,
//     String? adminNote,
//     DateTime? createdAt,
//     DateTime? updatedAt,
//     DateTime? acceptedAt,
//     DateTime? dispatchedAt,
//     DateTime? deliveredAt,
//     DateTime? cancelledAt,
//   }) {
//     return OrderModel(
//       id: id ?? this.id,
//       userId: userId ?? this.userId,
//       items: items ?? this.items,
//       subtotal: subtotal ?? this.subtotal,
//       shippingFee: shippingFee ?? this.shippingFee,
//       discount: discount ?? this.discount,
//       total: total ?? this.total,
//       currency: currency ?? this.currency,
//       paymentMethod: paymentMethod ?? this.paymentMethod,
//       paymentStatus: paymentStatus ?? this.paymentStatus,
//       transactionId: transactionId ?? this.transactionId,
//       orderStatus: orderStatus ?? this.orderStatus,
//       shippingAddress: shippingAddress ?? this.shippingAddress,
//       customerNote: customerNote ?? this.customerNote,
//       adminNote: adminNote ?? this.adminNote,
//       createdAt: createdAt ?? this.createdAt,
//       updatedAt: updatedAt ?? this.updatedAt,
//       acceptedAt: acceptedAt ?? this.acceptedAt,
//       dispatchedAt: dispatchedAt ?? this.dispatchedAt,
//       deliveredAt: deliveredAt ?? this.deliveredAt,
//       cancelledAt: cancelledAt ?? this.cancelledAt,
//     );
//   }

//   static double _toDouble(dynamic value) {
//     if (value is num) return value.toDouble();
//     return double.tryParse(value?.toString() ?? '') ?? 0;
//   }

//   static DateTime? _parseDate(dynamic value) {
//     if (value == null) return null;
//     if (value is DateTime) return value;
//     return DateTime.tryParse(value.toString());
//   }
// }

// // ============================================================
// // ORDER ITEM
// // ============================================================

// class OrderItem {
//   final String productId;
//   final String productName;
//   final String productImage;

//   final double price;
//   final int quantity;

//   final String? variationId;
//   final String? variationName;
//   final String? variationValue;

//   const OrderItem({
//     required this.productId,
//     required this.productName,
//     required this.productImage,
//     required this.price,
//     required this.quantity,
//     this.variationId,
//     this.variationName,
//     this.variationValue,
//   });

//   double get total => price * quantity;

//   factory OrderItem.fromMap(Map<String, dynamic> map) {
//     return OrderItem(
//       productId: map['productId']?.toString() ?? '',
//       productName: map['productName']?.toString() ?? '',
//       productImage: map['productImage']?.toString() ?? '',
//       price: _toDouble(map['price']),
//       quantity: _toInt(map['quantity']),
//       variationId: map['variationId']?.toString(),
//       variationName: map['variationName']?.toString(),
//       variationValue: map['variationValue']?.toString(),
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'productId': productId,
//       'productName': productName,
//       'productImage': productImage,
//       'price': price,
//       'quantity': quantity,
//       'variationId': variationId,
//       'variationName': variationName,
//       'variationValue': variationValue,
//     };
//   }

//   static double _toDouble(dynamic value) {
//     if (value is num) return value.toDouble();
//     return double.tryParse(value?.toString() ?? '') ?? 0;
//   }

//   static int _toInt(dynamic value) {
//     if (value is num) return value.toInt();
//     return int.tryParse(value?.toString() ?? '') ?? 1;
//   }
// }
// // ============================================================
// // SHIPPING ADDRESS
// // ============================================================

// class ShippingAddress {
//   final String fullName;
//   final String phone;
//   final String address;
//   final String city;
//   final String state;
//   final String postalCode;
//   final String country;

//   const ShippingAddress({
//     required this.fullName,
//     required this.phone,
//     required this.address,
//     required this.city,
//     this.state = '',
//     this.postalCode = '',
//     this.country = 'Pakistan',
//   });

//   factory ShippingAddress.fromMap(Map<String, dynamic> map) {
//     return ShippingAddress(
//       fullName: map['fullName']?.toString() ?? '',
//       phone: map['phone']?.toString() ?? '',
//       address: map['address']?.toString() ?? '',
//       city: map['city']?.toString() ?? '',
//       state: map['state']?.toString() ?? '',
//       postalCode: map['postalCode']?.toString() ?? '',
//       country: map['country']?.toString() ?? 'Pakistan',
//     );
//   }

//   Map<String, dynamic> toMap() {
//     return {
//       'fullName': fullName,
//       'phone': phone,
//       'address': address,
//       'city': city,
//       'state': state,
//       'postalCode': postalCode,
//       'country': country,
//     };
//   }

//   ShippingAddress copyWith({
//     String? fullName,
//     String? phone,
//     String? address,
//     String? city,
//     String? state,
//     String? postalCode,
//     String? country,
//   }) {
//     return ShippingAddress(
//       fullName: fullName ?? this.fullName,
//       phone: phone ?? this.phone,
//       address: address ?? this.address,
//       city: city ?? this.city,
//       state: state ?? this.state,
//       postalCode: postalCode ?? this.postalCode,
//       country: country ?? this.country,
//     );
//   }
// }

class OrderModel {
  final String id;
  final String userId;

  // ============================================================
  // ORDER ITEMS
  // ============================================================

  final List<OrderItem> items;

  // ============================================================
  // PRICING
  // ============================================================

  final double subtotal;
  final double shippingFee;
  final double discount;
  final double total;

  final String currency;

  // ============================================================
  // PAYMENT
  // ============================================================

  /// Examples:
  /// cash_on_delivery
  /// stripe
  /// payfast
  final String paymentMethod;

  /// Examples:
  /// pending
  /// paid
  /// failed
  /// refunded
  final String paymentStatus;

  final String? transactionId;

  // ============================================================
  // ORDER STATUS
  // ============================================================

  /// Examples:
  /// pending
  /// accepted
  /// processing
  /// dispatched
  /// delivered
  /// cancelled
  /// rejected
  final String orderStatus;

  // ============================================================
  // SHIPPING
  // ============================================================

  final ShippingAddress shippingAddress;

  // ============================================================
  // NOTES
  // ============================================================

  final String? customerNote;
  final String? adminNote;

  // ============================================================
  // TIMESTAMPS
  // ============================================================

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? acceptedAt;
  final DateTime? dispatchedAt;
  final DateTime? deliveredAt;
  final DateTime? cancelledAt;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.discount,
    required this.total,
    this.currency = 'PKR',
    required this.paymentMethod,
    this.paymentStatus = 'pending',
    this.transactionId,
    this.orderStatus = 'pending',
    required this.shippingAddress,
    this.customerNote,
    this.adminNote,
    this.createdAt,
    this.updatedAt,
    this.acceptedAt,
    this.dispatchedAt,
    this.deliveredAt,
    this.cancelledAt,
  });

  // ============================================================
  // COMPUTED HELPERS
  // ============================================================

  int get itemCount {
    return items.fold(0, (total, item) => total + item.quantity);
  }

  bool get isEmpty => items.isEmpty;

  bool get hasDiscount => discount > 0;

  bool get hasShippingFee => shippingFee > 0;

  bool get isPending => orderStatus == 'pending';

  bool get isAccepted => orderStatus == 'accepted';

  bool get isProcessing => orderStatus == 'processing';

  bool get isDispatched => orderStatus == 'dispatched';

  bool get isDelivered => orderStatus == 'delivered';

  bool get isCancelled => orderStatus == 'cancelled';

  bool get isRejected => orderStatus == 'rejected';

  bool get isCompleted => isDelivered;

  bool get canBeCancelled {
    return isPending || isAccepted || isProcessing;
  }

  bool get isPaymentPending => paymentStatus == 'pending';

  bool get isPaid => paymentStatus == 'paid';

  bool get isPaymentFailed => paymentStatus == 'failed';

  bool get isRefunded => paymentStatus == 'refunded';

  // ============================================================
  // FIREBASE REALTIME DATABASE
  // ============================================================

  factory OrderModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return OrderModel(
      id: documentId ?? map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',

      items: _parseItems(map['items']),

      subtotal: _toDouble(map['subtotal']),
      shippingFee: _toDouble(map['shippingFee']),
      discount: _toDouble(map['discount']),
      total: _toDouble(map['total']),

      currency: map['currency']?.toString() ?? 'PKR',

      paymentMethod: map['paymentMethod']?.toString() ?? 'cash_on_delivery',

      paymentStatus: map['paymentStatus']?.toString() ?? 'pending',

      transactionId: _nullableString(map['transactionId']),

      orderStatus: map['orderStatus']?.toString() ?? 'pending',

      shippingAddress: ShippingAddress.fromMap(
        _mapFromDynamic(map['shippingAddress']),
      ),

      customerNote: _nullableString(map['customerNote']),

      adminNote: _nullableString(map['adminNote']),

      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
      acceptedAt: _parseDate(map['acceptedAt']),
      dispatchedAt: _parseDate(map['dispatchedAt']),
      deliveredAt: _parseDate(map['deliveredAt']),
      cancelledAt: _parseDate(map['cancelledAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,

      'items': items.map((item) => item.toMap()).toList(),

      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'discount': discount,
      'total': total,

      'currency': currency,

      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'transactionId': transactionId,

      'orderStatus': orderStatus,

      'shippingAddress': shippingAddress.toMap(),

      'customerNote': customerNote,
      'adminNote': adminNote,

      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'dispatchedAt': dispatchedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'cancelledAt': cancelledAt?.toIso8601String(),
    };
  }

  // ============================================================
  // COPY WITH
  // ============================================================

  OrderModel copyWith({
    String? id,
    String? userId,
    List<OrderItem>? items,
    double? subtotal,
    double? shippingFee,
    double? discount,
    double? total,
    String? currency,
    String? paymentMethod,
    String? paymentStatus,
    String? transactionId,
    String? orderStatus,
    ShippingAddress? shippingAddress,
    String? customerNote,
    String? adminNote,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    DateTime? dispatchedAt,
    DateTime? deliveredAt,
    DateTime? cancelledAt,

    // Explicit nullable-field clearing.
    bool clearTransactionId = false,
    bool clearCustomerNote = false,
    bool clearAdminNote = false,
    bool clearAcceptedAt = false,
    bool clearDispatchedAt = false,
    bool clearDeliveredAt = false,
    bool clearCancelledAt = false,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,

      items: items ?? this.items,

      subtotal: subtotal ?? this.subtotal,
      shippingFee: shippingFee ?? this.shippingFee,
      discount: discount ?? this.discount,
      total: total ?? this.total,

      currency: currency ?? this.currency,

      paymentMethod: paymentMethod ?? this.paymentMethod,

      paymentStatus: paymentStatus ?? this.paymentStatus,

      transactionId: clearTransactionId
          ? null
          : transactionId ?? this.transactionId,

      orderStatus: orderStatus ?? this.orderStatus,

      shippingAddress: shippingAddress ?? this.shippingAddress,

      customerNote: clearCustomerNote
          ? null
          : customerNote ?? this.customerNote,

      adminNote: clearAdminNote ? null : adminNote ?? this.adminNote,

      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,

      acceptedAt: clearAcceptedAt ? null : acceptedAt ?? this.acceptedAt,

      dispatchedAt: clearDispatchedAt
          ? null
          : dispatchedAt ?? this.dispatchedAt,

      deliveredAt: clearDeliveredAt ? null : deliveredAt ?? this.deliveredAt,

      cancelledAt: clearCancelledAt ? null : cancelledAt ?? this.cancelledAt,
    );
  }

  // ============================================================
  // RTDB PARSING HELPERS
  // ============================================================

  static List<OrderItem> _parseItems(dynamic value) {
    if (value == null) {
      return [];
    }

    final List<OrderItem> result = [];

    if (value is List) {
      for (final item in value) {
        if (item is Map) {
          result.add(OrderItem.fromMap(Map<String, dynamic>.from(item)));
        }
      }

      return result;
    }

    if (value is Map) {
      for (final entry in value.entries) {
        final item = entry.value;

        if (item is Map) {
          result.add(OrderItem.fromMap(Map<String, dynamic>.from(item)));
        }
      }
    }

    return result;
  }

  static Map<String, dynamic> _mapFromDynamic(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }

    return {};
  }

  static String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final result = value.toString().trim();

    if (result.isEmpty) {
      return null;
    }

    return result;
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is DateTime) {
      return value;
    }

    return DateTime.tryParse(value.toString());
  }
}

// ============================================================
// ORDER ITEM
// ============================================================

class OrderItem {
  final String productId;
  final String productName;
  final String productImage;

  final double price;
  final int quantity;

  final String? variationId;
  final String? variationName;
  final String? variationValue;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    this.variationId,
    this.variationName,
    this.variationValue,
  });

  // ============================================================
  // HELPERS
  // ============================================================

  double get total {
    return price * quantity;
  }

  bool get hasVariation {
    return variationId != null && variationId!.isNotEmpty;
  }

  String get variationDisplayName {
    if (!hasVariation) {
      return '';
    }

    if (variationName != null &&
        variationName!.isNotEmpty &&
        variationValue != null &&
        variationValue!.isNotEmpty) {
      return '$variationName: $variationValue';
    }

    return variationValue ?? '';
  }

  // ============================================================
  // FIREBASE
  // ============================================================

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId']?.toString() ?? '',

      productName: map['productName']?.toString() ?? '',

      productImage: map['productImage']?.toString() ?? '',

      price: _toDouble(map['price']),

      quantity: _toInt(map['quantity']),

      variationId: _nullableString(map['variationId']),

      variationName: _nullableString(map['variationName']),

      variationValue: _nullableString(map['variationValue']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'productImage': productImage,
      'price': price,
      'quantity': quantity,
      'variationId': variationId,
      'variationName': variationName,
      'variationValue': variationValue,
    };
  }

  OrderItem copyWith({
    String? productId,
    String? productName,
    String? productImage,
    double? price,
    int? quantity,
    String? variationId,
    String? variationName,
    String? variationValue,
    bool clearVariation = false,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productImage: productImage ?? this.productImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,

      variationId: clearVariation ? null : variationId ?? this.variationId,

      variationName: clearVariation
          ? null
          : variationName ?? this.variationName,

      variationValue: clearVariation
          ? null
          : variationValue ?? this.variationValue,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? 1;
  }

  static String? _nullableString(dynamic value) {
    if (value == null) {
      return null;
    }

    final result = value.toString().trim();

    if (result.isEmpty) {
      return null;
    }

    return result;
  }
}

// ============================================================
// SHIPPING ADDRESS
// ============================================================

class ShippingAddress {
  final String fullName;
  final String phone;
  final String address;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  const ShippingAddress({
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    this.state = '',
    this.postalCode = '',
    this.country = 'Pakistan',
  });

  // ============================================================
  // HELPERS
  // ============================================================

  String get formattedAddress {
    final parts = <String>[address, city, state, postalCode, country];

    return parts.where((part) => part.trim().isNotEmpty).join(', ');
  }

  bool get hasState => state.trim().isNotEmpty;

  bool get hasPostalCode => postalCode.trim().isNotEmpty;

  // ============================================================
  // FIREBASE
  // ============================================================

  factory ShippingAddress.fromMap(Map<String, dynamic> map) {
    return ShippingAddress(
      fullName: map['fullName']?.toString() ?? '',

      phone: map['phone']?.toString() ?? '',

      address: map['address']?.toString() ?? '',

      city: map['city']?.toString() ?? '',

      state: map['state']?.toString() ?? '',

      postalCode: map['postalCode']?.toString() ?? '',

      country: map['country']?.toString() ?? 'Pakistan',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
    };
  }

  ShippingAddress copyWith({
    String? fullName,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? country,
  }) {
    return ShippingAddress(
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
    );
  }
}
