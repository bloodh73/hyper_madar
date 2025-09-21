import 'package:mysql1/mysql1.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _database;
  MySqlConnection? _mysqlConnection;

  // MySQL Configuration
  static const String _host = 'localhost';
  static const int _port = 3306;
  static const String _user = 'root';
  static const String _password = '';
  static const String _dbName = 'product_manager';

  // Local SQLite database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'products.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode TEXT UNIQUE NOT NULL,
        product_name TEXT NOT NULL,
        supplier TEXT NOT NULL,
        purchase_price REAL NOT NULL,
        original_price REAL NOT NULL,
        discounted_price REAL NOT NULL,
        supplier_code TEXT NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
  }

  // MySQL Connection
  Future<MySqlConnection?> connectToMySQL() async {
    try {
      _mysqlConnection = await MySqlConnection.connect(
        ConnectionSettings(
          host: _host,
          port: _port,
          user: _user,
          password: _password,
          db: _dbName,
        ),
      );
      return _mysqlConnection;
    } catch (e) {
      print('MySQL connection error: $e');
      return null;
    }
  }

  Future<void> disconnectMySQL() async {
    await _mysqlConnection?.close();
    _mysqlConnection = null;
  }

  // Create MySQL table if not exists
  Future<void> createMySQLTable() async {
    if (_mysqlConnection == null) return;

    try {
      // First try to create database if it doesn't exist
      await _mysqlConnection!.query('''
        CREATE DATABASE IF NOT EXISTS product_manager 
        CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci
      ''');
      
      // Use the database
      await _mysqlConnection!.query('USE product_manager');
      
      // Create table
      await _mysqlConnection!.query('''
        CREATE TABLE IF NOT EXISTS products(
          id INT AUTO_INCREMENT PRIMARY KEY,
          barcode VARCHAR(255) UNIQUE NOT NULL,
          product_name VARCHAR(255) NOT NULL,
          supplier VARCHAR(255) NOT NULL,
          purchase_price DECIMAL(10,2) NOT NULL,
          original_price DECIMAL(10,2) NOT NULL,
          discounted_price DECIMAL(10,2) NOT NULL,
          supplier_code VARCHAR(255) NOT NULL,
          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
      ''');
    } catch (e) {
      // If database creation fails, try to use existing database
      try {
        await _mysqlConnection!.query('USE product_manager');
        await _mysqlConnection!.query('''
          CREATE TABLE IF NOT EXISTS products(
            id INT AUTO_INCREMENT PRIMARY KEY,
            barcode VARCHAR(255) UNIQUE NOT NULL,
            product_name VARCHAR(255) NOT NULL,
            supplier VARCHAR(255) NOT NULL,
            purchase_price DECIMAL(10,2) NOT NULL,
            original_price DECIMAL(10,2) NOT NULL,
            discounted_price DECIMAL(10,2) NOT NULL,
            supplier_code VARCHAR(255) NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
          ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
        ''');
      } catch (e2) {
        throw Exception('خطا در ایجاد جدول: $e2');
      }
    }
  }

  // Product CRUD Operations
  Future<int> insertProduct(Product product, {bool useMySQL = false}) async {
    if (useMySQL && _mysqlConnection != null) {
      try {
        var result = await _mysqlConnection!.query(
          'INSERT INTO products (barcode, product_name, supplier, purchase_price, original_price, discounted_price, supplier_code) VALUES (?, ?, ?, ?, ?, ?, ?)',
          [
            product.barcode,
            product.productName,
            product.supplier,
            product.purchasePrice,
            product.originalPrice,
            product.discountedPrice,
            product.supplierCode,
          ],
        );
        return result.insertId ?? 0;
      } catch (e) {
        print('MySQL insert error: $e');
        return 0;
      }
    } else {
      final db = await database;
      return await db.insert('products', product.toMap());
    }
  }

  Future<List<Product>> getAllProducts({bool useMySQL = false}) async {
    if (useMySQL && _mysqlConnection != null) {
      try {
        var results = await _mysqlConnection!.query('SELECT * FROM products ORDER BY created_at DESC');
        return results.map((row) => Product.fromMap(row.fields)).toList();
      } catch (e) {
        print('MySQL select error: $e');
        return [];
      }
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('products', orderBy: 'created_at DESC');
      return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
    }
  }

  Future<List<Product>> searchProducts(String query, {bool useMySQL = false}) async {
    if (useMySQL && _mysqlConnection != null) {
      try {
        var results = await _mysqlConnection!.query(
          'SELECT * FROM products WHERE barcode LIKE ? OR product_name LIKE ? OR supplier LIKE ? OR supplier_code LIKE ? ORDER BY created_at DESC',
          ['%$query%', '%$query%', '%$query%', '%$query%'],
        );
        return results.map((row) => Product.fromMap(row.fields)).toList();
      } catch (e) {
        print('MySQL search error: $e');
        return [];
      }
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'barcode LIKE ? OR product_name LIKE ? OR supplier LIKE ? OR supplier_code LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
        orderBy: 'created_at DESC',
      );
      return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
    }
  }

  Future<Product?> getProductByBarcode(String barcode, {bool useMySQL = false}) async {
    if (useMySQL && _mysqlConnection != null) {
      try {
        var results = await _mysqlConnection!.query(
          'SELECT * FROM products WHERE barcode = ?',
          [barcode],
        );
        if (results.isNotEmpty) {
          return Product.fromMap(results.first.fields);
        }
        return null;
      } catch (e) {
        print('MySQL get by barcode error: $e');
        return null;
      }
    } else {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'products',
        where: 'barcode = ?',
        whereArgs: [barcode],
      );
      if (maps.isNotEmpty) {
        return Product.fromMap(maps.first);
      }
      return null;
    }
  }

  Future<int> updateProduct(Product product, {bool useMySQL = false}) async {
    if (useMySQL && _mysqlConnection != null) {
      try {
        var result = await _mysqlConnection!.query(
          'UPDATE products SET product_name = ?, supplier = ?, purchase_price = ?, original_price = ?, discounted_price = ?, supplier_code = ? WHERE id = ?',
          [
            product.productName,
            product.supplier,
            product.purchasePrice,
            product.originalPrice,
            product.discountedPrice,
            product.supplierCode,
            product.id,
          ],
        );
        return result.affectedRows ?? 0;
      } catch (e) {
        print('MySQL update error: $e');
        return 0;
      }
    } else {
      final db = await database;
      return await db.update(
        'products',
        product.toMap(),
        where: 'id = ?',
        whereArgs: [product.id],
      );
    }
  }

  Future<int> deleteProduct(int id, {bool useMySQL = false}) async {
    if (useMySQL && _mysqlConnection != null) {
      try {
        var result = await _mysqlConnection!.query(
          'DELETE FROM products WHERE id = ?',
          [id],
        );
        return result.affectedRows ?? 0;
      } catch (e) {
        print('MySQL delete error: $e');
        return 0;
      }
    } else {
      final db = await database;
      return await db.delete(
        'products',
        where: 'id = ?',
        whereArgs: [id],
      );
    }
  }

  // Bulk insert for Excel import
  Future<List<int>> insertProducts(List<Product> products, {bool useMySQL = false}) async {
    List<int> insertedIds = [];
    
    for (Product product in products) {
      int id = await insertProduct(product, useMySQL: useMySQL);
      if (id > 0) {
        insertedIds.add(id);
      }
    }
    
    return insertedIds;
  }
}
