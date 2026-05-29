// lib/screens/expenditures/expenditures_screen.dart
// lib/screens/expenditures/expenditures_screen.dart
import 'package:flutter/material.dart';
import '../../models/expenditure_model.dart';
import '../../models/app_user.dart'; // Import AppUser
import '../../services/expenditure_service.dart';
import '../../utils/app_permissions.dart';
import 'add_expenditure_screen.dart';
import 'expenditure_detail_screen.dart';

class ExpendituresScreen extends StatefulWidget {
  final AppUser currentUser; // Added currentUser

  const ExpendituresScreen({super.key, required this.currentUser});

  @override
  State<ExpendituresScreen> createState() => _ExpendituresScreenState();
}

class _ExpendituresScreenState extends State<ExpendituresScreen> {
  final ExpenditureService _service = ExpenditureService();
  List<Expenditure> _expenditures = [];
  bool _isLoading = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  // --- Pagination Layer States ---
  int _currentPage = 0;
  final int _pageSize = 20;
  bool _hasMore = true;
  int _totalCount = 0;
  int _totalPages = 1;

  @override
  void initState() {
    super.initState();
    _fetchData(); // Just fetch data now
  }

  // Helper method to check if current user has a specific permission
  bool _hasPermission(String permissionName) {
    if (widget.currentUser.role == 'admin') return true; // Admin has all access
    for (var module in widget.currentUser.modules) {
      if (module['module_name'] == permissionName && module['is_allowed'] == true) {
        return true;
      }
    }
    return false;
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final data = await _service.getExpenditures(
        searchQuery: _searchController.text,
        page: _currentPage,
        limit: _pageSize,
      );
      print('Fetched $data records ');
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
                          "Page Total: \Rs ${_totalAmount.toStringAsFixed(2)}",
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
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("${item.expenditureDate}  •  ${item.expenditureTime}"),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Added by: ${item.addedBy ?? 'N/A'}  •  Created: ${item.createdAt != null ? item.createdAt!.toLocal().toString().split('.').first : 'N/A'}  •  Updated: ${item.updatedAt != null ? item.updatedAt!.toLocal().toString().split('.').first : 'N/A'}",
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "\Rs ${item.paymentAmount.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  
                                  // Use _hasPermission for editing
                                  if (_hasPermission(AppPermissions.editExpenditures))
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
                                    
                                  // Use _hasPermission for deleting
                                  if (_hasPermission(AppPermissions.deleteExpenditures))
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
      
      // Use _hasPermission for adding
      floatingActionButton: _hasPermission(AppPermissions.addExpenditures)
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
          : null,
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