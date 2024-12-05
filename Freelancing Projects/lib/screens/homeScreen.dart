import 'package:flutter/material.dart';
import 'package:sholic_app/screens/fetchTagScreen.dart';
import 'buy_list.dart';
import 'fetchProductScreen.dart';
import 'marketScreen.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Screen', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
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
                    onTap: ()  async {
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
                  _buildDrawerItem(
                    icon: Icons.favorite,
                    title: 'Favorites',
                    onTap: () {
                      // Add Favorites screen navigation here
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      // Add Settings screen navigation here
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.person,
                    title: 'User',
                    onTap: () {
                      // Add User screen navigation here
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome to Sholic App!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.teal.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Navigate to your desired section below:',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  _buildHomeCard(
                    icon: Icons.list_alt,
                    label: 'Buy List',
                    color: Colors.teal.shade400,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BuyListScreen()),
                      );
                    },
                  ),
                  _buildHomeCard(
                    icon: Icons.shopping_cart,
                    label: 'Products',
                    color: Colors.teal.shade300,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ProductsScreen()),
                      );
                    },
                  ),
                  _buildHomeCard(
                    icon: Icons.store,
                    label: 'Markets',
                    color: Colors.teal.shade200,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MarketListScreen()),
                      );
                    },
                  ),
                  _buildHomeCard(
                    icon: Icons.label,
                    label: 'Tags',
                    color: Colors.teal.shade100,
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

  Widget _buildHomeCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
        elevation: 4,
        color: color,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 48, color: Colors.white),
              SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
