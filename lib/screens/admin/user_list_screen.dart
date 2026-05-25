//qudas\lib\screens\admin\user_list_screen.dart
// qudas/lib/screens/admin/user_list_screen.dart
// qudas/lib/screens/admin/user_list_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/app_permissions.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<dynamic> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  // Fetch users and their assigned modules in a single query
  Future<void> _fetchUsers() async {
    setState(() => _isLoading = true);
    try {
      print('🚀 --- SUPABASE REQUEST: FETCH USERS ---');
      print('Table: app_users');
      print('Query: select(id, username, role, module_access(module_name, is_allowed))');

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

      print('✅ --- SUPABASE RESPONSE: FETCH USERS ---');
      print('Data: $response');

      setState(() {
        _users = response;
      });
    } catch (e) {
      print('❌ --- SUPABASE ERROR: FETCH USERS ---');
      print('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Assign a new permission to a user
  Future<void> _assignPermission(int userId, String moduleName) async {
    try {
      final requestPayload = {
        'user_id': userId,
        'module_name': moduleName,
        'is_allowed': true,
      };

      print('🚀 --- SUPABASE REQUEST: ASSIGN PERMISSION ---');
      print('Table: module_access');
      print('Action: insert');
      print('Payload: $requestPayload');

      // Added .select() to get the newly inserted row back in the response
      final response = await Supabase.instance.client
          .from('module_access')
          .insert(requestPayload)
          .select();

      print('✅ --- SUPABASE RESPONSE: ASSIGN PERMISSION ---');
      print('Data: $response');

      _fetchUsers(); // Refresh the list
    } catch (e) {
      print('❌ --- SUPABASE ERROR: ASSIGN PERMISSION ---');
      print('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to assign permission: $e")));
      }
    }
  }

  // Remove a permission from a user
  Future<void> _removePermission(int userId, String moduleName) async {
    try {
      final matchCriteria = {'user_id': userId, 'module_name': moduleName};

      print('🚀 --- SUPABASE REQUEST: REMOVE PERMISSION ---');
      print('Table: module_access');
      print('Action: delete');
      print('Match Criteria: $matchCriteria');

      // Added .select() to get the deleted row back in the response
      final response = await Supabase.instance.client
          .from('module_access')
          .delete()
          .match(matchCriteria)
          .select();

      print('✅ --- SUPABASE RESPONSE: REMOVE PERMISSION ---');
      print('Data: $response');

      _fetchUsers(); // Refresh the list
    } catch (e) {
      print('❌ --- SUPABASE ERROR: REMOVE PERMISSION ---');
      print('Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to remove permission: $e")));
      }
    }
  }

  // Open dialog to show available permissions to add
  void _showAddAccessDialog(int userId, List<dynamic> currentModules) {
    // Extract strings of currently assigned permissions
    final assignedNames = currentModules
        .where((m) => m['is_allowed'] == true)
        .map((m) => m['module_name'].toString())
        .toList();

    // Filter out permissions the user already has
    final availablePermissions = AppPermissions.allPermissions
        .where((p) => !assignedNames.contains(p))
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Assign Permission"),
        content: SizedBox(
          width: double.maxFinite,
          child: availablePermissions.isEmpty
              ? const Text("User already has all permissions.")
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: availablePermissions.length,
                  itemBuilder: (context, index) {
                    final permission = availablePermissions[index];
                    return ListTile(
                      leading: const Icon(Icons.security, color: Colors.blue),
                      title: Text(permission),
                      trailing: const Icon(Icons.add_circle_outline),
                      onTap: () {
                        Navigator.pop(ctx);
                        _assignPermission(userId, permission);
                      },
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("System Users"),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUsers,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _users.isEmpty
              ? const Center(child: Text("No users found."))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
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
                                      backgroundColor: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.1),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: user['role'] == 'admin'
                                        ? Colors.red.withOpacity(0.1)
                                        : Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    user['role'].toString().toUpperCase(),
                                    style: TextStyle(
                                      color: user['role'] == 'admin'
                                          ? Colors.red
                                          : Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),

                            // Access Modules Section with the Plus Icon
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Module Access:",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.add_circle, color: Theme.of(context).primaryColor),
                                  tooltip: "Add Permission",
                                  onPressed: () => _showAddAccessDialog(user['id'], modules),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),

                            modules.isEmpty
                                ? const Text("No modules assigned",
                                    style: TextStyle(fontStyle: FontStyle.italic))
                                : Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: modules.map((module) {
                                      final isAllowed = module['is_allowed'] == true;
                                      if (!isAllowed) return const SizedBox.shrink();

                                      return Chip(
                                        label: Text(
                                          module['module_name'].toString(),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                        backgroundColor: Theme.of(context)
                                            .primaryColor
                                            .withOpacity(0.1),
                                        side: BorderSide.none,
                                        avatar: Icon(Icons.check_circle,
                                            size: 16,
                                            color: Theme.of(context).primaryColor),
                                        deleteIcon: const Icon(Icons.close, size: 16, color: Colors.redAccent),
                                        onDeleted: () => _removePermission(user['id'], module['module_name']),
                                      );
                                    }).toList(),
                                  ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}