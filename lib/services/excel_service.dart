import 'dart:io';
import 'package:excel/excel.dart';
import '../models/product.dart';

class ExcelService {
  static Future<List<Product>> parseExcelFile(String filePath) async {
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
            if (product.barcode.toString().isNotEmpty &&
                product.productName.isNotEmpty) {
              products.add(product);
            }
          } catch (e) {
            print('Error parsing row $rowIndex: $e');
            continue;
          }
        }
      }

      return products;
    } catch (e) {
      throw Exception('خطا در خواندن فایل اکسل: $e');
    }
  }

  static Future<void> exportToExcel(
      List<Product> products, String filePath) async {
    try {
      var excel = Excel.createExcel();
      var sheet = excel['Products'];

      // Add headers
      sheet.appendRow([
        TextCellValue('بارکد'),
        TextCellValue('نام محصول'),
        TextCellValue('تامین کننده'),
        TextCellValue('قیمت خرید'),
        TextCellValue('قیمت اصلی'),
        TextCellValue('قیمت نهایی'),
        TextCellValue('کد تامین کننده'),
      ]);

      // Add data rows
      for (Product product in products) {
        sheet.appendRow([
          TextCellValue(product.barcode.toString()),
          TextCellValue(product.productName),
          TextCellValue(product.supplier.toString()),
          DoubleCellValue(product.purchasePrice),
          DoubleCellValue(product.originalPrice),
          DoubleCellValue(product.discountedPrice),
          TextCellValue(product.supplierCode.toString()),
        ]);
      }

      // Save file
      var fileBytes = excel.save();
      if (fileBytes != null) {
        File(filePath).writeAsBytesSync(fileBytes);
      }
    } catch (e) {
      throw Exception('خطا در ذخیره فایل اکسل: $e');
    }
  }
}
