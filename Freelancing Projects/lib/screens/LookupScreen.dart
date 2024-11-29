import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'buy_list.dart';
import 'lookupDetailsScreen.dart'; // Add import for the new details screen

class LookupScreen extends StatefulWidget {
  @override
  _LookupScreenState createState() => _LookupScreenState();
}

class _LookupScreenState extends State<LookupScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final CollectionReference marketsRef = FirebaseFirestore.instance.collection('markets');

  // Fetch markets from Firestore
  Stream<List<Map<String, dynamic>>> _getMarketsStream() async* {
    QuerySnapshot snapshot = await marketsRef.get();

    // Create a map to aggregate prices by market
    Map<String, double> marketPriceMap = {};

    for (var doc in snapshot.docs) {
      var marketData = doc.data() as Map<String, dynamic>;
      var products = (marketData['products'] as List<dynamic>?) ?? [];

      for (var product in products) {
        var productData = product as Map<String, dynamic>;
        String marketName = marketData['name'] ?? 'Unnamed Market';
        double price = productData['price']?.toDouble() ?? 0.0;

        if (marketPriceMap.containsKey(marketName)) {
          marketPriceMap[marketName] = marketPriceMap[marketName]! + price;
        } else {
          marketPriceMap[marketName] = price;
        }
      }
    }

    // Convert the map to a list of maps
    List<Map<String, dynamic>> markets = marketPriceMap.entries.map((entry) {
      return {
        'marketName': entry.key,
        'totalPrice': entry.value,
        'marketId': snapshot.docs.firstWhere((doc) => (doc.data() as Map)['name'] == entry.key).id,
      };
    }).toList();

    // Sort by totalPrice
    markets.sort((a, b) => (a['totalPrice'] as double).compareTo(b['totalPrice'] as double));

    yield markets;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.teal, // Teal color for AppBar
        title: Text(
          'Market Comparison',
          style: TextStyle(color: Colors.white), // White text
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getMarketsStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error loading markets.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final markets = snapshot.data;

          if (markets == null || markets.isEmpty) {
            return Center(child: Text('No markets found.'));
          }

          return Center( // Center the entire table
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.all(Colors.teal), // Teal heading row
                columnSpacing: 20, // Increased spacing between columns
                dataRowHeight: 60, // Increased row height for better readability
                headingTextStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), // Bold white text for headings
                dataTextStyle: TextStyle(color: Colors.black, fontSize: 16), // Black text for data rows
                columns: [
                  DataColumn(
                    label: Text('Market Name', style: TextStyle(color: Colors.white)),
                  ),
                  DataColumn(
                    label: Text('Total Price', style: TextStyle(color: Colors.white)),
                  ),
                ],
                rows: markets.map((market) {
                  return DataRow(
                    color: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
                      if (states.contains(MaterialState.selected)) {
                        return Colors.teal.withOpacity(0.5); // Highlight selected rows
                      }
                      return (markets.indexOf(market) % 2 == 0) ? Colors.grey.withOpacity(0.1) : Colors.transparent; // Alternate row colors
                    }),
                    cells: [
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.all(8.0), // Padding for cell content
                          child: Text(market['marketName'] ?? '', style: TextStyle(color: Colors.black)),
                        ),
                        onTap: () {
                          // Navigate to LookupDetailsScreen on market tap
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LookupDetailsScreen(marketId: market['marketId']),
                            ),
                          );
                        },
                      ),
                      DataCell(
                        Padding(
                          padding: const EdgeInsets.all(8.0), // Padding for cell content
                          child: Text('\$${(market['totalPrice'] as double).toStringAsFixed(2)}', style: TextStyle(color: Colors.black)),
                        ),
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
