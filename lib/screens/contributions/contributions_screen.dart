//qudas\lib\screens\contributions\contributions_screen.dart
// qudas/lib/screens/contributions/contributions_screen.dart
import 'package:flutter/material.dart';
import '../../models/contribution_model.dart';
import '../../models/app_user.dart';
import '../../services/contribution_service.dart';
import '../../utils/app_permissions.dart'; // Import permissions check
import 'add_contribution_screen.dart';

class ContributionsScreen extends StatefulWidget {
  final AppUser currentUser;

  const ContributionsScreen({super.key, required this.currentUser});

  @override
  State<ContributionsScreen> createState() => _ContributionsScreenState();
}

class _ContributionsScreenState extends State<ContributionsScreen> {
  final ContributionService _service = ContributionService();
  List<Contribution> _contributions = [];
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
    _fetchData();
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
      final data = await _service.getContributions(
        searchQuery: _searchController.text,
        page: _currentPage,
        limit: _pageSize,
      );
      final count = await _service.getTotalContributionsCount(
        searchQuery: _searchController.text,
      );
      setState(() {
        _contributions = data;
        _totalCount = count;
        _totalPages = (_totalCount / _pageSize).ceil();
        if (_totalPages == 0) _totalPages = 1;
        _hasMore = _currentPage < _totalPages - 1;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching records: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  double get _totalAmount {
    return _contributions.fold(0.0, (sum, item) => sum + item.amount);
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
        await _service.deleteContribution(id);
        _fetchData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Action failed: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Only show FAB if user has 'add_contributions' permission
    final canAdd = _hasPermission(AppPermissions.addContributions);
    final canEdit = _hasPermission(AppPermissions.editContributions);
    final canDelete = _hasPermission(AppPermissions.deleteContributions);

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
                            hintText: "Search contributor name...",
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
                    _fetchData();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _contributions.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("No contribution entries found."),
                          if (_currentPage > 0) _buildPaginationUI(),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _contributions.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _contributions.length) {
                            return _buildPaginationUI();
                          }
                          final item = _contributions[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              title: Text(
                                item.contributorName?.isNotEmpty == true
                                    ? item.contributorName!
                                    : "Anonymous Contributor",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text("${item.contributionDate}  •  ${item.contributionTime}"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "\Rs ${item.amount.toStringAsFixed(2)}",
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (canEdit)
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AddContributionScreen(contribution: item),
                                          ),
                                        );
                                        _fetchData();
                                      },
                                    ),
                                  if (canDelete)
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
      // Conditionally render the Floating Action Button based on permissions
      floatingActionButton: canAdd
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddContributionScreen()),
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