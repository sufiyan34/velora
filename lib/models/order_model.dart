class OrderModel {
  final String id;
  final String userId;

  final List<OrderItem> items;

  final double subtotal;
  final double shippingFee;
  final double discount;
  final double total;

  final String currency;

  final String paymentMethod;
  final String paymentStatus;
  final String? transactionId;

  final String orderStatus;

  final ShippingAddress shippingAddress;

  final String? customerNote;
  final String? adminNote;

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
    required this.paymentStatus,
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

  // ==========================================================
  // STATUS HELPERS
  // ==========================================================

  bool get isPending => orderStatus == 'pending';

  bool get isAccepted => orderStatus == 'accepted';

  bool get isProcessing => orderStatus == 'processing';

  bool get isDispatched => orderStatus == 'dispatched';

  bool get isDelivered => orderStatus == 'delivered';

  bool get isCancelled => orderStatus == 'cancelled';

  bool get isRejected => orderStatus == 'rejected';

  // ==========================================================
  // FIREBASE
  // ==========================================================

  factory OrderModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return OrderModel(
      id: documentId ?? map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',

      items:
          (map['items'] as List?)
              ?.map(
                (item) => OrderItem.fromMap(Map<String, dynamic>.from(item)),
              )
              .toList() ??
          [],

      subtotal: _toDouble(map['subtotal']),
      shippingFee: _toDouble(map['shippingFee']),
      discount: _toDouble(map['discount']),
      total: _toDouble(map['total']),

      currency: map['currency']?.toString() ?? 'PKR',

      paymentMethod: map['paymentMethod']?.toString() ?? '',

      paymentStatus: map['paymentStatus']?.toString() ?? 'pending',

      transactionId: map['transactionId']?.toString(),

      orderStatus: map['orderStatus']?.toString() ?? 'pending',

      shippingAddress: ShippingAddress.fromMap(
        Map<String, dynamic>.from(map['shippingAddress'] ?? {}),
      ),

      customerNote: map['customerNote']?.toString(),

      adminNote: map['adminNote']?.toString(),

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
      transactionId: transactionId ?? this.transactionId,
      orderStatus: orderStatus ?? this.orderStatus,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      customerNote: customerNote ?? this.customerNote,
      adminNote: adminNote ?? this.adminNote,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      dispatchedAt: dispatchedAt ?? this.dispatchedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
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

  double get total => price * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId']?.toString() ?? '',
      productName: map['productName']?.toString() ?? '',
      productImage: map['productImage']?.toString() ?? '',
      price: _toDouble(map['price']),
      quantity: _toInt(map['quantity']),
      variationId: map['variationId']?.toString(),
      variationName: map['variationName']?.toString(),
      variationValue: map['variationValue']?.toString(),
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

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 1;
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
