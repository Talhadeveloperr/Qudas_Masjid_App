//qudas\lib\screens\dashboard_screen.dart
// qudas/lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';

import '../widgets/sidebar_routes.dart';
import '../widgets/bottom_navigation_link.dart';

class DashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;

  const DashboardScreen({
    super.key,
    required this.user,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  // This function handles the bottom navigation taps
  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Array of screens to display based on bottom nav selection
    // You will replace the placeholders with actual screens later
    final List<Widget> pages = [
      _buildHomeContent(), // Index 0: Home/Dashboard
      const Center(child: Text("Contributions Module (Coming Soon)")), // Index 1
      const Center(child: Text("Expenditures Module (Coming Soon)")), // Index 2
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Masjid App"),
        elevation: 0,
        // The drawer automatically adds a hamburger icon here.
      ),
      
      // Injecting the custom Sidebar widget
      drawer: AppSidebar(user: widget.user),
      
      // Displays the current selected page
      body: pages[_currentIndex],
      
      // Injecting the custom Bottom Navigation setup
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: Colors.green, // Primary Theme Color
        unselectedItemColor: Colors.grey,
        items: bottomNavigationItems,
      ),
    );
  }

  // Your original dashboard content moved to a helper widget for the "Home" tab
  Widget _buildHomeContent() {
    final modules = widget.user['module_access'] as List;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          "Welcome ${widget.user['username']}",
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Role: ${widget.user['role']}".toUpperCase(),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: widget.user['role'] == 'admin' ? Colors.red : Colors.blue,
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          "Your Module Access",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        ...modules.map((module) {
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              title: Text(module['module_name'].toString().toUpperCase()),
              trailing: Icon(
                module['is_allowed'] ? Icons.check_circle : Icons.cancel,
                color: module['is_allowed'] ? Colors.green : Colors.red,
              ),
            ),
          );
        }).toList(),
      ],
    );
  }
}