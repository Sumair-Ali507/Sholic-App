import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'database_helper.dart';


class AddItemScreen extends StatefulWidget {
  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _productController = TextEditingController();
  final _amountController = TextEditingController();
  final _dbHelper = DatabaseHelper();

  void _addItem() async {
    String product = _productController.text;
    int amount = int.parse(_amountController.text);
    await _dbHelper.insertItem(product, amount);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Item')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _productController,
              decoration: InputDecoration(labelText: 'Product'),
            ),
            TextField(
              controller: _amountController,
              decoration: InputDecoration(labelText: 'Amount'),
              keyboardType: TextInputType.number,
            ),
            ElevatedButton(
              onPressed: _addItem,
              child: Text('Add'),
            ),
          ],
        ),
      ),
    );
  }
}