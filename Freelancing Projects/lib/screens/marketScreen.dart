import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'buy_list.dart';
import 'marketDetailsScreen.dart';
import 'fetchTagScreen.dart';
import 'fetchProductScreen.dart';

class MarketListScreen extends StatefulWidget {
  @override
  _MarketListScreenState createState() => _MarketListScreenState();
}

class _MarketListScreenState extends State<MarketListScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController searchController = TextEditingController();
  String searchText = '';
  final CollectionReference marketsRef = FirebaseFirestore.instance.collection('markets');

  // Fetch markets from Firestore and filter by search text
  Stream<QuerySnapshot> _getFilteredMarketsStream() {
    if (searchText.isEmpty) {
      return marketsRef.snapshots();
    } else {
      return marketsRef
          .where('name', isGreaterThanOrEqualTo: searchText)
          .where('name', isLessThanOrEqualTo: searchText + '\uf8ff')
          .snapshots();
    }
  }

  // Open market details screen (empty for add)
  void _openMarketDetails({String? docId}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MarketDetailsScreen(docId: docId),
      ),
    );
  }

  // Delete market from Firestore
  Future<void> _deleteMarket(String docId) async {
    try {
      await marketsRef.doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Market deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete market')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          'Markets',
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
                    icon: Icons.list_alt,
                    title: 'Buy List',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BuyListScreen()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.shopping_cart,
                    title: 'Products',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProductsScreen()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.store,
                    title: 'Markets',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MarketListScreen()),
                      );
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.label,
                    title: 'Tags',
                    onTap: () {
                      Navigator.push(
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
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search markets',
                labelStyle: TextStyle(color: Colors.teal),
                prefixIcon: Icon(Icons.search, color: Colors.teal),
                suffixIcon: searchText.isNotEmpty
                    ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      searchText = '';
                      searchController.clear();
                    });
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.teal.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getFilteredMarketsStream(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading markets.'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final data = snapshot.requireData;

                if (data.size == 0) {
                  return Center(child: Text('No markets found.'));
                }

                return ListView.builder(
                  itemCount: data.size,
                  itemBuilder: (context, index) {
                    var market = data.docs[index];
                    var marketData = market.data() as Map<String, dynamic>;
                    var products = (marketData['products'] as List<dynamic>?) ?? [];

                    return Card(
                      elevation: 4,
                      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: ExpansionTile(
                        leading: Icon(Icons.store, color: Colors.teal), // Icon for each market
                        title: Text(marketData['name'] ?? 'Unnamed Market'),
                        subtitle: Text(
                          '${marketData['address'] ?? 'Unknown Distance'} km',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.teal),
                              onPressed: () {
                                _openMarketDetails(docId: market.id);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.teal),
                              onPressed: () {
                                _deleteMarket(market.id);
                              },
                            ),
                          ],
                        ),
                        children: [
                          // Display products with tags and prices in a list
                          ...products.map((product) {
                            var productData = product as Map<String, dynamic>;
                            var tags = (productData['tags'] as List<dynamic>?) ?? [];
                            var price = productData['price'] ?? 0.0;

                            return ListTile(
                              title: Text(productData['name'] ?? 'Unnamed Product'),
                              subtitle: Text(
                                '${productData['quantity']} ${productData['unit']} - ${productData['company']}\nPrice: \$${price.toStringAsFixed(2)}',
                              ),
                              trailing: Wrap(
                                spacing: 6.0,
                                children: tags.map<Widget>((tag) => Chip(label: Text(tag.toString()))).toList(),
                              ),
                            );
                          }).toList(),
                        ],
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
            MaterialPageRoute(builder: (context) => MarketDetailsScreen()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
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
