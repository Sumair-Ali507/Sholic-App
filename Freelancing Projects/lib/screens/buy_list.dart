import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sholic_app/screens/productScreen.dart'; // Adjust the import if necessary
import 'buy_list.dart'; // Adjust the import if necessary
import 'homeScreen.dart'; // Adjust the import if necessary

class BuyListScreen extends StatefulWidget {
  @override
  _BuyListScreenState createState() => _BuyListScreenState();
}

class _BuyListScreenState extends State<BuyListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buy List', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              child: Center(
                child: Text(
                  'Menu',
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart, color: Colors.teal),
              title: Text('Buy List'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BuyListScreen()),
                );
              },
            ),
            // Add other menu items here
          ],
        ),
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
                        subtitle: Text(
                          'Tag: ${data['tags'] ?? 'N/A'}\n'
                              'Quantity: ${data['quantity'] ?? 'N/A'} ${data['unit'] ?? ''}',
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductEnterScreen()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
