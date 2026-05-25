//qudas\lib\services\user_service.dart
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {

  final supabase = Supabase.instance.client;

  Future<void> createUser({
    required String username,
    required String password,
    required List<String> modules,
  }) async {

    final passwordHash = md5.convert(
      utf8.encode(password),
    ).toString();

    final user = await supabase
        .from('app_users')
        .insert({
      'username': username,
      'password_hash': passwordHash,
      'role': 'user',
    })
        .select()
        .single();

    final userId = user['id'];

    final moduleData = modules.map((module) {

      return {
        'user_id': userId,
        'module_name': module,
        'is_allowed': true,
      };

    }).toList();

    await supabase
        .from('module_access')
        .insert(moduleData);
  }
}