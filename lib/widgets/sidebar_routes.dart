//qudas\lib\widgets\sidebar_routes.dart
// qudas/lib/widgets/sidebar_routes.dart
import 'package:flutter/material.dart';

import '../screens/admin/change_password_screen.dart';
import '../screens/admin/create_user_screen.dart';
import '../screens/admin/user_list_screen.dart';
import '../screens/login_screen.dart';
import '../services/session_service.dart';
import '../utils/app_colors.dart';

class AppSidebar extends StatelessWidget {
  final Map<String, dynamic> user;

  const AppSidebar({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final isAdmin = user['role'] == 'admin';

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header Section
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: Theme.of(context).primaryColor),
            accountName: Text(user['username'].toString().toUpperCase(), style: TextStyle(color: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white)),
            accountEmail: Text("Role: ${user['role']}", style: TextStyle(color: Theme.of(context).appBarTheme.foregroundColor ?? Colors.white)),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              child: Icon(Icons.person, size: 40, color: Theme.of(context).primaryColor),
            ),
          ),

          // Regular App Routes (Will be added later)
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => Navigator.pop(context), // Close drawer
          ),
          
          const Divider(),

          // Admin Only Routes Section
          if (isAdmin) ...[
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
              child: Text(
                "Admin Controls",
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('View All Users'),
              onTap: () {
                Navigator.pop(context); // Close drawer first
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Create User'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreateUserScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.password),
              title: const Text('Change Passwords'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                );
              },
            ),
            const Divider(),
          ],

          // Theme Settings Section
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: Text(
              "Theme Settings",
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<AppThemeType>(
                value: AppTheme.themeNotifier.value,
                isExpanded: true,
                items: AppThemeType.values.map((AppThemeType type) {
                  return DropdownMenuItem<AppThemeType>(
                    value: type,
                    child: Text(type.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (AppThemeType? newValue) {
                  if (newValue != null) {
                    AppTheme.changeTheme(newValue);
                  }
                },
              ),
            ),
          ),
          const Divider(),

          // Logout Button
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await SessionService.logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}