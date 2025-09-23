import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const baseUrl = 'https://blizzardping.ir/hyper.php';
  
  try {
    print('Testing online API...');
    
    // Test connection
    final response = await http.get(
      Uri.parse('$baseUrl?action=test'),
    );
    
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      print('Success: ${data['success']}');
      print('Message: ${data['message']}');
      
      // Test getting products
      final productsResponse = await http.get(
        Uri.parse('$baseUrl?action=products&page=1&limit=10'),
      );
      
      print('\nProducts Response status: ${productsResponse.statusCode}');
      print('Products Response body: ${productsResponse.body}');
      
      if (productsResponse.statusCode == 200) {
        final productsData = json.decode(productsResponse.body);
        if (productsData['success']) {
          final products = productsData['data']['products'] as List;
          print('Found ${products.length} products');
          
          // Extract suppliers
          final suppliers = products.map((p) => p['supplier']).toSet().toList();
          print('Found ${suppliers.length} suppliers: $suppliers');
        }
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}