import 'package:flutter/material.dart';
import 'package:product_manager/services/database_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=== Testing Database Connection ===');
  
  try {
    final databaseService = DatabaseService();
    
    print('Getting suppliers from database...');
    final suppliers = await databaseService.getSuppliers();
    print('Found ${suppliers.length} suppliers: $suppliers');
    
    if (suppliers.isNotEmpty) {
      print('Testing product count for first supplier: ${suppliers.first}');
      final count = await databaseService.getSupplierProductCount(suppliers.first);
      print('Product count for ${suppliers.first}: $count');
    }
    
  } catch (e) {
    print('Error: $e');
  }
  
  print('=== Test Complete ===');
}