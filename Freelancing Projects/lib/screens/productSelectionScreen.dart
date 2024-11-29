import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductSelectionScreen extends StatefulWidget {
  final List<String> selectedProducts;

  ProductSelectionScreen({required this.selectedProducts});

  @override
  _ProductSelectionScreenState createState() => _ProductSelectionScreenState();
}

class _ProductSelectionScreenState extends State<ProductSelectionScreen> {
  List<Map<String, dynamic>> _availableProducts = [];
  List<String> _selectedProducts = [];

  @override
  void initState() {
    super.initState();
    _selectedProducts = widget.selectedProducts;
    _fetchProducts();
  }

  void _fetchProducts() async {
    QuerySnapshot snapshot =
    await FirebaseFirestore.instance.collection('products').get();
    setState(() {
      _availableProducts = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add the document ID to the product data
        return data;
      }).toList();
    });
  }

  void _selectProduct(Map<String, dynamic> product) {
    Navigator.pop(context, product);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Products'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _availableProducts.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> product = _availableProducts[index];
                  return Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      title: Text(
                        product['name'] ?? 'Unnamed Product',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Company: ${product['company'] ?? 'N/A'}'),
                          Text('Price: \$${product['price'] ?? 'N/A'}'),
                          Text('Quantity: ${product['quantity'] ?? 'N/A'}'),
                          Text('Unit: ${product['unit'] ?? 'N/A'}'),
                          if (product['tags'] != null &&
                              (product['tags'] as List).isNotEmpty)
                            Text('Tags: ${(product['tags'] as List).join(', ')}'),
                        ],
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey.shade300,
                        child: Icon(
                          Icons.inventory,
                          color: Colors.teal,
                        ),
                      ),
                      onTap: () {
                        _selectProduct(product);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
