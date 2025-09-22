import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../utils/price_formatter.dart';

class AddProductScreen extends StatefulWidget {
  final Product? product;

  const AddProductScreen({super.key, this.product});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _barcodeController = TextEditingController();
  final _productNameController = TextEditingController();
  final _supplierController = TextEditingController();
  final _supplierCodeController = TextEditingController();
  final _purchasePriceController = TextEditingController();
  final _originalPriceController = TextEditingController();
  final _discountedPriceController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final product = widget.product!;
    _barcodeController.text = product.barcode.toString();
    _productNameController.text = product.productName;
    _supplierController.text = product.supplier.toString();
    ;
    _supplierCodeController.text = product.supplierCode.toString();
    _purchasePriceController.text = product.purchasePrice.toString();
    _originalPriceController.text = product.originalPrice.toString();
    _discountedPriceController.text = product.discountedPrice.toString();
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _productNameController.dispose();
    _supplierController.dispose();
    _supplierCodeController.dispose();
    _purchasePriceController.dispose();
    _originalPriceController.dispose();
    _discountedPriceController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Parse formatted numbers (remove thousands separators)
      final purchase = double.parse(_purchasePriceController.text.replaceAll(',', ''));
      final original = double.parse(_originalPriceController.text.replaceAll(',', ''));
      final discounted = double.parse(_discountedPriceController.text.replaceAll(',', ''));

      final product = Product(
        id: widget.product?.id,
        barcode: _barcodeController.text.trim(),
        productName: _productNameController.text.trim(),
        supplier: _supplierController.text.trim(),
        supplierCode: double.parse(_supplierCodeController.text.trim()),
        purchasePrice: purchase,
        originalPrice: original,
        discountedPrice: discounted,
      );

      final productProvider = context.read<ProductProvider>();
      bool success;

      if (widget.product != null) {
        success = await productProvider.updateProduct(product);
      } else {
        success = await productProvider.addProduct(product);
      }

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.product != null
                    ? 'محصول با موفقیت بروزرسانی شد'
                    : 'محصول با موفقیت اضافه شد',
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(productProvider.error.isNotEmpty
                  ? productProvider.error
                  : 'خطا در ذخیره محصول'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطا: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.product != null ? 'ویرایش محصول' : 'افزودن محصول جدید'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barcode Field
              _buildTextField(
                controller: _barcodeController,
                label: 'بارکد',
                icon: Icons.qr_code,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفاً بارکد را وارد کنید';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Product Name Field
              _buildTextField(
                controller: _productNameController,
                label: 'نام محصول',
                icon: Icons.inventory_2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفاً نام محصول را وارد کنید';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Supplier Field
              _buildTextField(
                controller: _supplierController,
                label: 'تامین کننده',
                icon: Icons.business,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفاً تامین کننده را وارد کنید';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Supplier Code Field
              _buildTextField(
                controller: _supplierCodeController,
                label: 'کد تامین کننده',
                icon: Icons.tag,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفاً کد تامین کننده را وارد کنید';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Price Section
              Text(
                'اطلاعات قیمت',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),

              const SizedBox(height: 16),

              // Prices (minimal, side-by-side)
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _purchasePriceController,
                      label: 'قیمت خرید (ریال)',
                      icon: Icons.shopping_cart,
                      keyboardType: TextInputType.number,
                      inputFormatters: const [],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الزامی';
                        }
                        if (double.tryParse(value.replaceAll(',', '')) == null) {
                          return 'عدد نامعتبر';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _originalPriceController,
                      label: 'قیمت اصلی (ریال)',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                      inputFormatters: const [],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الزامی';
                        }
                        if (double.tryParse(value.replaceAll(',', '')) == null) {
                          return 'عدد نامعتبر';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              _buildTextField(
                controller: _discountedPriceController,
                label: 'قیمت نهایی (ریال)',
                icon: Icons.local_offer,
                keyboardType: TextInputType.number,
                inputFormatters: const [],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الزامی';
                  }
                  if (double.tryParse(value.replaceAll(',', '')) == null) {
                    return 'عدد نامعتبر';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          widget.product != null
                              ? 'بروزرسانی محصول'
                              : 'ذخیره محصول',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.right,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
