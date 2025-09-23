import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../widgets/supplier_card.dart';

class SuppliersManagementScreen extends StatefulWidget {
  const SuppliersManagementScreen({Key? key}) : super(key: key);

  @override
  _SuppliersManagementScreenState createState() => _SuppliersManagementScreenState();
}

class _SuppliersManagementScreenState extends State<SuppliersManagementScreen> {
  List<Map<String, dynamic>> _suppliers = [];
  List<Map<String, dynamic>> _filteredSuppliers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
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
      _filterSuppliers();
    });
  }

  Future<void> _loadSuppliers() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final suppliers = await productProvider.getSuppliersWithDetails();

      setState(() {
        _suppliers = suppliers;
        _filteredSuppliers = suppliers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطا در بارگیری تامین‌کنندگان: $e')),
      );
    }
  }

  void _filterSuppliers() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredSuppliers = _suppliers;
      });
    } else {
      setState(() {
        _filteredSuppliers = _suppliers.where((supplier) {
          final supplierName = supplier['supplier_name']?.toString().toLowerCase() ?? '';
          final contactPerson = supplier['contact_person']?.toString().toLowerCase() ?? '';
          final phone = supplier['phone']?.toString().toLowerCase() ?? '';
          final email = supplier['email']?.toString().toLowerCase() ?? '';
          final query = _searchQuery.toLowerCase();
          
          return supplierName.contains(query) ||
                 contactPerson.contains(query) ||
                 phone.contains(query) ||
                 email.contains(query);
        }).toList();
      });
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _filteredSuppliers = _suppliers;
    });
  }

  void _showAddSupplierDialog() {
    final _formKey = GlobalKey<FormState>();
    final _supplierNameController = TextEditingController();
    final _contactPersonController = TextEditingController();
    final _phoneController = TextEditingController();
    final _emailController = TextEditingController();
    final _addressController = TextEditingController();
    final _descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('افزودن تامین‌کننده جدید'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _supplierNameController,
                  decoration: const InputDecoration(
                    labelText: 'نام تامین‌کننده *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفاً نام تامین‌کننده را وارد کنید';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactPersonController,
                  decoration: const InputDecoration(
                    labelText: 'نام شخص تماس',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'تلفن',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'ایمیل',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'آدرس',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'توضیحات',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لغو'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final supplierData = {
                  'supplier_name': _supplierNameController.text,
                  'contact_person': _contactPersonController.text,
                  'phone': _phoneController.text,
                  'email': _emailController.text,
                  'address': _addressController.text,
                  'description': _descriptionController.text,
                  'is_active': 1,
                  'created_at': DateTime.now().toIso8601String(),
                  'updated_at': DateTime.now().toIso8601String(),
                };

                final productProvider = Provider.of<ProductProvider>(context, listen: false);
                final success = await productProvider.addSupplier(supplierData);

                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تامین‌کننده با موفقیت افزوده شد')),
                  );
                  _loadSuppliers();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطا در افزودن تامین‌کننده: ${productProvider.error}')),
                  );
                }
              }
            },
            child: const Text('افزودن'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مدیریت تامین‌کنندگان'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSuppliers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'جستجوی تامین‌کننده',
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
          
          // Suppliers List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredSuppliers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _searchQuery.isEmpty
                                  ? Icons.people_outline
                                  : Icons.search_off,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'هیچ تامین‌کننده‌ای یافت نشد'
                                  : 'هیچ تامین‌کننده‌ای با این جستجو یافت نشد',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _searchQuery.isEmpty
                                  ? 'برای افزودن تامین‌کننده جدید از دکمه + استفاده کنید'
                                  : 'لطفاً عبارت جستجوی دیگری را امتحان کنید',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey,
                                  ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        itemCount: _filteredSuppliers.length,
                        itemBuilder: (context, index) {
                          final supplier = _filteredSuppliers[index];
                          return SupplierCard(
                            supplier: supplier,
                            onTap: () => _showSupplierDetails(supplier),
                            onEdit: () => _editSupplier(supplier),
                            onDelete: () => _confirmDeleteSupplier(supplier),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSupplierDialog,
        child: const Icon(Icons.add),
        tooltip: 'افزودن تامین‌کننده جدید',
      ),
    );
  }

  void _showSupplierDetails(Map<String, dynamic> supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(supplier['supplier_name'] ?? 'تامین‌کننده'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('تعداد محصولات', supplier['product_count']?.toString() ?? '0'),
              if (supplier['contact_person'] != null && supplier['contact_person'].toString().isNotEmpty)
                _buildDetailRow('شخص تماس', supplier['contact_person']),
              if (supplier['phone'] != null && supplier['phone'].toString().isNotEmpty)
                _buildDetailRow('تلفن', supplier['phone']),
              if (supplier['email'] != null && supplier['email'].toString().isNotEmpty)
                _buildDetailRow('ایمیل', supplier['email']),
              if (supplier['address'] != null && supplier['address'].toString().isNotEmpty)
                _buildDetailRow('آدرس', supplier['address']),
              if (supplier['description'] != null && supplier['description'].toString().isNotEmpty)
                _buildDetailRow('توضیحات', supplier['description']),
              _buildDetailRow('وضعیت', supplier['is_active'] == 1 ? 'فعال' : 'غیرفعال'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('بستن'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _editSupplier(Map<String, dynamic> supplier) {
    final _formKey = GlobalKey<FormState>();
    final _supplierNameController = TextEditingController(text: supplier['supplier_name']);
    final _contactPersonController = TextEditingController(text: supplier['contact_person'] ?? '');
    final _phoneController = TextEditingController(text: supplier['phone'] ?? '');
    final _emailController = TextEditingController(text: supplier['email'] ?? '');
    final _addressController = TextEditingController(text: supplier['address'] ?? '');
    final _descriptionController = TextEditingController(text: supplier['description'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ویرایش تامین‌کننده'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _supplierNameController,
                  decoration: const InputDecoration(
                    labelText: 'نام تامین‌کننده *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'لطفاً نام تامین‌کننده را وارد کنید';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _contactPersonController,
                  decoration: const InputDecoration(
                    labelText: 'نام شخص تماس',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'تلفن',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'ایمیل',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'آدرس',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'توضیحات',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لغو'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final supplierData = {
                  'id': supplier['id'],
                  'supplier_name': _supplierNameController.text,
                  'contact_person': _contactPersonController.text,
                  'phone': _phoneController.text,
                  'email': _emailController.text,
                  'address': _addressController.text,
                  'description': _descriptionController.text,
                  'is_active': supplier['is_active'] ?? 1,
                  'updated_at': DateTime.now().toIso8601String(),
                };

                final productProvider = Provider.of<ProductProvider>(context, listen: false);
                final success = await productProvider.updateSupplier(supplierData);

                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تامین‌کننده با موفقیت بروزرسانی شد')),
                  );
                  _loadSuppliers();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('خطا در بروزرسانی تامین‌کننده: ${productProvider.error}')),
                  );
                }
              }
            },
            child: const Text('ذخیره'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSupplier(Map<String, dynamic> supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف تامین‌کننده'),
        content: Text('آیا از حذف تامین‌کننده "${supplier['supplier_name']}" اطمینان دارید؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('لغو'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final productProvider = Provider.of<ProductProvider>(context, listen: false);
              final success = await productProvider.deleteSupplier(supplier['id']);

              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تامین‌کننده با موفقیت حذف شد')),
                );
                _loadSuppliers();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('خطا در حذف تامین‌کننده: ${productProvider.error}')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}