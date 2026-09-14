class UserModel {
  final String id;

  final String name;
  final String email;
  final String phone;

  final String profileImage;

  final String role;

  final bool isActive;
  final bool emailVerified;

  final List<UserAddress> addresses;

  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLoginAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.profileImage = '',
    this.role = 'customer',
    this.isActive = true,
    this.emailVerified = false,
    this.addresses = const [],
    this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  // ==========================================================
  // ROLE HELPERS
  // ==========================================================

  bool get isCustomer => role == 'customer';

  bool get isAdmin => role == 'admin';

  bool get isSuperAdmin => role == 'superAdmin';

  // ==========================================================
  // FIREBASE
  // ==========================================================

  factory UserModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    return UserModel(
      id: documentId ?? map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      profileImage: map['profileImage']?.toString() ?? '',
      role: map['role']?.toString() ?? 'customer',
      isActive: map['isActive'] ?? true,
      emailVerified: map['emailVerified'] ?? false,

      addresses:
          (map['addresses'] as List?)
              ?.map(
                (address) =>
                    UserAddress.fromMap(Map<String, dynamic>.from(address)),
              )
              .toList() ??
          [],

      createdAt: _parseDate(map['createdAt']),
      updatedAt: _parseDate(map['updatedAt']),
      lastLoginAt: _parseDate(map['lastLoginAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'role': role,
      'isActive': isActive,
      'emailVerified': emailVerified,
      'addresses': addresses.map((e) => e.toMap()).toList(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? role,
    bool? isActive,
    bool? emailVerified,
    List<UserAddress>? addresses,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      emailVerified: emailVerified ?? this.emailVerified,
      addresses: addresses ?? this.addresses,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString());
  }
}

// ============================================================
// USER ADDRESS
// ============================================================

class UserAddress {
  final String id;

  final String label;

  final String fullName;
  final String phone;

  final String address;
  final String city;
  final String state;
  final String postalCode;
  final String country;

  final bool isDefault;

  const UserAddress({
    required this.id,
    this.label = 'Home',
    required this.fullName,
    required this.phone,
    required this.address,
    required this.city,
    this.state = '',
    this.postalCode = '',
    this.country = 'Pakistan',
    this.isDefault = false,
  });

  factory UserAddress.fromMap(Map<String, dynamic> map) {
    return UserAddress(
      id: map['id']?.toString() ?? '',
      label: map['label']?.toString() ?? 'Home',
      fullName: map['fullName']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      state: map['state']?.toString() ?? '',
      postalCode: map['postalCode']?.toString() ?? '',
      country: map['country']?.toString() ?? 'Pakistan',
      isDefault: map['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'fullName': fullName,
      'phone': phone,
      'address': address,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'isDefault': isDefault,
    };
  }

  UserAddress copyWith({
    String? id,
    String? label,
    String? fullName,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    bool? isDefault,
  }) {
    return UserAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
