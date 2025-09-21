class AppConfig {
  // Database Configuration
  static const String defaultDatabaseName = 'products.db';
  static const String mysqlDatabaseName = 'vghzoegc_hyper';

  // MySQL Default Settings
  static const String mysqlHost = 'localhost';
  static const int mysqlPort = 3306;
  static const String mysqlUser = 'vghzoegc_hamed';
  static const String mysqlPassword = 'Hamed1373r';

  // App Settings
  static const String appName = 'مدیریت محصولات';
  static const String appVersion = '1.0.0';

  // UI Settings
  static const double cardElevation = 2.0;
  static const double borderRadius = 12.0;
  static const double defaultPadding = 16.0;

  // Barcode Settings
  static const double barcodeWidth = 200.0;
  static const double barcodeHeight = 50.0;

  // Search Settings
  static const int searchMinLength = 1;
  static const int searchMaxResults = 100;

  // Excel Settings
  static const List<String> supportedExcelExtensions = ['xlsx', 'xls'];
  static const int maxExcelRows = 1000;

  // Validation Settings
  static const int maxBarcodeLength = 50;
  static const int maxProductNameLength = 255;
  static const int maxSupplierLength = 255;
  static const int maxSupplierCodeLength = 255;
  static const double maxPrice = 999999999.99;

  // Error Messages
  static const String errorDatabaseConnection = 'خطا در اتصال به دیتابیس';
  static const String errorFileNotFound = 'فایل یافت نشد';
  static const String errorInvalidFormat = 'فرمت فایل نامعتبر است';
  static const String errorNetworkConnection = 'خطا در اتصال شبکه';

  // Success Messages
  static const String successProductAdded = 'محصول با موفقیت اضافه شد';
  static const String successProductUpdated = 'محصول با موفقیت بروزرسانی شد';
  static const String successProductDeleted = 'محصول با موفقیت حذف شد';
  static const String successExcelImported = 'فایل اکسل با موفقیت وارد شد';
}
