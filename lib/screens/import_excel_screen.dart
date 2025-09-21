import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../models/product.dart';
import '../providers/product_provider.dart';

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
                          'راهنمای فرمت فایل اکسل',
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
                      'فایل اکسل باید شامل ستون‌های زیر باشد (به ترتیب):',
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

            const SizedBox(height: 24),

            // File picker button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _pickExcelFile,
                icon: const Icon(Icons.file_upload),
                label: const Text('انتخاب فایل اکسل'),
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
                        trailing: Text(
                          '${product.discountedPrice.toStringAsFixed(0)} تومان',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green[600],
                          ),
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
      // موقتاً غیرفعال شده - از دیتابیس آنلاین استفاده کنید
      setState(() {
        _error =
            'وارد کردن از اکسل موقتاً غیرفعال است. از دیتابیس آنلاین استفاده کنید.';
        _isLoading = false;
      });

      // TODO: فعال کردن file_picker بعداً
      /*
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result != null) {
        setState(() {
          _isLoading = true;
          _error = '';
          _fileName = result.files.first.name;
        });

        await _parseExcelFile(result.files.first.path!);
      }
      */
    } catch (e) {
      setState(() {
        _error = 'خطا در انتخاب فایل: $e';
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

        // Skip header row (first row)
        for (int rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
          var row = sheet.rows[rowIndex];
          if (row.length < 7) continue; // Skip incomplete rows

          try {
            Product product = Product.fromExcelRow(row);
            if (product.barcode.toString().isEmpty &&
                product.productName.isNotEmpty) {
              products.add(product);
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
          _error = 'هیچ محصول معتبری در فایل یافت نشد';
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${insertedIds.length} محصول با موفقیت وارد شد'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(productProvider.error.isNotEmpty
                  ? productProvider.error
                  : 'خطا در وارد کردن محصولات'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
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
