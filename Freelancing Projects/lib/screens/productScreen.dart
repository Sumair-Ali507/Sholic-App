import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sholic_app/screens/tagScreen.dart';
import 'package:sholic_app/screens/productSelectionScreen.dart';

class ProductEnterScreen extends StatefulWidget {
  final Map<String, dynamic>? product;

  ProductEnterScreen({this.product});

  @override
  _ProductEnterScreenState createState() => _ProductEnterScreenState();
}

class _ProductEnterScreenState extends State<ProductEnterScreen> {
  final _productnameController = TextEditingController();
  final _companyController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _unitController = TextEditingController(); // Replacing Dropdown with TextField
  List<String> _selectedTags = [];
  List<String> _selectedProducts = [];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      final product = widget.product!;
      _productnameController.text = product['name'] ?? '';
      _companyController.text = product['company'] ?? '';
      _quantityController.text = product['quantity']?.toString() ?? '';
      _priceController.text = product['price']?.toString() ?? '';
      _unitController.text = product['unit'] ?? 'kg'; // Default unit
      _selectedTags = List<String>.from(product['tags'] ?? []);
      _selectedProducts = List<String>.from(product['linkedProducts'] ?? []);
    }
  }

  void _submitProduct() async {
    String name = _productnameController.text.trim();
    String company = _companyController.text.trim();
    int quantity = int.tryParse(_quantityController.text) ?? 0;
    double price = double.tryParse(_priceController.text) ?? 0.0;
    String unit = _unitController.text.trim();
    List<String> tags = _selectedTags;
    List<String> products = _selectedProducts;

    if (name.isEmpty || company.isEmpty || unit.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all required fields.')),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('products').add({
      'name': name,
      'company': company,
      'quantity': quantity,
      'unit': unit,
      'tags': tags,
      'price': price,
      'linkedProducts': products,
    });

    Navigator.pop(context);
  }

  void _selectTags() async {
    final selectedTags = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TagSelectionScreen(selectedTags: _selectedTags),
      ),
    );
    if (selectedTags != null) {
      setState(() {
        _selectedTags = selectedTags;
      });
    }
  }

  void _selectProducts() async {
    final selectedProduct = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductSelectionScreen(selectedProducts: _selectedProducts),
      ),
    );

    if (selectedProduct != null) {
      setState(() {
        _productnameController.text = selectedProduct['name'] ?? '';
        _companyController.text = selectedProduct['company'] ?? '';
        _quantityController.text = selectedProduct['quantity']?.toString() ?? '';
        _priceController.text = selectedProduct['price']?.toString() ?? '';
        _unitController.text = selectedProduct['unit'] ?? 'kg';
        _selectedTags = List<String>.from(selectedProduct['tags'] ?? []);
        _selectedProducts = List<String>.from(selectedProduct['linkedProducts'] ?? []);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Product', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Product',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _productnameController,
                  decoration: InputDecoration(
                    labelText: 'Product Name',
                    prefixIcon: Icon(Icons.business, color: Colors.teal),
                    filled: true,
                    fillColor: Colors.teal.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _companyController,
                  decoration: InputDecoration(
                    labelText: 'Company Name',
                    prefixIcon: Icon(Icons.business, color: Colors.teal),
                    filled: true,
                    fillColor: Colors.teal.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _quantityController,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    prefixIcon: Icon(Icons.numbers, color: Colors.teal),
                    filled: true,
                    fillColor: Colors.teal.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _unitController, // New unit text field
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    prefixIcon: Icon(Icons.straighten, color: Colors.teal),
                    filled: true,
                    fillColor: Colors.teal.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    prefixIcon: Icon(Icons.attach_money, color: Colors.teal),
                    filled: true,
                    fillColor: Colors.teal.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _selectTags,
                  icon: Icon(Icons.label, color: Colors.white),
                  label: Text('Select Tags'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
                SizedBox(height: 8),
                if (_selectedTags.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: _selectedTags
                        .map((tag) => Chip(
                      label: Text(tag),
                      deleteIcon: Icon(Icons.close),
                      onDeleted: () {
                        setState(() {
                          _selectedTags.remove(tag);
                        });
                      },
                    ))
                        .toList(),
                  ),
                SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _selectProducts,
                  icon: Icon(Icons.shopping_cart, color: Colors.white),
                  label: Text('Select Products'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 50),
                  ),
                ),
                SizedBox(height: 8),
                if (_selectedProducts.isNotEmpty)
                  Wrap(
                    spacing: 8,
                    children: _selectedProducts
                        .map((product) => Chip(
                      label: Text(product),
                      deleteIcon: Icon(Icons.close),
                      onDeleted: () {
                        setState(() {
                          _selectedProducts.remove(product);
                        });
                      },
                    ))
                        .toList(),
                  ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.cancel, color: Colors.red),
                      label: Text('Cancel'),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                    ),
                    ElevatedButton.icon(
                      onPressed: _submitProduct,
                      icon: Icon(Icons.check, color: Colors.white),
                      label: Text('Submit'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

