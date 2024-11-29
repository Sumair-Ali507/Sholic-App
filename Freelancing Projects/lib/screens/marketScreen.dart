import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'buy_list.dart';
import 'marketDetailsScreen.dart';

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
                      borderOnForeground: true,
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
                              icon: Icon(Icons.edit, color: Colors.teal,),
                              onPressed: () {
                                _openMarketDetails(docId: market.id);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete,color: Colors.teal,),
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
}
