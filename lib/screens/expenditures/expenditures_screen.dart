//qudas\lib\screens\expenditures\expenditures_screen.dart
// qudas/lib/screens/expenditures/expenditures_screen.dart
import 'package:flutter/material.dart';

class ExpendituresScreen extends StatelessWidget {
  const ExpendituresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Expenditures",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Text(
              "Expenditures list and forms will go here.",
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}