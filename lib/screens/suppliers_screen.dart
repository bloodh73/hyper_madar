import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import 'supplier_products_screen.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({Key? key}) : super(key: key);

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  late Future<List<String>> _suppliersFuture;
  final TextEditingController _searchController = TextEditingController();
  List<String> _allSuppliers = [];
  List<String> _filteredSuppliers = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Load products first, then load suppliers
    _loadSuppliers();
    _searchController.addListener(_filterSuppliers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadSuppliers() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    // Use microtask to avoid calling loadProducts during build
    _suppliersFuture = Future.microtask(() => productProvider.loadProducts()).then((_) async {
      final suppliers = await productProvider.getSuppliers();
      print('DEBUG: Found ${suppliers.length} suppliers');
      setState(() {
        _allSuppliers = suppliers;
        _filteredSuppliers = suppliers;
      });
      return suppliers;
    }).catchError((error) {
      print('DEBUG: Error loading suppliers: $error');
      throw error;
    });
  }

  void _filterSuppliers() {
    final query = _searchController.text.toLowerCase();
    if (query.isEmpty) {
      setState(() {
        _filteredSuppliers = _allSuppliers;
        _isSearching = false;
      });
    } else {
      setState(() {
        _filteredSuppliers = _allSuppliers
            .where((supplier) => supplier.toLowerCase().contains(query))
            .toList();
        _isSearching = true;
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredSuppliers = _allSuppliers;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تامین کنندگان'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _loadSuppliers();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'جستجوی تامین‌کننده',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _isSearching
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: _suppliersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text('خطا در بارگذاری تامین‌کنندگان: ${snapshot.error}'),
                  );
                }

                final suppliers = _filteredSuppliers;

                if (suppliers.isEmpty) {
                  return const Center(
                    child: Text('هیچ تامین‌کننده‌ای یافت نشد'),
                  );
                }

                return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: suppliers.length,
                        itemBuilder: (context, index) {
                    final supplier = suppliers[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        title: Text(
                          supplier,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: FutureBuilder<int>(
                          future: Provider.of<ProductProvider>(context, listen: false).getSupplierProductCountFromDB(supplier),
                          builder: (context, countSnapshot) {
                            if (countSnapshot.hasData) {
                              return Text('تعداد محصولات: ${countSnapshot.data}');
                            } else if (countSnapshot.hasError) {
                              return Text('تعداد محصولات: خطا در بارگذاری');
                            } else {
                              return Text('تعداد محصولات: در حال بارگذاری...');
                            }
                          },
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SupplierProductsScreen(
                                supplier: supplier,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
        },
      ),
    )]));
  }
}