//qudas\lib\screens\contributors\contributors_screen.dart
import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../models/contributor_model.dart';
import '../../services/contributor_service.dart';
import '../../utils/app_permissions.dart';
import 'add_contributor_screen.dart';
import 'contributor_profile_screen.dart';
import 'contributor_analytics.dart';

class ContributorsScreen extends StatefulWidget {
  final AppUser currentUser;

  const ContributorsScreen({super.key, required this.currentUser});

  @override
  State<ContributorsScreen> createState() => _ContributorsScreenState();
}

class _ContributorsScreenState extends State<ContributorsScreen> {
  final ContributorService _service = ContributorService();
  List<Contributor> _contributors = [];
  bool _isLoading = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  // Pagination Configuration
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

  bool _hasPermission(String permissionName) {
    if (widget.currentUser.role == 'admin') return true;
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
      final data = await _service.getContributors(
        searchQuery: _searchController.text,
        page: _currentPage,
        limit: _pageSize,
      );
      final count = await _service.getTotalContributorsCount(
        searchQuery: _searchController.text,
      );
      setState(() {
        _contributors = data;
        _totalCount = count;
        _totalPages = (_totalCount / _pageSize).ceil();
        if (_totalPages == 0) _totalPages = 1;
        _hasMore = _currentPage < _totalPages - 1;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error fetching contributors: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _confirmDelete(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Remove Contributor"),
        content: const Text("Are you sure? This will permanently delete the contributor and cascade remove phone records."),
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
        await _service.deleteContributor(id);
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
                            hintText: "Search name...",
                            border: InputBorder.none,
                          ),
                          onChanged: (_) {
                            setState(() => _currentPage = 0);
                            _fetchData();
                          },
                        )
                      : const Text(
                          "Contributors Register",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                if (_hasPermission(AppPermissions.contributorAnalytics))
                  IconButton(
                    icon: const Icon(Icons.analytics_outlined, color: Colors.purple),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => ContributorAnalyticsScreen(currentUser: widget.currentUser)),
                      );
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _fetchData,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _contributors.isEmpty
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("No contributors registered."),
                          if (_currentPage > 0) _buildPaginationUI(),
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _contributors.length + 1,
                        itemBuilder: (context, index) {
                          if (index == _contributors.length) {
                            return _buildPaginationUI();
                          }
                          final item = _contributors[index];
                          final phoneDisplay = item.phoneNumbers.isNotEmpty ? item.phoneNumbers.join(', ') : "No Phone";

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ListTile(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ContributorProfileScreen(
                                      contributor: item,
                                      currentUser: widget.currentUser,
                                    ),
                                  ),
                                ).then((_) => _fetchData());
                              },
                              title: Text(item.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text("Commitment: \Rs ${item.monthlyCommitment.toStringAsFixed(2)}\nPhones: $phoneDisplay"),
                              isThreeLine: true,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (_hasPermission(AppPermissions.editContributors))
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => AddContributorScreen(contributor: item)),
                                        ).then((_) => _fetchData());
                                      },
                                    ),
                                  if (_hasPermission(AppPermissions.deleteContributors))
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
      floatingActionButton: _hasPermission(AppPermissions.addContributors)
          ? FloatingActionButton(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddContributorScreen()),
                ).then((_) => _fetchData());
              },
            )
          : null,
    );
  }

  Widget _buildPaginationUI() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
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
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
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