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
      barcode: map['barcode']?.toString() ?? '',
      productName: map['product_name']?.toString() ?? '',
      supplier: map['supplier']?.toString() ?? '',
      purchasePrice: _parseDouble(map['purchase_price']),
      originalPrice: _parseDouble(map['original_price']),
      discountedPrice: _parseDouble(map['discounted_price']),
      supplierCode: _parseDouble(map['supplier_code']),
    );
  }

  // Helper method to safely parse double values
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  // Extract string from Excel cell (Data/Cell) or primitive
  static String _extractString(dynamic cell) {
    if (cell == null) return '';
    try {
      final dynamic val = (cell as dynamic).value;
      if (val == null) return '';
      return val.toString().trim();
    } catch (_) {
      return cell.toString().trim();
    }
  }

  // Extract number from Excel cell (supports strings with commas)
  static double _extractDouble(dynamic cell) {
    dynamic raw;
    try {
      raw = (cell as dynamic).value;
    } catch (_) {
      raw = cell;
    }
    if (raw == null) return 0.0;
    if (raw is num) return raw.toDouble();
    final String s = raw.toString().trim().replaceAll(',', '').replaceAll('٬', '').replaceAll(' ', '');
    return double.tryParse(s) ?? 0.0;
  }

  // Create Product from Excel row
  factory Product.fromExcelRow(List<dynamic> row) {
    return Product(
      barcode: _extractString(row.length > 0 ? row[0] : null),
      productName: _extractString(row.length > 1 ? row[1] : null),
      supplier: _extractString(row.length > 2 ? row[2] : null),
      purchasePrice: _extractDouble(row.length > 3 ? row[3] : null),
      originalPrice: _extractDouble(row.length > 4 ? row[4] : null),
      discountedPrice: _extractDouble(row.length > 5 ? row[5] : null),
      supplierCode: _extractDouble(row.length > 6 ? row[6] : null),
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

  // Calculate discount percentage between original price and final price
  double getDiscountPercentage() {
    if (originalPrice <= 0) return 0.0;
    double discount = originalPrice - discountedPrice;
    return (discount / originalPrice) * 100;
  }

  // Check if there's a discount (final price is less than original price)
  bool hasDiscount() {
    return discountedPrice < originalPrice;
  }

  // Get discount amount in currency
  double getDiscountAmount() {
    return originalPrice - discountedPrice;
  }

  @override
  String toString() {
    return 'Product{id: $id, barcode: $barcode, productName: $productName, supplier: $supplier, purchasePrice: $purchasePrice, originalPrice: $originalPrice, discountedPrice: $discountedPrice, supplierCode: $supplierCode}';
  }
}
