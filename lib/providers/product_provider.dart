import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/database_service.dart';
import '../services/online_database_service.dart';


class ProductProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final OnlineDatabaseService _onlineService = OnlineDatabaseService();
  
  List<Product> _products = [];
  bool _isLoading = false;
  String _error = '';
  bool _useMySQL = false; // غیرفعال کردن MySQL به عنوان پیش‌فرض
  bool _useOnline = true; // استفاده از API آنلاین به عنوان پیش‌فرض

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get useMySQL => _useMySQL;
  bool get useOnline => _useOnline;

  // Load all products
  Future<void> loadProducts() async {
    _setLoading(true);
    try {
      if (_useOnline) {
        _products = await _onlineService.getAllProducts();
      } else {
        _products = await _databaseService.getAllProducts(useMySQL: _useMySQL);
      }
      _error = '';
    } catch (e) {
      _error = 'خطا در بارگذاری محصولات: $e';
      _products = [];
    } finally {
      _setLoading(false);
    }
  }

  // Get unique suppliers only (optimized for large datasets)
  Future<List<String>> getSuppliers() async {
    try {
      if (_useOnline) {
        // For online API, extract suppliers from loaded products
        if (_products.isEmpty) {
          await loadProducts(); // Load products first if not loaded
        }
        final suppliers = _products.map((p) => p.supplier).toSet().toList();
        suppliers.sort();
        return suppliers;
      } else {
        // Use database query for better performance
        return await _databaseService.getSuppliers(useMySQL: _useMySQL);
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get product count for a specific supplier
  int getSupplierProductCount(String supplier) {
    if (_products.isEmpty) return 0;
    
    // Use a simple counter for better performance
    int count = 0;
    for (final product in _products) {
      if (product.supplier == supplier) {
        count++;
      }
    }
    return count;
  }

  // Get supplier product count from database (more accurate)
  Future<int> getSupplierProductCountFromDB(String supplier) async {
    try {
      if (_useOnline) {
        // For online, use the local method
        return getSupplierProductCount(supplier);
      } else {
        return await _databaseService.getSupplierProductCount(supplier, useMySQL: _useMySQL);
      }
    } catch (e) {
      print('Error getting supplier count from DB: $e');
      return getSupplierProductCount(supplier); // Fallback to local method
    }
  }

  // Search products
  Future<void> searchProducts(String query) async {
    if (query.isEmpty) {
      await loadProducts();
      return;
    }

    _setLoading(true);
    try {
      if (_useOnline) {
        _products = await _onlineService.searchProducts(query);
      } else {
        _products = await _databaseService.searchProducts(query, useMySQL: _useMySQL);
      }
      _error = '';
    } catch (e) {
      _error = 'خطا در جستجو: $e';
      _products = [];
    } finally {
      _setLoading(false);
    }
  }

  // Add new product
  Future<bool> addProduct(Product product) async {
    try {
      int id;
      if (_useOnline) {
        id = await _onlineService.insertProduct(product);
      } else {
        id = await _databaseService.insertProduct(product, useMySQL: _useMySQL);
      }
      if (id > 0) {
        await loadProducts(); // Refresh the list
        return true;
      }
      return false;
    } catch (e) {
      _error = 'خطا در افزودن محصول: $e';
      Future.microtask(() {
        notifyListeners();
      });
      return false;
    }
  }

  // Update product
  Future<bool> updateProduct(Product product) async {
    try {
      int result;
      if (_useOnline) {
        result = await _onlineService.updateProduct(product);
      } else {
        result = await _databaseService.updateProduct(product, useMySQL: _useMySQL);
      }
      if (result > 0) {
        await loadProducts(); // Refresh the list
        return true;
      }
      return false;
    } catch (e) {
      _error = 'خطا در بروزرسانی محصول: $e';
      Future.microtask(() {
        notifyListeners();
      });
      return false;
    }
  }

  // Delete product
  Future<bool> deleteProduct(int id) async {
    try {
      int result;
      if (_useOnline) {
        result = await _onlineService.deleteProduct(id);
      } else {
        result = await _databaseService.deleteProduct(id, useMySQL: _useMySQL);
      }
      if (result > 0) {
        await loadProducts(); // Refresh the list
        return true;
      }
      return false;
    } catch (e) {
      _error = 'خطا در حذف محصول: $e';
      Future.microtask(() {
        notifyListeners();
      });
      return false;
    }
  }

  // Get product by barcode
  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      if (_useOnline) {
        return await _onlineService.getProductByBarcode(barcode);
      } else {
        return await _databaseService.getProductByBarcode(barcode, useMySQL: _useMySQL);
      }
    } catch (e) {
      _error = 'خطا در دریافت محصول: $e';
      Future.microtask(() {
        notifyListeners();
      });
      return null;
    }
  }

  // Import products from Excel
  Future<List<int>> importProducts(List<Product> products) async {
    try {
      List<int> insertedIds;
      if (_useOnline) {
        insertedIds = await _onlineService.insertProducts(products);
      } else {
        insertedIds = await _databaseService.insertProducts(products, useMySQL: _useMySQL);
      }
      await loadProducts(); // Refresh the list
      return insertedIds;
    } catch (e) {
      _error = 'خطا در وارد کردن محصولات: $e';
      Future.microtask(() {
        notifyListeners();
      });
      return [];
    }
  }

  // Toggle database type
  Future<void> toggleDatabaseType() async {
    _useMySQL = !_useMySQL;
    
    if (_useMySQL) {
      await _databaseService.connectToMySQL();
      await _databaseService.createMySQLTable();
    } else {
      await _databaseService.disconnectMySQL();
    }
    
    await loadProducts();
  }

  // Connect to MySQL
  Future<bool> connectToMySQL() async {
    try {
      var connection = await _databaseService.connectToMySQL();
      if (connection != null) {
        await _databaseService.createMySQLTable();
        _useMySQL = true;
        await loadProducts();
        return true;
      }
      return false;
    } catch (e) {
      _error = 'خطا در اتصال به MySQL: $e';
      Future.microtask(() {
        notifyListeners();
      });
      return false;
    }
  }

  // Disconnect from MySQL
  Future<void> disconnectFromMySQL() async {
    await _databaseService.disconnectMySQL();
    _useMySQL = false;
    await loadProducts();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    // Use microtask to avoid calling notifyListeners during build
    Future.microtask(() {
      notifyListeners();
    });
  }

  // Toggle online database
  Future<void> toggleOnlineDatabase() async {
    _useOnline = !_useOnline;
    if (_useOnline) {
      _useMySQL = false; // غیرفعال کردن MySQL وقتی آنلاین فعال است
    }
    await loadProducts();
  }

  // Test online connection
  Future<bool> testOnlineConnection() async {
    try {
      final stats = await _onlineService.getStats();
      return stats['connection_status'] == 'connected';
    } catch (e) {
      _error = 'خطا در اتصال به دیتابیس آنلاین: $e';
      Future.microtask(() {
        notifyListeners();
      });
      return false;
    }
  }

  void clearError() {
    _error = '';
    Future.microtask(() {
      notifyListeners();
    });
  }

  // ===== SUPPLIER MANAGEMENT METHODS =====

  // Get suppliers with detailed information and product counts
  Future<List<Map<String, dynamic>>> getSuppliersWithDetails() async {
    try {
      if (_useOnline) {
        // For online API, we'll enhance the existing getSuppliers method
        final suppliers = await getSuppliers();
        final List<Map<String, dynamic>> detailedSuppliers = [];
        
        for (String supplierName in suppliers) {
          final count = await getSupplierProductCountFromDB(supplierName);
          detailedSuppliers.add({
            'supplier_name': supplierName,
            'product_count': count,
            'contact_person': null,
            'phone': null,
            'email': null,
            'address': null,
            'description': null,
            'is_active': true,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
        return detailedSuppliers;
      } else {
        return await _databaseService.getSuppliersWithCounts(useMySQL: _useMySQL);
      }
    } catch (e) {
      _error = 'خطا در دریافت اطلاعات تامین‌کنندگان: $e';
      Future.microtask(() {
        notifyListeners();
      });
      return [];
    }
  }

  // Get a single supplier by ID
  Future<Map<String, dynamic>?> getSupplierById(int id) async {
    try {
      if (_useOnline) {
        // For online API, we don't have individual supplier records
        return null;
      } else {
        return await _databaseService.getSupplierById(id, useMySQL: _useMySQL);
      }
    } catch (e) {
      _error = 'خطا در دریافت اطلاعات تامین‌کننده: $e';
      Future.microtask(() {
        notifyListeners();
      });
      return null;
    }
  }

  // Add new supplier
  Future<bool> addSupplier(Map<String, dynamic> supplierData) async {
    try {
      int id;
      if (_useOnline) {
        // For online API, suppliers are managed through products
        _error = 'افزودن تامین‌کننده در حالت آنلاین پشتیبانی نمی‌شود';
        Future.microtask(() {
          notifyListeners();
        });
        return false;
      } else {
        id = await _databaseService.insertSupplier(supplierData, useMySQL: _useMySQL);
      }
      return id > 0;
    } catch (e) {
      _error = 'خطا در افزودن تامین‌کننده: $e';
      Future.microtask(() {
        notifyListeners();
      });
      return false;
    }
  }

  // Update supplier
  Future<bool> updateSupplier(Map<String, dynamic> supplierData) async {
    try {
      int result;
      if (_useOnline) {
        // For online API, suppliers are managed through products
        _error = 'بروزرسانی تامین‌کننده در حالت آنلاین پشتیبانی نمی‌شود';
        Future.microtask(() {
          notifyListeners();
        });
        return false;
      } else {
        result = await _databaseService.updateSupplier(supplierData, useMySQL: _useMySQL);
      }
      return result > 0;
    } catch (e) {
      _error = 'خطا در بروزرسانی تامین‌کننده: $e';
      Future.microtask(() {
        notifyListeners();
      });
      return false;
    }
  }

  // Delete supplier
  Future<bool> deleteSupplier(int id) async {
    try {
      int result;
      if (_useOnline) {
        // For online API, suppliers are managed through products
        _error = 'حذف تامین‌کننده در حالت آنلاین پشتیبانی نمی‌شود';
        Future.microtask(() {
          notifyListeners();
        });
        return false;
      } else {
        result = await _databaseService.deleteSupplier(id, useMySQL: _useMySQL);
        if (result == -1) {
          _error = 'نمی‌توان تامین‌کننده‌ای را که محصول دارد حذف کرد';
          Future.microtask(() {
            notifyListeners();
          });
          return false;
        }
      }
      return result > 0;
    } catch (e) {
      _error = 'خطا در حذف تامین‌کننده: $e';
      Future.microtask(() {
        notifyListeners();
      });
      return false;
    }
  }

  // Search suppliers
  Future<List<Map<String, dynamic>>> searchSuppliers(String query) async {
    try {
      if (_useOnline) {
        // For online API, search in existing suppliers
        final allSuppliers = await getSuppliers();
        final filteredSuppliers = allSuppliers
            .where((supplier) => supplier.toLowerCase().contains(query.toLowerCase()))
            .toList();
        
        final List<Map<String, dynamic>> detailedSuppliers = [];
        for (String supplierName in filteredSuppliers) {
          final count = await getSupplierProductCountFromDB(supplierName);
          detailedSuppliers.add({
            'supplier_name': supplierName,
            'product_count': count,
            'contact_person': null,
            'phone': null,
            'email': null,
            'address': null,
            'description': null,
            'is_active': true,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          });
        }
        return detailedSuppliers;
      } else {
        return await _databaseService.searchSuppliers(query, useMySQL: _useMySQL);
      }
    } catch (e) {
      _error = 'خطا در جستجوی تامین‌کنندگان: $e';
      Future.microtask(() {
        notifyListeners();
      });
      return [];
    }
  }
}
