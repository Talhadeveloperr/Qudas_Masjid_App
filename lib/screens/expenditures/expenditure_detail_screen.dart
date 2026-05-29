// lib/screens/expenditures/expenditure_detail_screen.dart
import 'package:flutter/material.dart';
import '../../models/expenditure_model.dart';

class ExpenditureDetailScreen extends StatelessWidget {
  final Expenditure expenditure;

  const ExpenditureDetailScreen({super.key, required this.expenditure});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Expenditure Details")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Expenditure ID: #${expenditure.id}", style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(20)),
                              child: const Text("SUCCESS", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                            )
                          ],
                        ),
                        const Divider(height: 32),
                        const Text("Title", style: TextStyle(color: Colors.grey, fontSize: 14)),
                        Text(
                          expenditure.title,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        const Text("Payment Amount", style: TextStyle(color: Colors.grey, fontSize: 14)),
                        Text(
                          "\Rs ${expenditure.paymentAmount.toStringAsFixed(2)}",
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                        ),
                        const SizedBox(height: 20),
                        const Text("Paid To", style: TextStyle(color: Colors.grey, fontSize: 14)),
                        Text(
                          expenditure.paidTo?.isNotEmpty == true ? expenditure.paidTo! : "N/A",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Date", style: TextStyle(color: Colors.grey)),
                                  Text(expenditure.expenditureDate, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Time", style: TextStyle(color: Colors.grey)),
                                  Text(expenditure.expenditureTime, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text("Details", style: TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          expenditure.details?.isNotEmpty == true ? expenditure.details! : "No details provided.",
                          style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                        ),
                        const SizedBox(height: 20),
                        const Text("Remarks", style: TextStyle(color: Colors.grey, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          expenditure.remarks?.isNotEmpty == true ? expenditure.remarks! : "No remarks provided.",
                          style: const TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
