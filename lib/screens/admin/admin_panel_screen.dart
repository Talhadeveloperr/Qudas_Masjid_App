//qudas\lib\screens\admin\admin_panel_screen.dart
import 'package:flutter/material.dart';

import 'change_password_screen.dart';
import 'create_user_screen.dart';

class AdminPanelScreen extends StatelessWidget {

  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Admin Panel"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text("Create User"),

              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const CreateUserScreen(),
                  ),
                );
              },
            ),

            ListTile(
              leading: const Icon(Icons.password),
              title: const Text("Change Password"),

              onTap: () {

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ChangePasswordScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}