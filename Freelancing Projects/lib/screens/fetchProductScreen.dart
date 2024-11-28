import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sholic_app/screens/productScreen.dart';
import 'buy_list.dart';
import 'homeScreen.dart';

class ProductsScreen extends StatefulWidget {
  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ],
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search, color: Colors.teal),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.teal),
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                    });
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.teal.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('products').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

                var products = snapshot.data!.docs.where((product) {
                  var data = product.data() as Map<String, dynamic>;
                  return data.containsKey('company') &&
                      data['company']
                          .toString()
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                }).toList();

                if (products.isEmpty) {
                  return Center(
                    child: Text(
                      'No products found.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    var product = products[index];
                    var data = product.data() as Map<String, dynamic>;

                    // Check if 'tags' is a List or String
                    var tags = data['tags'];

                    // If 'tags' is a String, we can display it directly, otherwise, handle it as a List
                    String tagsDisplay = '';
                    if (tags is String) {
                      tagsDisplay = tags; // If it's a single string
                    } else if (tags is List) {
                      // If it's a list of strings
                      tagsDisplay = tags.isNotEmpty ? tags.join(', ') : 'No Tags Available';
                    } else {
                      tagsDisplay = 'No Tags Available'; // In case 'tags' is not found
                    }

                    // Fetching the price of the product
                    var price = data['price'] ?? 'N/A';

                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        leading: CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Icon(Icons.inventory, color: Colors.white),
                        ),
                        title: Text(
                          data['company'] ?? 'Unknown Company',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tags: $tagsDisplay', // Show tags
                              style: TextStyle(color: Colors.black54),
                            ),
                            Text(
                              'Quantity: ${data['quantity'] ?? 'N/A'} ${data['unit'] ?? ''}',
                              style: TextStyle(color: Colors.black54),
                            ),
                            Text(
                              'price: \$${price.toString()}', // Display price
                              style: TextStyle(color: Colors.black54, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        onTap: () {
                          // Add onTap functionality if needed
                        },
                      ),
                    );
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
