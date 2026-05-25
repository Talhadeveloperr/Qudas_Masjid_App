//qudas\lib\screens\contributors\contributor_analytics.dart
import 'package:flutter/material.dart';
import '../../models/app_user.dart';
import '../../services/contributor_service.dart';

class ContributorAnalyticsScreen extends StatefulWidget {
  final AppUser currentUser;

  const ContributorAnalyticsScreen({super.key, required this.currentUser});

  @override
  State<ContributorAnalyticsScreen> createState() => _ContributorAnalyticsScreenState();
}

class _ContributorAnalyticsScreenState extends State<ContributorAnalyticsScreen> {
  final ContributorService _service = ContributorService();
  bool _isLoading = false;

  Map<String, dynamic>? _currentMonthMetrics;
  Map<String, dynamic>? _prevMonthMetrics;

  late String _currentMonthLabel;
  late String _prevMonthLabel;

  @override
  void initState() {
    super.initState();
    _computeTimeLabels();
    _loadMetrics();
  }

  void _computeTimeLabels() {
    final List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    final now = DateTime.now();

    _currentMonthLabel = "${months[now.month - 1]} ${now.year}";

    // Compute previous month boundary logic safely
    int prevMonthIdx = now.month - 2;
    int prevYear = now.year;
    if (prevMonthIdx < 0) {
      prevMonthIdx = 11;
      prevYear -= 1;
    }
    _prevMonthLabel = "${months[prevMonthIdx]} $prevYear";
  }

  Future<void> _loadMetrics() async {
    setState(() => _isLoading = true);
    try {
      final currentData = await _service.getAnalyticsForMonth(_currentMonthLabel);
      final prevData = await _service.getAnalyticsForMonth(_prevMonthLabel);

      setState(() {
        _currentMonthMetrics = currentData;
        _prevMonthMetrics = prevData;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Analytics pipeline crash: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Business Intelligence Dashboard"),
          bottom: TabBar(
            tabs: [
              Tab(text: "Active Cycle ($_currentMonthLabel)"),
              Tab(text: "Prior Cycle ($_prevMonthLabel)"),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildMetricViewport(_currentMonthMetrics),
                  _buildMetricViewport(_prevMonthMetrics),
                ],
              ),
      ),
    );
  }

  Widget _buildMetricViewport(Map<String, dynamic>? metrics) {
    if (metrics == null) return const Center(child: Text("Data missing or unallocated."));

    double committed = metrics['totalCommitted'];
    double collected = metrics['totalCollected'];
    double remaining = committed - collected;
    if (remaining < 0) remaining = 0.0;

    final List<dynamic> paidDetails = metrics['paidDetails'];
    final List<dynamic> remainingDetails = metrics['remainingDetails'];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: _buildMetricCard("Target Commitment", "\$${committed.toStringAsFixed(2)}", Colors.blue)),
            Expanded(child: _buildMetricCard("Settled Funds", "\$${collected.toStringAsFixed(2)}", Colors.green)),
          ],
        ),
        _buildMetricCard("Outstanding Processing Balance", "\$${remaining.toStringAsFixed(2)}", Colors.redAccent),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Settled Allocations (${metrics['paidCount']})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
            Text("Deficit Allocations (${metrics['remainingCount']})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
          ],
        ),
        const Divider(),
        const SizedBox(height: 8),
        const Text("Overdue Register List (Unpaid Contributors)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 6),
        remainingDetails.isEmpty
            ? const Text("Clean Ledger: No active account deficits found for this cycle context.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
            : Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.red.shade100), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: remainingDetails.map<Widget>((item) {
                    return ListTile(
                      leading: const Icon(Icons.dangerous, color: Colors.red),
                      title: Text(item['name']),
                      trailing: Text("Deficit: \$${item['committed'].toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    );
                  }).toList(),
                ),
              ),
        const SizedBox(height: 24),
        const Text("Settled Register List (Paid Contributors)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 6),
        paidDetails.isEmpty
            ? const Text("No matching verified clear receipts processed yet.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
            : Container(
                decoration: BoxDecoration(border: Border.all(color: Colors.green.shade100), borderRadius: BorderRadius.circular(8)),
                child: Column(
                  children: paidDetails.map<Widget>((item) {
                    return ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: Text(item['name']),
                      trailing: Text("Paid: \$${item['paid'].toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    );
                  }).toList(),
                ),
              ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}