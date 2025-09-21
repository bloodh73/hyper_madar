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
  bool _useMySQL = false;
  bool _useOnline = true; // استفاده از دیتابیس آنلاین به عنوان پیش‌فرض

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
      notifyListeners();
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
      notifyListeners();
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
      notifyListeners();
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
      notifyListeners();
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
      notifyListeners();
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
      notifyListeners();
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
    notifyListeners();
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
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = '';
    notifyListeners();
  }
}
