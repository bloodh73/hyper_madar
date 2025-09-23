import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import 'package:provider/provider.dart';

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
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final product = widget.product!;
    _barcodeController.text = product.barcode;
    _productNameController.text = product.productName;
    _supplierController.text = product.supplier;
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

  void _showScannerDialog() {
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
                        _barcodeController.text = code;
                        Navigator.pop(context);
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

  Future<void> _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        final product = Product(
          id: widget.product?.id,
          barcode: _barcodeController.text,
          productName: _productNameController.text,
          supplier: _supplierController.text,
          purchasePrice: double.parse(_purchasePriceController.text),
          originalPrice: double.parse(_originalPriceController.text),
          discountedPrice: double.parse(_discountedPriceController.text),
          supplierCode: double.parse(_supplierCodeController.text),
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
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'ویرایش محصول' : 'افزودن محصول جدید'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _barcodeController,
                      decoration: const InputDecoration(
                        labelText: 'بارکد',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'لطفاً بارکد را وارد کنید';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.qr_code_scanner),
                    onPressed: _showScannerDialog,
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _productNameController,
                decoration: const InputDecoration(
                  labelText: 'نام محصول',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفاً نام محصول را وارد کنید';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _supplierController,
                decoration: const InputDecoration(
                  labelText: 'تامین کننده',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفاً تامین کننده را وارد کنید';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _supplierCodeController,
                decoration: const InputDecoration(
                  labelText: 'کد تامین کننده',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفاً کد تامین کننده را وارد کنید';
                  }
                  if (double.tryParse(value) == null) {
                    return 'لطفاً یک عدد معتبر وارد کنید';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _purchasePriceController,
                decoration: const InputDecoration(
                  labelText: 'قیمت خرید',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفاً قیمت خرید را وارد کنید';
                  }
                  if (double.tryParse(value) == null) {
                    return 'لطفاً یک عدد معتبر وارد کنید';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _originalPriceController,
                decoration: const InputDecoration(
                  labelText: 'قیمت اصلی',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفاً قیمت اصلی را وارد کنید';
                  }
                  if (double.tryParse(value) == null) {
                    return 'لطفاً یک عدد معتبر وارد کنید';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _discountedPriceController,
                decoration: const InputDecoration(
                  labelText: 'قیمت نهایی',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لطفاً قیمت نهایی را وارد کنید';
                  }
                  if (double.tryParse(value) == null) {
                    return 'لطفاً یک عدد معتبر وارد کنید';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _isSaving ? null : _saveProduct,
                child: _isSaving
                    ? const CircularProgressIndicator()
                    : Text(widget.product != null ? 'بروزرسانی محصول' : 'ذخیره محصول'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
