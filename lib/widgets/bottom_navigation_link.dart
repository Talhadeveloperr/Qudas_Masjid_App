//qudas\lib\widgets\bottom_navigation_link.dart
// qudas/lib/widgets/bottom_navigation_link.dart
import 'package:flutter/material.dart';

// Define the static list of Bottom Navigation Items here
const List<BottomNavigationBarItem> bottomNavigationItems = [
  BottomNavigationBarItem(
    icon: Icon(Icons.home),
    label: 'Home',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.volunteer_activism),
    label: 'Contributions',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.account_balance_wallet),
    label: 'Expenditures',
  ),
  BottomNavigationBarItem(
    icon: Icon(Icons.account_balance_wallet),
    label: 'Contributors',
  ),
];