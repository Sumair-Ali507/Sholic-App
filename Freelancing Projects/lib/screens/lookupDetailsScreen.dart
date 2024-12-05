import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'buy_list.dart';

class LookupDetailsScreen extends StatefulWidget {
  final String marketId; // Pass the selected market's ID

  LookupDetailsScreen({required this.marketId});

  @override
  _LookupDetailsScreenState createState() => _LookupDetailsScreenState();
}

class _LookupDetailsScreenState extends State<LookupDetailsScreen> {
  final CollectionReference marketsRef = FirebaseFirestore.instance.collection('markets');
  final CollectionReference buyListRef = FirebaseFirestore.instance.collection('products');

  // Fetch products of the selected market
  Future<List<Map<String, dynamic>>> _getProducts() async {
    DocumentSnapshot marketSnapshot = await marketsRef.doc(widget.marketId).get();
    Map<String, dynamic> marketData = marketSnapshot.data() as Map<String, dynamic>;
    List<dynamic> products = marketData['products'] ?? [];

    return products.map((product) {
      var productData = product as Map<String, dynamic>;
      return {
        'name': productData['name'] ?? 'Unnamed Product',
        'price': productData['price']?.toDouble() ?? 0.0,
      };
    }).toList();
  }

  // Delete product from Firestore buy_list by product name
  Future<void> _deleteProductsFromBuyList(String productName) async {
    var buyListSnapshot = await buyListRef.where('name', isEqualTo: productName).get();
    for (var doc in buyListSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  // Mark product as unavailable and move to buy list
  Future<void> _markProductUnavailable(Map<String, dynamic> product) async {
    // Add the unavailable product back to buy list
    await buyListRef.add({
      'name': product['name'],
      'price': 'n.a.', // Mark as unavailable in the buy list
    });

    // Remove the product from buy list (synchronized with the BuyList screen)
    await _deleteProductsFromBuyList(product['name']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal, // Teal color for AppBar
        title: Text('Market Details', style: TextStyle(color: Colors.white)), // White text
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(  // Fetch products of selected market
        future: _getProducts(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading products.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final products = snapshot.data;

          if (products == null || products.isEmpty) {
            return Center(child: Text('No products found.'));
          }

          return Center( // Center the table
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.teal), // Teal color for heading row
                columnSpacing: 20, // Increased spacing between columns
                dataRowHeight: 60, // Increased row height for better readability
                headingTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), // Bold white text for headings
                dataTextStyle: TextStyle(color: Colors.black, fontSize: 16), // Black text for data rows
                columns: [  // Define columns for DataTable
                  DataColumn(label: Text('Product Name', style: TextStyle(color: Colors.white))),
                  DataColumn(label: Text('Price', style: TextStyle(color: Colors.white))),
                ],
                rows: products.map((product) {
                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.teal.withOpacity(0.5); // Highlight selected rows
                      }
                      return (products.indexOf(product) % 2 == 0) ? Colors.grey.withOpacity(0.1) : Colors.transparent; // Alternate row colors
                    }),
                    cells: [
                      DataCell(Text(product['name'] ?? 'Unnamed Product')),
                      DataCell(
                        Text(product['price'] == 'n.a.' ? 'n.a.' : '\$${product['price'].toStringAsFixed(2)}'),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}
