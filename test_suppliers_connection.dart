import 'lib/services/database_service.dart';

void main() async {
  print('Testing suppliers connection...');
  
  final dbService = DatabaseService();
  
  try {
    // Test SQLite first
    print('Testing SQLite connection...');
    final suppliersSQLite = await dbService.getSuppliers(useMySQL: false);
    print('SQLite - Found ${suppliersSQLite.length} suppliers');
    if (suppliersSQLite.isNotEmpty) {
      print('First 5 suppliers from SQLite:');
      for (int i = 0; i < 5 && i < suppliersSQLite.length; i++) {
        print('  - ${suppliersSQLite[i]}');
      }
    }
    
    // Test MySQL if available
    print('\nTesting MySQL connection...');
    try {
      final connection = await dbService.connectToMySQL();
      if (connection != null) {
        final suppliersMySQL = await dbService.getSuppliers(useMySQL: true);
        print('MySQL - Found ${suppliersMySQL.length} suppliers');
        if (suppliersMySQL.isNotEmpty) {
          print('First 5 suppliers from MySQL:');
          for (int i = 0; i < 5 && i < suppliersMySQL.length; i++) {
            print('  - ${suppliersMySQL[i]}');
          }
        }
      } else {
        print('MySQL connection failed');
      }
    } catch (e) {
      print('MySQL error: $e');
    }
    
  } catch (e) {
    print('Error: $e');
  }
  
  print('Test completed.');
}