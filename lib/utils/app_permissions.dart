//qudas\lib\utils\app_permissions.dart
// qudas/lib/utils/app_permissions.dart
class AppPermissions {
  static const String budget = "budget";
  static const String contributions = "contributions";
  
  // --- Granular Contribution Permissions ---
  static const String addContributions = "add_contributions";
  static const String editContributions = "edit_contributions";
  static const String deleteContributions = "delete_contributions";

  static const String expenditures = "expenditures";

  // --- Granular Contribution Permissions ---
  static const String addExpenditures = "add_expenditures";
  static const String editExpenditures = "edit_expenditures";
  static const String deleteExpenditures = "delete_expenditures";

  static const String financeAnalytics = "finance_analytics";
  static const String users = "users";
  static const String bills = "bills";
  static const String contributors = "contributors";
  static const String appAnalytics = "app_analytics";
  static const String userActivity = "user_activity";

  // List of all permissions to display in the assignment dialog
  static const List<String> allPermissions = [
    budget,
    contributions,
    addContributions,
    editContributions,
    deleteContributions,
    expenditures,
    financeAnalytics,
    users,
    bills,
    contributors,
    appAnalytics,
    userActivity,
  ];
}