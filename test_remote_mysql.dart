import 'dart:io';
import 'package:mysql1/mysql1.dart';

void main() async {
  print('Testing remote MySQL connection...');
  
  try {
    // Test connection to your remote MySQL database
    // Note: You may need to change 'localhost' to your actual server IP/hostname
    final connection = await MySqlConnection.connect(
      ConnectionSettings(
        host: 'vghzoegc.hyperphp.com', // Remote MySQL server
        port: 3306,
        user: 'vghzoegc_hamed',
        password: 'Hamed1373r',
        db: 'vghzoegc_hyper',
      ),
    );
    
    print('✓ Connected to MySQL successfully!');
    
    // Test supplier query
    var results = await connection.query(
      'SELECT DISTINCT TRIM(supplier) as supplier FROM products WHERE supplier IS NOT NULL AND TRIM(supplier) != "" ORDER BY TRIM(supplier)'
    );
    
    print('✓ Found ${results.length} suppliers:');
    for (var row in results) {
      print('  - ${row['supplier']}');
    }
    
    // Test product count
    var countResults = await connection.query(
      'SELECT TRIM(supplier) as supplier, COUNT(*) as count FROM products WHERE supplier IS NOT NULL AND TRIM(supplier) != "" GROUP BY TRIM(supplier) ORDER BY TRIM(supplier)'
    );
    
    print('\n✓ Product counts:');
    for (var row in countResults) {
      print('  - ${row['supplier']}: ${row['count']} products');
    }
    
    await connection.close();
    print('\n✓ Test completed successfully!');
    
  } catch (e) {
    print('✗ Error: $e');
    print('\nNote: If your MySQL server is on a remote host,');
    print('you need to change "localhost" to your server IP address.');
    exit(1);
  }
}