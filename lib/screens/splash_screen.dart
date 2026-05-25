//qudas\lib\screens\splash_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/session_service.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  String status = "Connecting to Supabase...";

  @override
  void initState() {
    super.initState();

    initialize();
  }

  Future<void> initialize() async {

    try {

      await Supabase.instance.client
          .from('app_users')
          .select()
          .limit(1);

      final savedUser = await SessionService.getUser();

      if (savedUser != null) {

        final user = await Supabase.instance.client
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
            .eq('username', savedUser)
            .single();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => DashboardScreen(user: user),
          ),
        );

      } else {

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const LoginScreen(),
          ),
        );
      }

    } catch (e) {

      setState(() {
        status = "Connection Failed";
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(
        child: Text(
          status,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}