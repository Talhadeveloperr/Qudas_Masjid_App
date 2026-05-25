//qudas\lib\screens\dashboard_screen.dart
import 'package:flutter/material.dart';

import '../services/session_service.dart';
import 'admin/admin_panel_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatelessWidget {

  final Map<String, dynamic> user;

  const DashboardScreen({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {

    final modules = user['module_access'] as List;

    return Scaffold(

      appBar: AppBar(
        title: Text(
          "Welcome ${user['username']}",
        ),

        actions: [

          if (user['role'] == 'admin')

            IconButton(
              icon: const Icon(Icons.admin_panel_settings),

              onPressed: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdminPanelScreen(),
                  ),
                );
              },
            ),

          IconButton(
            icon: const Icon(Icons.logout),

            onPressed: () async {

              await SessionService.logout();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => const LoginScreen(),
                ),
                    (route) => false,
              );
            },
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [

          Text(
            "Role: ${user['role']}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Module Access",
            style: TextStyle(
              fontSize: 18,
            ),
          ),

          const SizedBox(height: 10),

          ...modules.map((module) {

            return Card(
              child: ListTile(
                title: Text(
                  module['module_name'],
                ),
                trailing: Icon(
                  module['is_allowed']
                      ? Icons.check_circle
                      : Icons.cancel,
                ),
              ),
            );

          }).toList(),
        ],
      ),
    );
  }
}