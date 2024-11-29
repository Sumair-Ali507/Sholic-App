import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tagScreen.dart';
import 'fetchProductScreen.dart';

class MarketDetailsScreen extends StatefulWidget {
  final String? docId;

  MarketDetailsScreen({this.docId});

  @override
  _MarketDetailsScreenState createState() => _MarketDetailsScreenState();
}

class _MarketDetailsScreenState extends State<MarketDetailsScreen> {
  TextEditingController marketNameController = TextEditingController();
  TextEditingController marketDistanceController = TextEditingController();
  final CollectionReference marketsRef = FirebaseFirestore.instance.collection('markets');
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    if (widget.docId != null) {
      _loadMarketDetails();
    }
  }

  Future<void> _loadMarketDetails() async {
    DocumentSnapshot doc = await marketsRef.doc(widget.docId).get();
    if (doc.exists) {
      setState(() {
        marketNameController.text = doc.get('name') ?? '';
        marketDistanceController.text = doc.get('address')?.toString() ?? '';
        products = List<Map<String, dynamic>>.from(doc.get('products') ?? []);
      });
    }
  }

  Future<void> _submitMarketDetails() async {
    String marketName = marketNameController.text.trim();
    String marketDistance = marketDistanceController.text.trim();

    if (marketName.isEmpty || marketDistance.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all the fields')),
      );
      return;
    }

    try {
      Map<String, dynamic> marketData = {
        'name': marketName,
        'address': double.tryParse(marketDistance) ?? 0.0,
        'products': products,
      };

      if (widget.docId == null) {
        await marketsRef.add(marketData);
      } else {
        await marketsRef.doc(widget.docId).update(marketData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Market saved successfully')),
      );

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving market: $error')),
      );
    }
  }

  void _abort() {
    Navigator.pop(context);
  }

  void _showProductDialog({String? name, String? company, double? quantity, String? unit, double? price, List<String>? productTags}) {
    // Same implementation as before

    TextEditingController nameController = TextEditingController(text: name);
    TextEditingController companyController = TextEditingController(text: company);
    TextEditingController quantityController = TextEditingController(text: quantity?.toString() ?? '');
    TextEditingController unitController = TextEditingController(text: unit);
    TextEditingController priceController = TextEditingController(text: price?.toString() ?? '');
    List<String> tagsForProduct = productTags ?? [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dialog Title
                  Center(
                    child: Text(
                      name == null ? 'Add Product' : 'Edit Product',
                      style: TextStyle(
                        color: Colors.teal,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Divider(color: Colors.teal),
                  SizedBox(height: 8.0),
                  // Product Name Field
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Product Name',
                      labelStyle: TextStyle(color: Colors.teal),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.0),
                  // Company Field
                  TextField(
                    controller: companyController,
                    decoration: InputDecoration(
                      labelText: 'Company',
                      labelStyle: TextStyle(color: Colors.teal),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.0),
                  // Quantity Field
                  TextField(
                    controller: quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      labelStyle: TextStyle(color: Colors.teal),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.0),
                  // Unit Field
                  TextField(
                    controller: unitController,
                    decoration: InputDecoration(
                      labelText: 'Unit (ml, g, etc.)',
                      labelStyle: TextStyle(color: Colors.teal),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.0),
                  // Price Field
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      labelStyle: TextStyle(color: Colors.teal),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.0),
                  // Manage Tags Button
                  ElevatedButton.icon(
                    onPressed: () async {
                      final updatedTags = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TagSelectionScreen(selectedTags: tagsForProduct),
                        ),
                      );
                      if (updatedTags != null) {
                        setState(() {
                          tagsForProduct = List.from(updatedTags);
                        });
                      }
                    },
                    icon: Icon(Icons.tag, color: Colors.white),
                    label: Text('Manage Tags'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                  ),
                  SizedBox(height: 12.0),
                  // Select Existing Product Button

                  SizedBox(height: 8.0),
                  Wrap(
                    spacing: 8.0,
                    children: tagsForProduct
                        .map((tag) => Chip(
                      label: Text(tag, style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.teal,
                    ))
                        .toList(),
                  ),
                  SizedBox(height: 16.0),
                  // Cancel and Submit Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text('Cancel', style: TextStyle(color: Colors.teal)),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          Map<String, dynamic> productData = {
                            'name': nameController.text,
                            'company': companyController.text,
                            'quantity': double.tryParse(quantityController.text) ?? 0.0,
                            'unit': unitController.text,
                            'price': double.tryParse(priceController.text) ?? 0.0,
                            'tags': tagsForProduct,
                          };

                          try {
                            await FirebaseFirestore.instance.collection('products').add(productData);
                            setState(() {
                              products.add(productData);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Product added successfully')),
                            );
                            Navigator.pop(context);
                          } catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error adding product: $error')),
                            );
                          }
                        },
                        child: Text('Submit'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );




  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.teal,
          title: Text(
            widget.docId == null ? 'Add Market' : 'Edit Market',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: marketNameController,
                decoration: InputDecoration(
                  labelText: 'Market Name',
                  labelStyle: TextStyle(color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: marketDistanceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Market Distance (km)',
                  labelStyle: TextStyle(color: Colors.teal),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {
                    _showProductDialog();
                  },
                  icon: Icon(Icons.add),
                  label: Text('Add Products'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Text('Added Products:', style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return Card(
                      elevation: 3,
                      child: ListTile(
                        leading: Icon(Icons.shopping_cart, color: Colors.teal),
                        title: Text(product['name']),
                        subtitle: Text('${product['quantity']} ${product['unit']} - ${product['company']} - \$${product['price'].toString()}'),
                        trailing: Wrap(
                          spacing: 8,
                          children: product['tags']?.map<Widget>((tag) => Chip(label: Text(tag, style: TextStyle(color: Colors.white)), backgroundColor: Colors.teal)).toList() ?? [],
                        ),
                        onTap: () {
                          _showProductDialog(
                            name: product['name'],
                            company: product['company'],
                            quantity: product['quantity'],
                            unit: product['unit'],
                            price: product['price'],
                            productTags: product['tags'],
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: _abort,
                    child: Text('Cancel', style: TextStyle(color: Colors.teal)),
                  ),
                  ElevatedButton(
                    onPressed: _submitMarketDetails,
                    child: Text('Submit'),
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
    );
  }
}
