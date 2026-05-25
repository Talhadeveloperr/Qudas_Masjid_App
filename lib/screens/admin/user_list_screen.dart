//qudas\lib\screens\admin\user_list_screen.dart
// qudas/lib/screens/admin/user_list_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  // Fetch users and their assigned modules in a single query
  Future<List<dynamic>> fetchUsers() async {
    final response = await Supabase.instance.client
        .from('app_users')
        .select('''
          id,
          username,
          role,
          module_access (
            module_name,
            is_allowed
          )
        ''')
        .order('id', ascending: true);
        
    return response;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("System Users"),
        elevation: 0,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error loading users: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final users = snapshot.data ?? [];

          if (users.isEmpty) {
            return const Center(child: Text("No users found."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final modules = user['module_access'] as List<dynamic>? ?? [];

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: ID, Username, and Role
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                                child: Text(
                                  user['id'].toString(),
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                user['username'].toString().toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: user['role'] == 'admin' 
                                  ? Colors.red.withOpacity(0.1) 
                                  : Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user['role'].toString().toUpperCase(),
                              style: TextStyle(
                                color: user['role'] == 'admin' ? Colors.red : Colors.blue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      
                      // Access Modules Section
                      const Text(
                        "Module Access:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      modules.isEmpty
                          ? const Text("No modules assigned", style: TextStyle(fontStyle: FontStyle.italic))
                          : Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: modules.map((module) {
                                final isAllowed = module['is_allowed'] == true;
                                if (!isAllowed) return const SizedBox.shrink(); // Only show allowed modules
                                
                                return Chip(
                                  label: Text(
                                    module['module_name'].toString(),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  backgroundColor: Colors.green.withOpacity(0.1),
                                  side: BorderSide.none,
                                  avatar: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                                );
                              }).toList(),
                            ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}