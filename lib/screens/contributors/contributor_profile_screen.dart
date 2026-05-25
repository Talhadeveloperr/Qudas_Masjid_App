//qudas\lib\screens\contributors\contributor_profile_screen.dart
import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../models/contributor_model.dart';
import '../../services/contributor_service.dart';
import '../../utils/app_permissions.dart';
import 'add_monthly_payment_screen.dart';

class ContributorProfileScreen extends StatefulWidget {
  final Contributor contributor;
  final AppUser currentUser;

  const ContributorProfileScreen({super.key, required this.contributor, required this.currentUser});

  @override
  State<ContributorProfileScreen> createState() => _ContributorProfileScreenState();
}

class _ContributorProfileScreenState extends State<ContributorProfileScreen> {
  final ContributorService _service = ContributorService();
  List<ContributorPayment> _payments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPayments();
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

  Future<void> _fetchPayments() async {
    setState(() => _isLoading = true);
    try {
      final records = await _service.getPaymentsForContributor(widget.contributor.id!);
      setState(() => _payments = records);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error fetching log: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleDelete(int paymentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Receipt"),
        content: const Text("Remove this execution entry completely?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Remove", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      await _service.deletePayment(paymentId);
      _fetchPayments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.contributor.fullName)),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Address: ${widget.contributor.address ?? 'N/A'}", style: const TextStyle(fontSize: 14)),
                  const SizedBox(height: 8),
                  Text("Committed Base: \$${widget.contributor.monthlyCommitment.toStringAsFixed(2)} / month",
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.teal)),
                  const SizedBox(height: 8),
                  Text("Configured Vectors: ${widget.contributor.phoneNumbers.join(', ')}", style: const TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Ledger History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                if (_hasPermission(AppPermissions.addContributorsContribution))
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text("Add Payment"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddMonthlyPaymentScreen(contributor: widget.contributor),
                        ),
                      ).then((_) => _fetchPayments());
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _payments.isEmpty
                    ? const Center(child: Text("No transactions recorded on this profile."))
                    : ListView.builder(
                        itemCount: _payments.length,
                        itemBuilder: (context, index) {
                          final payment = _payments[index];
                          return ListTile(
                            leading: const Icon(Icons.monetization_on, color: Colors.green),
                            title: Text("\$${payment.amount.toStringAsFixed(2)} - ${payment.monthPaid}"),
                            subtitle: Text("Date: ${payment.contributionDate} @ ${payment.contributionTime}\nRemarks: ${payment.remarks ?? 'None'}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_hasPermission(AppPermissions.editContributorsContribution))
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.amber, size: 18),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddMonthlyPaymentScreen(
                                            contributor: widget.contributor,
                                            payment: payment,
                                          ),
                                        ),
                                      ).then((_) => _fetchPayments());
                                    },
                                  ),
                                if (_hasPermission(AppPermissions.deleteContributorsContribution))
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                                    onPressed: () => _handleDelete(payment.id!),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}