//qudas\lib\models\app_user.dart
class AppUser {

  final int id;
  final String username;
  final String role;
  final List modules;

  AppUser({
    required this.id,
    required this.username,
    required this.role,
    required this.modules,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {

    return AppUser(
      id: json['id'],
      username: json['username'],
      role: json['role'],
      modules: json['module_access'] ?? [],
    );
  }
}