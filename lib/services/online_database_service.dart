import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class OnlineDatabaseService {
  static final OnlineDatabaseService _instance = OnlineDatabaseService._internal();
  factory OnlineDatabaseService() => _instance;
  OnlineDatabaseService._internal();

  // آدرس API شما
  static const String _baseUrl = 'https://blizzardping.ir/hyper.php';
  
  // Headers برای درخواست‌ها
  Map<String, String> get _headers => {
    'Content-Type': 'application/json; charset=utf-8',
    'Accept': 'application/json',
  };

  // تست اتصال
  Future<Map<String, dynamic>> testConnection() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?action=test'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final error = json.decode(response.body);
        return {
          'success': false,
          'error': error['error'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'خطا در اتصال: $e',
      };
    }
  }

  // دریافت تمام محصولات
  Future<List<Product>> getAllProducts({int page = 1, int limit = 5000000}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?action=products&page=$page&limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          List<dynamic> productsJson = data['data']['products'];
          return productsJson.map((json) => Product.fromMap(json)).toList();
        } else {
          throw Exception(data['error']);
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error']);
      }
    } catch (e) {
      throw Exception('خطا در دریافت محصولات: $e');
    }
  }

  // جستجو در محصولات
  Future<List<Product>> searchProducts(String query, {int page = 1, int limit = 1000}) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?action=search&q=${Uri.encodeComponent(query)}&page=$page&limit=$limit'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          List<dynamic> productsJson = data['data']['products'];
          return productsJson.map((json) => Product.fromMap(json)).toList();
        } else {
          throw Exception(data['error']);
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error']);
      }
    } catch (e) {
      throw Exception('خطا در جستجو: $e');
    }
  }

  // دریافت محصول بر اساس ID
  Future<Product?> getProductById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?action=product&id=$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return Product.fromMap(data['data']['product']);
        } else {
          throw Exception(data['error']);
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error']);
      }
    } catch (e) {
      throw Exception('خطا در دریافت محصول: $e');
    }
  }

  // دریافت محصول بر اساس بارکد
  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?action=barcode&barcode=${Uri.encodeComponent(barcode)}'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return Product.fromMap(data['data']['product']);
        } else {
          return null; // محصول یافت نشد
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error']);
      }
    } catch (e) {
      throw Exception('خطا در دریافت محصول: $e');
    }
  }

  // ایجاد محصول جدید
  Future<int> insertProduct(Product product) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?action=product'),
        headers: _headers,
        body: json.encode(product.toMap()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return data['data']['product_id'];
        } else {
          throw Exception(data['error']);
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error']);
      }
    } catch (e) {
      throw Exception('خطا در ایجاد محصول: $e');
    }
  }

  // بروزرسانی محصول
  Future<int> updateProduct(Product product) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl?action=product'),
        headers: _headers,
        body: json.encode(product.toMap()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return data['data']['product_id'];
        } else {
          throw Exception(data['error']);
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error']);
      }
    } catch (e) {
      throw Exception('خطا در بروزرسانی محصول: $e');
    }
  }

  // حذف محصول
  Future<int> deleteProduct(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl?action=product&id=$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return data['data']['product_id'];
        } else {
          throw Exception(data['error']);
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error']);
      }
    } catch (e) {
      throw Exception('خطا در حذف محصول: $e');
    }
  }

  // وارد کردن چندین محصول (از اکسل)
  Future<List<int>> insertProducts(List<Product> products) async {
    try {
      final productsJson = products.map((p) => p.toMap()).toList();
      
      final response = await http.post(
        Uri.parse('$_baseUrl?action=products'),
        headers: _headers,
        body: json.encode({'products': productsJson}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          // Convert string IDs to integers
          List<dynamic> insertedIds = data['data']['inserted_ids'];
          return insertedIds.map((id) => int.parse(id.toString())).toList();
        } else {
          throw Exception(data['error']);
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error']);
      }
    } catch (e) {
      throw Exception('خطا در وارد کردن محصولات: $e');
    }
  }

  // دریافت آمار کلی
  Future<Map<String, dynamic>> getStats() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?action=stats'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          return {
            'total_products': data['data']['total_products'],
            'server_time': data['data']['server_time'],
            'connection_status': 'connected',
          };
        } else {
          throw Exception(data['error']);
        }
      } else {
        final error = json.decode(response.body);
        throw Exception(error['error']);
      }
    } catch (e) {
      return {
        'total_products': 0,
        'server_time': null,
        'connection_status': 'disconnected',
        'error': e.toString(),
      };
    }
  }
}
