import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'dart:convert';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../utils/price_formatter.dart';

class ImportExcelScreen extends StatefulWidget {
  const ImportExcelScreen({super.key});

  @override
  State<ImportExcelScreen> createState() => _ImportExcelScreenState();
}

class _ImportExcelScreenState extends State<ImportExcelScreen> {
  List<Product> _importedProducts = [];
  bool _isLoading = false;
  String _fileName = '';
  String _error = '';
  ScaffoldMessengerState? _messenger;
  NavigatorState? _navigator;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Cache ancestors to avoid looking them up after unmount
    _messenger = ScaffoldMessenger.maybeOf(context);
    _navigator = Navigator.maybeOf(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('وارد کردن از اکسل'),
        backgroundColor: Colors.green[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instructions
            Card(
              color: Colors.blue[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue[600]),
                        const SizedBox(width: 8),
                        Text(
                          'راهنمای فرمت فایل',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'فایل Excel یا CSV باید شامل ستون‌های زیر باشد (به ترتیب):',
                      style: TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. بارکد\n2. نام محصول\n3. تامین کننده\n4. قیمت خرید\n5. قیمت اصلی\n6. قیمت نهایی\n7. کد تامین کننده',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Database status
            Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                return Card(
                  color: productProvider.useOnline ? Colors.green[50] : Colors.orange[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          productProvider.useOnline ? Icons.cloud_done : Icons.storage,
                          color: productProvider.useOnline ? Colors.green[600] : Colors.orange[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                productProvider.useOnline ? 'دیتابیس آنلاین' : 'دیتابیس محلی',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: productProvider.useOnline ? Colors.green[800] : Colors.orange[800],
                                ),
                              ),
                              Text(
                                productProvider.useOnline 
                                    ? 'محصولات به دیتابیس آنلاین وارد می‌شوند'
                                    : 'محصولات به دیتابیس محلی وارد می‌شوند',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: productProvider.useOnline ? Colors.green[700] : Colors.orange[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // File picker button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickExcelFile,
                icon: const Icon(Icons.file_upload),
                label: const Text('انتخاب فایل (Excel یا CSV)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            if (_fileName.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.file_present, color: Colors.green),
                  title: Text('فایل انتخاب شده: $_fileName'),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _fileName = '';
                        _importedProducts.clear();
                        _error = '';
                      });
                    },
                  ),
                ),
              ),
            ],

            if (_error.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _error,
                          style: TextStyle(color: Colors.red[800]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (_importedProducts.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'محصولات یافت شده: ${_importedProducts.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _importedProducts.length,
                  itemBuilder: (context, index) {
                    final product = _importedProducts[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green[100],
                          child: Text('${index + 1}'),
                        ),
                        title: Text(product.productName),
                        subtitle: Text('بارکد: ${product.barcode}'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              PriceFormatter.formatPrice(product.discountedPrice),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[600],
                              ),
                            ),
                            if (product.hasDiscount())
                              Container(
                                margin: const EdgeInsets.only(top: 4),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red[100],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${product.getDiscountPercentage().toStringAsFixed(1)}% تخفیف',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red[700],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Import button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _importProducts,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(
                      _isLoading ? 'در حال وارد کردن...' : 'وارد کردن محصولات'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickExcelFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls', 'csv'],
      );

      if (result != null) {
        setState(() {
          _isLoading = true;
          _error = '';
          _fileName = result.files.first.name;
        });

        String filePath = result.files.first.path!;
        String extension = filePath.split('.').last.toLowerCase();
        
        if (extension == 'csv') {
          await _parseCsvFile(filePath);
        } else {
          await _parseExcelFile(filePath);
        }
      }
    } catch (e) {
      setState(() {
        _error = 'خطا در انتخاب فایل: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _parseCsvFile(String filePath) async {
    try {
      String content = await File(filePath).readAsString(encoding: utf8);
      List<String> lines = content.split('\n');
      
      List<Product> products = [];
      
      // Skip header row (first line)
      for (int i = 1; i < lines.length; i++) {
        String line = lines[i].trim();
        if (line.isEmpty) continue;
        
        List<String> fields = line.split(',');
        if (fields.length < 7) {
          print('Skipping line $i: insufficient fields (${fields.length})');
          continue;
        }
        
        try {
          // Create a row-like structure for Product.fromExcelRow
          List<dynamic> row = fields.map((field) => field.trim()).toList();
          Product product = Product.fromExcelRow(row);
          
          print('Parsed CSV product: ${product.productName}, barcode: ${product.barcode}');
          
          if (product.barcode.toString().isNotEmpty &&
              product.productName.isNotEmpty) {
            products.add(product);
            print('Added CSV product: ${product.productName}');
          } else {
            print('Skipped CSV product: empty barcode or name');
          }
        } catch (e) {
          print('Error parsing CSV line $i: $e');
          continue;
        }
      }
      
      setState(() {
        _importedProducts = products;
        _isLoading = false;
        if (products.isEmpty) {
          _error = 'هیچ محصول معتبری در فایل CSV یافت نشد. لطفاً مطمئن شوید که:\n'
              '• فایل شامل حداقل 7 ستون است\n'
              '• ستون اول (بارکد) و دوم (نام محصول) خالی نیستند\n'
              '• فرمت فایل صحیح است (.csv)';
        }
      });
    } catch (e) {
      setState(() {
        _error = 'خطا در خواندن فایل CSV: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _parseExcelFile(String filePath) async {
    try {
      var bytes = File(filePath).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      List<Product> products = [];

      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet == null) continue;

        print('Processing sheet: $table with ${sheet.maxRows} rows');
        
        // Skip header row (first row)
        for (int rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
          var row = sheet.rows[rowIndex];
          if (row.length < 7) {
            print('Skipping row $rowIndex: insufficient columns (${row.length})');
            continue; // Skip incomplete rows
          }

          try {
            Product product = Product.fromExcelRow(row);
            print('Parsed product: ${product.productName}, barcode: ${product.barcode}');
            
            if (product.barcode.toString().isNotEmpty &&
                product.productName.isNotEmpty) {
              products.add(product);
              print('Added product: ${product.productName}');
            } else {
              print('Skipped product: empty barcode or name');
            }
          } catch (e) {
            print('Error parsing row $rowIndex: $e');
            continue;
          }
        }
      }

      setState(() {
        _importedProducts = products;
        _isLoading = false;
        if (products.isEmpty) {
          _error = 'هیچ محصول معتبری در فایل یافت نشد. لطفاً مطمئن شوید که:\n'
              '• فایل شامل حداقل 7 ستون است\n'
              '• ستون اول (بارکد) و دوم (نام محصول) خالی نیستند\n'
              '• فرمت فایل صحیح است (.xlsx یا .xls)';
        }
      });
    } catch (e) {
      setState(() {
        _error = 'خطا در خواندن فایل اکسل: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _importProducts() async {
    if (_importedProducts.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final productProvider = context.read<ProductProvider>();
      
      
      List<int> insertedIds =
          await productProvider.importProducts(_importedProducts);

      if (mounted) {
        if (insertedIds.isNotEmpty) {
          _messenger?.showSnackBar(
            SnackBar(
              content: Text('${insertedIds.length} محصول با موفقیت وارد شد'),
              backgroundColor: Colors.green,
            ),
          );
          _navigator?.maybePop();
        } else {
          String errorMessage = productProvider.error.isNotEmpty
              ? productProvider.error
              : 'خطا در وارد کردن محصولات';
          
          _messenger?.showSnackBar(
            SnackBar(
              content: Text(errorMessage),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _messenger?.showSnackBar(
          SnackBar(
            content: Text('خطا: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
