import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar.dart';

class SupplierProductsScreen extends StatefulWidget {
  final String supplier;

  const SupplierProductsScreen({Key? key, required this.supplier}) : super(key: key);

  @override
  State<SupplierProductsScreen> createState() => _SupplierProductsScreenState();
}

class _SupplierProductsScreenState extends State<SupplierProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _filteredProducts = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Use microtask to ensure this runs after the current build cycle
    Future.microtask(() {
      if (mounted) {
        Provider.of<ProductProvider>(context, listen: false).loadProducts();
      }
    });
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('محصولات ${widget.supplier}'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'جستجو در محصولات ${widget.supplier}',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _clearSearch,
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          
          // Products List
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (productProvider.error.isNotEmpty) {
                  return Center(child: Text(productProvider.error));
                }

                // Filter products by supplier
                final supplierProducts = productProvider.products
                    .where((product) => product.supplier == widget.supplier)
                    .toList();

                // Apply search filter
                final filteredProducts = _searchQuery.isEmpty
                    ? supplierProducts
                    : supplierProducts.where((product) {
                        final query = _searchQuery.toLowerCase();
                        return product.productName.toLowerCase().contains(query) ||
                               product.barcode.toLowerCase().contains(query) ||
                               product.supplier.toLowerCase().contains(query);
                      }).toList();

                if (filteredProducts.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _searchQuery.isEmpty
                              ? Icons.inventory_2_outlined
                              : Icons.search_off,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _searchQuery.isEmpty
                              ? 'محصولی از ${widget.supplier} یافت نشد'
                              : 'هیچ محصولی با جستجوی "$_searchQuery" یافت نشد',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _searchQuery.isEmpty
                              ? 'برای افزودن محصول جدید از دکمه + در صفحه اصلی استفاده کنید'
                              : 'لطفاً عبارت جستجوی دیگری را امتحان کنید',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    return ProductCard(product: filteredProducts[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}