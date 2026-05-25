//qudas\lib\screens\admin\change_password_screen.dart
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class ChangePasswordScreen extends StatefulWidget {

  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends State<ChangePasswordScreen> {

  final userIdController = TextEditingController();
  final passwordController = TextEditingController();

  final authService = AuthService();

  Future<void> changePassword() async {

    await authService.changePassword(
      int.parse(userIdController.text),
      passwordController.text,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Password Updated"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Change Password"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              controller: userIdController,
              decoration: const InputDecoration(
                labelText: "User ID",
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: "New Password",
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: changePassword,
              child: const Text("Update"),
            ),
          ],
        ),
      ),
    );
  }
}