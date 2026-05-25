//qudas\lib\screens\contributions\contribution_detail_screen.dart
// qudas/lib/screens/contributions/contribution_detail_screen.dart
import 'package:flutter/material.dart';
import '../../models/contribution_model.dart';

class ContributionDetailScreen extends StatelessWidget {
  final Contribution contribution;

  const ContributionDetailScreen({super.key, required this.contribution});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transaction Details")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Transaction ID: #${contribution.id}", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                      child: const Text("SUCCESS", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                  ],
                ),
                const Divider(height: 32),
                const Text("Contributor", style: TextStyle(color: Colors.grey, fontSize: 14)),
                Text(
                  contribution.contributorName?.isNotEmpty == true ? contribution.contributorName! : "Anonymous Contributor",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                const Text("Amount Contributed", style: TextStyle(color: Colors.grey, fontSize: 14)),
                Text(
                  "\Rs ${contribution.amount.toStringAsFixed(2)}",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Date Logged", style: TextStyle(color: Colors.grey)),
                          Text(contribution.contributionDate, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Time Logged", style: TextStyle(color: Colors.grey)),
                          Text(contribution.contributionTime, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Remarks / Audit Notes", style: TextStyle(color: Colors.grey, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  contribution.remarks?.isNotEmpty == true ? contribution.remarks! : "No remarks provided for this transaction.",
                  style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}