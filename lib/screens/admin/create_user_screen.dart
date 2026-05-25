//qudas\lib\screens\admin\create_user_screen.dart
import 'package:flutter/material.dart';

import '../../services/user_service.dart';

class CreateUserScreen extends StatefulWidget {

  const CreateUserScreen({super.key});

  @override
  State<CreateUserScreen> createState() =>
      _CreateUserScreenState();
}

class _CreateUserScreenState
    extends State<CreateUserScreen> {

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  final userService = UserService();

  final List<String> modules = [
    'dashboard',
    'finance',
    'events',
    'settings',
  ];

  final List<String> selectedModules = [];

  Future<void> createUser() async {

    await userService.createUser(
      username: usernameController.text,
      password: passwordController.text,
      modules: selectedModules,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("User Created"),
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Create User"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: ListView(
          children: [

            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: "Username",
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Modules",
            ),

            ...modules.map((module) {

              return CheckboxListTile(
                value: selectedModules.contains(module),

                title: Text(module),

                onChanged: (value) {

                  setState(() {

                    if (value == true) {
                      selectedModules.add(module);
                    } else {
                      selectedModules.remove(module);
                    }
                  });
                },
              );

            }),

            ElevatedButton(
              onPressed: createUser,
              child: const Text("Create User"),
            ),
          ],
        ),
      ),
    );
  }
}