// ============================================================
// COMPLAINT
// ============================================================
//
// A customer-submitted complaint — about an order, a product, payment,
// service, or the app itself. Optionally tied to an [orderId]. Stored
// under `complaints/{id}` with a lightweight reference under
// `users/{userId}/complaints/{id}` — the same pattern [ReturnRequestModel]
// and [OrderModel] use.

class ComplaintModel {
  final String id;
  final String userId;

  /// Optional — set when the complaint is about a specific order.
  final String? orderId;

  final String subject;

  /// One of [ComplaintCategories.all].
  final String category;

  final String description;

  /// open | inProgress | resolved | closed
  final String status;

  final List<String> photoUrls;

  /// The admin/support team's reply, shown back to the customer.
  final String? adminResponse;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? resolvedAt;

  const ComplaintModel({
    required this.id,
    required this.userId,
    this.orderId,
    required this.subject,
    required this.category,
    required this.description,
    this.status = 'open',
    this.photoUrls = const [],
    this.adminResponse,
    this.createdAt,
    this.updatedAt,
    this.resolvedAt,
  });

  // ------------------------------------------------------------
  // HELPERS
  // ------------------------------------------------------------

  bool get hasOrder => orderId != null && orderId!.isNotEmpty;

  bool get hasPhotos => photoUrls.isNotEmpty;

  bool get hasResponse =>
      adminResponse != null && adminResponse!.trim().isNotEmpty;

  bool get isOpen => status == ComplaintStatuses.open;

  bool get isInProgress => status == ComplaintStatuses.inProgress;

  bool get isResolved => status == ComplaintStatuses.resolved;

  bool get isClosed => status == ComplaintStatuses.closed;

  /// A complaint is still "active" while it hasn't been resolved or closed.
  bool get isActive => !isResolved && !isClosed;

  // ------------------------------------------------------------
  // FIREBASE REALTIME DATABASE
  // ------------------------------------------------------------

  factory ComplaintModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    return ComplaintModel(
      id: documentId ?? map['id']?.toString() ?? '',
      userId: map['userId']?.toString() ?? '',
      orderId: _nullableString(map['orderId']),
      subject: map['subject']?.toString() ?? '',
      category: map['category']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      status: map['status']?.toString() ?? ComplaintStatuses.open,
      photoUrls: _parseStringList(map['photoUrls']),
      adminResponse: _nullableString(map['adminResponse']),
      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
      resolvedAt: _parseDate(map['resolvedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'orderId': orderId,
      'subject': subject,
      'category': category,
      'description': description,
      'status': status,
      'photoUrls': photoUrls,
      'adminResponse': adminResponse,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
    };
  }

  ComplaintModel copyWith({
    String? id,
    String? orderId,
    String? subject,
    String? category,
    String? description,
    String? status,
    List<String>? photoUrls,
    String? adminResponse,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? resolvedAt,
    bool clearAdminResponse = false,
  }) {
    return ComplaintModel(
      id: id ?? this.id,
      userId: userId,
      orderId: orderId ?? this.orderId,
      subject: subject ?? this.subject,
      category: category ?? this.category,
      description: description ?? this.description,
      status: status ?? this.status,
      photoUrls: photoUrls ?? this.photoUrls,
      adminResponse: clearAdminResponse
          ? null
          : adminResponse ?? this.adminResponse,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
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
// COMPLAINT CATEGORIES
// ============================================================
//
// Fixed set of categories offered in the complaint form UI.

class ComplaintCategories {
  ComplaintCategories._();

  static const List<String> all = [
    'Order & Delivery',
    'Product Quality',
    'Payment & Refund',
    'Customer Service',
    'App / Website Issue',
    'Other',
  ];
}

// ============================================================
// COMPLAINT STATUSES
// ============================================================

class ComplaintStatuses {
  ComplaintStatuses._();

  static const open = 'open';
  static const inProgress = 'inProgress';
  static const resolved = 'resolved';
  static const closed = 'closed';

  /// Full lifecycle, in order — used for status pickers and filter tabs.
  static const all = <String>[open, inProgress, resolved, closed];

  static bool isClosed(String status) => status == resolved || status == closed;
}
