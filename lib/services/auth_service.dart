//qudas\lib\services\auth_service.dart
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {

  final supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> login(
      String username,
      String password,
      ) async {

    final passwordHash = md5.convert(
      utf8.encode(password),
    ).toString();

    final response = await supabase
        .from('app_users')
        .select('''
          id,
          username,
          role,
          module_access(
            module_name,
            is_allowed
          )
        ''')
        .eq('username', username)
        .eq('password_hash', passwordHash)
        .maybeSingle();

    return response;
  }

  Future<void> changePassword(
      int userId,
      String newPassword,
      ) async {

    final passwordHash = md5.convert(
      utf8.encode(newPassword),
    ).toString();

    await supabase
        .from('app_users')
        .update({
      'password_hash': passwordHash,
    })
        .eq('id', userId);
  }
}