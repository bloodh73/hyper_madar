class Supplier {
  final int? id;
  final String supplierName;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final String? address;
  final String? description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? productCount; // For display purposes

  Supplier({
    this.id,
    required this.supplierName,
    this.contactPerson,
    this.phone,
    this.email,
    this.address,
    this.description,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.productCount,
  });

  // Convert Supplier object to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplier_name': supplierName,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'address': address,
      'description': description,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Create Supplier object from Map (database query result)
  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'] as int?,
      supplierName: map['supplier_name'] as String,
      contactPerson: map['contact_person'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      description: map['description'] as String?,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String)
          : DateTime.now(),
      updatedAt: map['updated_at'] != null 
          ? DateTime.parse(map['updated_at'] as String)
          : DateTime.now(),
      productCount: map['product_count'] as int?,
    );
  }

  // Copy with method for updating supplier data
  Supplier copyWith({
    int? id,
    String? supplierName,
    String? contactPerson,
    String? phone,
    String? email,
    String? address,
    String? description,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? productCount,
  }) {
    return Supplier(
      id: id ?? this.id,
      supplierName: supplierName ?? this.supplierName,
      contactPerson: contactPerson ?? this.contactPerson,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      productCount: productCount ?? this.productCount,
    );
  }

  @override
  String toString() {
    return 'Supplier(id: $id, supplierName: $supplierName, contactPerson: $contactPerson, phone: $phone, email: $email, isActive: $isActive, productCount: $productCount)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Supplier &&
        other.id == id &&
        other.supplierName == supplierName;
  }

  @override
  int get hashCode => id.hashCode ^ supplierName.hashCode;
}