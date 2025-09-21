class Product {
  final int? id;
  final String barcode;
  final String productName;
  final String supplier;
  final double purchasePrice;
  final double originalPrice;
  final double discountedPrice;
  final double supplierCode;

  Product({
    this.id,
    required this.barcode,
    required this.productName,
    required this.supplier,
    required this.purchasePrice,
    required this.originalPrice,
    required this.discountedPrice,
    required this.supplierCode,
  });

  // Convert Product to Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'barcode': barcode,
      'product_name': productName,
      'supplier': supplier,
      'purchase_price': purchasePrice,
      'original_price': originalPrice,
      'discounted_price': discountedPrice,
      'supplier_code': supplierCode,
    };
  }

  // Create Product from Map (from database)
  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      barcode: map['barcode'] ?? '',
      productName: map['product_name'] ?? '',
      supplier: map['supplier'] ?? '',
      purchasePrice: map['purchase_price']?.toDouble() ?? 0.0,
      originalPrice: map['original_price']?.toDouble() ?? 0.0,
      discountedPrice: map['discounted_price']?.toDouble() ?? 0.0,
      supplierCode: map['supplier_code'] ?? '',
    );
  }

  // Create Product from Excel row
  factory Product.fromExcelRow(List<dynamic> row) {
    return Product(
      barcode: row[0]?.toDouble() ?? '',
      productName: row[1]?.toString() ?? '',
      supplier: row[2]?.toDouble() ?? '',
      purchasePrice: double.tryParse(row[3]?.toString() ?? '0') ?? 0.0,
      originalPrice: double.tryParse(row[4]?.toString() ?? '0') ?? 0.0,
      discountedPrice: double.tryParse(row[5]?.toString() ?? '0') ?? 0.0,
      supplierCode: double.tryParse(row[6]?.toString() ?? '0') ?? 0.0,
    );
  }

  // Copy with method for updates
  Product copyWith({
    int? id,
    String? barcode,
    String? productName,
    String? supplier,
    double? purchasePrice,
    double? originalPrice,
    double? discountedPrice,
    double? supplierCode,
  }) {
    return Product(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      productName: productName ?? this.productName,
      supplier: supplier ?? this.supplier,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      supplierCode: supplierCode ?? this.supplierCode,
    );
  }

  @override
  String toString() {
    return 'Product{id: $id, barcode: $barcode, productName: $productName, supplier: $supplier, purchasePrice: $purchasePrice, originalPrice: $originalPrice, discountedPrice: $discountedPrice, supplierCode: $supplierCode}';
  }
}
