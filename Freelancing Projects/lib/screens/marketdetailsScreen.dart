import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sholic_app/screens/productScreen.dart';

class MarketDetailsScreen extends StatefulWidget {
  @override
  _MarketDetailsScreenState createState() => _MarketDetailsScreenState();
}

class _MarketDetailsScreenState extends State<MarketDetailsScreen> {
  final _marketNameController = TextEditingController();
  final _marketAddressController = TextEditingController();

  void _submitMarket() async {
    String marketName = _marketNameController.text;
    String marketAddress = _marketAddressController.text;

    if (marketName.isNotEmpty && marketAddress.isNotEmpty) {
      await FirebaseFirestore.instance.collection('markets').add({
        'name': marketName,
        'address': marketAddress,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Market added successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all fields!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Market Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Enter Market Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade700,
                ),
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _marketNameController,
                labelText: 'Market Name',
                icon: Icons.store,
              ),
              SizedBox(height: 16),
              _buildTextField(
                controller: _marketAddressController,
                labelText: 'Market Address (e.g., km-distance)',
                icon: Icons.location_on,
              ),
              SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProductEnterScreen()),
                  );
                },
                icon: Icon(Icons.inventory, color: Colors.white),
                label: Text(
                  'Add/View Products',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      textStyle: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    child: Text('Abort'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _submitMarket,
                    child: Text(
                      'Submit',
                      style: TextStyle(fontSize: 16),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon, color: Colors.teal),
        filled: true,
        fillColor: Colors.teal.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
