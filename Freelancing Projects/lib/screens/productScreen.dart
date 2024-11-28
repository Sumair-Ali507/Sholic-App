import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sholic_app/screens/tagScreen.dart';

class ProductEnterScreen extends StatefulWidget {
  @override
  _ProductEnterScreenState createState() => _ProductEnterScreenState();
}

class _ProductEnterScreenState extends State<ProductEnterScreen> {
  final _companyController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController(); // Controller for the price
  String _selectedUnit = 'kg';
  List<String> _selectedTags = [];

  void _submitProduct() async {
    String company = _companyController.text;
    int quantity = int.parse(_quantityController.text);
    String unit = _selectedUnit;
    List<String> tags = _selectedTags;
    double price = double.parse(_priceController.text); // Get the price as double

    // Save product to Firestore
    await FirebaseFirestore.instance.collection('products').add({
      'company': company,
      'quantity': quantity,
      'unit': unit,
      'tags': tags,
      'price': price, // Save price to Firestore
    });

    Navigator.pop(context);
  }

  void _selectTags() async {
    final selectedTags = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => TagSelectionScreen(selectedTags: _selectedTags)),
    );
    if (selectedTags != null) {
      setState(() {
        _selectedTags = selectedTags;
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
          elevation: 8,
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
                DropdownButtonFormField<String>(
                  value: _selectedUnit,
                  decoration: InputDecoration(
                    labelText: 'Unit',
                    filled: true,
                    fillColor: Colors.teal.withOpacity(0.05),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedUnit = newValue!;
                    });
                  },
                  items: <String>['l', 'kg', 'g', 'dag']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
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
                        .map(
                          (tag) => Chip(
                        label: Text(tag),
                        deleteIcon: Icon(Icons.close),
                        onDeleted: () {
                          setState(() {
                            _selectedTags.remove(tag);
                          });
                        },
                      ),
                    )
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
