// lib/screens/expenditures/expenditures_screen.dart
// lib/screens/expenditures/expenditures_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/expenditure_model.dart';
import '../../services/expenditure_service.dart';
import '../../utils/app_permissions.dart'; // Import permissions
import 'add_expenditure_screen.dart';
import 'expenditure_detail_screen.dart';

class ExpendituresScreen extends StatefulWidget {
  const ExpendituresScreen({super.key});

  @override
  State<ExpendituresScreen> createState() => _ExpendituresScreenState();
}

class _ExpendituresScreenState extends State<ExpendituresScreen> {
  final ExpenditureService _service = ExpenditureService();
  List<Expenditure> _expenditures = [];
  bool _isLoading = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  // --- Permissions Layer States ---
  bool _canAdd = false;
  bool _canEdit = false;
  bool _canDelete = false;

  // --- Pagination Layer States ---
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMore = true;
  int _totalCount = 0;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  // Initialize both permissions and data
  Future<void> _initializeScreen() async {
    setState(() => _isLoading = true);
    await _fetchUserPermissions();
    await _fetchData();
  }

  // Fetch the current user's role and permissions
  Future<void> _fetchUserPermissions() async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) return;

      // Note: Adjust '.eq('id', ...)' if you match the user in 'app_users' using a different column (like 'auth_id')
      final userData = await Supabase.instance.client
          .from('app_users')
          .select('role, module_access(module_name, is_allowed)')
          .eq('id', currentUser.id) 
          .maybeSingle();

      if (userData != null) {
        final role = userData['role'];
        final modules = userData['module_access'] as List<dynamic>? ?? [];

        final allowedModules = modules
            .where((m) => m['is_allowed'] == true)
            .map((m) => m['module_name'].toString())
            .toList();

        setState(() {
          // Grant access if the user is an admin, otherwise check granular permissions
          _canAdd = role == 'admin' || allowedModules.contains(AppPermissions.addExpenditures);
          _canEdit = role == 'admin' || allowedModules.contains(AppPermissions.editExpenditures);
          _canDelete = role == 'admin' || allowedModules.contains(AppPermissions.deleteExpenditures);
        });
      }
    } catch (e) {
      debugPrint("Failed to load permissions: $e");
    }
  }

  Future<void> _fetchData() async {
    try {
      final data = await _service.getExpenditures(
        searchQuery: _searchController.text,
        page: _currentPage,
        limit: _pageSize,
      );
      final count = await _service.getTotalExpendituresCount(
        searchQuery: _searchController.text,
      );
      setState(() {
        _expenditures = data;
        _totalCount = count;
        _totalPages = (_totalCount / _pageSize).ceil();
        if (_totalPages == 0) _totalPages = 1;
        _hasMore = _currentPage < _totalPages - 1;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching records: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  double get _totalAmount {
    return _expenditures.fold(0.0, (sum, item) => sum + item.paymentAmount);
  }

  Future<void> _confirmDelete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Record"),
        content: const Text("Are you sure you want to completely remove this entry?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _service.deleteExpenditure(id);
        _fetchData();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Action failed: $e")));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Theme.of(context).primaryColor.withOpacity(0.05),
            child: Row(
              children: [
                Expanded(
                  child: _isSearching
                      ? TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: const InputDecoration(
                            hintText: "Search title...",
                            border: InputBorder.none,
                          ),
                          onChanged: (_) {
                            setState(() => _currentPage = 0);
                            _fetchData();
                          },
                        )
                      : Text(
                          "Page Total: \$${_totalAmount.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                ),
                IconButton(
                  icon: Icon(_isSearching ? Icons.close : Icons.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = !_isSearching;
                      if (!_isSearching) {
                        _searchController.clear();
                        _currentPage = 0;
                        _fetchData();
                      }
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    _fetchData(); // Refresh current page
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _expenditures.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("No expenditure entries found."),
                          if (_currentPage > 0) _buildPaginationUI(),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _expenditures.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _expenditures.length) {
                            return _buildPaginationUI();
                          }
                          final item = _expenditures[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => ExpenditureDetailScreen(expenditure: item)),
                                );
                              },
                              title: Text(
                                item.title,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text("${item.expenditureDate}  •  ${item.expenditureTime}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "\$${item.paymentAmount.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  
                                  // CONDITIONAL: Only show Edit button if user has permission
                                  if (_canEdit)
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AddExpenditureScreen(expenditure: item),
                                          ),
                                        );
                                        _fetchData();
                                      },
                                    ),
                                    
                                  // CONDITIONAL: Only show Delete button if user has permission
                                  if (_canDelete)
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                      onPressed: () => _confirmDelete(item.id!),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      
      // CONDITIONAL: Only render FloatingActionButton if user has Add permission
      floatingActionButton: _canAdd
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddExpenditureScreen()),
                );
                _fetchData();
              },
            )
          : null, // Returns null to hide the FAB completely
    );
  }

  Widget _buildPaginationUI() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _currentPage > 0
                ? () {
                    setState(() => _currentPage--);
                    _fetchData();
                  }
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              "Page ${_currentPage + 1} of $_totalPages",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _hasMore
                ? () {
                    setState(() => _currentPage++);
                    _fetchData();
                  }
                : null,
          ),
        ],
      ),
    );
  }
}