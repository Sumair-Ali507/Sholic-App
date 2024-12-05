import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sholic_app/screens/productScreen.dart';
import 'buy_list.dart';
import 'fetchTagScreen.dart';
import 'homeScreen.dart';
import 'marketScreen.dart';  // Import HomeScreen to navigate back to it

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
        title: Text(
          'Products',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.teal,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.teal,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.account_circle, size: 60, color: Colors.white),
                  SizedBox(height: 10),
                  Text(
                    'Hello, User!',
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                  Text(
                    'Welcome to Sholic App',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  _buildDrawerItem(
                    icon: Icons.home,
                    title: 'Home',
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => HomeScreen()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.list_alt,
                    title: 'Buy List',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BuyListScreen()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.shopping_cart,
                    title: 'Products',
                    onTap: ()  async{
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProductsScreen()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.store,
                    title: 'Markets',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MarketListScreen()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.label,
                    title: 'Tags',
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => TagScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
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
                  stream: FirebaseFirestore.instance
                      .collection('products')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

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

                        var tags = data['tags'];
                        String tagsDisplay = '';
                        if (tags is String) {
                          tagsDisplay = tags;
                        } else if (tags is List) {
                          tagsDisplay = tags.isNotEmpty
                              ? tags.join(', ')
                              : 'No Tags Available';
                        } else {
                          tagsDisplay = 'No Tags Available';
                        }

                        var price = data['price'] ?? 'N/A';

                        return Card(
                          elevation: 4,
                          margin:
                          EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            leading: CircleAvatar(
                              backgroundColor: Colors.teal,
                              child: Icon(Icons.inventory, color: Colors.white),
                            ),
                            title: Text(
                              data['name'] ?? 'Unnamed Product', // Display product name
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Company: ${data['company'] ?? 'Unknown Company'}', // Company information
                                  style: TextStyle(color: Colors.black54),
                                ),
                                Text(
                                  'Tags: $tagsDisplay', // Show tags
                                  style: TextStyle(color: Colors.black54),
                                ),
                                Text(
                                  'Quantity: ${data['quantity'] ?? 'N/A'} ${data['unit'] ?? ''}',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                Text(
                                  'Price: \$${price.toString()}', // Display price
                                  style: TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold),
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
          Positioned(
            bottom: 16,
            right: 16,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProductEnterScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(16),
                backgroundColor: Colors.teal,
              ),
              child: Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal),
      title: Text(title),
      onTap: onTap,
    );
  }
}
