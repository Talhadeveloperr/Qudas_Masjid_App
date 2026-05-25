//qudas\lib\screens\contributors\contributor_analytics.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Map<String, dynamic>? _selectedMonthMetrics;
  late String _selectedMonthLabel;
  List<String> _availableMonths = [];

  @override
  void initState() {
    super.initState();
    _buildMonthDropdownOptions();
    _loadMetrics();
  }

  // Generates a historical window of the last 12 months for compilation selection
  void _buildMonthDropdownOptions() {
    final List<String> months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    final now = DateTime.now();

    List<String> generatedOptions = [];
    for (int i = 0; i < 12; i++) {
      int targetMonthIdx = now.month - 1 - i;
      int targetYear = now.year;

      while (targetMonthIdx < 0) {
        targetMonthIdx += 12;
        targetYear -= 1;
      }

      generatedOptions.add("${months[targetMonthIdx]} $targetYear");
    }

    setState(() {
      _availableMonths = generatedOptions;
      _selectedMonthLabel = generatedOptions.first; // Defaults automatically to current month
    });
  }

  Future<void> _loadMetrics() async {
    setState(() => _isLoading = true);
    try {
      final metricsData = await _service.getAnalyticsForMonth(_selectedMonthLabel);
      setState(() {
        _selectedMonthMetrics = metricsData;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Analytics engine failure: $e"), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Compiles metadata, logs variables to console, and launches external WhatsApp deep links
  Future<void> _sendWhatsAppReminder({
    required String name,
    required double pendingAmount,
    required List<dynamic> phones,
  }) async {
    final String customReminderMessage = 
        "Dear $name,\n\nThis is a friendly reminder regarding your outstanding monthly contribution commitment for *$_selectedMonthLabel*.\n\n"
        "Our registry ledger currently reports a pending balance of *\Rs ${pendingAmount.toStringAsFixed(2)}* yet to be allocated.\n\n"
        "Kindly arrange for fulfillment at your earliest convenience or get in touch with our team to update your transaction record. Thank you for your support!";

    // --- CONSOLE DEBUGGING OUTPUT BLOCK ---
    debugPrint("====================================================");
    debugPrint("📱 WHATSAPP DISPATCH TARGET META INFO");
    debugPrint("====================================================");
    debugPrint("👤 Contributor Name : $name");
    debugPrint("📞 Associated Phones: $phones");
    debugPrint("💬 Message Content  :\n$customReminderMessage");
    debugPrint("====================================================");

    if (phones.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("No validated telephone records linked to this contributor registry profile."),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Strip alphanumeric spaces, retaining pure integers for the country/area format
    final String cleanPhone = phones.first.toString().replaceAll(RegExp(r'[^\d+]'), '');
    
    final Uri whatsappUrl = Uri.parse(
      "https://wa.me/$cleanPhone?text=${Uri.encodeComponent(customReminderMessage)}"
    );

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl, mode: LaunchMode.externalApplication);
      } else {
        throw "System could not find any compatible communications app to handle the request.";
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not initialize custom messaging string: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Contributor Metrics"),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _loadMetrics,
          )
        ],
      ),
      body: Column(
        children: [
          // Interactive Month Selection Header Block Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            color: Theme.of(context).primaryColor.withOpacity(0.06),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Billing Processing Cycle:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedMonthLabel,
                      icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: Colors.teal),
                      items: _availableMonths.map((String monthValue) {
                        return DropdownMenuItem<String>(
                          value: monthValue,
                          child: Text(
                            monthValue,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                        );
                      }).toList(),
                      onChanged: (newSelection) {
                        if (newSelection != null && newSelection != _selectedMonthLabel) {
                          setState(() {
                            _selectedMonthLabel = newSelection;
                          });
                          _loadMetrics();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildMetricViewport(_selectedMonthMetrics),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricViewport(Map<String, dynamic>? metrics) {
    if (metrics == null) return const Center(child: Text("No records indexed within this database space."));

    double committed = metrics['totalCommitted'] ?? 0.0;
    double collected = metrics['totalCollected'] ?? 0.0;
    double remaining = committed - collected;
    if (remaining < 0) remaining = 0.0;

    final List<dynamic> paidDetails = metrics['paidDetails'] ?? [];
    final List<dynamic> remainingDetails = metrics['remainingDetails'] ?? [];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            Expanded(child: _buildMetricCard("Target Expectation", "\RS ${committed.toStringAsFixed(2)}", Colors.blue)),
            Expanded(child: _buildMetricCard("Settled Funds", "\Rs ${collected.toStringAsFixed(2)}", Colors.green)),
          ],
        ),
        _buildMetricCard("Deficit Processing Balance", "\Rs ${remaining.toStringAsFixed(2)}", Colors.redAccent),
        const SizedBox(height: 24),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Settled Allocations (${metrics['paidCount']})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.green)),
            Text("Deficit Allocations (${metrics['remainingCount']})", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.red)),
          ],
        ),
        const Divider(height: 20),
        
        // --- Overdue Deficit Section View ---
        const Text("Overdue Register List (Unpaid Contributors)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        remainingDetails.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("Clean Ledger: No active account deficits mapped for this period cycle.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
              )
            : Container(
                decoration: BoxDecoration(
                  color: Colors.red.shade50.withOpacity(0.3),
                  border: Border.all(color: Colors.red.shade100), 
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: remainingDetails.map<Widget>((item) {
                    final double owed = (item['committed'] as num?)?.toDouble() ?? 0.0;
                    final List<dynamic> linkedPhones = item['phones'] ?? [];
                    
                    // Format phone display string identically to ContributorsScreen
                    final String phoneDisplay = linkedPhones.isNotEmpty ? linkedPhones.join(', ') : "No Phone";

                    return ListTile(
                      leading: const Icon(Icons.dangerous, color: Colors.red, size: 22),
                      title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(
                        "Deficit: \Rs ${owed.toStringAsFixed(2)}\nPhones: $phoneDisplay", 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.wechat, color: Colors.green, size: 28),
                        tooltip: "Dispatch WhatsApp follow-up reminder",
                        onPressed: () => _sendWhatsAppReminder(
                          name: item['name'],
                          pendingAmount: owed,
                          phones: linkedPhones,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              
        const SizedBox(height: 24),
        
        // --- Settled Verified Section View ---
        const Text("Settled Register List (Paid Contributors)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        paidDetails.isEmpty
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text("No clear verified payment receipts found inside this partition slice.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
              )
            : Container(
                decoration: BoxDecoration(
                  color: Colors.green.shade50.withOpacity(0.3),
                  border: Border.all(color: Colors.green.shade100), 
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: paidDetails.map<Widget>((item) {
                    final double paidValue = (item['paid'] as num?)?.toDouble() ?? 0.0;
                    return ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green, size: 22),
                      title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.w500)),
                      trailing: Text("Paid: \Rs ${paidValue.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    );
                  }).toList(),
                ),
              ),
      ],
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Card(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}