import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../providers/product_provider.dart';
import '../widgets/product_card.dart';
import '../widgets/search_bar.dart';
import 'add_product_screen.dart';
import 'import_excel_screen.dart';
import 'suppliers_screen.dart';
import 'suppliers_management_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Use a microtask to ensure this runs after the current build cycle
    Future.microtask(() {
      if (mounted) {
        context.read<ProductProvider>().loadProducts();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      context.read<ProductProvider>().loadProducts();
    } else {
      context.read<ProductProvider>().searchProducts(query);
    }
  }

  void _showScannerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          height: 400,
          child: Column(
            children: [
              Expanded(
                child: MobileScanner(
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      final String? code = barcodes.first.rawValue;
                      if (code != null) {
                        Navigator.pop(context);
                        context.read<ProductProvider>().searchProducts(code);
                      }
                    }
                  },
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('لغو'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<ProductProvider>(
          builder: (context, provider, child) {
            return Row(
              children: [
                const Text('مدیریت محصولات'),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${provider.products.length} محصول',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            );
          },
        ),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.business),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SuppliersManagementScreen(),
                ),
              );
            },
            tooltip: 'مدیریت تامین‌کنندگان',
          ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SuppliersScreen(),
                ),
              );
            },
            tooltip: 'تامین کنندگان',
          ),
          IconButton(
            icon: const Icon(Icons.file_upload),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ImportExcelScreen(),
                ),
              );
            },
            tooltip: 'وارد کردن از اکسل',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                CustomSearchBar(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  hintText: 'جستجو در محصولات...',
                ),
                const SizedBox(height: 12),
              
              ],
            ),
          ),
          
          // Products List
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (context, productProvider, child) {
                if (productProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (productProvider.products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'هیچ محصولی یافت نشد',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'برای شروع، محصول جدیدی اضافه کنید',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await productProvider.loadProducts();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: productProvider.products.length,
                    itemBuilder: (context, index) {
                      final product = productProvider.products[index];
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        child: ProductCard(
                          product: product,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddProductScreen(
                                  product: product,
                                ),
                              ),
                            );
                          },
                          onDelete: () async {
                            await _showDeleteDialog(context, product);
                          },
                        ),
                      );
                    },
                    // Optimize for large lists
                    addAutomaticKeepAlives: false,
                    addRepaintBoundaries: true,
                    cacheExtent: 200.0,
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showScannerDialog(context);
        },
        label: const Text('اسکن بارکد', style: TextStyle(color: Colors.white)),
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        backgroundColor: Colors.blue[600],
        elevation: 4,
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, product) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('حذف محصول'),
          content: const Text('آیا مطمئن هستید که می‌خواهید این محصول را حذف کنید؟'),
          actions: <Widget>[
            TextButton(
              child: const Text('انصراف'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('حذف'),
              onPressed: () async {
                Navigator.of(context).pop();
                await context.read<ProductProvider>().deleteProduct(product.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('محصول با موفقیت حذف شد'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
